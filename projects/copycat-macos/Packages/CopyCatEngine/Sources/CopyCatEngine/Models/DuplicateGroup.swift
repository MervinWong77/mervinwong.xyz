import Foundation

/// A set of files believed to be duplicates of one another.
public struct DuplicateGroup: Identifiable, Sendable, Hashable {
    public let id: UUID
    public let files: [ScannedFile]
    public let category: DuplicateCategory
    public let reasons: [DuplicateReason]
    public let recoverableBytes: UInt64

    public init(
        id: UUID = UUID(),
        files: [ScannedFile],
        category: DuplicateCategory,
        reasons: [DuplicateReason],
        recoverableBytes: UInt64? = nil
    ) {
        self.id = id
        self.files = files
        self.category = category
        self.reasons = reasons
        if let recoverableBytes {
            self.recoverableBytes = recoverableBytes
        } else if let first = files.first, files.count > 1 {
            self.recoverableBytes = first.size * UInt64(files.count - 1)
        } else {
            self.recoverableBytes = 0
        }
    }

    public var title: String {
        files.first?.filename ?? "Untitled"
    }
}
