import Foundation

/// Builds exact-duplicate groups using size → partial hash → full SHA-256.
///
/// Balanced mode: one file at a time, path-stable order, shared reusable read buffer,
/// cooperative yields between batches (async API).
public struct ExactDuplicateDetector: Sendable {
    private let partialHasher: PartialHasher
    private let fullHasher: FullHasher
    private let reader: ReusableHashReader
    private let yieldEveryFiles: Int

    public var ioBytesRead: UInt64 { reader.bytesRead }
    public var ioReadOperations: UInt64 { reader.readOperations }
    public var ioFilesOpened: UInt64 { reader.filesOpened }
    public var ioReader: ReusableHashReader { reader }
    public var activeHasherCount: Int { 1 }

    public init(
        mode: PerformanceMode = .balanced,
        reader: ReusableHashReader? = nil
    ) {
        let shared = reader ?? ReusableHashReader(
            capacity: mode.hashReadBufferBytes,
            partialByteCount: PartialHasher.defaultByteCount
        )
        self.reader = shared
        self.partialHasher = PartialHasher(reader: shared)
        self.fullHasher = FullHasher(chunkSize: mode.preferredHashChunkBytes, reader: shared)
        self.yieldEveryFiles = mode.hashYieldEveryFiles
        precondition(mode.maxConcurrentHashReaders == 1, "Balanced hashing is single-reader only")
    }

    /// Detects exact duplicates from already-collected metadata.
    public func detect(
        files: [ScannedFile],
        onProgress: ((_ candidateFiles: Int, _ groupsFound: Int, _ stage: HashingProgressStage) throws -> Void)? = nil
    ) throws -> [DuplicateGroup] {
        var bySize: [UInt64: [ScannedFile]] = [:]
        for file in files where file.size > 0 {
            bySize[file.size, default: []].append(file)
        }

        let sizeCandidates = bySize.keys.sorted().compactMap { size -> [ScannedFile]? in
            guard let group = bySize[size], group.count >= 2 else { return nil }
            return group
        }
        let candidateCount = sizeCandidates.reduce(0) { $0 + $1.count }
        try onProgress?(candidateCount, 0, .partial)

        var groups: [DuplicateGroup] = []
        for sizeGroup in sizeCandidates {
            let bucketGroups = try detectSizeGroup(
                sizeGroup,
                totalCandidateFiles: candidateCount,
                groupsFoundSoFar: groups.count,
                onProgress: onProgress
            )
            groups.append(contentsOf: bucketGroups)
        }

        return groups.sorted { $0.recoverableBytes > $1.recoverableBytes }
    }

    /// Sync path (tests / helpers). Same I/O policy without cooperative yields.
    public func detectSizeGroup(
        _ sizeGroup: [ScannedFile],
        totalCandidateFiles: Int,
        groupsFoundSoFar: Int = 0,
        onProgress: ((_ candidateFiles: Int, _ groupsFound: Int, _ stage: HashingProgressStage) throws -> Void)? = nil
    ) throws -> [DuplicateGroup] {
        try hashSizeGroup(
            sizeGroup,
            totalCandidateFiles: totalCandidateFiles,
            groupsFoundSoFar: groupsFoundSoFar,
            onProgress: onProgress,
            shouldYield: false
        )
    }

    /// Async Balanced path — yields between file batches so the Mac stays responsive.
    public func detectSizeGroup(
        _ sizeGroup: [ScannedFile],
        totalCandidateFiles: Int,
        groupsFoundSoFar: Int = 0,
        onProgress: ((_ candidateFiles: Int, _ groupsFound: Int, _ stage: HashingProgressStage) throws -> Void)? = nil
    ) async throws -> [DuplicateGroup] {
        try await hashSizeGroupAsync(
            sizeGroup,
            totalCandidateFiles: totalCandidateFiles,
            groupsFoundSoFar: groupsFoundSoFar,
            onProgress: onProgress
        )
    }

    public func resetIOCounters() {
        reader.resetCounters()
    }

    // MARK: - Core

