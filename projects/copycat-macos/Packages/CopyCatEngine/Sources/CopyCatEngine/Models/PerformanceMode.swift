import Foundation

/// Scan resource posture. Only `.balanced` is available in the product UI for now.
public enum PerformanceMode: String, Codable, Sendable, Hashable {
    case balanced

    public var displayName: String {
        switch self {
        case .balanced:
            return "Balanced (Recommended)"
        }
    }

    /// Balanced keeps one reader on disk at a time — smooth sequential access over peak throughput.
    public var maxConcurrentHashReaders: Int {
        switch self {
        case .balanced:
            return 1
        }
    }

    /// Allocated reusable read buffer (Balanced: 1 MB max capacity; active chunk adapts 64KB…1MB).
    public var hashReadBufferBytes: Int {
        switch self {
        case .balanced:
            return ReusableHashReader.maximumBufferBytes
        }
    }

    /// Default streaming chunk for mid-size files.
    public var preferredHashChunkBytes: Int {
        switch self {
        case .balanced:
            return ReusableHashReader.balancedBufferBytes
        }
    }

    /// Cooperative yield cadence during hashing (files hashed between yields).
    public var hashYieldEveryFiles: Int {
        switch self {
        case .balanced:
            return 16
        }
    }
}
