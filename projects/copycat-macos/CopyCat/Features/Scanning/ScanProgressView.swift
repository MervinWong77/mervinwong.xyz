import SwiftUI
import CopyCatEngine

/// Production scanning screen — thin wrapper over the polished journey UI.
struct ScanProgressView: View {
    var body: some View {
        JourneyScanProgressView()
    }
}

#Preview {
    ScanProgressView()
        .environment(AppModel())
        .frame(width: CopyCatWindow.minWidth, height: CopyCatWindow.minHeight)
}
