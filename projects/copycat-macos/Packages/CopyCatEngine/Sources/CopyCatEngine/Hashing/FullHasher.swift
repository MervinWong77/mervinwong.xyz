import Foundation

/// Full-file SHA-256 using a reusable read buffer to keep memory and allocator pressure bounded.
public struct FullHasher: Sendable {
    public static let defaultChunkSize = ReusableHashReader.balancedBufferBytes

    public let chunkSize: Int
    private let reader: ReusableHashReader

    public init(
        chunkSize: Int = FullHasher.defaultChunkSize,
        reader: ReusableHashReader? = nil
    ) {
        self.chunkSize = chunkSize
        self.reader = reader ?? ReusableHashReader(capacity: chunkSize)
    }

    public func hash(fileAt url: URL, fileSize: UInt64? = nil) throws -> String {
        try reader.fullSHA256(of: url, fileSize: fileSize)
    }
}
