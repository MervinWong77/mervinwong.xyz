import AppKit
import SwiftUI

struct CleanupFinishedView: View {
    @Environment(AppModel.self) private var model

    private var recovered: UInt64 { model.review.totalRecoveredBytes }
    private var count: Int { model.review.totalRecoveredFileCount }
    private var reviewedGroups: Int { model.review.reviewedGroupCount }

    var body: some View {
        CopyCatAppShell(showSettings: false, showAtmosphere: true, atmosphereAlignment: .center) {
            HStack(alignment: .center, spacing: 32) {
                VStack(spacing: 24) {
                    Spacer(minLength: 0)

                    VStack(spacing: 8) {
                        Text("All done")
                            .font(.largeTitle.weight(.semibold))
                            .foregroundStyle(CopyCatChrome.textPrimary)
                        Text(summaryLine)
                            .font(.title3)
                            .foregroundStyle(CopyCatChrome.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    Text("Files are in the macOS Trash. You can restore them from Finder if needed.")
                        .font(.callout)
                        .foregroundStyle(CopyCatChrome.textTertiary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 420)

                    if let pending = model.pendingTrashUndo {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.uturn.backward.circle.fill")
                                .foregroundStyle(CopyCatChrome.primary)
                            Text(pending.fileCount == 1
                                  ? "1 file moved to Trash"
                                  : "\(pending.fileCount) files moved to Trash")
                                .font(.callout.weight(.medium))
                                .foregroundStyle(CopyCatChrome.textPrimary)
                            Button("Undo") {
                                model.undoLastTrash()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(CopyCatChrome.primary)
                            .keyboardShortcut("z", modifiers: [.command])
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(CopyCatChrome.surface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    HStack(spacing: 12) {
                        Button("Open Trash") {
                            openTrash()
                        }
                        Button("New Scan") {
                            model.resetToFolderSelection()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(CopyCatChrome.primary)
                        .keyboardShortcut(.defaultAction)
                    }

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: 480, maxHeight: .infinity, alignment: .center)

                CopyCatMascotStage(
                    resourceName: "CopyCatProud",
                    role: .journey,
                    showGlow: true,
                    pawCount: 0,
                    idleMotion: true
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var summaryLine: String {
        let files = count == 1 ? "1 file" : "\(count) files"
        let groups = reviewedGroups == 1 ? "1 group" : "\(reviewedGroups) groups"
        return "\(files) · \(formattedBytes(recovered)) recovered · \(groups) reviewed"
    }

    private func openTrash() {
        let trash = try? FileManager.default.url(
            for: .trashDirectory,
            in: .userDomainMask,
            appropriateFor: FileManager.default.homeDirectoryForCurrentUser,
            create: false
        )
        if let trash {
            NSWorkspace.shared.open(trash)
        } else {
            NSWorkspace.shared.open(URL(fileURLWithPath: NSString(string: "~/.Trash").expandingTildeInPath))
        }
    }
}
