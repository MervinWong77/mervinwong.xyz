import AppKit
import Foundation
import Observation
import CopyCatEngine

enum AppScreen: Equatable {
    case folderSelection
    case scanning
    case review
    case finished
    case settings
}

@Observable
@MainActor
final class AppModel {
    var screen: AppScreen = .folderSelection
    var selectedFolders: [URL] = []
    /// Home preference: skip files under 1 MB during scan.
    var ignoreSmallFiles = false
    var progress = ScanProgress()
    var groups: [DuplicateGroup] = []
    var errorMessage: String?
    var isScanning = false
    /// True after user requests cancel until the engine reports a terminal event (or a new scan starts).
    private(set) var cancelRequested = false
    /// DEBUG developer metrics only — never shown in release UI.
    var diagnostics: ScanDiagnostics?

    let review = ReviewSession()
    /// Shared flag so menu commands and the review toolbar can present the same Trash confirm sheet.
    var showCleanupConfirm = false
    /// Advanced bulk confirm (separate from per-group confirm).
    var showAdvancedBulkConfirm = false

    /// In-app undo for the most recent Trash action (~10 seconds).
    private(set) var pendingTrashUndo: PendingTrashUndo?
    private var undoClearTask: Task<Void, Never>?

    /// Shown when Undo cannot restore because the original path is occupied.
    var occupiedRestorePrompt: OccupiedRestorePrompt?

    struct OccupiedRestorePrompt: Identifiable {
        let id = UUID()
        let items: [TrashedItem]
        let queueBefore: ReviewQueueSnapshot
        let otherFailures: [String]
    }

    private let coordinator = ScanCoordinator()
    private var scanTask: Task<Void, Never>?
    private var securityScopedURLs: [URL] = []
    private var scanGeneration: UInt64 = 0

    /// Coalesce high-frequency progress onto the MainActor (~10 Hz).
    private var pendingProgress: ScanProgress?
    private var lastProgressPublish: ContinuousClock.Instant?
    private let progressPublishInterval: Duration = .milliseconds(100)

    struct PendingTrashUndo: Equatable {
        let items: [TrashedItem]
        let queueBefore: ReviewQueueSnapshot
        let fileCount: Int
    }

    func addFolders(_ urls: [URL]) {
        for url in urls {
            guard !selectedFolders.contains(where: { $0.standardizedFileURL == url.standardizedFileURL }) else {
                continue
            }
            selectedFolders.append(url)
            if url.startAccessingSecurityScopedResource() {
                securityScopedURLs.append(url)
            }
        }
    }

    func removeFolder(_ url: URL) {
        selectedFolders.removeAll { $0.standardizedFileURL == url.standardizedFileURL }
        if let index = securityScopedURLs.firstIndex(where: { $0.standardizedFileURL == url.standardizedFileURL }) {
            securityScopedURLs[index].stopAccessingSecurityScopedResource()
            securityScopedURLs.remove(at: index)
        }
    }

    /// Opens the Settings screen from Home chrome.
    func openSettings() {
        screen = .settings
    }

    /// Returns from Settings to Home.
    func dismissSettings() {
        guard screen == .settings else { return }
        screen = .folderSelection
    }

