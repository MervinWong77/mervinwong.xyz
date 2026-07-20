import Foundation

/// Orchestrates two-pass enumeration → disk-backed candidates → per-size exact hashing.
///
/// Pass 1 counts sizes only (no path retention).
/// Pass 2 writes colliding-size metadata to a temporary SQLite index (not RAM).
/// Hashing loads one size bucket at a time from disk.
public actor ScanCoordinator {
    private let enumerator: FileEnumerator
    private let metadataReader: MetadataReader
    private let detector: ExactDuplicateDetector
    /// Test-only hook invoked after pass 1 completes (before pass 2).
    private let afterPass1: (@Sendable () async throws -> Void)?
    /// Optional memory-audit milestones (nil in production UI).
    private let auditHooks: ScanAuditHooks?

    private var currentTask: Task<Void, Never>?

    public init(
        enumerator: FileEnumerator = FileEnumerator(),
        metadataReader: MetadataReader = MetadataReader(),
        detector: ExactDuplicateDetector = ExactDuplicateDetector(),
        afterPass1: (@Sendable () async throws -> Void)? = nil,
        auditHooks: ScanAuditHooks? = nil
    ) {
        self.enumerator = enumerator
        self.metadataReader = metadataReader
        self.detector = detector
        self.afterPass1 = afterPass1
        self.auditHooks = auditHooks
    }

    /// Starts a scan and yields events until finished, cancelled, or failed.
    public func scan(configuration: ScanConfiguration) -> AsyncStream<ScanEvent> {
        currentTask?.cancel()

        let (stream, continuation) = AsyncStream<ScanEvent>.makeStream()
        let enumerator = self.enumerator
        let metadataReader = self.metadataReader
        let afterPass1 = self.afterPass1
        let auditHooks = self.auditHooks
        let mode = configuration.performanceMode
        let memoryLimit = configuration.resolvedMemoryLimitBytes
        let memoryCheckInterval = 250
        // Fresh Balanced reader/detector per scan — one file at a time, reusable buffer.
        let detector = ExactDuplicateDetector(mode: mode)

        let task = Task(priority: .utility) {
            var progress = ScanProgress(phase: .enumerating, message: ScanProgressLabels.indexingFileSizes)
            var frequency = SizeFrequencyMap()
            var candidateStore: CandidateSQLiteStore?
            var telemetry = PerformanceTelemetry()
            var filesProcessed = 0
            var filesSinceMemoryCheck = 0
            var pass2Seen = 0
            var collisionSizeCount = 0
            var candidateCount = 0
            var hashingInputCount = 0
            var peakHashingInputCount = 0
            var eventsYielded = 0
            var lastPass1MilestoneFiles = 0
            var hashingStarted = false
            var diagnosticsTracker = ScanDiagnosticsTracker()
            var lastHashUIEmit: ContinuousClock.Instant?
            var lastDiagnosticsEmit: ContinuousClock.Instant?
            let hashUIInterval: Duration = .milliseconds(100)
            let diagnosticsInterval: Duration = .milliseconds(500)

            func releaseScanState() {
                frequency.removeAll()
                if let store = candidateStore {
                    try? store.closeAndDelete()
                    candidateStore = nil
                }
                candidateCount = 0
                hashingInputCount = 0
            }

            func yieldEvent(_ event: ScanEvent) {
                eventsYielded += 1
                continuation.yield(event)
            }

            func emitDiagnostics(force: Bool = false) {
                let now = ContinuousClock.now
                if !force, let last = lastDiagnosticsEmit, now - last < diagnosticsInterval {
                    return
                }
                lastDiagnosticsEmit = now
                let rss = ProcessMemorySampler.residentByteCount()
                diagnosticsTracker.noteResident(rss)
                let snap = progress.performance
                let mbps: Double? = {
                    guard let bps = snap?.bytesPerSecond, bps.isFinite else { return nil }
                    return bps / 1_048_576
                }()
                let diag = ScanDiagnostics(
                    phase: progress.phase,
                    filesPerSecond: snap?.filesPerSecond,
                    megabytesPerSecond: mbps,
                    residentBytes: rss,
                    peakResidentBytes: diagnosticsTracker.peakResidentBytes == 0
                        ? rss
                        : diagnosticsTracker.peakResidentBytes,
                    largestSQLiteBucket: max(
                        diagnosticsTracker.largestSQLiteBucket,
                        peakHashingInputCount
                    ),
                    sqliteRowCount: candidateCount,
                    temporaryDBBytes: candidateStore?.databaseByteCount,
                    averageHashLatencyMilliseconds: detector.ioReader.averageHashLatencyMilliseconds,
                    averageFullHashLatencyMilliseconds: detector.ioReader.averageFullHashLatencyMilliseconds,
                    readBufferBytes: detector.ioReader.lastFullHashChunkBytes,
                    activeHasherCount: detector.activeHasherCount,
                    pass1Seconds: diagnosticsTracker.pass1Seconds > 0
                        ? diagnosticsTracker.pass1Seconds
                        : nil,
                    pass2Seconds: diagnosticsTracker.pass2Seconds > 0
                        ? diagnosticsTracker.pass2Seconds
                        : nil,
                    hashingSeconds: diagnosticsTracker.hashingSeconds > 0
                        ? diagnosticsTracker.hashingSeconds
                        : nil,
                    readOperations: hashingStarted ? detector.ioReadOperations : nil,
                    averageFileBytes: detector.ioReader.averageBytesPerFile,
                    diskWaitSeconds: hashingStarted ? detector.ioReader.diskWaitSeconds : nil
                )
                yieldEvent(.diagnostics(diag))
            }

            func emitAudit(_ name: String) {
                guard let onMilestone = auditHooks?.onMilestone else { return }
                let metrics = ScanAuditMetrics(
                    phase: progress.phase,
                    message: progress.message,
                    filesSeen: progress.filesSeen,
                    frequencyEntries: frequency.retainedSizeEntries,
                    collisionSizeCount: collisionSizeCount,
                    candidateCount: candidateCount,
                    hashingInputCount: max(hashingInputCount, peakHashingInputCount),
                    groupsFound: progress.groupsFound,
                    eventsYielded: eventsYielded,
                    residentBytes: ProcessMemorySampler.residentByteCount(),
                    physicalFootprintBytes: ProcessMemorySampler.physicalFootprintByteCount()
                )
                onMilestone(name, metrics)
            }

            func checkMemoryLimit(force: Bool = false) throws {
                filesSinceMemoryCheck += 1
                guard force || filesSinceMemoryCheck >= memoryCheckInterval else { return }
                filesSinceMemoryCheck = 0
                guard let resident = ProcessMemorySampler.residentByteCount() else { return }
                if resident > memoryLimit {
                    releaseScanState()
                    throw ScanMemoryLimitError.exceeded(limitBytes: memoryLimit, residentBytes: resident)
                }
            }

            func attachPerformance(force: Bool = false) {
                let hashBytes = detector.ioBytesRead
                let readOps = detector.ioReadOperations
                // Prefer actual hash-read bytes once hashing begins; else pass-1 size totals.
                let bytesForRate = hashingStarted && hashBytes > 0 ? hashBytes : progress.bytesSeen
                let filesForRate = hashingStarted
                    ? max(filesProcessed, Int(detector.ioFilesOpened))
                    : max(progress.filesSeen, frequency.filesDiscovered)

                if let snapshot = telemetry.sampleIfNeeded(
                    mode: mode,
                    phase: progress.phase,
                    filesDiscovered: filesForRate,
                    filesProcessed: filesProcessed,
                    bytesScanned: bytesForRate,
                    duplicateGroupsFound: progress.groupsFound,
                    readOperations: hashingStarted ? readOps : nil,
                    force: force
                ) {
                    progress.performance = snapshot
                    yieldEvent(.performance(snapshot))
                    diagnosticsTracker.noteResident(snapshot.memoryBytes)
                    emitDiagnostics(force: force)
                } else if force {
                    diagnosticsTracker.noteResident(ProcessMemorySampler.residentByteCount())
                    emitDiagnostics(force: true)
                }
            }

            func emitProgress(forceTelemetry: Bool = false) {
                attachPerformance(force: forceTelemetry)
                yieldEvent(.progress(progress))
            }

            do {
                emitProgress(forceTelemetry: true)
                emitAudit("idle_start")

                // MARK: Pass 1 — size frequencies only
                progress.phase = .enumerating
                progress.message = ScanProgressLabels.indexingFileSizes
                diagnosticsTracker.beginPass1()
                try await enumerator.enumerate(configuration: configuration) { url in
                    try Task.checkCancellation()
                    try checkMemoryLimit()

                    try autoreleasepool {
                        do {
                            let size = try metadataReader.fileSize(url: url)
                            if configuration.skipZeroByteFiles && size == 0 {
                                return
                            }

                            frequency.note(size: size)
                            filesProcessed = frequency.filesDiscovered
                            progress.filesSeen = frequency.filesDiscovered
                            progress.bytesSeen = frequency.bytesDiscovered
                            progress.phase = .enumerating
                            progress.message = ScanProgressLabels.indexingFileSizes

                            attachPerformance()
                            if frequency.filesDiscovered % 200 == 0 {
                                yieldEvent(.progress(progress))
                            }

                            let seen = frequency.filesDiscovered
                            if seen != lastPass1MilestoneFiles,
                               [12_500, 25_000, 37_500, 50_000, 100_000].contains(seen) {
                                lastPass1MilestoneFiles = seen
                                emitAudit("pass1_\(seen)_files")
                            }
                        } catch {
                            // Skip unreadable / disconnected files; continue.
                        }
                    }
                }

                try Task.checkCancellation()
                try checkMemoryLimit(force: true)
                diagnosticsTracker.endPass1()
                emitAudit("pass1_complete_before_take")

                let collisionSizes = frequency.takeCollisionSizes()
                collisionSizeCount = collisionSizes.count
                let pass1Files = frequency.filesDiscovered
                let pass1Bytes = frequency.bytesDiscovered
                frequency.removeAll()
                emitAudit("pass1_complete_after_take")

                progress.filesSeen = pass1Files
                progress.bytesSeen = pass1Bytes
                progress.candidateFiles = 0
                progress.phase = .grouping
                progress.message = ScanProgressLabels.collectingDuplicateCandidates
                emitProgress(forceTelemetry: true)

                if let afterPass1 {
                    try await afterPass1()
                }

                diagnosticsTracker.beginPass2()

                try Task.checkCancellation()

                // MARK: Pass 2 — write colliding-size metadata to temp SQLite (not RAM)
                let store = try CandidateSQLiteStore()
                candidateStore = store
                var lastPass2Milestone = 0
                try await enumerator.enumerate(configuration: configuration) { url in
                    try Task.checkCancellation()
                    try checkMemoryLimit()
                    pass2Seen += 1

                    try autoreleasepool {
                        do {
                            let scanned = try metadataReader.read(url: url)
                            if configuration.skipZeroByteFiles && scanned.size == 0 {
                                return
                            }
                            guard collisionSizes.contains(scanned.size) else { return }

                            try store.insert(
                                size: scanned.size,
                                path: scanned.url.path,
                                createdAt: scanned.createdDate,
                                modifiedAt: scanned.modifiedDate
                            )
                            candidateCount = store.insertedCount
                            progress.filesSeen = pass1Files
                            progress.bytesSeen = pass1Bytes
                            progress.candidateFiles = candidateCount
                            progress.phase = .grouping
                            progress.message = ScanProgressLabels.collectingDuplicateCandidates
                            filesProcessed = pass1Files

                            attachPerformance()
                            if candidateCount % 100 == 0 || pass2Seen % 200 == 0 {
                                yieldEvent(.progress(progress))
                            }

                            if candidateCount >= 1000, candidateCount - lastPass2Milestone >= max(candidateCount / 4, 1) {
                                lastPass2Milestone = candidateCount
                                emitAudit("pass2_progress")
                            }
                        } catch let error as CandidateStoreError {
                            throw error
                        } catch {
                            // Disappeared, permission lost, or drive disconnected — skip.
                        }
                    }
                }

                try store.finishInserts()
                candidateCount = store.insertedCount
                if let largest = try? store.largestCollidingBucketCount() {
                    diagnosticsTracker.noteBucketSize(largest)
                }

                try Task.checkCancellation()
                try checkMemoryLimit(force: true)
                diagnosticsTracker.endPass2()
                emitAudit("pass2_complete")

                progress.candidateFiles = candidateCount
                progress.filesSeen = pass1Files
                progress.bytesSeen = pass1Bytes
                progress.phase = .grouping
                progress.message = ScanProgressLabels.collectingDuplicateCandidates
                emitProgress(forceTelemetry: true)

                progress.phase = .hashing
                progress.message = ScanProgressLabels.partialHashing
                hashingStarted = true
                detector.resetIOCounters()
                telemetry.reset()
                diagnosticsTracker.beginHashing()
                emitProgress(forceTelemetry: true)

                let sizes = try store.collidingSizes()
                hashingInputCount = 0
                emitAudit("hashing_start")

                var groups: [DuplicateGroup] = []
                groups.reserveCapacity(min(sizes.count, 1_024))
                var lastEmittedGroupCount = -1

                for size in sizes {
                    try Task.checkCancellation()
                    try checkMemoryLimit()

                    let bucket = try store.scannedFiles(forSize: size)
                    hashingInputCount = bucket.count
                    peakHashingInputCount = max(peakHashingInputCount, bucket.count)
                    diagnosticsTracker.noteBucketSize(bucket.count)
                    guard bucket.count >= 2 else { continue }

                    let bucketGroups = try await detector.detectSizeGroup(
                        bucket,
                        totalCandidateFiles: candidateCount,
                        groupsFoundSoFar: groups.count
                    ) { candidates, groupCount, stage in
                        try Task.checkCancellation()
                        try checkMemoryLimit()
                        progress.candidateFiles = candidates
                        progress.groupsFound = groupCount
                        progress.phase = .hashing
                        progress.message = stage == .full
                            ? ScanProgressLabels.fullHashing
                            : ScanProgressLabels.partialHashing
                        filesProcessed = max(filesProcessed, Int(detector.ioFilesOpened))

                        // Rate-limit UI progress during hashing (not per-file MainActor floods).
                        let now = ContinuousClock.now
                        let groupChanged = groupCount != lastEmittedGroupCount
                        let due: Bool = {
                            guard let last = lastHashUIEmit else { return true }
                            return now - last >= hashUIInterval
                        }()
                        if groupChanged || due {
                            lastHashUIEmit = now
                            lastEmittedGroupCount = groupCount
                            attachPerformance()
                            yieldEvent(.progress(progress))
                        }
                    }
                    groups.append(contentsOf: bucketGroups)
                    hashingInputCount = 0
                    // Cooperative yield between size buckets (HDD-friendly pacing).
                    await Task.yield()
                }

                // Drop disk index before classifying / returning results.
                try store.closeAndDelete()
                candidateStore = nil

                groups.sort { $0.recoverableBytes > $1.recoverableBytes }
                diagnosticsTracker.endHashing()
                emitAudit("hashing_complete")

                await Task.yield()
                attachPerformance(force: true)
                emitDiagnostics(force: true)

                try Task.checkCancellation()
                progress.phase = .classifying
                progress.groupsFound = groups.count
                progress.message = ScanProgressLabels.preparingResults
                emitProgress(forceTelemetry: true)
                yieldEvent(.groupsUpdated(groups))

                progress.phase = .finished
                progress.message = nil
                emitProgress(forceTelemetry: true)
                yieldEvent(.finished(groups: groups, progress: progress))
                emitAudit("scan_completed")
                continuation.finish()
            } catch is CancellationError {
                releaseScanState()
                progress.phase = .cancelled
                progress.message = "Scan cancelled"
                attachPerformance(force: true)
                yieldEvent(.cancelled(progress: progress))
                emitAudit("scan_cancelled")
                continuation.finish()
            } catch let limit as ScanMemoryLimitError {
                releaseScanState()
                progress.phase = .failed
                progress.message = limit.localizedDescription
                attachPerformance(force: true)
                yieldEvent(.failed(message: ScanConfiguration.userFacingMemoryLimitMessage, progress: progress))
                emitAudit("scan_memory_limit")
                continuation.finish()
            } catch {
                releaseScanState()
                progress.phase = .failed
                progress.message = error.localizedDescription
                attachPerformance(force: true)
                yieldEvent(.failed(message: error.localizedDescription, progress: progress))
                emitAudit("scan_failed")
                continuation.finish()
            }
        }

        currentTask = task

        continuation.onTermination = { @Sendable _ in
            task.cancel()
        }

        return stream
    }

    public func cancel() {
        currentTask?.cancel()
        currentTask = nil
    }
}

/// Stable, user-facing progress labels for the two-pass scan.
public enum ScanProgressLabels {
    public static let indexingFileSizes = "Indexing file sizes"
    public static let collectingDuplicateCandidates = "Collecting duplicate candidates"
    public static let partialHashing = "Partial hashing"
    public static let fullHashing = "Full hashing"
    public static let preparingResults = "Preparing results"
}
