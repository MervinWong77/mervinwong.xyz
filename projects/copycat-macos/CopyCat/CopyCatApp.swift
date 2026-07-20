import SwiftUI
import CopyCatEngine

@main
struct CopyCatApp: App {
    @State private var model = AppModel()

    init() {
        #if DEBUG
        UISnapshotExport.runIfRequested()
        #endif
    }

    var body: some Scene {
        WindowGroup("CopyCat") {
            ContentView()
                .environment(model)
        }
        .defaultSize(width: CopyCatWindow.minWidth, height: CopyCatWindow.minHeight)
        .commands {
            CommandGroup(replacing: .newItem) {}

            CommandMenu("Review") {
                Button("Previous Duplicate") {
                    model.review.goToPreviousGroup()
                }
                .keyboardShortcut(.leftArrow, modifiers: [])
                .disabled(model.screen != .review)

                Button("Next Duplicate") {
                    model.review.goToNextGroup()
                }
                .keyboardShortcut(.rightArrow, modifiers: [])
                .disabled(model.screen != .review)

                Button("Skip Duplicate") {
                    model.review.skipCurrentGroup()
                }
                .keyboardShortcut("s", modifiers: [])
                .disabled(model.screen != .review || model.review.remainingGroupCount <= 1)

                Divider()

                Button("Reveal in Finder") {
                    model.revealFocusedInFinder()
                }
                .keyboardShortcut("r", modifiers: [.command])
                .disabled(model.screen != .review)

                Divider()

                Button("Move Selected to Trash…") {
                    model.requestCurrentGroupCleanup()
                }
                .keyboardShortcut(.delete, modifiers: [.command])
                .disabled(model.screen != .review || model.review.currentGroupDeleteCount == 0)

                Button("Undo Last Trash") {
                    model.undoLastTrash()
                }
                .keyboardShortcut("z", modifiers: [.command])
                .disabled(model.pendingTrashUndo == nil)

                Divider()

                Button("Delete All Selected…") {
                    model.requestAdvancedBulkCleanup()
                }
                .disabled(model.screen != .review || model.review.totalSelectedDeleteCount == 0)
            }
        }

        // Isolated animation prototype — open from Welcome or Window menu.
        WindowGroup("Scanning Prototype", id: "scanning-prototype") {
            ScanningPrototypeDemoView()
        }
        .defaultSize(width: 980, height: 640)
    }
}