    func startScan() {
        let paths = selectedFolders.map(\.path)
        #if DEBUG
        print(
            "[CopyCat DEBUG] startScan() — count=\(selectedFolders.count) paths=\(paths) screen=\(screen) isScanning=\(isScanning)"
        )
        #endif

        guard !selectedFolders.isEmpty else {
            #if DEBUG
            print("[CopyCat DEBUG] startScan rejected: no selected locations")
            #endif
            return
        }

        // Prevent double-starts from repeated clicks / Return while already leaving Home.
        guard !isScanning, screen == .folderSelection else {
            #if DEBUG
            print(
                "[CopyCat DEBUG] startScan rejected: scan already in flight (screen=\(screen) isScanning=\(isScanning))"
            )
            #endif
            return
        }

        let unavailable = selectedFolders.filter {
            !FileManager.default.fileExists(atPath: $0.path)
        }
        if !unavailable.isEmpty {
            let listed = unavailable.map(\.path).joined(separator: "\n")
            errorMessage = unavailable.count == 1
                ? "The selected path is unavailable:\n\(listed)"
                : "Some selected paths are unavailable:\n\(listed)"
            #if DEBUG
            print("[CopyCat DEBUG] startScan rejected: unavailable paths \(unavailable.map(\.path))")
            #endif
            return
        }

        scanGeneration &+= 1
        let generation = scanGeneration
        cancelRequested = false
        errorMessage = nil
        groups = []
        review.clear()
        progress = ScanProgress(phase: .enumerating)
        pendingProgress = nil
        lastProgressPublish = nil
        diagnostics = nil

        // Leave Home immediately — engine work continues asynchronously.
        screen = .scanning
        isScanning = true

        ensureSecurityScopedAccess()

        let folders = selectedFolders
        let ignoreSmall = ignoreSmallFiles

        // Cancel previous consumer + engine, then start a fresh stream.
        // Do not cancel the new consumer when user hits Cancel — only cancel the engine
        // so we still receive the terminal `.cancelled` event.
        let previousConsumer = scanTask
        scanTask = nil
        previousConsumer?.cancel()

        scanTask = Task { [coordinator] in
            // Keep heavy prep off the synchronous MainActor button path.
            let roots = SelectedRootNormalizer.normalize(folders)
            let config = ScanConfiguration(
                rootURLs: roots,
                minimumFileSizeBytes: ignoreSmall ? 1_048_576 : 0
            )

            await coordinator.cancel()
            guard !Task.isCancelled, generation == self.scanGeneration else { return }

            #if DEBUG
            print("[CopyCat DEBUG] startScan engine begin — roots=\(roots.map(\.path))")
            #endif

            let stream = await coordinator.scan(configuration: config)
            for await event in stream {
                guard generation == self.scanGeneration else { break }
                await MainActor.run {
                    self.handle(event, generation: generation)
                }
            }
            await MainActor.run {
                guard generation == self.scanGeneration else { return }
                self.flushPendingProgress()
                if self.isScanning {
                    // Stream ended without a handled terminal event — recover UI.
                    self.isScanning = false
                    if self.screen == .scanning {
                        self.restoreHomeAfterCancel(clearPartialResults: true)
                    }
                }
            }
        }

        #if DEBUG
        print("[CopyCat DEBUG] startScan accepted — screen=scanning, engine task scheduled")
        #endif
    }

    /// Immediately leaves the scanning UI and requests engine cancellation.
    /// Partial results are discarded. A later `.cancelled` event is ignored safely.
    func cancelScan() {
        guard screen == .scanning || isScanning else {
            Task { await coordinator.cancel() }
            return
        }

        cancelRequested = true
        scanGeneration &+= 1 // invalidate in-flight consumer handlers
        restoreHomeAfterCancel(clearPartialResults: true)

        Task {
            await coordinator.cancel()
        }
    }

    func resetToFolderSelection() {
        cancelRequested = true
        scanGeneration &+= 1
        scanTask?.cancel()
        scanTask = nil
        Task { await coordinator.cancel() }

        groups = []
        review.clear()
        clearPendingTrashUndo()
        progress = ScanProgress()
        pendingProgress = nil
        errorMessage = nil
        diagnostics = nil
        screen = .folderSelection
        isScanning = false
        cancelRequested = false
        endSecurityScopedAccess()
        ensureSecurityScopedAccess()
    }

    /// Primary path: confirm moving the current group's selection to Trash.
    func requestCurrentGroupCleanup() {
        guard review.currentGroupDeleteCount > 0 else { return }
        showCleanupConfirm = true
    }

    /// Advanced path: confirm moving every selected delete across the remaining queue.
    func requestAdvancedBulkCleanup() {
        guard review.totalSelectedDeleteCount > 0 else { return }
        showAdvancedBulkConfirm = true
    }

