import Foundation

/// Compact first-pass index: size → occurrence count only (no paths, URLs, dates, or hashes).
public struct SizeFrequencyMap: Sendable {
    private var counts: [UInt64: UInt32] = [:]

    public private(set) var filesDiscovered: Int = 0
    public private(set) var bytesDiscovered: UInt64 = 0

    public init() {}

    /// Number of distinct sizes currently retained (counts only — never paths).
    public var retainedSizeEntries: Int { counts.count }

    public mutating func note(size: UInt64) {
        filesDiscovered += 1
        bytesDiscovered &+= size
        guard size > 0 else { return }
        counts[size, default: 0] &+= 1
    }

    public func count(for size: UInt64) -> UInt32 {
        counts[size] ?? 0
    }

    /// Sizes that appear at least twice (hash candidates). Clears the count table.
    public mutating func takeCollisionSizes() -> Set<UInt64> {
        var collisions = Set<UInt64>()
        collisions.reserveCapacity(max(counts.count / 8, 1))
        for (size, count) in counts where count >= 2 {
            collisions.insert(size)
        }
        counts.removeAll(keepingCapacity: false)
        return collisions
    }

    public mutating func removeAll() {
        counts.removeAll(keepingCapacity: false)
        filesDiscovered = 0
        bytesDiscovered = 0
    }
}
