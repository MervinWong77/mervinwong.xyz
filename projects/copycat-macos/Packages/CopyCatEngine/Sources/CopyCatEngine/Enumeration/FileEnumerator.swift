import Foundation

/// Recursively enumerates file URLs under configured roots, respecting exclusions.
public struct FileEnumerator: Sendable {
    public init() {}

    public func enumerate(
        configuration: ScanConfiguration,
        onFile: (URL) throws -> Void
    ) throws {
        let fileManager = FileManager.default

        for root in configuration.rootURLs {
            try Task.checkCancellation()

            var isDirectory: ObjCBool = false
            guard fileManager.fileExists(atPath: root.path, isDirectory: &isDirectory) else {
                continue
            }

            if !isDirectory.boolValue {
                try onFile(root)
                continue
            }

            guard let enumerator = fileManager.enumerator(
                at: root,
                includingPropertiesForKeys: [
                    .isRegularFileKey,
                    .isDirectoryKey,
                    .isSymbolicLinkKey,
                ],
                options: [.skipsHiddenFiles, .skipsPackageDescendants]
            ) else {
                continue
            }

            var filesInBatch = 0
            while let next = enumerator.nextObject() as? URL {
                try Task.checkCancellation()

                let values = try next.resourceValues(forKeys: [
                    .isRegularFileKey,
                    .isDirectoryKey,
                    .isSymbolicLinkKey,
                    .nameKey,
                ])

                if values.isDirectory == true {
                    let name = values.name ?? next.lastPathComponent
                    if configuration.excludedDirectoryNames.contains(name) {
                        enumerator.skipDescendants()
                    }
                    continue
                }

                if values.isSymbolicLink == true {
                    continue
                }

                if values.isRegularFile == true {
                    try onFile(next)
                    filesInBatch += 1
                }
            }
        }
    }

    /// Async variant that cooperatively yields so UI stays responsive under Balanced mode.
    public func enumerate(
        configuration: ScanConfiguration,
        yieldEvery: Int = 200,
        onFile: (URL) async throws -> Void
    ) async throws {
        let fileManager = FileManager.default

        for root in configuration.rootURLs {
            try Task.checkCancellation()

            var isDirectory: ObjCBool = false
            guard fileManager.fileExists(atPath: root.path, isDirectory: &isDirectory) else {
                continue
            }

            if !isDirectory.boolValue {
                try await onFile(root)
                continue
            }

            guard let enumerator = fileManager.enumerator(
                at: root,
                includingPropertiesForKeys: [
                    .isRegularFileKey,
                    .isDirectoryKey,
                    .isSymbolicLinkKey,
                ],
                options: [.skipsHiddenFiles, .skipsPackageDescendants]
            ) else {
                continue
            }

            var seen = 0
            while let next = enumerator.nextObject() as? URL {
                try Task.checkCancellation()

                let isRegular: Bool = try autoreleasepool {
                    let values = try next.resourceValues(forKeys: [
                        .isRegularFileKey,
                        .isDirectoryKey,
                        .isSymbolicLinkKey,
                        .nameKey,
                    ])

                    if values.isDirectory == true {
                        let name = values.name ?? next.lastPathComponent
                        if configuration.excludedDirectoryNames.contains(name) {
                            enumerator.skipDescendants()
                        }
                        return false
                    }

                    if values.isSymbolicLink == true {
                        return false
                    }

                    return values.isRegularFile == true
                }

                if isRegular {
                    try await onFile(next)
                    seen += 1
                    if seen % yieldEvery == 0 {
                        await Task.yield()
                    }
                }
            }
        }
    }
}
