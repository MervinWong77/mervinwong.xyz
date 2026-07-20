import SwiftUI

/// Isolated scanning-screen prototype for design review (not wired to the engine).
struct ScanningScreenPrototypeView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var director = ScanAnimationDirector()
    @State private var simulatorTask: Task<Void, Never>?
    var showsSimulatorControls: Bool = true
    var compact: Bool = false

    var body: some View {
        ZStack {
            ScanMaterialBackground()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: ScanDesign.Spacing.xl) {
                        hero
                        metrics
                    }
                    .frame(maxWidth: ScanDesign.contentMaxWidth)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, compact ? ScanDesign.Spacing.md : ScanDesign.Spacing.xl)
                    .padding(.top, compact ? ScanDesign.Spacing.md : ScanDesign.Spacing.xl)
                    .padding(.bottom, ScanDesign.Spacing.lg)
                }

                if showsSimulatorControls {
                    controls
                }
            }
        }
        .onDisappear {
            simulatorTask?.cancel()
            director.reset()
        }
    }

    private var hero: some View {
        VStack(spacing: ScanDesign.Spacing.lg) {
            ScanningMascotSceneView(director: director, reduceMotion: reduceMotion)
                .frame(height: compact ? 180 : ScanDesign.heroHeight)
                .frame(maxWidth: .infinity)
                .scanSurface(cornerRadius: ScanDesign.Radius.hero)

            VStack(spacing: ScanDesign.Spacing.sm) {
                Text(director.mode == .completed
                     ? "Found \(director.duplicateGroups) duplicate groups"
                     : "CopyCat is searching…")
                    .font(compact ? .title.weight(.semibold) : ScanDesign.TypeScale.heroTitle)
                    .foregroundStyle(BrandColor.ink)
                    .multilineTextAlignment(.center)

                Text("Scanning your files for exact duplicates.")
                    .font(ScanDesign.TypeScale.heroSubtitle)
                    .foregroundStyle(BrandColor.muted)
                    .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: ScanDesign.Spacing.xs) {
                    HStack {
                        Text("Current phase")
                            .font(ScanDesign.TypeScale.phase)
                            .foregroundStyle(BrandColor.muted)
                        Text(director.phaseLabel)
                            .font(ScanDesign.TypeScale.phase)
                            .foregroundStyle(BrandColor.teal)
                        Spacer(minLength: 0)
                    }
                    ProgressView(value: progressValue)
                        .tint(BrandColor.teal)
                        .controlSize(.small)
                }
                .frame(maxWidth: 420)
                .padding(.top, ScanDesign.Spacing.xs)
            }
        }
    }

    private var metrics: some View {
        VStack(spacing: ScanDesign.Spacing.md) {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: ScanDesign.Spacing.md), count: 4),
                spacing: ScanDesign.Spacing.md
            ) {
                ScanMetricCard(icon: "square.on.square", label: "Duplicates", value: "\(director.duplicateGroups)", emphasize: director.duplicateGroups > 0)
                ScanMetricCard(icon: "internaldrive", label: "Recoverable", value: "—")
                ScanMetricCard(icon: "doc.on.doc", label: "Files checked", value: director.filesChecked.formatted())
                ScanMetricCard(icon: "externaldrive", label: "Data scanned", value: formattedBytes(director.bytesScanned))
            }
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: ScanDesign.Spacing.md), count: 4),
                spacing: ScanDesign.Spacing.md
            ) {
                ScanMetricCard(icon: "memorychip", label: "Memory", value: "129 MB")
                ScanMetricCard(icon: "speedometer", label: "Speed", value: "1124/s")
                ScanMetricCard(icon: "folder", label: "Folder", value: director.currentFolder ?? "Downloads")
                ScanMetricCard(icon: "leaf", label: "Mode", value: "Balanced")
            }
        }
    }

    private var progressValue: Double {
        switch director.mode {
        case .completed: return 1
        case .cancelled: return 0
        default:
            return min(0.95, 0.15 + Double(director.filesChecked) / 120_000)
        }
    }

    private var controls: some View {
        HStack(spacing: 12) {
            ScanStatusPill(icon: "leaf.fill", text: "Balanced")
            ScanStatusPill(icon: "memorychip", text: "129 MB")
            ScanStatusPill(icon: "speedometer", text: "1124 files/sec")
            Spacer()
            Button(director.isScanning ? "Running…" : "Simulate Scan") {
                startSimulation()
            }
            .disabled(director.isScanning)
            .keyboardShortcut(.defaultAction)

            Button("Inject Duplicate") {
                director.handle(.exactDuplicateFound(totalGroups: director.duplicateGroups + 1))
            }
            .disabled(!director.isScanning)

            Button("Cancel Scan") {
                simulatorTask?.cancel()
                director.handle(.scanCancelled)
            }
            .disabled(!director.isScanning)
        }
        .padding(.horizontal, ScanDesign.Spacing.xl)
        .padding(.vertical, ScanDesign.Spacing.md)
        .background {
            Rectangle()
                .fill(.bar)
                .overlay(alignment: .top) { Divider() }
        }
    }

    private func startSimulation() {
        simulatorTask?.cancel()
        director.reset()
        director.handle(.scanningStarted)
        simulatorTask = Task { @MainActor in
            let phases = [
                ("Indexing file sizes…", 0.2),
                ("Collecting candidates…", 0.35),
                ("Partial hashing", 0.55),
                ("Full hashing", 0.8)
            ]
            var files = 0
            var groups = 0
            for (label, _) in phases {
                guard !Task.isCancelled else { return }
                director.handle(.phaseChanged(label: label))
                for _ in 0..<8 {
                    guard !Task.isCancelled else { return }
                    files += Int.random(in: 2_000...6_000)
                    director.handle(.progress(
                        filesChecked: files,
                        bytesScanned: UInt64(files) * 110_000,
                        duplicateGroups: groups,
                        currentFolder: "Downloads"
                    ))
                    if Bool.random() && groups < 12 {
                        groups += 1
                        director.handle(.exactDuplicateFound(totalGroups: groups))
                    }
                    try? await Task.sleep(for: .milliseconds(280))
                }
            }
            director.handle(.scanCompleted)
        }
    }
}
