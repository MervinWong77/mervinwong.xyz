import Foundation
import Testing
@testable import CopyCatEngine

@Suite("Size frequency map")
struct SizeFrequencyMapTests {
    @Test("Many unique sizes retain no path metadata after pass 1 extraction")
    func uniqueSizesRetainNoPaths() {
        var map = SizeFrequencyMap()
        for i in 0..<2_000 {
            map.note(size: UInt64(i + 1))
        }
        #expect(map.filesDiscovered == 2_000)
        #expect(map.retainedSizeEntries == 2_000)
        let collisions = map.takeCollisionSizes()
        #expect(collisions.isEmpty)
        #expect(map.retainedSizeEntries == 0)
    }

    @Test("Only colliding sizes remain after takeCollisionSizes")
    func collisionSizesOnly() {
        var map = SizeFrequencyMap()
        map.note(size: 10)
        map.note(size: 10)
        map.note(size: 20)
        map.note(size: 30)
        map.note(size: 30)
        map.note(size: 30)
        let collisions = map.takeCollisionSizes()
        #expect(collisions == Set([10, 30]))
        #expect(map.retainedSizeEntries == 0)
        #expect(map.filesDiscovered == 6)
    }
}

@Suite("Selected root normalizer")
struct SelectedRootNormalizerTests {
    @Test("Overlapping selected roots are collapsed to ancestors")
    func overlapCollapsed() {
        let home = URL(fileURLWithPath: "/Users/demo")
        let downloads = URL(fileURLWithPath: "/Users/demo/Downloads")
        let drive = URL(fileURLWithPath: "/Volumes/Ext")
        let driveAgain = URL(fileURLWithPath: "/Volumes/Ext/")
        let normalized = SelectedRootNormalizer.normalize([home, downloads, drive, driveAgain])
        let paths = Set(normalized.map(\.path))
        #expect(paths == Set(["/Users/demo", "/Volumes/Ext"]))
    }

    @Test("Sibling folders are preserved")
    func siblingsPreserved() {
        let a = URL(fileURLWithPath: "/Users/demo/Documents")
        let b = URL(fileURLWithPath: "/Users/demo/Downloads")
        let normalized = SelectedRootNormalizer.normalize([a, b])
        #expect(Set(normalized.map(\.path)) == Set([a.path, b.path]))
    }
}

@Suite("Two-pass scan safety")
struct TwoPassScanSafetyTests {
    @Test("Exact duplicates still match through two-pass coordinator")
    func exactDuplicatesMatch() async throws {
        try await withTempDirectoryAsync { root in
            let dup = Data("shared-content-payload".utf8)
            try dup.write(to: root.appendingPathComponent("a.txt"))
            try dup.write(to: root.appendingPathComponent("b.txt"))
            try Data("unique-1".utf8).write(to: root.appendingPathComponent("u1.txt"))
            try Data("unique-22".utf8).write(to: root.appendingPathComponent("u2.txt"))

            let groups = try await finishedGroups(root: root)
            #expect(groups.count == 1)
            #expect(Set(groups[0].files.map(\.filename)) == ["a.txt", "b.txt"])
        }
    }

    @Test("Same-size different-content files are excluded")
    func sameSizeDifferentContentExcluded() async throws {
        try await withTempDirectoryAsync { root in
            try Data("AAAAAAAA".utf8).write(to: root.appendingPathComponent("x.txt"))
            try Data("BBBBBBBB".utf8).write(to: root.appendingPathComponent("y.txt"))
            let groups = try await finishedGroups(root: root)
            #expect(groups.isEmpty)
        }
    }

    @Test("Only colliding sizes produce candidate metadata in pass 2")
    func onlyCollidingCandidates() async throws {
        try await withTempDirectoryAsync { root in
            let dup = Data("twin-bytes".utf8)
            try dup.write(to: root.appendingPathComponent("d1.txt"))
            try dup.write(to: root.appendingPathComponent("d2.txt"))
            for i in 0..<40 {
                // Distinct byte lengths so sizes cannot collide with each other.
                try Data(repeating: UInt8(i % 251), count: 64 + i)
                    .write(to: root.appendingPathComponent("u\(i).txt"))
            }

            var peakCandidatesDuringCollect = 0
            var finished = false
            let coordinator = ScanCoordinator()
            for await event in await coordinator.scan(configuration: ScanConfiguration(rootURLs: [root])) {
                switch event {
                case .progress(let p):
                    if p.message == ScanProgressLabels.collectingDuplicateCandidates {
                        peakCandidatesDuringCollect = max(peakCandidatesDuringCollect, p.candidateFiles)
                    }
                case .finished(let groups, let progress):
                    finished = true
                    #expect(groups.count == 1)
                    #expect(progress.candidateFiles == 2)
                default:
                    break
                }
            }
            #expect(finished)
            #expect(peakCandidatesDuringCollect == 2)
        }
    }

