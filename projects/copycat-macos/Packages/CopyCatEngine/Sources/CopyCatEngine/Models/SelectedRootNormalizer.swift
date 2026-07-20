import Foundation

/// Normalizes and deduplicates selected scan roots so overlapping folders are not walked twice.
public enum SelectedRootNormalizer: Sendable {
    /// Standardizes paths, drops exact duplicates, and removes roots that are strict descendants of another selected root.
    public static func normalize(_ urls: [URL]) -> [URL] {
        var unique: [URL] = []
        unique.reserveCapacity(urls.count)

        for url in urls {
            let standardized = url.standardizedFileURL.resolvingSymlinksInPath()
            if unique.contains(where: { $0.path == standardized.path }) {
                continue
            }
            unique.append(standardized)
        }

        return unique.filter { candidate in
            !unique.contains { ancestor in
                isStrictDescendant(candidate, of: ancestor)
            }
        }
    }

    public static func isStrictDescendant(_ child: URL, of parent: URL) -> Bool {
        let childPath = child.standardizedFileURL.path
        let parentPath = parent.standardizedFileURL.path
        guard childPath != parentPath else { return false }
        let prefix = parentPath.hasSuffix("/") ? parentPath : parentPath + "/"
        return childPath.hasPrefix(prefix)
    }
}
