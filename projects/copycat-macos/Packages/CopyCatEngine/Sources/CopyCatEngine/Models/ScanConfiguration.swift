import Foundation

/// Inputs that control a scan run.
public struct ScanConfiguration: Sendable {
    public var rootURLs: [URL]
    public var excludedDirectoryNames: Set<String>
    public var skipZeroByteFiles: Bool
    /// Skip files smaller than this many bytes (0 = no minimum beyond zero-byte rule).
    public var minimumFileSizeBytes: UInt64
    /// Resource posture. Defaults to `.balanced`. Not exposed as a UI control yet.
    public var performanceMode: PerformanceMode
    /// Soft resident-memory ceiling. Exceeding it fails the scan instead of freezing the Mac.
    /// `nil` uses ~25% of physical RAM, floored at 512MB and capped at 1GB.
    public var memoryLimitBytes: UInt64?

    public static let standardExcludedDirectoryNames: Set<String> = [
        "Library",
        "Applications",
        ".git",
        "node_modules",
        ".next",
        "DerivedData",
        "Caches",
        ".Trash",
    ]

    public static let userFacingMemoryLimitMessage =
        "CopyCat stopped this scan to keep your Mac responsive. Try scanning a smaller folder or excluding large system and application folders."

    public init(
        rootURLs: [URL],
        excludedDirectoryNames: Set<String> = ScanConfiguration.standardExcludedDirectoryNames,
        skipZeroByteFiles: Bool = true,
        minimumFileSizeBytes: UInt64 = 0,
        performanceMode: PerformanceMode = .balanced,
        memoryLimitBytes: UInt64? = nil,
        normalizeRoots: Bool = true
    ) {
        self.rootURLs = normalizeRoots ? SelectedRootNormalizer.normalize(rootURLs) : rootURLs
        self.excludedDirectoryNames = excludedDirectoryNames
        self.skipZeroByteFiles = skipZeroByteFiles
        self.minimumFileSizeBytes = minimumFileSizeBytes
        self.performanceMode = performanceMode
        self.memoryLimitBytes = memoryLimitBytes
    }

    /// Resolved soft memory limit for this scan.
    public var resolvedMemoryLimitBytes: UInt64 {
        if let memoryLimitBytes { return memoryLimitBytes }
        let physical = ProcessInfo.processInfo.physicalMemory
        let quarter = physical / 4
        let floor: UInt64 = 512 * 1024 * 1024
        let ceiling: UInt64 = 1024 * 1024 * 1024
        return min(max(quarter, floor), ceiling)
    }
}

public enum ScanMemoryLimitError: Error, LocalizedError, Sendable {
    case exceeded(limitBytes: UInt64, residentBytes: UInt64)

    public var errorDescription: String? {
        ScanConfiguration.userFacingMemoryLimitMessage
    }
}

/// Hashing sub-stage reported during exact detection.
public enum HashingProgressStage: String, Sendable, Hashable {
    case partial
    case full
}