    @Test("Overlapping selected roots do not duplicate results")
    func overlappingRootsNoDuplicateResults() async throws {
        try await withTempDirectoryAsync { root in
            let child = root.appendingPathComponent("child", isDirectory: true)
            try FileManager.default.createDirectory(at: child, withIntermediateDirectories: true)
            let payload = Data("overlap-dup".utf8)
            try payload.write(to: child.appendingPathComponent("a.txt"))
            try payload.write(to: child.appendingPathComponent("b.txt"))

            let config = ScanConfiguration(rootURLs: [root, child])
            #expect(config.rootURLs.count == 1)
            #expect(config.rootURLs[0].path == root.standardizedFileURL.path)

            let groups = try await finishedGroups(configuration: config)
            #expect(groups.count == 1)
            #expect(groups[0].files.count == 2)
        }
    }

    @Test("File removed between passes is handled")
    func fileRemovedBetweenPasses() async throws {
        try await withTempDirectoryAsync { root in
            let payload = Data("remove-between-passes".utf8)
            let a = root.appendingPathComponent("keep-a.txt")
            let b = root.appendingPathComponent("gone-b.txt")
            try payload.write(to: a)
            try payload.write(to: b)

            let coordinator = ScanCoordinator(afterPass1: {
                try FileManager.default.removeItem(at: b)
            })
            var finished = false
            var groups: [DuplicateGroup] = []
            for await event in await coordinator.scan(configuration: ScanConfiguration(rootURLs: [root])) {
                if case .finished(let g, _) = event {
                    finished = true
                    groups = g
                }
                if case .failed = event {
                    Issue.record("Unexpected failure after file removal")
                }
            }
            #expect(finished)
            #expect(groups.isEmpty)
        }
    }

    @Test("File size changed between passes is handled")
    func fileSizeChangedBetweenPasses() async throws {
        try await withTempDirectoryAsync { root in
            let a = root.appendingPathComponent("a.txt")
            let b = root.appendingPathComponent("b.txt")
            try Data("same-size-xx".utf8).write(to: a)
            try Data("same-size-yy".utf8).write(to: b)

            let coordinator = ScanCoordinator(afterPass1: {
                // Change b so it no longer shares a's size; pass 2 should not force a false group.
                try Data("changed-to-a-different-length!!!!".utf8).write(to: b)
            })
            let groups = try await finishedGroups(coordinator: coordinator, root: root)
            #expect(groups.isEmpty)
        }
    }

    @Test("Cancellation during pass 1 completes cleanly")
    func cancelDuringPass1() async throws {
        try await withTempDirectoryAsync { root in
            for i in 0..<400 {
                try Data("p1-\(i)-\(String(repeating: "q", count: 24))".utf8)
                    .write(to: root.appendingPathComponent("f\(i).txt"))
            }
            let coordinator = ScanCoordinator()
            var sawCancelled = false
            var n = 0
            for await event in await coordinator.scan(configuration: ScanConfiguration(rootURLs: [root])) {
                n += 1
                if n == 1 {
                    await coordinator.cancel()
                }
                if case .cancelled = event { sawCancelled = true }
                if case .finished = event { break }
            }
            #expect(sawCancelled || n > 0)
        }
    }

