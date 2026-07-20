import Foundation

/// Informational performance payload for Balanced scanning (not a tuning surface).
public struct PerformanceSnapshot: Sendable, Hashable {
    public var mode: PerformanceMode
    public var phase: ScanPhase
    public var filesDiscovered: Int
    public var filesProcessed: Int
    public var filesPerSecond: Double?
    /// Bytes read from disk by hashing (when available); otherwise pass-1 size totals.
    public var bytesScanned: UInt64
    /// Rolling MB/s equivalent as bytes/sec of actual hash reads when available.
    public var bytesPerSecond: Double?
    public var readOperations: UInt64?
    public var readOperationsPerSecond: Double?
    /// Disk queue depth is not exposed by public macOS APIs for app sandboxes — always nil today.
    public var averageQueueDepth: Double?
    public var duplicateGroupsFound: Int
    public var memoryBytes: UInt64?

    public init(
        mode: PerformanceMode = .balanced,
        phase: ScanPhase = .idle,
        filesDiscovered: Int = 0,
        filesProcessed: Int = 0,
        filesPerSecond: Double? = nil,
        bytesScanned: UInt64 = 0,
        bytesPerSecond: Double? = nil,
        readOperations: UInt64? = nil,
        readOperationsPerSecond: Double? = nil,
        averageQueueDepth: Double? = nil,
        duplicateGroupsFound: Int = 0,
        memoryBytes: UInt64? = nil
    ) {
        self.mode = mode
        self.phase = phase
        self.filesDiscovered = filesDiscovered
        self.filesProcessed = filesProcessed
        self.filesPerSecond = filesPerSecond
        self.bytesScanned = bytesScanned
        self.bytesPerSecond = bytesPerSecond
        self.readOperations = readOperations
        self.readOperationsPerSecond = readOperationsPerSecond
        self.averageQueueDepth = averageQueueDepth
        self.duplicateGroupsFound = duplicateGroupsFound
        self.memoryBytes = memoryBytes
    }
}

/// Builds snapshots on a controlled interval. Sampling errors never fail the scan.
public struct PerformanceTelemetry: Sendable {
    public let interval: Duration
    private var lastEmit: ContinuousClock.Instant?
    private var filesMeter = FilesPerSecondMeter()
    private var bytesMeter = RollingRateMeter()
    private var readOpsMeter = RollingRateMeter()

    public init(interval: Duration = .milliseconds(250)) {
        self.interval = interval
    }

    public mutating func reset() {
        lastEmit = nil
        filesMeter.reset()
        bytesMeter.reset()
        readOpsMeter.reset()
    }

    /// Returns a snapshot when the interval has elapsed; otherwise `nil`.
    public mutating func sampleIfNeeded(
        mode: PerformanceMode,
        phase: ScanPhase,
        filesDiscovered: Int,
        filesProcessed: Int,
        bytesScanned: UInt64,
        duplicateGroupsFound: Int,
        readOperations: UInt64? = nil,
        force: Bool = false,
        now: ContinuousClock.Instant = .now
    ) -> PerformanceSnapshot? {
        if !force, let lastEmit, now - lastEmit < interval {
            return nil
        }

        filesMeter.record(filesDiscovered: filesDiscovered, at: now)
        bytesMeter.record(bytesScanned, at: now)
        if let readOperations {
            readOpsMeter.record(readOperations, at: now)
        }
        lastEmit = now

        let memory = ProcessMemorySampler.residentByteCount()
        // Forced end-of-phase samples may span <50ms on tiny SSD fixtures.
        let minSeconds = force ? 0.001 : 0.05

        return PerformanceSnapshot(
            mode: mode,
            phase: phase,
            filesDiscovered: filesDiscovered,
            filesProcessed: filesProcessed,
            filesPerSecond: filesMeter.rate(at: now, minimumSeconds: minSeconds),
            bytesScanned: bytesScanned,
            bytesPerSecond: bytesMeter.rate(at: now, minimumSeconds: minSeconds),
            readOperations: readOperations,
            readOperationsPerSecond: readOperations.map { _ in
                readOpsMeter.rate(at: now, minimumSeconds: minSeconds)
            } ?? nil,
            averageQueueDepth: nil,
            duplicateGroupsFound: duplicateGroupsFound,
            memoryBytes: memory
        )
    }
}
