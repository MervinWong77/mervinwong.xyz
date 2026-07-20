import Foundation

struct TrashedItem: Sendable, Equatable {
    let originalURL: URL
    let trashURL: URL
    let byteSize: UInt64
}

struct CleanupResult: Sendable {
    var items: [TrashedItem] = []
    var failures: [(url: URL, message: String)] = []

    var trashedURLs: [URL] { items.map(\.originalURL) }
    var recoveredBytes: UInt64 { items.reduce(0) { $0 + $1.byteSize } }

    var didSucceedFully: Bool { failures.isEmpty && !items.isEmpty }
    var didSucceedPartially: Bool { !items.isEmpty && !failures.isEmpty }
}

enum RestoreFailureReason: Sendable, Equatable {
    case occupied
    case other(String)
}

struct RestoreResult: Sendable {
    var restoredURLs: [URL] = []
    var failures: [(item: TrashedItem, reason: RestoreFailureReason)] = []

    var occupiedItems: [TrashedItem] {
        failures.compactMap { failure in
            if case .occupied = failure.reason { return failure.item }
            return nil
        }
    }
}

enum CleanupService {
    /// Moves files into the macOS Trash. Never permanently deletes.
    static func moveToTrash(urls: [URL], byteSizes: [URL: UInt64] = [:]) -> CleanupResult {
        var result = CleanupResult()
        let unique = Array(Set(urls.map(\.standardizedFileURL)))

        for url in unique {
            do {
                var resulting: NSURL?
                try FileManager.default.trashItem(at: url, resultingItemURL: &resulting)
                guard let trashURL = resulting as URL? else {
                    result.failures.append((url, "Trash location unavailable"))
                    continue
                }
                let size = byteSizes[url]
                    ?? byteSizes[url.standardizedFileURL]
                    ?? fileSize(trashURL)
                    ?? 0
                result.items.append(TrashedItem(
                    originalURL: url,
                    trashURL: trashURL,
                    byteSize: size
                ))
            } catch {
                result.failures.append((url, error.localizedDescription))
            }
        }
        return result
    }

    /// Restores previously trashed items to their original locations.
    /// Never overwrites an occupied path — reports `.occupied` instead.
    static func restoreFromTrash(items: [TrashedItem]) -> RestoreResult {
        var result = RestoreResult()
        let fm = FileManager.default

        for item in items {
            let destination = item.originalURL
            let parent = destination.deletingLastPathComponent()
            do {
                if !fm.fileExists(atPath: parent.path) {
                    try fm.createDirectory(at: parent, withIntermediateDirectories: true)
                }
                if fm.fileExists(atPath: destination.path) {
                    result.failures.append((item, .occupied))
                    continue
                }
                try fm.moveItem(at: item.trashURL, to: destination)
                result.restoredURLs.append(destination)
            } catch {
                result.failures.append((item, .other(error.localizedDescription)))
            }
        }
        return result
    }

    /// Restores a trashed item to an alternate directory using its original filename.
    static func restoreToDirectory(_ item: TrashedItem, directory: URL) -> RestoreResult {
        var result = RestoreResult()
        let fm = FileManager.default
        var destination = directory.appendingPathComponent(item.originalURL.lastPathComponent)
        if fm.fileExists(atPath: destination.path) {
            let stem = item.originalURL.deletingPathExtension().lastPathComponent
            let ext = item.originalURL.pathExtension
            let suffix = ext.isEmpty ? " (recovered)" : " (recovered).\(ext)"
            destination = directory.appendingPathComponent(stem + suffix)
        }
        do {
            try fm.moveItem(at: item.trashURL, to: destination)
            result.restoredURLs.append(destination)
        } catch {
            result.failures.append((item, .other(error.localizedDescription)))
        }
        return result
    }

    private static func fileSize(_ url: URL) -> UInt64? {
        let values = try? url.resourceValues(forKeys: [.fileSizeKey])
        if let size = values?.fileSize {
            return UInt64(size)
        }
        return nil
    }
}
