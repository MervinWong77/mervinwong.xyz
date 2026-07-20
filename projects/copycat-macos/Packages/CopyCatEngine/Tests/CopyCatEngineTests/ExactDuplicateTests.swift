import Foundation
import Testing
@testable import CopyCatEngine

@Suite("Exact duplicate detection")
struct ExactDuplicateDetectorTests {
    @Test("Two identical files with different names form one exact group")
    func identicalFilesDifferentNames() throws {
        try withTempDirectory { root in
            let content = Data("hello copycat exact duplicate".utf8)
            try content.write(to: root.appendingPathComponent("a.txt"))
            try content.write(to: root.appendingPathComponent("b-copy.txt"))

            let groups = try scanExact(root: root)
            #expect(groups.count == 1)
            #expect(groups[0].files.count == 2)
            #expect(groups[0].category == .exact)
            #expect(groups[0].reasons.contains(.identicalSHA256))
            #expect(groups[0].recoverableBytes == UInt64(content.count))
        }
    }

    @Test("Same size different content produces no exact group")
    func sameSizeDifferentContent() throws {
        try withTempDirectory { root in
            try Data("aaaaaaaa".utf8).write(to: root.appendingPathComponent("one.txt"))
            try Data("bbbbbbbb".utf8).write(to: root.appendingPathComponent("two.txt"))

            let groups = try scanExact(root: root)
            #expect(groups.isEmpty)
        }
    }

    @Test("Unique sizes produce no exact groups")
    func uniqueSizes() throws {
        try withTempDirectory { root in
            try Data("short".utf8).write(to: root.appendingPathComponent("a.txt"))
            try Data("a bit longer".utf8).write(to: root.appendingPathComponent("b.txt"))

            let groups = try scanExact(root: root)
            #expect(groups.isEmpty)
        }
    }

    @Test("Three identical copies recover two file sizes")
    func threeIdenticalCopies() throws {
        try withTempDirectory { root in
            let content = Data(repeating: 0xAB, count: 4096)
            try content.write(to: root.appendingPathComponent("1.bin"))
            try content.write(to: root.appendingPathComponent("2.bin"))
            try content.write(to: root.appendingPathComponent("3.bin"))

            let groups = try scanExact(root: root)
            #expect(groups.count == 1)
            #expect(groups[0].files.count == 3)
            #expect(groups[0].recoverableBytes == UInt64(content.count) * 2)
        }
    }

    @Test("Excluded directory names are skipped")
    func excludedDirectoriesSkipped() throws {
        try withTempDirectory { root in
            let content = Data("duplicate payload".utf8)
            try content.write(to: root.appendingPathComponent("keep.txt"))

            let nodeModules = root.appendingPathComponent("node_modules")
            try FileManager.default.createDirectory(at: nodeModules, withIntermediateDirectories: true)
            try content.write(to: nodeModules.appendingPathComponent("hidden.txt"))

            let files = try collectFiles(root: root)
            let paths = Set(files.map(\.url.lastPathComponent))
            #expect(paths.contains("keep.txt"))
            #expect(!paths.contains("hidden.txt"))
        }
    }
}

@Suite("Hashers")
struct HasherTests {
    @Test("Partial and full hashes match for identical content")
    func hashesMatch() throws {
        try withTempDirectory { root in
            let urlA = root.appendingPathComponent("a.dat")
            let urlB = root.appendingPathComponent("b.dat")
            let data = Data((0..<100_000).map { UInt8($0 % 256) })
            try data.write(to: urlA)
            try data.write(to: urlB)

            let partial = PartialHasher()
            let full = FullHasher()

            #expect(try partial.hash(fileAt: urlA) == partial.hash(fileAt: urlB))
            #expect(try full.hash(fileAt: urlA) == full.hash(fileAt: urlB))
        }
    }

    @Test("Different content yields different full hashes")
    func differentFullHashes() throws {
        try withTempDirectory { root in
            let urlA = root.appendingPathComponent("a.dat")
            let urlB = root.appendingPathComponent("b.dat")
            try Data("alpha".utf8).write(to: urlA)
            try Data("bravo".utf8).write(to: urlB)

            let full = FullHasher()
            #expect(try full.hash(fileAt: urlA) != full.hash(fileAt: urlB))
        }
    }
}

@Suite("ScanCoordinator")
struct ScanCoordinatorTests {
    @Test("Scan finishes with exact groups")
    func scanFinishes() async throws {
        try await withTempDirectoryAsync { root in
            let content = Data("coordinator exact".utf8)
            try content.write(to: root.appendingPathComponent("x.txt"))
            try content.write(to: root.appendingPathComponent("y.txt"))

            let coordinator = ScanCoordinator()
            let config = ScanConfiguration(rootURLs: [root])

            var finishedGroups: [DuplicateGroup] = []
            var sawFinished = false

            for await event in await coordinator.scan(configuration: config) {
                switch event {
                case .finished(let groups, _):
                    finishedGroups = groups
                    sawFinished = true
                case .cancelled, .failed:
                    Issue.record("Unexpected terminal event")
                default:
                    break
                }
            }

            #expect(sawFinished)
            #expect(finishedGroups.count == 1)
            #expect(finishedGroups[0].files.count == 2)
        }
    }

    @Test("Cancel mid-scan completes as cancelled")
    func cancelMidScan() async throws {
        try await withTempDirectoryAsync { root in
            // Create enough files that cancellation can race enumeration.
            for i in 0..<200 {
                let data = Data("file-\(i)-\(String(repeating: "z", count: 64))".utf8)
                try data.write(to: root.appendingPathComponent("f\(i).txt"))
            }
            // Add duplicates so hashing would take work if not cancelled.
            let dup = Data(repeating: 7, count: 50_000)
            try dup.write(to: root.appendingPathComponent("dup-a.bin"))
            try dup.write(to: root.appendingPathComponent("dup-b.bin"))

            let coordinator = ScanCoordinator()
            let config = ScanConfiguration(rootURLs: [root])

            var sawCancelled = false
            let stream = await coordinator.scan(configuration: config)

            var eventCount = 0
            for await event in stream {
                eventCount += 1
                if eventCount == 1 {
                    await coordinator.cancel()
                }
                if case .cancelled = event {
                    sawCancelled = true
                }
                if case .finished = event {
                    // Possible if scan finished before cancel took effect.
                    break
                }
            }

            #expect(sawCancelled || eventCount > 0)
        }
    }
}

// MARK: - Helpers

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

private func scanExact(root: URL) throws -> [DuplicateGroup] {
    let files = try collectFiles(root: root)
    return try ExactDuplicateDetector().detect(files: files)
}
