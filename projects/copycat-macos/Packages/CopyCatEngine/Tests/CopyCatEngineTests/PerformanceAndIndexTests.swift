import Foundation
import Testing
@testable import CopyCatEngine

@Suite("Performance mode")
struct PerformanceModeTests {
    @Test("Default scan configuration is balanced")
    func defaultIsBalanced() {
        let config = ScanConfiguration(rootURLs: [])
        #expect(config.performanceMode == .balanced)
    }
}

@Suite("Size collision index")
struct SizeCollisionIndexTests {
    @Test("Unique-size files do not enter collision candidates")
    func uniqueSizesStayOut() {
        var index = SizeCollisionIndex()
        index.insert(candidate(size: 10, name: "a"))
        index.insert(candidate(size: 20, name: "b"))
        index.insert(candidate(size: 30, name: "c"))
        #expect(index.collisionCandidates().isEmpty)
        #expect(index.pendingCount == 3)
        #expect(index.collisionFileCount == 0)
    }

    @Test("Second same-size file promotes pending into collision bucket")
    func secondPromotes() {
        var index = SizeCollisionIndex()
        index.insert(candidate(size: 42, name: "first"))
        #expect(index.pendingCount == 1)
        index.insert(candidate(size: 42, name: "second"))
        #expect(index.pendingCount == 0)
        #expect(index.collisionBucketCount == 1)
        #expect(index.collisionFileCount == 2)
        let names = Set(index.collisionCandidates().map(\.filename))
        #expect(names == ["first", "second"])
    }

    @Test("Three or more same-size files stay in one bucket")
    func threeInOneBucket() {
        var index = SizeCollisionIndex()
        index.insert(candidate(size: 7, name: "a"))
        index.insert(candidate(size: 7, name: "b"))
        index.insert(candidate(size: 7, name: "c"))
        #expect(index.collisionBuckets().count == 1)
        #expect(index.collisionBuckets()[0].count == 3)
        #expect(index.collisionFileCount == 3)
    }

    @Test("Discard pending singles leaves only collisions")
    func discardPending() {
        var index = SizeCollisionIndex()
        index.insert(candidate(size: 1, name: "solo"))
        index.insert(candidate(size: 9, name: "d1"))
        index.insert(candidate(size: 9, name: "d2"))
        index.discardPendingSingles()
        #expect(index.pendingCount == 0)
        #expect(index.collisionCandidates().map(\.filename).sorted() == ["d1", "d2"])
    }

    @Test("Many unique sizes produce empty collision output")
    func manyUniqueEmptyCandidates() {
        var index = SizeCollisionIndex()
        for i in 0..<5_000 {
            index.insert(candidate(size: UInt64(i + 1), name: "u\(i)"))
        }
        #expect(index.collisionCandidates().isEmpty)
        #expect(index.pendingCount == 5_000)
        index.discardPendingSingles()
        #expect(index.collisionCandidates().isEmpty)
        #expect(index.pendingCount == 0)
    }

    @Test("removeAll clears retained metadata")
    func removeAllClears() {
        var index = SizeCollisionIndex()
        index.insert(candidate(size: 3, name: "a"))
        index.insert(candidate(size: 3, name: "b"))
        index.removeAll()
        #expect(index.filesDiscovered == 0)
        #expect(index.collisionFileCount == 0)
        #expect(index.collisionCandidates().isEmpty)
    }
}

@Suite("Telemetry")
struct TelemetryTests {
    @Test("Files/sec rolling calculation")
    func filesPerSecondRolling() {
        var meter = FilesPerSecondMeter(window: .seconds(2))
        let t0 = ContinuousClock.now
        meter.record(filesDiscovered: 0, at: t0)
        meter.record(filesDiscovered: 200, at: t0.advanced(by: .seconds(1)))
        let rate = meter.rate(at: t0.advanced(by: .seconds(1)))
        #expect(rate != nil)
        #expect(abs((rate ?? 0) - 200) < 1)
    }

