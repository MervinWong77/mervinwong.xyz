import Foundation

enum FolderSizeEstimator {
    static func quickAllocatedSize(at url: URL) -> UInt64? {
        let values = try? url.resourceValues(forKeys: [
            .totalFileAllocatedSizeKey,
            .fileAllocatedSizeKey,
        ])
        if let total = values?.totalFileAllocatedSize, total > 0 {
            return UInt64(total)
        }
        if let allocated = values?.fileAllocatedSize, allocated > 0 {
            return UInt64(allocated)
        }
        return nil
    }

    /// Shallow estimate for Home stats — not a full recursive walk.
    static func approximateByteCount(at url: URL) -> UInt64 {
        if let quick = quickAllocatedSize(at: url), quick > 0 { return quick }
        let fm = FileManager.default
        guard let children = try? fm.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .fileSizeKey],
            options: [.skipsHiddenFiles]
        ) else { return 0 }

        var total: UInt64 = 0
        for child in children.prefix(400) {
            if let values = try? child.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .fileSizeKey]),
               let size = values.totalFileAllocatedSize ?? values.fileSize {
                total += UInt64(size)
            }
        }
        return total
    }
}
