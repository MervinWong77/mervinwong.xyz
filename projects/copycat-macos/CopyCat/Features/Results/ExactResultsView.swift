import AppKit
import SwiftUI
import CopyCatEngine

struct ExactResultsView: View {
    @Environment(AppModel.self) private var model

    private var totalRecoverable: UInt64 {
        model.groups.reduce(0) { $0 + $1.recoverableBytes }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Exact Duplicates")
                        .font(.title2.weight(.semibold))
                    Text("\(model.groups.count) groups · \(formattedBytes(totalRecoverable)) recoverable")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("New Scan") {
                    model.resetToFolderSelection()
                }
                .accessibilityIdentifier("newScanButton")
            }
            .padding(20)

            Divider()

            if model.groups.isEmpty {
                ContentUnavailableView(
                    "No exact duplicates",
                    systemImage: "checkmark.seal",
                    description: Text("CopyCat did not find any files with identical content in the selected folders.")
                )
            } else {
                List {
                    ForEach(model.groups) { group in
                        Section {
                            ForEach(group.files) { file in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(file.filename)
                                        .font(.body.weight(.medium))
                                    Text(file.url.deletingLastPathComponent().path)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                    Text(formattedBytes(file.size))
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                }
                                .padding(.vertical, 2)
                                .contextMenu {
                                    Button("Reveal in Finder") {
                                        NSWorkspace.shared.activateFileViewerSelecting([file.url])
                                    }
                                    Button("Copy Path") {
                                        NSPasteboard.general.clearContents()
                                        NSPasteboard.general.setString(file.url.path, forType: .string)
                                    }
                                }
                            }
                        } header: {
                            HStack {
                                Text(group.title)
                                Spacer()
                                Text("EXACT")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                Text(formattedBytes(group.recoverableBytes))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } footer: {
                            Text(group.reasons.map(\.rawValue).joined(separator: " · "))
                                .font(.caption2)
                        }
                    }
                }
                .listStyle(.inset)
            }
        }
    }
}
