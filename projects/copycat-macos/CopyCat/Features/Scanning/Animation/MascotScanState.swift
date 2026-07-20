import Foundation
import CopyCatEngine

/// Presentation-only scan state for the mascot scanning UI.
/// Derived from live `ScanProgress` / cancellation / errors — never drives the engine.
enum MascotScanState: Equatable {
    case idle
    case searching
    case duplicateFound
    case completed
    case cancelled
    case failed
}

enum MascotScanStateMapping {
    /// Maps production scan progress + optional duplicate-reaction flag into mascot state.
    static func state(
        phase: ScanPhase,
        isScanning: Bool,
        isShowingDuplicateReaction: Bool
    ) -> MascotScanState {
        switch phase {
        case .cancelled:
            return .cancelled
        case .failed:
            return .failed
        case .finished:
            return .completed
        case .idle:
            return isScanning ? .searching : .idle
        case .enumerating, .grouping, .hashing, .classifying:
            if isShowingDuplicateReaction {
                return .duplicateFound
            }
            return .searching
        }
    }

    /// Prefer engine progress messages (two-pass labels); fall back to phase defaults.
    static func phaseLabel(
        _ phase: ScanPhase,
        message: String? = nil,
        groupsFound: Int = 0
    ) -> String {
        if let message, !message.isEmpty {
            return message
        }
        switch phase {
        case .idle: return "Ready"
        case .enumerating: return ScanProgressLabels.indexingFileSizes
        case .grouping: return ScanProgressLabels.collectingDuplicateCandidates
        case .hashing:
            return groupsFound > 0 ? ScanProgressLabels.fullHashing : ScanProgressLabels.partialHashing
        case .classifying: return ScanProgressLabels.preparingResults
        case .finished: return "Completed"
        case .cancelled: return "Cancelled"
        case .failed: return "Failed"
        }
    }

    static func headline(for state: MascotScanState) -> String {
        switch state {
        case .idle:
            return "Ready to scan"
        case .searching:
            return "CopyCat is searching…"
        case .duplicateFound:
            return "Found a twin!"
        case .completed:
            return "All done"
        case .cancelled:
            return "Scan cancelled"
        case .failed:
            return "Scan failed"
        }
    }

    static func subtitle(for state: MascotScanState) -> String {
        switch state {
        case .idle:
            return "Choose folders to begin."
        case .searching:
            return "Scanning your files for exact duplicates."
        case .duplicateFound:
            return "Exact match confirmed — continuing quietly."
        case .completed:
            return "Your results are ready."
        case .cancelled:
            return "Nothing was changed on your Mac."
        case .failed:
            return "Something went wrong while scanning."
        }
    }
}