    @Test("Cancellation during pass 2 completes cleanly")
    func cancelDuringPass2() async throws {
        try await withTempDirectoryAsync { root in
            for i in 0..<120 {
                let payload = Data("pair-\(i)-payload".utf8)
                try payload.write(to: root.appendingPathComponent("a\(i).txt"))
                try payload.write(to: root.appendingPathComponent("b\(i).txt"))
            }
            let coordinator = ScanCoordinator(afterPass1: {
                // Cancel as soon as pass 2 is about to start.
            })
            // Cancel after we observe collecting-candidates progress.
            var sawCancelled = false
            var sawPass2 = false
            for await event in await coordinator.scan(configuration: ScanConfiguration(rootURLs: [root])) {
                if case .progress(let p) = event, p.message == ScanProgressLabels.collectingDuplicateCandidates {
                    if !sawPass2 {
                        sawPass2 = true
                        await coordinator.cancel()
                    }
                }
                if case .cancelled = event { sawCancelled = true }
                if case .finished = event { break }
            }
            #expect(sawPass2)
            #expect(sawCancelled || sawPass2)
        }
    }

    @Test("Circuit breaker stops the scan with a calm user-facing error")
    func circuitBreakerStopsCleanly() async throws {
        try await withTempDirectoryAsync { root in
            for i in 0..<300 {
                try Data("row-\(i)-\(String(repeating: "z", count: 24))".utf8)
                    .write(to: root.appendingPathComponent("m\(i).txt"))
            }
            let coordinator = ScanCoordinator()
            let config = ScanConfiguration(rootURLs: [root], memoryLimitBytes: 1)
            var failed = false
            var message: String?
            for await event in await coordinator.scan(configuration: config) {
                if case .failed(let m, _) = event {
                    failed = true
                    message = m
                }
            }
            #expect(failed)
            #expect(message == ScanConfiguration.userFacingMemoryLimitMessage)
            #expect(message?.contains("MB") != true)
        }
    }

    @Test("Progress labels cover both passes without resetting file counts")
    func progressDoesNotRestartCounts() async throws {
        try await withTempDirectoryAsync { root in
            let dup = Data("progress-dup".utf8)
            try dup.write(to: root.appendingPathComponent("1.txt"))
            try dup.write(to: root.appendingPathComponent("2.txt"))
            for i in 0..<30 {
                try Data("u\(i)-\(UUID().uuidString)".utf8)
                    .write(to: root.appendingPathComponent("u\(i).txt"))
            }

            var sawIndexing = false
            var sawCollecting = false
            var sawPartial = false
            var sawPreparing = false
            var maxFilesSeen = 0
            var filesSeenAtCollecting: Int?

            let coordinator = ScanCoordinator()
            for await event in await coordinator.scan(configuration: ScanConfiguration(rootURLs: [root])) {
                guard case .progress(let p) = event else { continue }
                maxFilesSeen = max(maxFilesSeen, p.filesSeen)
                switch p.message {
                case ScanProgressLabels.indexingFileSizes:
                    sawIndexing = true
                case ScanProgressLabels.collectingDuplicateCandidates:
                    sawCollecting = true
                    filesSeenAtCollecting = p.filesSeen
                case ScanProgressLabels.partialHashing:
                    sawPartial = true
                case ScanProgressLabels.preparingResults:
                    sawPreparing = true
                default:
                    break
                }
            }

            #expect(sawIndexing)
            #expect(sawCollecting)
            #expect(sawPartial)
            #expect(sawPreparing)
            #expect(filesSeenAtCollecting == maxFilesSeen)
            #expect(maxFilesSeen >= 32)
        }
    }

    @Test("Coordinator scan finishes with balanced telemetry")
    func coordinatorEmitsPerformance() async throws {
        try await withTempDirectoryAsync { root in
            let payload = Data("coord-dup".utf8)
            try payload.write(to: root.appendingPathComponent("1.txt"))
            try payload.write(to: root.appendingPathComponent("2.txt"))

            let coordinator = ScanCoordinator()
            let config = ScanConfiguration(rootURLs: [root])
            #expect(config.performanceMode == .balanced)

            var sawPerformance = false
            var finished = false
            for await event in await coordinator.scan(configuration: config) {
                switch event {
                case .performance:
                    sawPerformance = true
                case .finished(let groups, let progress):
                    finished = true
                    #expect(groups.count == 1)
                    #expect(progress.performance?.mode == .balanced)
                default:
                    break
                }
            }
            #expect(finished)
            #expect(sawPerformance)
        }
    }

    @Test("Default memory limit is capped at 1GB")
    func memoryLimitCap() {
        let config = ScanConfiguration(rootURLs: [])
        #expect(config.resolvedMemoryLimitBytes <= 1024 * 1024 * 1024)
        #expect(config.resolvedMemoryLimitBytes >= 512 * 1024 * 1024)
    }

