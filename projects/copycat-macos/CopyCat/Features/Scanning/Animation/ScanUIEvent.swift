import Foundation

/// Lightweight UI events published for the scanning experience.
/// Independent from `CopyCatEngine` — the engine never waits on these.
enum ScanUIEvent: Sendable, Equatable {
    case scanningStarted
    case phaseChanged(label: String)
    case progress(
        filesChecked: Int,
        bytesScanned: UInt64,
        duplicateGroups: Int,
        currentFolder: String?
    )
    case exactDuplicateFound(totalGroups: Int)
    case scanCompleted
    case scanCancelled
    case scanFailed
}