    @Test("Telemetry is rate limited")
    func rateLimited() {
        var telemetry = PerformanceTelemetry(interval: .milliseconds(200))
        let t0 = ContinuousClock.now
        let first = telemetry.sampleIfNeeded(
            mode: .balanced,
            phase: .enumerating,
            filesDiscovered: 10,
            filesProcessed: 10,
            bytesScanned: 100,
            duplicateGroupsFound: 0,
            force: false,
            now: t0
        )
        let second = telemetry.sampleIfNeeded(
            mode: .balanced,
            phase: .enumerating,
            filesDiscovered: 20,
            filesProcessed: 20,
            bytesScanned: 200,
            duplicateGroupsFound: 0,
            force: false,
            now: t0.advanced(by: .milliseconds(50))
        )
        let third = telemetry.sampleIfNeeded(
            mode: .balanced,
            phase: .enumerating,
            filesDiscovered: 30,
            filesProcessed: 30,
            bytesScanned: 300,
            duplicateGroupsFound: 0,
            force: false,
            now: t0.advanced(by: .milliseconds(250))
        )
        #expect(first != nil)
        #expect(second == nil)
        #expect(third != nil)
    }

    @Test("Forced sample always returns")
    func forcedSample() {
        var telemetry = PerformanceTelemetry(interval: .seconds(10))
        let a = telemetry.sampleIfNeeded(
            mode: .balanced,
            phase: .hashing,
            filesDiscovered: 1,
            filesProcessed: 1,
            bytesScanned: 1,
            duplicateGroupsFound: 0,
            force: true
        )
        let b = telemetry.sampleIfNeeded(
            mode: .balanced,
            phase: .hashing,
            filesDiscovered: 2,
            filesProcessed: 2,
            bytesScanned: 2,
            duplicateGroupsFound: 0,
            force: true
        )
        #expect(a != nil)
        #expect(b != nil)
    }

    @Test("Memory sampler failure path does not throw")
    func memorySamplerSafe() {
        _ = ProcessMemorySampler.residentByteCount()
    }

    @Test("Balanced mode is single-reader with mid-size buffer")
    func balancedIOPolicy() {
        #expect(PerformanceMode.balanced.maxConcurrentHashReaders == 1)
        #expect(PerformanceMode.balanced.hashReadBufferBytes >= 256 * 1024)
        #expect(PerformanceMode.balanced.hashReadBufferBytes <= 1024 * 1024)
        #expect(PerformanceMode.balanced.preferredHashChunkBytes == 512 * 1024)
        #expect(PerformanceMode.balanced.hashYieldEveryFiles > 0)
    }

    @Test("Adaptive hash chunk sizes follow Balanced policy")
    func adaptiveChunks() {
        let cap = ReusableHashReader.maximumBufferBytes
        #expect(ReusableHashReader.preferredChunkBytes(fileSize: 8_000, capacity: cap) == 8_000)
        #expect(ReusableHashReader.preferredChunkBytes(fileSize: 500_000, capacity: cap) == 512 * 1024)
        #expect(ReusableHashReader.preferredChunkBytes(fileSize: 20_000_000, capacity: cap) == 1024 * 1024)
    }

    @Test("Telemetry reports bytes/sec and read ops when provided")
    func bytesAndReadOps() {
        var telemetry = PerformanceTelemetry(interval: .milliseconds(1))
        let t0 = ContinuousClock.now
        _ = telemetry.sampleIfNeeded(
            mode: .balanced,
            phase: .hashing,
            filesDiscovered: 10,
            filesProcessed: 10,
            bytesScanned: 1_000_000,
            duplicateGroupsFound: 0,
            readOperations: 20,
            force: true,
            now: t0
        )
        let second = telemetry.sampleIfNeeded(
            mode: .balanced,
            phase: .hashing,
            filesDiscovered: 20,
            filesProcessed: 20,
            bytesScanned: 5_000_000,
            duplicateGroupsFound: 1,
            readOperations: 80,
            force: true,
            now: t0.advanced(by: .milliseconds(500))
        )
        #expect(second?.bytesPerSecond != nil)
        #expect(second?.readOperations == 80)
        #expect(second?.readOperationsPerSecond != nil)
        #expect(second?.averageQueueDepth == nil)
    }
}

@Suite("Balanced disk I/O")
struct BalancedDiskIOTests {
    @Test("Reusable reader hashes match across partial and full")
    func reusableReaderMatches() throws {
        try withTempDirectory { root in
            let url = root.appendingPathComponent("payload.bin")
            let data = Data((0..<200_000).map { UInt8($0 % 251) })
            try data.write(to: url)

            let reader = ReusableHashReader(capacity: 256 * 1024)
            let partialA = try reader.partialSHA256(of: url)
            let fullA = try reader.fullSHA256(of: url)
            #expect(reader.readOperations > 0)
            #expect(reader.bytesRead > 0)

            let partial = PartialHasher()
            let full = FullHasher()
            #expect(try partial.hash(fileAt: url) == partialA)
            #expect(try full.hash(fileAt: url) == fullA)
        }
    }

