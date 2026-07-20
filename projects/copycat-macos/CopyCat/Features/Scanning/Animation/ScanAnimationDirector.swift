import Foundation
import Observation

/// Directs scanning-screen animation from UI events.
/// Never blocks or throttles the real scanner — only visual reactions are paced.
@Observable
@MainActor
final class ScanAnimationDirector {
    enum SceneMode: Equatable {
        case idlePlay
        case duplicateReaction
        case completed
        case cancelled
    }

    private(set) var mode: SceneMode = .idlePlay
    private(set) var phaseLabel: String = "Ready"
    private(set) var filesChecked: Int = 0
    private(set) var bytesScanned: UInt64 = 0
    private(set) var duplicateGroups: Int = 0
    private(set) var currentFolder: String?
    private(set) var isScanning: Bool = false
    private(set) var reactionToken: Int = 0

    /// When true, skip motion-heavy loops and swipe choreography.
    var reduceMotion: Bool = false

    /// Minimum spacing between duplicate visual reactions.
    var reactionInterval: Duration = .seconds(1.5)

    private var lastReactionAt: ContinuousClock.Instant?
    private var pendingReactions: Int = 0
    private var drainTask: Task<Void, Never>?
    private var lastEmittedGroupCount: Int = 0

    func handle(_ event: ScanUIEvent) {
        switch event {
        case .scanningStarted:
            isScanning = true
            mode = .idlePlay
            phaseLabel = "Enumerating"
            lastEmittedGroupCount = 0
            filesChecked = 0
            bytesScanned = 0
            duplicateGroups = 0
            currentFolder = nil
            pendingReactions = 0
        case .phaseChanged(let label):
            phaseLabel = label
        case .progress(let files, let bytes, let groups, let folder):
            filesChecked = files
            bytesScanned = bytes
            duplicateGroups = groups
            currentFolder = folder
        case .exactDuplicateFound(let total):
            duplicateGroups = total
            if total > lastEmittedGroupCount {
                lastEmittedGroupCount = total
                if !reduceMotion {
                    enqueueReaction()
                }
            }
        case .scanCompleted:
            isScanning = false
            phaseLabel = "Finished"
            pendingReactions = 0
            drainTask?.cancel()
            drainTask = nil
            mode = reduceMotion ? .idlePlay : .completed
        case .scanCancelled:
            isScanning = false
            phaseLabel = "Cancelled"
            pendingReactions = 0
            drainTask?.cancel()
            drainTask = nil
            mode = .cancelled
        case .scanFailed:
            isScanning = false
            phaseLabel = "Failed"
            pendingReactions = 0
            drainTask?.cancel()
            drainTask = nil
            mode = .cancelled
        }
    }

    /// Maps engine group-count increases into throttled visual reactions.
    func noteExactGroupsConfirmed(_ total: Int) {
        guard total > lastEmittedGroupCount else {
            duplicateGroups = max(duplicateGroups, total)
            return
        }
        handle(.exactDuplicateFound(totalGroups: total))
    }

    private func enqueueReaction() {
        pendingReactions += 1
        drainReactionsIfNeeded()
    }

    private func drainReactionsIfNeeded() {
        guard !reduceMotion else {
            pendingReactions = 0
            return
        }
        guard drainTask == nil else { return }
        drainTask = Task { @MainActor in
            while pendingReactions > 0 && !Task.isCancelled && isScanning {
                let now = ContinuousClock.now
                if let last = lastReactionAt {
                    let elapsed = last.duration(to: now)
                    if elapsed < reactionInterval {
                        try? await Task.sleep(for: reactionInterval - elapsed)
                    }
                }

                guard pendingReactions > 0, !Task.isCancelled else { break }
                pendingReactions -= 1
                // Coalesce a burst into a single visual beat.
                pendingReactions = 0
                lastReactionAt = .now
                reactionToken &+= 1
                mode = .duplicateReaction

                try? await Task.sleep(for: .milliseconds(1600))
                if mode == .duplicateReaction {
                    mode = .idlePlay
                }
            }
            drainTask = nil
        }
    }

    func reset() {
        drainTask?.cancel()
        drainTask = nil
        pendingReactions = 0
        lastReactionAt = nil
        mode = .idlePlay
        phaseLabel = "Ready"
        filesChecked = 0
        bytesScanned = 0
        duplicateGroups = 0
        currentFolder = nil
        lastEmittedGroupCount = 0
        isScanning = false
        reactionToken = 0
    }
}