    func performCurrentGroupCleanup() {
        showCleanupConfirm = false
        guard let group = review.currentGroup else { return }

        let deleteItems: [(URL, UInt64)] = group.files
            .filter { $0.decision == .delete }
            .map { ($0.file.url, $0.file.size) }
        guard !deleteItems.isEmpty else { return }

        let queueBefore = review.queueSnapshot()
        ensureSecurityScopedAccess()

        let sizes = Dictionary(uniqueKeysWithValues: deleteItems.map { ($0.0.standardizedFileURL, $0.1) })
        let result = CleanupService.moveToTrash(
            urls: deleteItems.map(\.0),
            byteSizes: sizes
        )

        reportCleanupFailures(result)
        // Only count bytes/files that actually landed in Trash.
        guard !result.items.isEmpty else { return }

        let intended = Set(deleteItems.map { $0.0.standardizedFileURL })
        let trashed = Set(result.items.map { $0.originalURL.standardizedFileURL })

        // Never remove the group unless every selected delete succeeded.
        if trashed == intended {
            review.removeCurrentGroupAfterTrash(
                recoveredBytes: result.recoveredBytes,
                fileCount: result.items.count
            )
        } else {
            review.applyBulkTrash(urls: trashed, recoveredBytes: result.recoveredBytes)
        }

        presentTrashUndo(PendingTrashUndo(
            items: result.items,
            queueBefore: queueBefore,
            fileCount: result.items.count
        ))

        finishReviewIfQueueEmpty()
    }

    func performAdvancedBulkCleanup() {
        showAdvancedBulkConfirm = false

        let deleteItems: [(URL, UInt64)] = review.groups.flatMap { group in
            group.files
                .filter { $0.decision == .delete }
                .map { ($0.file.url, $0.file.size) }
        }
        guard !deleteItems.isEmpty else { return }

        let queueBefore = review.queueSnapshot()
        ensureSecurityScopedAccess()

        let sizes = Dictionary(uniqueKeysWithValues: deleteItems.map { ($0.0.standardizedFileURL, $0.1) })
        let result = CleanupService.moveToTrash(
            urls: deleteItems.map(\.0),
            byteSizes: sizes
        )

        reportCleanupFailures(result)
        guard !result.items.isEmpty else { return }

        review.applyBulkTrash(
            urls: Set(result.items.map { $0.originalURL.standardizedFileURL }),
            recoveredBytes: result.recoveredBytes
        )

        presentTrashUndo(PendingTrashUndo(
            items: result.items,
            queueBefore: queueBefore,
            fileCount: result.items.count
        ))

        finishReviewIfQueueEmpty()
    }

    func undoLastTrash() {
        guard let pending = pendingTrashUndo else { return }
        clearPendingTrashUndo()

        ensureSecurityScopedAccess()
        let restore = CleanupService.restoreFromTrash(items: pending.items)

        let occupied = restore.occupiedItems
        let otherMessages = restore.failures.compactMap { failure -> String? in
            if case .other(let message) = failure.reason {
                return "\(failure.item.originalURL.lastPathComponent): \(message)"
            }
            return nil
        }

        if !occupied.isEmpty {
            // Do not overwrite. Offer an explicit recovery choice.
            occupiedRestorePrompt = OccupiedRestorePrompt(
                items: occupied,
                queueBefore: pending.queueBefore,
                otherFailures: otherMessages
            )
            // Still restore queue if anything made it back; occupied files stay in Trash.
            if !restore.restoredURLs.isEmpty {
                review.restoreQueue(from: pending.queueBefore)
                if screen == .finished { screen = .review }
            }
            return
        }

        if !otherMessages.isEmpty {
            var message = otherMessages.prefix(5).joined(separator: "\n")
            if otherMessages.count > 5 {
                message += "\n…and \(otherMessages.count - 5) more"
            }
            review.cleanupErrorMessage = "Could not undo all files:\n\(message)"
        }

        guard !restore.restoredURLs.isEmpty else { return }

        review.restoreQueue(from: pending.queueBefore)
        if screen == .finished {
            screen = .review
        }
    }

    /// Reveal occupied originals' Trash copies in Finder.
    func revealOccupiedRestoreInTrash() {
        guard let prompt = occupiedRestorePrompt else { return }
        let urls = prompt.items.map(\.trashURL)
        if !urls.isEmpty {
            NSWorkspace.shared.activateFileViewerSelecting(urls)
        }
        occupiedRestorePrompt = nil
        if !prompt.otherFailures.isEmpty {
            review.cleanupErrorMessage = prompt.otherFailures.joined(separator: "\n")
        }
    }

