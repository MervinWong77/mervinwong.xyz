import SwiftUI
import CopyCatEngine

/// Production scanning — shared-frame two-region composition.
struct JourneyScanProgressView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var scanStartedAt = Date()
    @State private var tick = Date()
    @State private var isCancelling = false
    @State private var peakProgress: Double = 0
    @State private var discoveryToast: DiscoveryToastPayload?
    @State private var lastGroupsFound = 0
    @State private var toastHideTask: Task<Void, Never>?

    private struct DiscoveryToastPayload: Equatable {
        let filename: String
        let recoverableLabel: String
    }

    #if DEBUG
    private static var forceDiscoveryToastForSnapshot: Bool {
        ProcessInfo.processInfo.environment["COPYCAT_FORCE_DISCOVERY_TOAST"] == "1"
            || CopyCatSnapshotHooks.forceDiscoveryToast
    }
    #else
    private static let forceDiscoveryToastForSnapshot = false
    #endif

    var body: some View {
        CopyCatAppShell(showSettings: false, showAtmosphere: false) {
            GeometryReader { geo in
                let layout = ScanningLayout.solve(availableWidth: geo.size.width)

                HStack(alignment: .center, spacing: layout.gap) {
                    leftColumn
                        .frame(width: layout.leftWidth, alignment: .leading)
                        .layoutPriority(1)

                    rightRegion(
                        rightWidth: layout.rightWidth,
                        stageSide: layout.stageSide,
                        compactJourney: layout.compactJourney
                    )
                    .frame(width: layout.rightWidth, alignment: .center)
                    .frame(maxHeight: .infinity)
                    .layoutPriority(0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .animation(
                reduceMotion
                    ? .easeOut(duration: CopyCatMotion.fade)
                    : .easeOut(duration: CopyCatMotion.slide),
                value: discoveryToast
            )
        }
        .onAppear {
            isCancelling = false
            peakProgress = 0
            scanStartedAt = Date()
            lastGroupsFound = model.progress.groupsFound
            advanceProgress()
            #if DEBUG
            if Self.forceDiscoveryToastForSnapshot, model.progress.groupsFound >= 4 {
                discoveryToast = DiscoveryToastPayload(
                    filename: "Vacation-Final.jpg",
                    recoverableLabel: "+4.2 MB recoverable"
                )
            }
            #endif
        }
        .onDisappear {
            toastHideTask?.cancel()
            toastHideTask = nil
        }
        .onChange(of: model.progress.phase) { _, _ in advanceProgress() }
        .onChange(of: model.progress.filesSeen) { _, _ in advanceProgress() }
        .onChange(of: model.progress.groupsFound) { _, newValue in
            advanceProgress()
            handleDiscovery(groupsFound: newValue)
        }
        .onChange(of: model.progress.candidateFiles) { _, _ in advanceProgress() }
        .onChange(of: model.isScanning) { _, scanning in
            if !scanning { isCancelling = false }
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { date in
            tick = date
        }
    }

    /// Responsive two-region contract — left priority; right gets remaining width.
    private struct ScanningLayout {
        var leftWidth: CGFloat
        var rightWidth: CGFloat
        var gap: CGFloat
        var stageSide: CGFloat
        var compactJourney: Bool

        static func solve(availableWidth: CGFloat) -> ScanningLayout {
            let width = max(0, availableWidth)
            let leftMin = CopyCatWindow.scanningLeftMinWidth
            let leftIdeal = CopyCatWindow.scanningLeftIdealWidth

            var gap = CopyCatWindow.regionGapComfortable
            var compact = false
            var visible = CopyCatMascotMetrics.visibleHeight(role: .journey)
            var stage = CopyCatMascotMetrics.stageSide(visibleHeight: visible)

            // Prefer comfortable gap; tighten before compacting journey height.
            if leftMin + gap + stage > width {
                gap = CopyCatWindow.regionGapCompact
            }
            if leftMin + gap + stage > width {
                compact = true
                visible = CopyCatMascotMetrics.visibleHeight(role: .journey, compactJourney: true)
                stage = CopyCatMascotMetrics.stageSide(visibleHeight: visible)
            }

            // Left has priority up to ideal, but never steal the mascot stage reservation.
            // Any leftover width goes to the right so the mascot region fills the trailing side.
            let leftWidth = min(leftIdeal, max(leftMin, width - gap - stage))
            let rightWidth = max(stage, width - leftWidth - gap)

            return ScanningLayout(
                leftWidth: leftWidth,
                rightWidth: rightWidth,
                gap: gap,
                stageSide: stage,
                compactJourney: compact
            )
        }
    }

    private func rightRegion(
        rightWidth: CGFloat,
        stageSide: CGFloat,
        compactJourney: Bool
    ) -> some View {
        let visible = CopyCatMascotMetrics.visibleHeight(
            role: .journey,
            compactJourney: compactJourney
        )
        // Glow sizing only — does not change mascot artwork scale.
        let glowArtWidth = visible * 0.86

        return ZStack(alignment: .bottomTrailing) {
            // Independent radial glow behind the stage — not framed/clipped with the art.
            CopyCatMascotAmbientGlow(
                mascotWidth: glowArtWidth,
                visibleHeight: visible
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .allowsHitTesting(false)
            .accessibilityHidden(true)

            CopyCatMascotStage(
                resourceName: mascotResource,
                role: .journey,
                compactJourney: compactJourney,
                showGlow: false,
                pawCount: CopyCatMascotMetrics.pawTrailCount,
                idleMotion: true,
                scanMotion: true,
                reactivePawTrail: model.isScanning && !isCancelling,
                stageContentAlignment: .center
            )
            .frame(width: stageSide, height: stageSide, alignment: .center)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(.leading, CopyCatWindow.scanningMascotLeadingSafe)
            .padding(.trailing, CopyCatWindow.scanningMascotTrailingSafe)

            if let discoveryToast {
                CopyCatDiscoveryToast(
                    filename: discoveryToast.filename,
                    recoverableLabel: discoveryToast.recoverableLabel
                )
                .padding(.trailing, CopyCatWindow.scanningMascotTrailingSafe)
                .padding(.bottom, 24)
                .transition(discoveryTransition)
            } else if Self.forceDiscoveryToastForSnapshot, model.progress.groupsFound >= 4 {
                CopyCatDiscoveryToast(
                    filename: "Vacation-Final.jpg",
                    recoverableLabel: "+4.2 MB recoverable"
                )
                .padding(.trailing, CopyCatWindow.scanningMascotTrailingSafe)
                .padding(.bottom, 24)
            }
        }
        .frame(width: rightWidth)
        .frame(maxHeight: .infinity, alignment: .center)
        // No .clipped() — glow must feather freely; mascot stays in-bounds via offsets/margins.
    }

    private var discoveryTransition: AnyTransition {
        if reduceMotion {
            return .opacity
        }
        return .asymmetric(
            insertion: .offset(y: 12).combined(with: .opacity),
            removal: .opacity
        )
    }

    private var leftColumn: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(CopyCatChrome.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(subtitle)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(CopyCatChrome.textSecondary)
                .padding(.top, 12)
                .frame(maxWidth: .infinity, alignment: .leading)

            CopyCatProgressBar(value: peakProgress, width: nil, height: 10)
                .padding(.top, 28)

            VStack(alignment: .leading, spacing: 4) {
                Text("Currently checking")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(CopyCatChrome.textTertiary)
                Text(pathCaption)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(CopyCatChrome.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .padding(.top, 14)
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(alignment: .top, spacing: 16) {
                CopyCatMetric(value: model.progress.filesSeen.formatted(.number), label: "Files checked")
                CopyCatMetric(value: "\(model.progress.groupsFound)", label: "Duplicate groups")
                CopyCatMetric(value: formattedBytes(recoverableBytes), label: "Recoverable")
                CopyCatMetric(value: elapsedText, label: "Elapsed")
            }
            .padding(.top, 32)
            .frame(maxWidth: .infinity, alignment: .leading)

            CopyCatSecondaryButton(
                title: isCancelling || model.cancelRequested ? "Cancelling…" : "Cancel scan",
                isEnabled: model.isScanning || model.cancelRequested
            ) {
                isCancelling = true
                model.cancelScan()
            }
            .keyboardShortcut(.cancelAction)
            .accessibilityIdentifier("cancelScanButton")
            .padding(.top, 36)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var title: String {
        if isCancelling || model.cancelRequested { return "Stopping…" }
        switch model.progress.phase {
        case .finished:
            return model.progress.groupsFound == 0 ? "Everything looks tidy…" : "Wrapping up…"
        case .cancelled: return "Scan cancelled"
        case .failed: return "Scan failed"
        case .classifying: return "Preparing results…"
        case .hashing:
            if model.progress.message == ScanProgressLabels.fullHashing {
                return "Verifying identical files…"
            }
            return "Hunting for duplicate files…"
        case .grouping, .enumerating, .idle:
            return "Hunting for duplicate files…"
        }
    }

    private var subtitle: String {
        if model.selectedFolders.count == 1 {
            let name = model.selectedFolders[0].lastPathComponent
            return "Checking \(name.isEmpty ? model.selectedFolders[0].path : name)"
        }
        if model.selectedFolders.isEmpty { return "Checking selected locations" }
        return "Checking \(model.selectedFolders.count) locations"
    }

    private var pathCaption: String {
        if let current = model.progress.message, current.contains("/") { return current }
        if model.selectedFolders.count == 1 { return model.selectedFolders[0].path }
        if model.selectedFolders.isEmpty { return " " }
        return "\(model.selectedFolders.count) locations"
    }

    private var mascotResource: String {
        discoveryToast != nil ? "CopyCatFound" : "CopyCatSearch"
    }

    private var recoverableBytes: UInt64 {
        model.groups.reduce(UInt64(0)) { $0 + $1.recoverableBytes }
    }

    private var elapsedText: String {
        let seconds = max(0, Int(tick.timeIntervalSince(scanStartedAt)))
        return String(format: "%02d:%02d:%02d", seconds / 3600, (seconds % 3600) / 60, seconds % 60)
    }

    private func rawProgress() -> Double {
        switch model.progress.phase {
        case .idle: return 0
        case .enumerating: return min(0.28, 0.08 + Double(model.progress.filesSeen) / 200_000)
        case .grouping: return 0.32
        case .hashing:
            let candidates = max(model.progress.candidateFiles, 1)
            let hint = min(0.5, Double(model.progress.groupsFound) / Double(max(candidates / 8, 1)))
            return min(0.92, 0.36 + hint)
        case .classifying: return 0.95
        case .finished: return 1
        case .cancelled, .failed: return peakProgress
        }
    }

    private func advanceProgress() {
        peakProgress = max(peakProgress, rawProgress())
    }

    private func handleDiscovery(groupsFound: Int) {
        guard groupsFound > lastGroupsFound else {
            lastGroupsFound = groupsFound
            return
        }
        lastGroupsFound = groupsFound

        let group = model.groups.last ?? model.groups.first
        discoveryToast = DiscoveryToastPayload(
            filename: group?.files.first?.filename ?? "Duplicate file",
            recoverableLabel: group.map { "+\(formattedBytes($0.recoverableBytes)) recoverable" }
                ?? "New match found"
        )

        toastHideTask?.cancel()
        toastHideTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(CopyCatMotion.discoveryVisible))
            guard !Task.isCancelled else { return }
            discoveryToast = nil
        }
    }
}
