import AppKit
import SwiftUI

struct FolderSelectionView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("CopyCat")
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(BrandColor.teal)
                Text("Find exact duplicate files on your Mac. Nothing is deleted automatically.")
                    .foregroundStyle(.secondary)
            }

            GroupBox("Folders to scan") {
                VStack(alignment: .leading, spacing: 12) {
                    if model.selectedFolders.isEmpty {
                        Text("Add one or more folders or drives to begin.")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 24)
                    } else {
                        List {
                            ForEach(model.selectedFolders, id: \.self) { url in
                                HStack {
                                    Image(systemName: "folder")
                                    Text(url.path)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                    Spacer()
                                    Button("Remove") {
                                        model.removeFolder(url)
                                    }
                                    .buttonStyle(.borderless)
                                }
                            }
                        }
                        .frame(minHeight: 160)
                    }

                    HStack {
                        Button("Add Folder…") {
                            presentFolderPicker()
                        }
                        .accessibilityIdentifier("addFolderButton")
                        Spacer()
                        Button("Start Scan") {
                            model.startScan()
                        }
                        .accessibilityIdentifier("startScanButton")
                        .keyboardShortcut(.defaultAction)
                        .disabled(model.selectedFolders.isEmpty)
                    }
                }
                .padding(8)
            }

            Text("Default exclusions: Library, Applications, .git, node_modules, .next, DerivedData, Caches, .Trash")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Text("Tip: start with a small folder. Whole-home or whole-drive scans can still be heavy.")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Button("Open scanning animation prototype") {
                openWindow(id: "scanning-prototype")
            }
            .buttonStyle(.link)
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func presentFolderPicker() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true
        panel.canCreateDirectories = false
        panel.prompt = "Add"
        panel.message = "Choose folders or drives to scan for exact duplicates."

        if panel.runModal() == .OK {
            model.addFolders(panel.urls)
        }
    }
}
