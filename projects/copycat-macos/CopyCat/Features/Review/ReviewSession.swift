import Foundation
import Observation
import CopyCatEngine

enum FileDecision: String, Equatable, Sendable {
    case keep
    case delete
}

struct ReviewFileItem: Identifiable, Equatable {
    let file: ScannedFile
    var decision: FileDecision
    var recommendedDecision: FileDecision
    var keepReasons: [String]
    var deleteReasons: [String]
    var media: MediaMetadata

    var id: UUID { file.id }

    var folderPath: String {
        file.url.deletingLastPathComponent().path
    }

    var folderName: String {
        file.url.deletingLastPathComponent().lastPathComponent
    }
}

struct ReviewGroupItem: Identifiable, Equatable {
    let source: DuplicateGroup
    var files: [ReviewFileItem]

    var id: UUID { source.id }
    var title: String { source.title }
    var recoverableBytes: UInt64 { source.recoverableBytes }

    var selectedDeleteBytes: UInt64 {
        files.filter { $0.decision == .delete }.reduce(0) { $0 + $1.file.size }
    }

    var selectedDeleteCount: Int {
        files.filter { $0.decision == .delete }.count
    }

    var deleteURLs: [URL] {
        files.filter { $0.decision == .delete }.map(\.file.url)
    }

    var keepFile: ReviewFileItem? {
        files.first { $0.decision == .keep }
    }
}

/// Snapshot used to restore queue state after Undo.
struct ReviewQueueSnapshot: Equatable {
    let groups: [ReviewGroupItem]
    let currentIndex: Int
    let reviewedGroupCount: Int
    let totalRecoveredBytes: UInt64
    let totalRecoveredFileCount: Int
}

@Observable
@MainActor
final class ReviewSession {
    /// Active review queue only — processed groups are removed immediately.
    private(set) var groups: [ReviewGroupItem] = []
    var currentIndex: Int = 0

    /// Total groups at scan load time (denominator for Reviewed X / Y).
    private(set) var initialGroupCount: Int = 0
    /// Groups successfully moved to Trash (removed from the queue).
    private(set) var reviewedGroupCount: Int = 0
    private(set) var totalRecoveredBytes: UInt64 = 0
    private(set) var totalRecoveredFileCount: Int = 0

    var cleanupErrorMessage: String?

    var currentGroup: ReviewGroupItem? {
        guard groups.indices.contains(currentIndex) else { return nil }
        return groups[currentIndex]
    }

    var remainingGroupCount: Int { groups.count }

    var currentGroupDeleteCount: Int {
        currentGroup?.selectedDeleteCount ?? 0
    }

    var currentGroupDeleteBytes: UInt64 {
        currentGroup?.selectedDeleteBytes ?? 0
    }

    /// All delete selections across the remaining queue (Advanced bulk only).
    var totalSelectedDeleteBytes: UInt64 {
        groups.reduce(0) { $0 + $1.selectedDeleteBytes }
    }

    var totalSelectedDeleteCount: Int {
        groups.flatMap(\.files).filter { $0.decision == .delete }.count
    }

    func load(from duplicateGroups: [DuplicateGroup]) {
        groups = duplicateGroups.map { Self.makeReviewGroup(from: $0) }
        currentIndex = 0
        initialGroupCount = groups.count
        reviewedGroupCount = 0
        totalRecoveredBytes = 0
        totalRecoveredFileCount = 0
        cleanupErrorMessage = nil

        Task { await enrichMediaMetadata() }
    }

    func clear() {
        groups = []
        currentIndex = 0
        initialGroupCount = 0
        reviewedGroupCount = 0
        totalRecoveredBytes = 0
        totalRecoveredFileCount = 0
        cleanupErrorMessage = nil
    }

    // MARK: - Per-file decisions

