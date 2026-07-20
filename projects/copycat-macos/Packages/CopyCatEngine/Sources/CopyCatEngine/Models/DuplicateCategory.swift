import Foundation

/// Confidence category for a duplicate group.
/// Phase 1 only emits `.exact`. Likely/possible arrive in a later phase.
public enum DuplicateCategory: String, Sendable, Hashable, Codable, CaseIterable {
    case exact
    case likely
    case possible
}
