#if DEBUG
import SwiftUI
import CopyCatEngine

/// Debug-only Balanced scan diagnostics. Compiled out of Release.
struct ScanDiagnosticsDebugPanel: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        if model.isScanning || model.diagnostics != nil {
            DisclosureGroup("Developer Diagnostics") {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(lines, id: \.self) { line in
                        Text(line)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 6)
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 4)
            .accessibilityIdentifier("scanDiagnosticsDebugPanel")
        }
    }

    private var lines: [String] {
        model.diagnostics?.summaryLines ?? ["(waiting for samples…)"]
    }
}
#endif
