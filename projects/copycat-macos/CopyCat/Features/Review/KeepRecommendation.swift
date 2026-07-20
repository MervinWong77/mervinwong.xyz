import Foundation
import CopyCatEngine

/// UI-only heuristic for which copy to keep. Engine never chooses.
enum KeepRecommendation {
    struct Result: Equatable, Sendable {
        let keepFileID: UUID
        /// fileID → reasons that support keeping this file (only filled for keep candidate)
        let keepReasons: [UUID: [String]]
        /// fileID → reasons that support deleting this file
        let deleteReasons: [UUID: [String]]
    }

    private static let preferredPathFragments = [
        "/Movies/", "/Pictures/", "/Music/", "/Documents/",
        "/Animation/", "/Library/Mobile Documents/",
        "/Photos Library", "/Final Cut", "/Adobe",
    ]

    private static let poorPathFragments = [
        "/Desktop/", "/Downloads/", "/Random/", "/Temp/", "/tmp/",
        "/Untitled Folder/", "/New Folder/",
    ]

    private static let poorFilenameTokens = [
        " copy", "copy of", " duplicate", "(1)", "(2)", "(3)",
        " - copy", "_copy", "-copy", "conflicted copy",
    ]

    static func recommend(for files: [ScannedFile], media: [UUID: MediaMetadata] = [:]) -> Result {
        guard let first = files.first else {
            return Result(keepFileID: UUID(), keepReasons: [:], deleteReasons: [:])
        }
        guard files.count > 1 else {
            return Result(
                keepFileID: first.id,
                keepReasons: [first.id: ["Only copy in group"]],
                deleteReasons: [:]
            )
        }

        var scores: [UUID: Int] = [:]
        var keepReasons: [UUID: [String]] = [:]
        var deleteReasons: [UUID: [String]] = [:]

        for file in files {
            scores[file.id] = 0
            keepReasons[file.id] = []
            deleteReasons[file.id] = []
        }

        // Preferred library / project paths
        for file in files {
            let path = file.url.path
            if preferredPathFragments.contains(where: { path.localizedCaseInsensitiveContains($0) }) {
                scores[file.id, default: 0] += 40
                keepReasons[file.id, default: []].append("Located in a preferred library folder")
            }
            if poorPathFragments.contains(where: { path.localizedCaseInsensitiveContains($0) }) {
                scores[file.id, default: 0] -= 35
                deleteReasons[file.id, default: []].append("Located in a temporary or clutter folder")
            }
        }

        // Newer modified date preferred
        if let newest = files.max(by: { ($0.modifiedDate ?? .distantPast) < ($1.modifiedDate ?? .distantPast) }),
           let newestDate = newest.modifiedDate,
           files.contains(where: { ($0.modifiedDate ?? .distantPast) < newestDate }) {
            scores[newest.id, default: 0] += 25
            keepReasons[newest.id, default: []].append("Newer modified date")
            for file in files where file.id != newest.id {
                if let d = file.modifiedDate, d < newestDate {
                    deleteReasons[file.id, default: []].append("Older modified date")
                }
            }
        }

        // Better filename (no “copy” noise)
        for file in files {
            let name = file.filename.lowercased()
            if poorFilenameTokens.contains(where: { name.contains($0) }) {
                scores[file.id, default: 0] -= 20
                deleteReasons[file.id, default: []].append("Filename looks like a duplicate copy")
            } else {
                scores[file.id, default: 0] += 10
                keepReasons[file.id, default: []].append("Cleaner filename")
            }
        }

        // Shallower / cleaner directory depth (prefer shorter paths slightly)
        if let shallowest = files.min(by: {
            $0.url.pathComponents.count < $1.url.pathComponents.count
        }) {
            let depth = shallowest.url.pathComponents.count
            if files.contains(where: { $0.url.pathComponents.count > depth }) {
                scores[shallowest.id, default: 0] += 8
                keepReasons[shallowest.id, default: []].append("Shorter, clearer directory path")
            }
        }

        // Higher quality media (resolution / duration presence)
        var bestPixels: (UUID, Int)?
        for file in files {
            if let meta = media[file.id], let w = meta.pixelWidth, let h = meta.pixelHeight {
                let pixels = w * h
                if bestPixels == nil || pixels > bestPixels!.1 {
                    bestPixels = (file.id, pixels)
                }
            }
        }
        if let best = bestPixels, files.contains(where: {
            guard let m = media[$0.id], let w = m.pixelWidth, let h = m.pixelHeight else { return true }
            return w * h < best.1
        }) {
            scores[best.0, default: 0] += 30
            keepReasons[best.0, default: []].append("Higher resolution")
            for file in files where file.id != best.0 {
                deleteReasons[file.id, default: []].append("Lower or unknown resolution")
            }
        }

        let keepID = files.max(by: { (scores[$0.id] ?? 0) < (scores[$1.id] ?? 0) })?.id ?? first.id

        // Trim reasons: keep only for winner; delete reasons for losers (cap 3)
        var trimmedKeep: [UUID: [String]] = [:]
        var trimmedDelete: [UUID: [String]] = [:]
        for file in files {
            if file.id == keepID {
                let reasons = Array((keepReasons[file.id] ?? []).uniqued().prefix(3))
                trimmedKeep[file.id] = reasons.isEmpty ? ["Best overall match for your libraries"] : reasons
            } else {
                var reasons = Array((deleteReasons[file.id] ?? []).uniqued().prefix(3))
                if reasons.isEmpty {
                    reasons = ["Not the recommended keep location"]
                }
                trimmedDelete[file.id] = reasons
            }
        }

        return Result(keepFileID: keepID, keepReasons: trimmedKeep, deleteReasons: trimmedDelete)
    }
}

private extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
