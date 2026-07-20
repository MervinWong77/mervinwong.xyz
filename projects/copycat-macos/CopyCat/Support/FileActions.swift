import AppKit
import Foundation

@MainActor
enum FileActions {
    static func revealInFinder(_ url: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    static func open(_ url: URL) {
        NSWorkspace.shared.open(url)
    }

    static func copyPath(_ url: URL) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(url.path, forType: .string)
    }

    static func quickLook(_ url: URL) {
        QuickLookPresenter.shared.preview(urls: [url])
    }

    static func quickLook(urls: [URL], startingAt url: URL? = nil) {
        QuickLookPresenter.shared.preview(urls: urls, startingAt: url)
    }
}
