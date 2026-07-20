import Foundation

/// Explains why files were grouped together.
public enum DuplicateReason: String, Sendable, Hashable, Codable {
    case identicalSHA256 = "Identical SHA-256 hash"
    case identicalPartialHash = "Identical partial hash"
    case sameSize = "Same file size"
}
