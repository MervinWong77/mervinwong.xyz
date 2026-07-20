import Foundation

/// Compact streaming index that avoids retaining every unique-size file as a list.
///
/// - First sighting of a size is stored as a single pending record.
/// - A second same-size file promotes both into a collision bucket.
/// - Further matches append to that bucket.
/// - `collisionCandidates()` returns only collision members; pending singles are discarded.
///
/// Limitation: when used as a single-pass index, the pending map holds one record per unique
/// size until promotion or finalization. Production scans use `SizeFrequencyMap` (two-pass)
/// instead and only retain collision candidates.
public struct SizeCollisionIndex: Sendable {
    private enum Bucket: Sendable {
        case pending(FileCandidate)
        case collision([FileCandidate])
    }

    private var buckets: [UInt64: Bucket] = [:]

    public private(set) var filesDiscovered: Int = 0
    public private(set) var bytesDiscovered: UInt64 = 0
    public private(set) var pendingCount: Int = 0
    public private(set) var collisionFileCount: Int = 0
    public private(set) var collisionBucketCount: Int = 0

    public init() {}

    public mutating func insert(_ candidate: FileCandidate) {
        filesDiscovered += 1
        bytesDiscovered += candidate.size
        guard candidate.size > 0 else { return }

        switch buckets[candidate.size] {
        case nil:
            buckets[candidate.size] = .pending(candidate)
            pendingCount += 1
        case .pending(let first):
            buckets[candidate.size] = .collision([first, candidate])
            pendingCount -= 1
            collisionBucketCount += 1
            collisionFileCount += 2
        case .collision(var files):
            files.append(candidate)
            buckets[candidate.size] = .collision(files)
            collisionFileCount += 1
        }
    }

    /// All files that share a size with at least one other file.
    public func collisionCandidates() -> [FileCandidate] {
        var result: [FileCandidate] = []
        result.reserveCapacity(collisionFileCount)
        for bucket in buckets.values {
            if case .collision(let files) = bucket {
                result.append(contentsOf: files)
            }
        }
        return result
    }

    public func collisionBuckets() -> [[FileCandidate]] {
        buckets.values.compactMap { bucket in
            if case .collision(let files) = bucket {
                return files
            }
            return nil
        }
    }

    /// Drops pending singles and collision data. Call when abandoning or finishing a scan.
    public mutating func removeAll() {
        buckets.removeAll(keepingCapacity: false)
        filesDiscovered = 0
        bytesDiscovered = 0
        pendingCount = 0
        collisionFileCount = 0
        collisionBucketCount = 0
    }

    /// Discards unique pending records after collision extraction.
    public mutating func discardPendingSingles() {
        let pendingKeys = buckets.compactMap { key, value -> UInt64? in
            if case .pending = value { return key }
            return nil
        }
        for key in pendingKeys {
            buckets.removeValue(forKey: key)
        }
        pendingCount = 0
    }
}
