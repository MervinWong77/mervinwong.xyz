import Foundation

/// Developer-facing scan I/O diagnostics. Safe to emit in all builds; UI must stay DEBUG-only.
public struct ScanDiagnostics: Sendable, Hashable {
    public var phase: ScanPhase
    public var filesPerSecond: Double?
    public var megabytesPerSecond: Double?
    public var residentBytes: UInt64?
    public var peakResidentBytes: UInt64?
    public var largestSQLiteBucket: Int
    public var sqliteRowCount: Int
    public var temporaryDBBytes: UInt64?
    public var averageHashLatencyMilliseconds: Double?
    public var averageFullHashLatencyMilliseconds: Double?
    public var readBufferBytes: Int
    public var activeHasherCount: Int
    public var pass1Seconds: Double?
    public var pass2Seconds: Double?
    public var hashingSeconds: Double?
    public var readOperations: UInt64?
    public var averageFileBytes: Double?
    public var diskWaitSeconds: Double?

    public init(
        phase: ScanPhase = .idle,
        filesPerSecond: Double? = nil,
        megabytesPerSecond: Double? = nil,
        residentBytes: UInt64? = nil,
        peakResidentBytes: UInt64? = nil,
        largestSQLiteBucket: Int = 0,
        sqliteRowCount: Int = 0,
        temporaryDBBytes: UInt64? = nil,
        averageHashLatencyMilliseconds: Double? = nil,
        averageFullHashLatencyMilliseconds: Double? = nil,
        readBufferBytes: Int = PerformanceMode.balanced.hashReadBufferBytes,
        activeHasherCount: Int = 1,
        pass1Seconds: Double? = nil,
        pass2Seconds: Double? = nil,
        hashingSeconds: Double? = nil,
        readOperations: UInt64? = nil,
        averageFileBytes: Double? = nil,
        diskWaitSeconds: Double? = nil
    ) {
        self.phase = phase
        self.filesPerSecond = filesPerSecond
        self.megabytesPerSecond = megabytesPerSecond
        self.residentBytes = residentBytes
        self.peakResidentBytes = peakResidentBytes
        self.largestSQLiteBucket = largestSQLiteBucket
        self.sqliteRowCount = sqliteRowCount
        self.temporaryDBBytes = temporaryDBBytes
        self.averageHashLatencyMilliseconds = averageHashLatencyMilliseconds
        self.averageFullHashLatencyMilliseconds = averageFullHashLatencyMilliseconds
        self.readBufferBytes = readBufferBytes
        self.activeHasherCount = activeHasherCount
        self.pass1Seconds = pass1Seconds
        self.pass2Seconds = pass2Seconds
        self.hashingSeconds = hashingSeconds
        self.readOperations = readOperations
        self.averageFileBytes = averageFileBytes
        self.diskWaitSeconds = diskWaitSeconds
    }

    public var summaryLines: [String] {
        [
            "phase=\(phase.rawValue)",
            "files/s=\(fmt(filesPerSecond))",
            "MB/s=\(fmt(megabytesPerSecond.map { $0 }))",
            "RSS=\(fmtBytes(residentBytes)) peak=\(fmtBytes(peakResidentBytes))",
            "sqliteRows=\(sqliteRowCount) largestBucket=\(largestSQLiteBucket) db=\(fmtBytes(temporaryDBBytes))",
            "hashAvgMs=\(fmt(averageHashLatencyMilliseconds)) fullHashAvgMs=\(fmt(averageFullHashLatencyMilliseconds))",
            "buffer=\(readBufferBytes) activeHashers=\(activeHasherCount)",
            "pass1=\(fmt(pass1Seconds))s pass2=\(fmt(pass2Seconds))s hash=\(fmt(hashingSeconds))s",
            "reads=\(readOperations.map(String.init) ?? "—") avgFile=\(fmtBytes(averageFileBytes.map { UInt64($0) })) diskWait=\(fmt(diskWaitSeconds))s",
        ]
    }

    private func fmt(_ value: Double?) -> String {
        guard let value, value.isFinite else { return "—" }
        return String(format: "%.2f", value)
    }

    private func fmtBytes(_ value: UInt64?) -> String {
        guard let value else { return "—" }
        if value >= 1_048_576 { return String(format: "%.1fMB", Double(value) / 1_048_576) }
        if value >= 1024 { return String(format: "%.0fKB", Double(value) / 1024) }
        return "\(value)B"
    }
}

/// Accumulates phase timings and peak RSS for diagnostics.
public struct ScanDiagnosticsTracker: Sendable {
    public private(set) var peakResidentBytes: UInt64 = 0
    public private(set) var pass1Seconds: Double = 0
    public private(set) var pass2Seconds: Double = 0
    public private(set) var hashingSeconds: Double = 0
    public private(set) var largestSQLiteBucket: Int = 0

    private var pass1Started: ContinuousClock.Instant?
    private var pass2Started: ContinuousClock.Instant?
    private var hashingStartedAt: ContinuousClock.Instant?

    public init() {}

    public mutating func noteResident(_ bytes: UInt64?) {
        guard let bytes else { return }
        peakResidentBytes = max(peakResidentBytes, bytes)
    }

    public mutating func beginPass1(at instant: ContinuousClock.Instant = .now) {
        pass1Started = instant
    }

    public mutating func endPass1(at instant: ContinuousClock.Instant = .now) {
        if let start = pass1Started {
            pass1Seconds = Self.seconds(from: start, to: instant)
        }
        pass1Started = nil
    }

    public mutating func beginPass2(at instant: ContinuousClock.Instant = .now) {
        pass2Started = instant
    }

    public mutating func endPass2(at instant: ContinuousClock.Instant = .now) {
        if let start = pass2Started {
            pass2Seconds = Self.seconds(from: start, to: instant)
        }
        pass2Started = nil
    }

    public mutating func beginHashing(at instant: ContinuousClock.Instant = .now) {
        hashingStartedAt = instant
    }

    public mutating func endHashing(at instant: ContinuousClock.Instant = .now) {
        if let start = hashingStartedAt {
            hashingSeconds = Self.seconds(from: start, to: instant)
        }
        hashingStartedAt = nil
    }

    public mutating func noteBucketSize(_ count: Int) {
        largestSQLiteBucket = max(largestSQLiteBucket, count)
    }

    private static func seconds(from start: ContinuousClock.Instant, to end: ContinuousClock.Instant) -> Double {
        let d = start.duration(to: end)
        return Double(d.components.seconds) + Double(d.components.attoseconds) / 1e18
    }
}