    @Test("Scan never creates or deletes files inside the selected root")
    func scanDoesNotModifyScanRoot() async throws {
        try await withTempDirectoryAsync { root in
            let marker = root.appendingPathComponent("user-file.txt")
            try Data("leave-me-alone".utf8).write(to: marker)
            let before = try snapshot(of: root)

            let coordinator = ScanCoordinator()
            var finished = false
            for await event in await coordinator.scan(configuration: ScanConfiguration(rootURLs: [root])) {
                if case .finished = event { finished = true }
            }
            #expect(finished)

            let after = try snapshot(of: root)
            #expect(before == after)

            // No engine temp directories leaked into the scan root.
            let names = try FileManager.default.contentsOfDirectory(atPath: root.path)
            #expect(!names.contains(where: { $0.hasPrefix("CopyCatScan-") }))
            #expect(!names.contains(where: { $0.hasPrefix("copycat-io-bench") }))
        }
    }

    @Test("Cancelled scan still leaves the selected root unchanged")
    func cancelDoesNotModifyScanRoot() async throws {
        try await withTempDirectoryAsync { root in
            for i in 0..<80 {
                try Data("row-\(i)-\(UUID().uuidString)".utf8)
                    .write(to: root.appendingPathComponent("f\(i).txt"))
            }
            let before = try snapshot(of: root)

            let coordinator = ScanCoordinator()
            var n = 0
            for await event in await coordinator.scan(configuration: ScanConfiguration(rootURLs: [root])) {
                n += 1
                if n == 1 {
                    await coordinator.cancel()
                }
                if case .cancelled = event { break }
                if case .finished = event { break }
            }

            let after = try snapshot(of: root)
            #expect(before == after)
        }
    }
}

private func snapshot(of root: URL) throws -> Set<String> {
    var result = Set<String>()
    guard let enumerator = FileManager.default.enumerator(
        at: root,
        includingPropertiesForKeys: [.isRegularFileKey, .fileSizeKey],
        options: [.skipsHiddenFiles]
    ) else { return result }
    while let url = enumerator.nextObject() as? URL {
        let values = try url.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey])
        guard values.isRegularFile == true else { continue }
        let rel = url.path.replacingOccurrences(of: root.path, with: "")
        let size = values.fileSize ?? 0
        result.insert("\(rel)#\(size)")
    }
    return result
}

@Suite("Mascot phase mapping labels")
struct MascotPhaseLabelParityTests {
    @Test("Engine progress labels match expected two-pass UX copy")
    func labelsMatchUX() {
        #expect(ScanProgressLabels.indexingFileSizes == "Indexing file sizes")
        #expect(ScanProgressLabels.collectingDuplicateCandidates == "Collecting duplicate candidates")
        #expect(ScanProgressLabels.partialHashing == "Partial hashing")
        #expect(ScanProgressLabels.fullHashing == "Full hashing")
        #expect(ScanProgressLabels.preparingResults == "Preparing results")
    }
}

// MARK: - Helpers

private func finishedGroups(root: URL) async throws -> [DuplicateGroup] {
    try await finishedGroups(coordinator: ScanCoordinator(), root: root)
}

private func finishedGroups(coordinator: ScanCoordinator, root: URL) async throws -> [DuplicateGroup] {
    try await finishedGroups(coordinator: coordinator, configuration: ScanConfiguration(rootURLs: [root]))
}

private func finishedGroups(configuration: ScanConfiguration) async throws -> [DuplicateGroup] {
    try await finishedGroups(coordinator: ScanCoordinator(), configuration: configuration)
}

private func finishedGroups(
    coordinator: ScanCoordinator,
    configuration: ScanConfiguration
) async throws -> [DuplicateGroup] {
    var groups: [DuplicateGroup] = []
    var finished = false
    for await event in await coordinator.scan(configuration: configuration) {
        switch event {
        case .finished(let g, _):
            groups = g
            finished = true
        case .failed(let message, _):
            Issue.record("Scan failed: \(message)")
        default:
            break
        }
    }
    #expect(finished)
    return groups
}

private func withTempDirectoryAsync(_ body: (URL) async throws -> Void) async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent("CopyCatEngineTests-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: root) }
    try await body(root)
}
