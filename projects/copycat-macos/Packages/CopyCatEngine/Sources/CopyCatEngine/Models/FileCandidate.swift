import Foundation

/// Lightweight metadata retained for duplicate detection (no hashes, no previews).
public struct FileCandidate: Identifiable, Sendable, Hashable {
    public let id: UUID
    public let url: URL
    public let filename: String
    public let `extension`: String
    public let size: UInt64
    public let createdDate: Date?
    public let modifiedDate: Date?

    public init(
        id: UUID = UUID(),
        url: URL,
        filename: String,
        extension: String,
        size: UInt64,
        createdDate: Date?,
        modifiedDate: Date?
    ) {
        self.id = id
        self.url = url
        self.filename = filename
        self.extension = `extension`
        self.size = size
        self.createdDate = createdDate
        self.modifiedDate = modifiedDate
    }

    public init(_ file: ScannedFile) {
        self.id = file.id
        self.url = file.url
        self.filename = file.filename
        self.extension = file.extension
        self.size = file.size
        self.createdDate = file.createdDate
        self.modifiedDate = file.modifiedDate
    }

    public func asScannedFile() -> ScannedFile {
        ScannedFile(
            id: id,
            url: url,
            filename: filename,
            extension: `extension`,
            size: size,
            createdDate: createdDate,
            modifiedDate: modifiedDate
        )
    }
}