    private func hashSizeGroupAsync(
        _ sizeGroup: [ScannedFile],
        totalCandidateFiles: Int,
        groupsFoundSoFar: Int,
        onProgress: ((_ candidateFiles: Int, _ groupsFound: Int, _ stage: HashingProgressStage) throws -> Void)?
    ) async throws -> [DuplicateGroup] {
        guard sizeGroup.count >= 2 else { return [] }

        let ordered = Self.stableDiskOrder(sizeGroup)
        try Task.checkCancellation()
        try onProgress?(totalCandidateFiles, groupsFoundSoFar, .partial)

        var withPartial: [ScannedFile] = []
        withPartial.reserveCapacity(ordered.count)
        var hashedSinceYield = 0
        let yieldEvery = SystemLoadHints.hashYieldEveryFiles(base: yieldEveryFiles)

        for var file in ordered {
            try Task.checkCancellation()
            do {
                try autoreleasepool {
                    file.partialHash = try partialHasher.hash(fileAt: file.url)
                }
                withPartial.append(file)
            } catch {
                continue
            }
            hashedSinceYield += 1
            if hashedSinceYield >= yieldEvery {
                hashedSinceYield = 0
                await Task.yield()
            }
        }

        var byPartial: [String: [ScannedFile]] = [:]
        for file in withPartial {
            guard let partial = file.partialHash else { continue }
            byPartial[partial, default: []].append(file)
        }
        withPartial.removeAll(keepingCapacity: false)

        var groups: [DuplicateGroup] = []
        var found = groupsFoundSoFar

        for key in byPartial.keys.sorted() {
            guard var partialGroup = byPartial[key], partialGroup.count >= 2 else { continue }
            partialGroup = Self.stableDiskOrder(partialGroup)

            try Task.checkCancellation()
            try onProgress?(totalCandidateFiles, found, .full)

            var withFull: [ScannedFile] = []
            withFull.reserveCapacity(partialGroup.count)

            for var file in partialGroup {
                try Task.checkCancellation()
                do {
                    try autoreleasepool {
                        file.fullHash = try fullHasher.hash(fileAt: file.url, fileSize: file.size)
                    }
                    withFull.append(file)
                } catch {
                    continue
                }
                hashedSinceYield += 1
                if hashedSinceYield >= yieldEvery {
                    hashedSinceYield = 0
                    await Task.yield()
                }
            }

            try appendExactGroups(
                from: withFull,
                into: &groups,
                found: &found,
                totalCandidateFiles: totalCandidateFiles,
                onProgress: onProgress
            )
        }

        if hashedSinceYield > 0 {
            await Task.yield()
        }
        return groups
    }

    private func hashSizeGroup(
        _ sizeGroup: [ScannedFile],
        totalCandidateFiles: Int,
        groupsFoundSoFar: Int,
        onProgress: ((_ candidateFiles: Int, _ groupsFound: Int, _ stage: HashingProgressStage) throws -> Void)?,
        shouldYield: Bool
    ) throws -> [DuplicateGroup] {
        _ = shouldYield
        guard sizeGroup.count >= 2 else { return [] }

        let ordered = Self.stableDiskOrder(sizeGroup)
        try Task.checkCancellation()
        try onProgress?(totalCandidateFiles, groupsFoundSoFar, .partial)

        var withPartial: [ScannedFile] = []
        withPartial.reserveCapacity(ordered.count)

        for var file in ordered {
            try Task.checkCancellation()
            do {
                try autoreleasepool {
                    file.partialHash = try partialHasher.hash(fileAt: file.url)
                }
                withPartial.append(file)
            } catch {
                continue
            }
        }

        var byPartial: [String: [ScannedFile]] = [:]
        for file in withPartial {
            guard let partial = file.partialHash else { continue }
            byPartial[partial, default: []].append(file)
        }
        withPartial.removeAll(keepingCapacity: false)

        var groups: [DuplicateGroup] = []
        var found = groupsFoundSoFar

        for key in byPartial.keys.sorted() {
            guard var partialGroup = byPartial[key], partialGroup.count >= 2 else { continue }
            partialGroup = Self.stableDiskOrder(partialGroup)

            try Task.checkCancellation()
            try onProgress?(totalCandidateFiles, found, .full)

            var withFull: [ScannedFile] = []
            withFull.reserveCapacity(partialGroup.count)

            for var file in partialGroup {
                try Task.checkCancellation()
                do {
                    try autoreleasepool {
                        file.fullHash = try fullHasher.hash(fileAt: file.url, fileSize: file.size)
                    }
                    withFull.append(file)
                } catch {
                    continue
                }
            }

            try appendExactGroups(
                from: withFull,
                into: &groups,
                found: &found,
                totalCandidateFiles: totalCandidateFiles,
                onProgress: onProgress
            )
        }

        return groups
    }

    private func appendExactGroups(
        from withFull: [ScannedFile],
        into groups: inout [DuplicateGroup],
        found: inout Int,
        totalCandidateFiles: Int,
        onProgress: ((_ candidateFiles: Int, _ groupsFound: Int, _ stage: HashingProgressStage) throws -> Void)?
    ) throws {
        var byFull: [String: [ScannedFile]] = [:]
        for file in withFull {
            guard let full = file.fullHash else { continue }
            byFull[full, default: []].append(file)
        }

        for fullKey in byFull.keys.sorted() {
            guard let exactFiles = byFull[fullKey], exactFiles.count >= 2 else { continue }
            let group = DuplicateGroup(
                files: Self.stableDiskOrder(exactFiles),
                category: .exact,
                reasons: [.identicalSHA256]
            )
            groups.append(group)
            found += 1
            try onProgress?(totalCandidateFiles, found, .full)
        }
    }

    /// Directory-then-name order — keep same-folder files together to reduce seeks.
    static func stableDiskOrder(_ files: [ScannedFile]) -> [ScannedFile] {
        files.sorted { lhs, rhs in
            let leftDir = lhs.url.deletingLastPathComponent().path
            let rightDir = rhs.url.deletingLastPathComponent().path
            let dirOrder = leftDir.localizedStandardCompare(rightDir)
            if dirOrder != .orderedSame {
                return dirOrder == .orderedAscending
            }
            return lhs.url.lastPathComponent.localizedStandardCompare(rhs.url.lastPathComponent)
                == .orderedAscending
        }
    }
}
