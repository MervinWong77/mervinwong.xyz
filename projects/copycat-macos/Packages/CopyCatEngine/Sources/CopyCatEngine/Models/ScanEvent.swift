import Foundation

/// High-level phases of an exact-duplicate scan.
public enum ScanPhase: String, Sendable, Hashable {
    case idle
    case enumerating
    case grouping
    case hashing
    case classifying
    case finished
    case cancelled
    case failed
}

/// Progress snapshot emitted during a scan.
public struct ScanProgress: Sendable, Hashable {
    public var phase: ScanPhase
    public var filesSeen: Int
    public var bytesSeen: UInt64
    public var candidateFiles: Int
    public var groupsFound: Int
    public var message: String?
    public var performance: PerformanceSnapshot?

    public init(
        phase: ScanPhase = .idle,
        filesSeen: Int = 0,
        bytesSeen: UInt64 = 0,
        candidateFiles: Int = 0,
        groupsFound: Int = 0,
        message: String? = nil,
        performance: PerformanceSnapshot? = nil
    ) {
        self.phase = phase
        self.filesSeen = filesSeen
        self.bytesSeen = bytesSeen
        self.candidateFiles = candidateFiles
        self.groupsFound = groupsFound
        self.message = message
        self.performance = performance
    }
}

/// Events streamed from `ScanCoordinator` to the UI.
public enum ScanEvent: Sendable {
    case progress(ScanProgress)
    case performance(PerformanceSnapshot)
    /// Developer diagnostics — UI must only surface this in DEBUG builds.
    case diagnostics(ScanDiagnostics)
    case groupsUpdated([DuplicateGroup])
    case finished(groups: [DuplicateGroup], progress: ScanProgress)
    case cancelled(progress: ScanProgress)
    case failed(message: String, progress: ScanProgress)
}
