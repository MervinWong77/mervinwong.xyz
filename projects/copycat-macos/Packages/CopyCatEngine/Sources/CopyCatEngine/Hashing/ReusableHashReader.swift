import CryptoKit
import Darwin
import Foundation

/// Reusable sequential file reader for Balanced-mode hashing.
///
/// Owns one buffer (up to 1 MB) shared across partial and full hashes.
/// Chunk size adapts per file; contents are never retained after hashing.
public final class ReusableHashReader: @unchecked Sendable {
    public static let minimumBufferBytes = 256 * 1024
    public static let balancedBufferBytes = 512 * 1024
    public static let maximumBufferBytes = 1024 * 1024

    /// Allocated buffer capacity (≤ 1 MB).
    public let capacity: Int
    public let partialByteCount: Int

    public private(set) var bytesRead: UInt64 = 0
    public private(set) var readOperations: UInt64 = 0
    public private(set) var filesOpened: UInt64 = 0
    public private(set) var diskWaitNanoseconds: UInt64 = 0
    public private(set) var hashWallNanoseconds: UInt64 = 0
    public private(set) var hashOperations: UInt64 = 0
    public private(set) var fullHashNanoseconds: UInt64 = 0
    public private(set) var fullHashOperations: UInt64 = 0
    /// Last adaptive full-hash chunk size chosen.
    public private(set) var lastFullHashChunkBytes: Int

    private let buffer: UnsafeMutableRawPointer

    public init(
        capacity: Int = ReusableHashReader.balancedBufferBytes,
        partialByteCount: Int = PartialHasher.defaultByteCount
    ) {
        let capped = min(max(capacity, Self.minimumBufferBytes), Self.maximumBufferBytes)
        self.capacity = capped
        self.partialByteCount = max(1, partialByteCount)
        self.lastFullHashChunkBytes = min(Self.balancedBufferBytes, capped)
        self.buffer = UnsafeMutableRawPointer.allocate(byteCount: capped, alignment: 64)
        self.buffer.initializeMemory(as: UInt8.self, repeating: 0, count: capped)
    }

    deinit {
        buffer.deallocate()
    }

    public func resetCounters() {
        bytesRead = 0
        readOperations = 0
        filesOpened = 0
        diskWaitNanoseconds = 0
        hashWallNanoseconds = 0
        hashOperations = 0
        fullHashNanoseconds = 0
        fullHashOperations = 0
    }

    public var averageHashLatencyMilliseconds: Double? {
        guard hashOperations > 0 else { return nil }
        return Double(hashWallNanoseconds) / Double(hashOperations) / 1_000_000
    }

    public var averageFullHashLatencyMilliseconds: Double? {
        guard fullHashOperations > 0 else { return nil }
        return Double(fullHashNanoseconds) / Double(fullHashOperations) / 1_000_000
    }

    public var diskWaitSeconds: Double {
        Double(diskWaitNanoseconds) / 1_000_000_000
    }

    public var averageBytesPerFile: Double? {
        guard filesOpened > 0 else { return nil }
        return Double(bytesRead) / Double(filesOpened)
    }

    /// Balanced chunk policy: small files one-shot; normal 512 KB; large up to 1 MB.
    public static func preferredChunkBytes(fileSize: UInt64, capacity: Int) -> Int {
        if fileSize == 0 { return min(Self.balancedBufferBytes, capacity) }
        if fileSize <= 64 * 1024 {
            return min(Int(fileSize), capacity)
        }
        if fileSize <= 4 * 1024 * 1024 {
            return min(Self.balancedBufferBytes, capacity)
        }
        return min(Self.maximumBufferBytes, capacity)
    }

    public func partialSHA256(of url: URL) throws -> String {
        let wallStart = DispatchTime.now().uptimeNanoseconds
        defer {
            hashWallNanoseconds += DispatchTime.now().uptimeNanoseconds &- wallStart
            hashOperations += 1
        }
        return try withOpenFile(url) { fd in
            var hasher = SHA256()
            var remaining = partialByteCount
            while remaining > 0 {
                try Task.checkCancellation()
                let want = min(remaining, capacity)
                let n = readIntoBuffer(fd: fd, count: want)
                if n == 0 { break }
                hasher.update(bufferPointer: UnsafeRawBufferPointer(start: buffer, count: n))
                remaining -= n
                if n < want { break }
            }
            return Self.hex(hasher.finalize())
        }
    }

    public func fullSHA256(of url: URL, fileSize: UInt64? = nil) throws -> String {
        let wallStart = DispatchTime.now().uptimeNanoseconds
        defer {
            let elapsed = DispatchTime.now().uptimeNanoseconds &- wallStart
            hashWallNanoseconds += elapsed
            hashOperations += 1
            fullHashNanoseconds += elapsed
            fullHashOperations += 1
        }

        let size = try fileSize ?? ((try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? NSNumber)?.uint64Value)
        let chunk = Self.preferredChunkBytes(fileSize: size ?? UInt64(capacity), capacity: capacity)
        lastFullHashChunkBytes = chunk

        return try withOpenFile(url) { fd in
            var hasher = SHA256()
            while true {
                try Task.checkCancellation()
                let n = readIntoBuffer(fd: fd, count: chunk)
                if n == 0 { break }
                hasher.update(bufferPointer: UnsafeRawBufferPointer(start: buffer, count: n))
            }
            return Self.hex(hasher.finalize())
        }
    }

    private func withOpenFile<T>(_ url: URL, _ body: (Int32) throws -> T) throws -> T {
        let path = url.path
        let fd = path.withCString { open($0, O_RDONLY) }
        guard fd >= 0 else {
            throw NSError(
                domain: NSPOSIXErrorDomain,
                code: Int(errno),
                userInfo: [NSFilePathErrorKey: path]
            )
        }
        filesOpened += 1
        defer { close(fd) }
        _ = fcntl(fd, F_RDAHEAD, 1)
        return try body(fd)
    }

    private func readIntoBuffer(fd: Int32, count: Int) -> Int {
        let start = DispatchTime.now().uptimeNanoseconds
        let n = read(fd, buffer, count)
        diskWaitNanoseconds += DispatchTime.now().uptimeNanoseconds &- start
        if n > 0 {
            readOperations += 1
            bytesRead += UInt64(n)
            return n
        }
        return 0
    }

    private static func hex(_ digest: SHA256.Digest) -> String {
        digest.map { String(format: "%02x", $0) }.joined()
    }
}
