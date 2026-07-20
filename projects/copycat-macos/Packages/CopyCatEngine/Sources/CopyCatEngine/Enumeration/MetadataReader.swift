import Foundation

/// Reads filesystem metadata into a `ScannedFile` without hashing.
public struct MetadataReader: Sendable {
    public init() {}

    /// Size-only probe for the first enumeration pass (no path retention).
    public func fileSize(url: URL) throws -> UInt64 {
        let values = try url.resourceValues(forKeys: [
            .fileSizeKey,
            .isRegularFileKey,
        ])

        guard values.isRegularFile == true else {
            throw MetadataError.notARegularFile(url)
        }

        return UInt64(values.fileSize ?? 0)
    }

    public func read(url: URL) throws -> ScannedFile {
        let values = try url.resourceValues(forKeys: [
            .fileSizeKey,
            .creationDateKey,
            .contentModificationDateKey,
            .nameKey,
            .isRegularFileKey,
        ])

        guard values.isRegularFile == true else {
            throw MetadataError.notARegularFile(url)
        }

        let size = UInt64(values.fileSize ?? 0)
        let filename = values.name ?? url.lastPathComponent
        let ext = url.pathExtension

        return ScannedFile(
            url: url,
            filename: filename,
            extension: ext,
            size: size,
            createdDate: values.creationDate,
            modifiedDate: values.contentModificationDate
        )
    }
}

public enum MetadataError: Error, LocalizedError, Sendable {
    case notARegularFile(URL)

    public var errorDescription: String? {
        switch self {
        case .notARegularFile(let url):
            return "Not a regular file: \(url.path)"
        }
    }
}
