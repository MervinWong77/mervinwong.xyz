import Foundation

/// SHA-256 of the first N bytes of a file (default 64 KiB).
/// Uses a shared `ReusableHashReader` so Balanced mode avoids per-read `Data` churn.
public struct PartialHasher: Sendable {
    public static let defaultByteCount = 64 * 1024

    public let byteCount: Int
    private let reader: ReusableHashReader

    public init(
        byteCount: Int = PartialHasher.defaultByteCount,
        reader: ReusableHashReader? = nil
    ) {
        self.byteCount = byteCount
        self.reader = reader ?? ReusableHashReader(partialByteCount: byteCount)
    }

    public func hash(fileAt url: URL) throws -> String {
        try reader.partialSHA256(of: url)
    }
}
