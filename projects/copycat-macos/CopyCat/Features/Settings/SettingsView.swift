import SwiftUI

/// Polished native-feeling settings — preferences only, no new product features.
struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @State private var section: Section

    init(initialSection: Section = .general) {
        _section = State(initialValue: initialSection)
    }

    enum Section: String, CaseIterable, Identifiable {
        case general = "General"
        case scanning = "Scanning"
        case duplicates = "Duplicates"
        case safety = "Safety"
        case advanced = "Advanced"
        case about = "About"

        var id: String { rawValue }

        var systemImage: String {
            switch self {
            case .general: return "gearshape"
            case .scanning: return "magnifyingglass"
            case .duplicates: return "square.on.square"
            case .safety: return "checkmark.shield"
            case .advanced: return "slider.horizontal.3"
            case .about: return "info.circle"
            }
        }
    }

    var body: some View {
        CopyCatAppShell(
            showSettings: false,
            showAtmosphere: false,
            trailing: AnyView(
                CopyCatSecondaryButton(title: "Done") {
                    model.dismissSettings()
                }
            )
        ) {
            HStack(alignment: .top, spacing: 0) {
                sidebar
                    .frame(width: 220)
                    .padding(.vertical, 8)

                detail
                    .padding(.leading, 32)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Section.allCases) { item in
                Button {
                    section = item
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: item.systemImage)
                            .font(.system(size: 13, weight: .medium))
                            .frame(width: 18)
                        Text(item.rawValue)
                            .font(.system(size: 13, weight: section == item ? .semibold : .regular))
                        Spacer(minLength: 0)
                    }
                    .foregroundStyle(section == item ? CopyCatChrome.textPrimary : CopyCatChrome.textSecondary)
                    .padding(.horizontal, 12)
                    .frame(height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: CopyCatChrome.radius10, style: .continuous)
                            .fill(section == item ? CopyCatChrome.primary.opacity(0.14) : .clear)
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(CopyCatChrome.surface)
        .clipShape(RoundedRectangle(cornerRadius: CopyCatChrome.radius16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: CopyCatChrome.radius16, style: .continuous)
                .strokeBorder(CopyCatChrome.border.opacity(0.7), lineWidth: 1)
        }
    }

    @ViewBuilder
    private var detail: some View {
        switch section {
        case .general:
            settingsGroup("General") {
                toggleRow(
                    "Ignore files under 1 MB",
                    subtitle: "Skips tiny files during scans to finish faster.",
                    isOn: Binding(
                        get: { model.ignoreSmallFiles },
                        set: { model.ignoreSmallFiles = $0 }
                    )
                )
            }
        case .scanning:
            settingsGroup("Scanning") {
                infoRow("Exact duplicates only", "CopyCat compares file content with SHA-256. Similar photos are not matched yet.")
                infoRow("Default exclusions", "Library, Applications, .git, node_modules, Caches, and Trash are skipped.")
            }
        case .duplicates:
            settingsGroup("Duplicates") {
                infoRow("Keep recommendation", "CopyCat suggests a keep copy based on location and recency. You always decide.")
                infoRow("One group at a time", "Review focuses on a single duplicate group so decisions stay clear.")
            }
        case .safety:
            settingsGroup("Safety") {
                infoRow("Read-only scanning", "CopyCat never deletes during a scan. Cleanup only moves files to Trash.")
                infoRow("Undo window", "After cleanup, Undo is available briefly so you can restore mistakes.")
                infoRow("No overwrite on restore", "If a path is occupied, CopyCat asks before restoring.")
            }
        case .advanced:
            settingsGroup("Advanced") {
                infoRow("Security-scoped access", "Folders you choose stay available for the current session.")
                infoRow("Diagnostics", "Developer metrics are available in DEBUG builds only.")
            }
        case .about:
            VStack(spacing: 20) {
                CopyCatMascotStage(
                    resourceName: "CopyCatWave",
                    role: .dialog,
                    showGlow: true,
                    pawCount: 0,
                    idleMotion: true
                )
                Text("CopyCat")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(CopyCatChrome.textPrimary)
                Text("Find exact duplicate files and reclaim space — safely.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(CopyCatChrome.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 360)
                Text("Version 0.1.0")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(CopyCatChrome.textTertiary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func settingsGroup<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(CopyCatChrome.textPrimary)
            VStack(alignment: .leading, spacing: 0) {
                content()
            }
            .padding(16)
            .background(CopyCatChrome.surface)
            .clipShape(RoundedRectangle(cornerRadius: CopyCatChrome.radius16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: CopyCatChrome.radius16, style: .continuous)
                    .strokeBorder(CopyCatChrome.border.opacity(0.7), lineWidth: 1)
            }
            .frame(maxWidth: 560, alignment: .leading)
        }
    }

    private func toggleRow(_ title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(CopyCatChrome.textPrimary)
                Text(subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(CopyCatChrome.textTertiary)
            }
        }
        .toggleStyle(.switch)
        .tint(CopyCatChrome.primary)
    }

    private func infoRow(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(CopyCatChrome.textPrimary)
            Text(body)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(CopyCatChrome.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 10)
    }
}
