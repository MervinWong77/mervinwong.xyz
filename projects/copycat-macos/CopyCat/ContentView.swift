import SwiftUI

struct ContentView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        Group {
            switch model.screen {
            case .folderSelection:
                HomeView()
            case .scanning:
                ScanProgressView()
                #if DEBUG
                    .safeAreaInset(edge: .bottom) {
                        // Debug-only; not part of the production hierarchy.
                        ScanDiagnosticsDebugPanel()
                            .padding(.horizontal, 24)
                            .padding(.bottom, 8)
                    }
                #endif
            case .review:
                DuplicateReviewView()
            case .finished:
                CleanupFinishedView()
            case .settings:
                SettingsView()
            }
        }
        // Single window contract — never changes across screen transitions.
        .frame(
            minWidth: CopyCatWindow.minWidth,
            minHeight: CopyCatWindow.minHeight
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert("Scan Error", isPresented: Binding(
            get: { model.errorMessage != nil },
            set: { if !$0 { model.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(model.errorMessage ?? "")
        }
    }
}

#Preview {
    ContentView()
        .environment(AppModel())
}