    @Test("Detector sorts same-size files into stable path order")
    func stableOrder() {
        let files = [
            ScannedFile(url: URL(fileURLWithPath: "/z/b.txt"), filename: "b.txt", extension: "txt", size: 1, createdDate: nil, modifiedDate: nil),
            ScannedFile(url: URL(fileURLWithPath: "/a/a.txt"), filename: "a.txt", extension: "txt", size: 1, createdDate: nil, modifiedDate: nil),
            ScannedFile(url: URL(fileURLWithPath: "/m/c.txt"), filename: "c.txt", extension: "txt", size: 1, createdDate: nil, modifiedDate: nil),
        ]
        let ordered = ExactDuplicateDetector.stableDiskOrder(files).map(\.url.path)
        #expect(ordered == ["/a/a.txt", "/m/c.txt", "/z/b.txt"])
    }

    @Test("Same-folder files stay clustered before other directories")
    func directoryClusterOrder() {
        let files = [
            ScannedFile(url: URL(fileURLWithPath: "/photos/z.jpg"), filename: "z.jpg", extension: "jpg", size: 9, createdDate: nil, modifiedDate: nil),
            ScannedFile(url: URL(fileURLWithPath: "/docs/a.txt"), filename: "a.txt", extension: "txt", size: 9, createdDate: nil, modifiedDate: nil),
            ScannedFile(url: URL(fileURLWithPath: "/photos/a.jpg"), filename: "a.jpg", extension: "jpg", size: 9, createdDate: nil, modifiedDate: nil),
        ]
        let ordered = ExactDuplicateDetector.stableDiskOrder(files).map(\.url.path)
        #expect(ordered == ["/docs/a.txt", "/photos/a.jpg", "/photos/z.jpg"])
    }
}

@Suite("Legacy size collision index helpers")
struct StreamingScanTests {
    @Test("Only collision candidates are hashed; exact duplicates still found")
    func streamingExactDuplicates() async throws {
        try await withTempDirectoryAsync { root in
            let dup = Data("shared-content-payload".utf8)
            try dup.write(to: root.appendingPathComponent("a.txt"))
            try dup.write(to: root.appendingPathComponent("b.txt"))
            try Data("unique-1".utf8).write(to: root.appendingPathComponent("u1.txt"))
            try Data("unique-22".utf8).write(to: root.appendingPathComponent("u2.txt"))

            var index = SizeCollisionIndex()
            let files = try collectFiles(root: root)
            for file in files {
                index.insert(FileCandidate(file))
            }
            let candidates = index.collisionCandidates()
            #expect(candidates.count == 2)
            #expect(Set(candidates.map(\.filename)) == ["a.txt", "b.txt"])

            let groups = try ExactDuplicateDetector().detect(files: candidates.map { $0.asScannedFile() })
            #expect(groups.count == 1)
            #expect(groups[0].files.count == 2)
        }
    }

    @Test("Same-size different content excluded after hashing")
    func sameSizeDifferentContentStreaming() throws {
        var index = SizeCollisionIndex()
        try withTempDirectory { root in
            try Data("AAAAAAAA".utf8).write(to: root.appendingPathComponent("x.txt"))
            try Data("BBBBBBBB".utf8).write(to: root.appendingPathComponent("y.txt"))
            for file in try collectFiles(root: root) {
                index.insert(FileCandidate(file))
            }
            #expect(index.collisionCandidates().count == 2)
            let groups = try ExactDuplicateDetector().detect(
                files: index.collisionCandidates().map { $0.asScannedFile() }
            )
            #expect(groups.isEmpty)
        }
    }
}

// MARK: - Helpers

private func candidate(size: UInt64, name: String) -> FileCandidate {
    FileCandidate(
        url: URL(fileURLWithPath: "/tmp/\(name)"),
        filename: name,
        extension: "txt",
        size: size,
        createdDate: nil,
        modifiedDate: nil
    )
}

private func withTempDirectory(_ body: (URL) throws -> Void) throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent("CopyCatEngineTests-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: root) }
    try body(root)
}

private func withTempDirectoryAsync(_ body: (URL) async throws -> Void) async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent("CopyCatEngineTests-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: root) }
    try await body(root)
}

private func collectFiles(root: URL) throws -> [ScannedFile] {
    let enumerator = FileEnumerator()
    let reader = MetadataReader()
    let config = ScanConfiguration(rootURLs: [root])
    var files: [ScannedFile] = []
    try enumerator.enumerate(configuration: config) { url in
        files.append(try reader.read(url: url))
    }
    return files
}