    /// Restore occupied items beside the original (or into a chosen folder).
    func restoreOccupiedBesideOriginal() {
        guard let prompt = occupiedRestorePrompt else { return }
        ensureSecurityScopedAccess()
        var restoredAny = false
        var failures: [String] = prompt.otherFailures
        for item in prompt.items {
            let directory = item.originalURL.deletingLastPathComponent()
            let result = CleanupService.restoreToDirectory(item, directory: directory)
            if !result.restoredURLs.isEmpty {
                restoredAny = true
            }
            for failure in result.failures {
                if case .other(let message) = failure.reason {
                    failures.append("\(failure.item.originalURL.lastPathComponent): \(message)")
                }
            }
        }
        occupiedRestorePrompt = nil
        if restoredAny {
            review.restoreQueue(from: prompt.queueBefore)
            if screen == .finished { screen = .review }
        }
        if !failures.isEmpty {
            review.cleanupErrorMessage = failures.joined(separator: "\n")
        }
    }

    func dismissOccupiedRestorePrompt() {
        occupiedRestorePrompt = nil
    }

    private func finishReviewIfQueueEmpty() {
        guard review.groups.isEmpty else { return }
        // Keep pendingTrashUndo briefly so Undo / ⌘Z still works from the finished screen.
        screen = .finished
    }

