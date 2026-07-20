import Foundation

/// Optional audit-only callbacks. Must not alter scan correctness or retain large graphs.
/// Used by `MemoryAuditRunner`; production AppModel leaves this nil.
public struct ScanAuditHooks: Sendable {
    public var onMilestone: (@Sendable (_ name: String, _ metrics: ScanAuditMetrics) -> Void)?

    public init(onMilestone: (@Sendable (String, ScanAuditMetrics) -> Void)? = nil) {
        self.onMilestone = onMilestone
    }
}

/// Point-in-time collection sizes for memory auditing (no paths / file lists).
public struct ScanAuditMetrics: Sendable, Hashable {
    public var phase: ScanPhase
    public var message: String?
    public var filesSeen: Int
    public var frequencyEntries: Int
    public var collisionSizeCount: Int
    public var candidateCount: Int
    public var hashingInputCount: Int
    public var groupsFound: Int
    public var eventsYielded: Int
    public var residentBytes: UInt64?
    public var physicalFootprintBytes: UInt64?

    public init(
        phase: ScanPhase = .idle,
        message: String? = nil,
        filesSeen: Int = 0,
        frequencyEntries: Int = 0,
        collisionSizeCount: Int = 0,
        candidateCount: Int = 0,
        hashingInputCount: Int = 0,
        groupsFound: Int = 0,
        eventsYielded: Int = 0,
        residentBytes: UInt64? = nil,
        physicalFootprintBytes: UInt64? = nil
    ) {
        self.phase = phase
        self.message = message
        self.filesSeen = filesSeen
        self.frequencyEntries = frequencyEntries
        self.collisionSizeCount = collisionSizeCount
        self.candidateCount = candidateCount
        self.hashingInputCount = hashingInputCount
        self.groupsFound = groupsFound
        self.eventsYielded = eventsYielded
        self.residentBytes = residentBytes
        self.physicalFootprintBytes = physicalFootprintBytes
    }
}
