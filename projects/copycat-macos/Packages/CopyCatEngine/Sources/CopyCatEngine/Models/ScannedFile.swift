import Foundation

/// A file discovered during a scan, with optional progressive hash state.
public struct ScannedFile: Identifiable, Sendable, Hashable {
    public let id: UUID
    public let url: URL
    public let filename: String
    public let `extension`: String
    public let size: UInt64
    public let createdDate: Date?
    public let modifiedDate: Date?
    public var partialHash: String?
    public var fullHash: String?

    public init(
        id: UUID = UUID(),
        url: URL,
        filename: String,
        extension: String,
        size: UInt64,
        createdDate: Date?,
        modifiedDate: Date?,
        partialHash: String? = nil,
        fullHash: String? = nil
    ) {
        self.id = id
        self.url = url
        self.filename = filename
        self.extension = `extension`
        self.size = size
        self.createdDate = createdDate
        self.modifiedDate = modifiedDate
        self.partialHash = partialHash
        self.fullHash = fullHash
    }
}