    private func presentTrashUndo(_ pending: PendingTrashUndo) {
        undoClearTask?.cancel()
        pendingTrashUndo = pending
        undoClearTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(10))
            guard !Task.isCancelled else { return }
            if self.pendingTrashUndo == pending {
                self.pendingTrashUndo = nil
            }
        }
    }

    private func clearPendingTrashUndo() {
        undoClearTask?.cancel()
        undoClearTask = nil
        pendingTrashUndo = nil
    }

    private func reportCleanupFailures(_ result: CleanupResult) {
        guard !result.failures.isEmpty else { return }
        let lines = result.failures.prefix(5).map { "\($0.url.lastPathComponent): \($0.message)" }
        var message = lines.joined(separator: "\n")
        if result.failures.count > 5 {
            message += "\n…and \(result.failures.count - 5) more"
        }
        if result.items.isEmpty {
            review.cleanupErrorMessage = message
        } else {
            review.cleanupErrorMessage = "Some files could not be moved to Trash:\n\(message)"
        }
    }

    func revealFocusedInFinder() {
        guard let group = review.currentGroup,
              let url = group.keepFile?.file.url ?? group.files.first?.file.url else { return }
        FileActions.revealInFinder(url)
    }

    // MARK: - Event handling

    private func handle(_ event: ScanEvent, generation: UInt64) {
        guard generation == scanGeneration else { return }

        // After an explicit cancel, ignore late progress / finished from the dying scan.
        if cancelRequested {
            switch event {
            case .cancelled, .failed:
                cancelRequested = false
                isScanning = false
            case .finished:
                // Cancel won the race — discard results.
                cancelRequested = false
                isScanning = false
                groups = []
                review.clear()
            case .progress, .performance, .diagnostics, .groupsUpdated:
                return
            }
            return
        }

        switch event {
        case .progress(let progress):
            publishProgress(progress, force: false)
        case .performance(let snapshot):
            var next = pendingProgress ?? self.progress
            next.performance = snapshot
            publishProgress(next, force: false)
        case .diagnostics(let snapshot):
            self.diagnostics = snapshot
        case .groupsUpdated(let groups):
            flushPendingProgress()
            self.groups = groups
        case .finished(let groups, let progress):
            flushPendingProgress()
            self.groups = groups
            self.progress = progress
            self.isScanning = false
            review.load(from: groups)
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(1100))
                guard self.scanGeneration == generation else { return }
                guard self.screen == .scanning, !self.cancelRequested else { return }
                self.screen = .review
            }
        case .cancelled(let progress):
            flushPendingProgress()
            self.progress = progress
            self.isScanning = false
            // Spec: discard partial results; return Home.
            restoreHomeAfterCancel(clearPartialResults: true)
        case .failed(let message, let progress):
            flushPendingProgress()
            self.progress = progress
            self.errorMessage = message
            self.isScanning = false
            self.groups = []
            self.review.clear()
            self.screen = .folderSelection
            #if DEBUG
            print("[CopyCat DEBUG] scan failed — \(message)")
            #endif
        }
    }

    private func restoreHomeAfterCancel(clearPartialResults: Bool) {
        if clearPartialResults {
            groups = []
            review.clear()
        }
        pendingProgress = nil
        progress = ScanProgress(phase: .cancelled, message: "Scan cancelled")
        diagnostics = nil
        isScanning = false
        screen = .folderSelection
    }

    private func publishProgress(_ progress: ScanProgress, force: Bool) {
        let now = ContinuousClock.now
        if !force, let last = lastProgressPublish, now - last < progressPublishInterval {
            pendingProgress = progress
            return
        }
        lastProgressPublish = now
        pendingProgress = nil
        self.progress = progress
    }

    private func flushPendingProgress() {
        if let pendingProgress {
            self.progress = pendingProgress
            self.pendingProgress = nil
            lastProgressPublish = .now
        }
    }

    private func ensureSecurityScopedAccess() {
        let already = Set(securityScopedURLs.map(\.standardizedFileURL))
        for url in selectedFolders {
            let standard = url.standardizedFileURL
            guard !already.contains(standard) else { continue }
            if url.startAccessingSecurityScopedResource() {
                securityScopedURLs.append(url)
            }
        }
    }

    private func endSecurityScopedAccess() {
        for url in securityScopedURLs {
            url.stopAccessingSecurityScopedResource()
        }
        securityScopedURLs = []
    }

    #if DEBUG
    /// Stages post-cleanup UI without touching the filesystem (snapshot export).
    func debugSimulateCurrentGroupCleanupSuccess(recoveredBytes: UInt64, fileCount: Int) {
        let queueBefore = review.queueSnapshot()
        let fakeItems = (review.currentGroup?.files ?? [])
            .filter { $0.decision == .delete }
            .prefix(fileCount)
            .map {
                TrashedItem(
                    originalURL: $0.file.url,
                    trashURL: URL(fileURLWithPath: "/Users/demo/.Trash/\($0.file.filename)"),
                    byteSize: $0.file.size
                )
            }
        review.removeCurrentGroupAfterTrash(recoveredBytes: recoveredBytes, fileCount: fileCount)
        presentTrashUndo(PendingTrashUndo(
            items: Array(fakeItems),
            queueBefore: queueBefore,
            fileCount: fileCount
        ))
        screen = .review
    }

    func debugSimulateAllGroupsResolved(
        recoveredBytes: UInt64,
        fileCount: Int,
        reviewedGroups: Int,
        withUndo: Bool = false
    ) {
        let queueBefore = review.queueSnapshot()
        let fakeItems = (queueBefore.groups.first?.files ?? [])
            .filter { $0.decision == .delete }
            .prefix(max(fileCount, 1))
            .map {
                TrashedItem(
                    originalURL: $0.file.url,
                    trashURL: URL(fileURLWithPath: "/Users/demo/.Trash/\($0.file.filename)"),
                    byteSize: $0.file.size
                )
            }

        review.restoreQueue(from: ReviewQueueSnapshot(
            groups: [],
            currentIndex: 0,
            reviewedGroupCount: reviewedGroups,
            totalRecoveredBytes: recoveredBytes,
            totalRecoveredFileCount: fileCount
        ))
        screen = .finished

        if withUndo {
            presentTrashUndo(PendingTrashUndo(
                items: Array(fakeItems),
                queueBefore: queueBefore,
                fileCount: min(fileCount, max(fakeItems.count, 1))
            ))
        }
    }

    func debugRestoreQueueFromPendingUndo() {
        guard let pending = pendingTrashUndo else { return }
        clearPendingTrashUndo()
        review.restoreQueue(from: pending.queueBefore)
        screen = .review
    }
    #endif
}