    func setDecision(groupID: UUID, fileID: UUID, decision: FileDecision) {
        guard let gIndex = groups.firstIndex(where: { $0.id == groupID }) else { return }
        var group = groups[gIndex]
        guard let fIndex = group.files.firstIndex(where: { $0.id == fileID }) else { return }

        switch decision {
        case .keep:
            for i in group.files.indices {
                group.files[i].decision = group.files[i].id == fileID ? .keep : .delete
            }
        case .delete:
            // Never leave a group with zero keeps.
            let keepCount = group.files.filter { $0.decision == .keep }.count
            if group.files[fIndex].decision == .keep && keepCount <= 1 {
                // Promote another file (prefer recommendation).
                if let alt = group.files.first(where: { $0.id != fileID && $0.recommendedDecision == .keep })
                    ?? group.files.first(where: { $0.id != fileID }) {
                    for i in group.files.indices {
                        group.files[i].decision = group.files[i].id == alt.id ? .keep : .delete
                    }
                }
            } else {
                group.files[fIndex].decision = .delete
            }
        }
        groups[gIndex] = group
    }

    // MARK: - Navigation

    func goToNextGroup() {
        guard currentIndex + 1 < groups.count else { return }
        currentIndex += 1
    }

    func goToPreviousGroup() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
    }

    func goToGroup(id: UUID) {
        if let index = groups.firstIndex(where: { $0.id == id }) {
            currentIndex = index
        }
    }

    /// Moves the current group to the end of the queue and shows the next one.
    func skipCurrentGroup() {
        guard groups.count > 1, groups.indices.contains(currentIndex) else { return }
        let skipped = groups.remove(at: currentIndex)
        groups.append(skipped)
        // currentIndex now points at what was formerly next; clamp if we skipped the last item.
        if currentIndex >= groups.count {
            currentIndex = 0
        }
    }

    // MARK: - Current-group selection helpers

    func applyRecommendedToCurrent() {
        guard groups.indices.contains(currentIndex) else { return }
        applyRecommended(toGroupAt: currentIndex)
    }

    func selectOlderCopiesInCurrent() {
        guard groups.indices.contains(currentIndex) else { return }
        let files = groups[currentIndex].files
        guard let newest = files.max(by: {
            ($0.file.modifiedDate ?? .distantPast) < ($1.file.modifiedDate ?? .distantPast)
        }) else { return }
        setKeep(fileID: newest.id, inGroupAt: currentIndex)
    }

    func selectOutsideLibraryInCurrent() {
        guard groups.indices.contains(currentIndex) else { return }
        let files = groups[currentIndex].files
        let libraryIDs = files.filter { Self.isLibraryPath($0.folderPath) }.map(\.id)
        if let keep = libraryIDs.first ?? files.first?.id {
            setKeep(fileID: keep, inGroupAt: currentIndex)
        }
    }

    func selectInPathFragmentInCurrent(_ fragment: String) {
        guard groups.indices.contains(currentIndex) else { return }
        let g = currentIndex
        let files = groups[g].files
        let matches = files.filter {
            $0.folderPath.localizedCaseInsensitiveContains(fragment)
        }
        if let keep = files.first(where: {
            !$0.folderPath.localizedCaseInsensitiveContains(fragment)
        }) ?? files.first {
            setKeep(fileID: keep.id, inGroupAt: g)
            for file in matches where file.id != keep.id {
                if let idx = groups[g].files.firstIndex(where: { $0.id == file.id }) {
                    groups[g].files[idx].decision = .delete
                }
            }
        }
    }

    func invertSelectionInCurrent() {
        guard groups.indices.contains(currentIndex) else { return }
        let files = groups[currentIndex].files
        let formerDelete = files.first(where: { $0.decision == .delete })
        let formerKeep = files.first(where: { $0.decision == .keep })
        if let nextKeep = formerDelete ?? formerKeep {
            setKeep(fileID: nextKeep.id, inGroupAt: currentIndex)
        }
    }

    // MARK: - Advanced cross-group selection

    func applyAllRecommended() {
        for g in groups.indices {
            applyRecommended(toGroupAt: g)
        }
    }

    func selectOlderCopies() {
        for g in groups.indices {
            let files = groups[g].files
            guard let newest = files.max(by: {
                ($0.file.modifiedDate ?? .distantPast) < ($1.file.modifiedDate ?? .distantPast)
            }) else { continue }
            setKeep(fileID: newest.id, inGroupAt: g)
        }
    }

    func selectSmallerCopies() {
        for g in groups.indices {
            let files = groups[g].files
            guard let largest = files.max(by: { $0.file.size < $1.file.size }) else { continue }
            if files.contains(where: { $0.file.size < largest.file.size }) {
                setKeep(fileID: largest.id, inGroupAt: g)
            }
        }
    }

    func selectOutsideLibrary() {
        for g in groups.indices {
            let files = groups[g].files
            let libraryIDs = files.filter { Self.isLibraryPath($0.folderPath) }.map(\.id)
            if let keep = libraryIDs.first ?? files.first?.id {
                setKeep(fileID: keep, inGroupAt: g)
            }
        }
    }

    func selectInPathFragment(_ fragment: String) {
        for g in groups.indices {
            let files = groups[g].files
            let matches = files.filter {
                $0.folderPath.localizedCaseInsensitiveContains(fragment)
            }
            if let keep = files.first(where: {
                !$0.folderPath.localizedCaseInsensitiveContains(fragment)
            }) ?? files.first {
                setKeep(fileID: keep.id, inGroupAt: g)
                for file in matches where file.id != keep.id {
                    if let idx = groups[g].files.firstIndex(where: { $0.id == file.id }) {
                        groups[g].files[idx].decision = .delete
                    }
                }
            }
        }
    }

    func invertSelection() {
        for g in groups.indices {
            let files = groups[g].files
            let formerKeep = files.first(where: { $0.decision == .keep })
            let formerDelete = files.first(where: { $0.decision == .delete })
            if let nextKeep = formerDelete ?? formerKeep {
                setKeep(fileID: nextKeep.id, inGroupAt: g)
            }
        }
    }

    func clearSelectionToRecommended() {
        applyAllRecommended()
    }

    // MARK: - Cleanup bookkeeping

    func queueSnapshot() -> ReviewQueueSnapshot {
        ReviewQueueSnapshot(
            groups: groups,
            currentIndex: currentIndex,
            reviewedGroupCount: reviewedGroupCount,
            totalRecoveredBytes: totalRecoveredBytes,
            totalRecoveredFileCount: totalRecoveredFileCount
        )
    }

    func restoreQueue(from snapshot: ReviewQueueSnapshot) {
        groups = snapshot.groups
        currentIndex = min(snapshot.currentIndex, max(snapshot.groups.count - 1, 0))
        reviewedGroupCount = snapshot.reviewedGroupCount
        totalRecoveredBytes = snapshot.totalRecoveredBytes
        totalRecoveredFileCount = snapshot.totalRecoveredFileCount
    }

    /// Removes the current group after a successful trash of its delete selections.
    func removeCurrentGroupAfterTrash(recoveredBytes: UInt64, fileCount: Int) {
        guard groups.indices.contains(currentIndex) else { return }
        groups.remove(at: currentIndex)
        reviewedGroupCount += 1
        totalRecoveredBytes += recoveredBytes
        totalRecoveredFileCount += fileCount
        if currentIndex >= groups.count {
            currentIndex = max(groups.count - 1, 0)
        }
    }

    /// After advanced bulk trash: drop groups that no longer have duplicates; update files that were trashed.
    func applyBulkTrash(urls: Set<URL>, recoveredBytes: UInt64) {
        let trashed = Set(urls.map(\.standardizedFileURL))
        var nextGroups: [ReviewGroupItem] = []
        let previousCurrentID = currentGroup?.id
        var removedCount = 0

        for var group in groups {
            let remaining = group.files.filter {
                !trashed.contains($0.file.url.standardizedFileURL)
            }
            if remaining.count < group.files.count {
                group.files = remaining
            }

            if group.files.count <= 1 {
                removedCount += 1
                continue
            }

            if group.files.contains(where: { $0.decision == .keep }) == false,
               let first = group.files.first {
                for i in group.files.indices {
                    group.files[i].decision = group.files[i].id == first.id ? .keep : .delete
                }
            }
            nextGroups.append(group)
        }

        reviewedGroupCount += removedCount
        totalRecoveredBytes += recoveredBytes
        totalRecoveredFileCount += trashed.count
        groups = nextGroups

        if let id = previousCurrentID, let idx = groups.firstIndex(where: { $0.id == id }) {
            currentIndex = idx
        } else {
            currentIndex = min(currentIndex, max(groups.count - 1, 0))
        }
    }

    // MARK: - Private

    private func setKeep(fileID: UUID, inGroupAt g: Int) {
        for i in groups[g].files.indices {
            groups[g].files[i].decision = groups[g].files[i].id == fileID ? .keep : .delete
        }
    }

    private func applyRecommended(toGroupAt g: Int) {
        for i in groups[g].files.indices {
            groups[g].files[i].decision = groups[g].files[i].recommendedDecision
        }
        // Ensure exactly one keep.
        if groups[g].files.filter({ $0.decision == .keep }).count != 1,
           let recommended = groups[g].files.first(where: { $0.recommendedDecision == .keep })
            ?? groups[g].files.first {
            setKeep(fileID: recommended.id, inGroupAt: g)
        }
    }

    private func enrichMediaMetadata() async {
        let snapshot = groups
        for (gIndex, group) in snapshot.enumerated() {
            for (fIndex, item) in group.files.enumerated() {
                let url = item.file.url
                let meta = await Task.detached(priority: .utility) {
                    MediaMetadataLoader.load(for: url)
                }.value
                // Group may have been removed or reordered while enriching.
                guard let liveG = groups.firstIndex(where: { $0.id == group.id }),
                      groups[liveG].files.indices.contains(fIndex),
                      groups[liveG].files[fIndex].id == item.id else { continue }
                groups[liveG].files[fIndex].media = meta
            }

            guard let liveG = groups.firstIndex(where: { $0.id == group.id }) else { continue }
            let files = groups[liveG].files.map(\.file)
            let mediaMap = Dictionary(uniqueKeysWithValues: groups[liveG].files.map { ($0.id, $0.media) })
            let result = KeepRecommendation.recommend(for: files, media: mediaMap)
            let stillOnRecommendation = groups[liveG].files.allSatisfy {
                $0.decision == $0.recommendedDecision
            }
            for i in groups[liveG].files.indices {
                let id = groups[liveG].files[i].id
                let isKeep = id == result.keepFileID
                groups[liveG].files[i].recommendedDecision = isKeep ? .keep : .delete
                groups[liveG].files[i].keepReasons = result.keepReasons[id] ?? []
                groups[liveG].files[i].deleteReasons = result.deleteReasons[id] ?? []
                if stillOnRecommendation {
                    groups[liveG].files[i].decision = isKeep ? .keep : .delete
                }
            }
        }
    }

    private static func makeReviewGroup(from group: DuplicateGroup) -> ReviewGroupItem {
        let recommendation = KeepRecommendation.recommend(for: group.files)
        let items = group.files.map { file -> ReviewFileItem in
            let isKeep = file.id == recommendation.keepFileID
            return ReviewFileItem(
                file: file,
                decision: isKeep ? .keep : .delete,
                recommendedDecision: isKeep ? .keep : .delete,
                keepReasons: recommendation.keepReasons[file.id] ?? [],
                deleteReasons: recommendation.deleteReasons[file.id] ?? [],
                media: MediaMetadata()
            )
        }
        return ReviewGroupItem(source: group, files: items)
    }

    private static func isLibraryPath(_ path: String) -> Bool {
        ["/Movies/", "/Pictures/", "/Music/", "/Documents/", "/Animation/"]
            .contains { path.localizedCaseInsensitiveContains($0) }
    }
}
