import AppKit
import QuickLookUI

/// Presents the system Quick Look panel for local file URLs.
@MainActor
final class QuickLookPresenter: NSObject, QLPreviewPanelDataSource, QLPreviewPanelDelegate {
    static let shared = QuickLookPresenter()

    private var urls: [URL] = []
    private var currentIndex: Int = 0

    func preview(urls: [URL], startingAt start: URL? = nil) {
        guard !urls.isEmpty else { return }
        self.urls = urls
        if let start, let index = urls.firstIndex(where: { $0.standardizedFileURL == start.standardizedFileURL }) {
            currentIndex = index
        } else {
            currentIndex = 0
        }

        guard let panel = QLPreviewPanel.shared() else { return }
        panel.dataSource = self
        panel.delegate = self
        panel.currentPreviewItemIndex = currentIndex
        panel.makeKeyAndOrderFront(nil)
        panel.reloadData()
    }

    nonisolated func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
        MainActor.assumeIsolated { urls.count }
    }

    nonisolated func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> (any QLPreviewItem)! {
        MainActor.assumeIsolated {
            guard urls.indices.contains(index) else { return nil }
            return urls[index] as NSURL
        }
    }
}
