import AppKit
import SwiftUI
import UniformTypeIdentifiers

/// Home — polished production composition (workflows unchanged).
struct HomeView: View {
    @Environment(AppModel.self) private var model

    @State private var sizeByPath: [String: UInt64] = [:]
    @State private var isDropTargeted = false
    @State private var isDropzoneHovered = false

    // MARK: Centered composition (not a growing two-column split)

    /// Entire Home block — wider windows add equal outer margins.
    private static let homeContainerMaxWidth: CGFloat = 1200
    /// Left functional column target (hero through safety) on comfortable widths.
    private static let functionalColumnMaxWidth: CGFloat = 700
    /// Trailing reserve so cards clear the large hero mascot body.
    private static let mascotOverlapInset: CGFloat = 520

    /// Location card metrics — keep in sync with `CopyCatLocationCard`.
    private static let locationCardHeight: CGFloat = HomeChrome.locationCardHeight
    private static let locationCardSpacing: CGFloat = 10
    /// Visible cards before the list scrolls.
    private static let locationVisibleCount = 2

    private static var locationListScrollHeight: CGFloat {
        CGFloat(locationVisibleCount) * locationCardHeight
            + CGFloat(max(locationVisibleCount - 1, 0)) * locationCardSpacing
    }

    var body: some View {
        CopyCatAppShell(
            showSettings: true,
            onSettings: { model.openSettings() },
            showAtmosphere: true,
            atmosphereAlignment: .topTrailing
        ) {
            GeometryReader { geo in
                let containerWidth = min(
                    Self.homeContainerMaxWidth,
                    max(0, geo.size.width)
                )
                let interactiveWidth = min(
                    Self.functionalColumnMaxWidth,
                    max(0, containerWidth - Self.mascotOverlapInset)
                )
                let narrowHome = geo.size.width + CopyCatWindow.horizontalInset * 2 < CopyCatWindow.minWidth

                ZStack(alignment: .topLeading) {
                    // Functional column — leading within the centered container.
                    mainColumn(width: interactiveWidth)
                        .frame(width: interactiveWidth, alignment: .leading)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

                    // Decorative mascot — anchored to the *container* trailing edge.
                    CopyCatMascotStage(
                        resourceName: HomeChrome.mascotResourceName,
                        role: .home,
                        narrowHome: narrowHome,
                        showGlow: true,
                        pawCount: CopyCatMascotMetrics.pawTrailCount,
                        idleMotion: true
                    )
                    .offset(y: 12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                }
                .frame(width: containerWidth)
                // Extra window width becomes equal outer margins (not a mid-gap).
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task(id: model.selectedFolders.map(\.path)) {
            await refreshSizeEstimates(for: model.selectedFolders)
        }
    }

    private func mainColumn(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            hero

            dropzone(width: width)
                .padding(.top, HomeChrome.subtitleToDropzone - 32)

            selectedLocations(width: width)
                .padding(.top, HomeChrome.dropzoneToSelectedTitle)

            HStack {
                Spacer(minLength: 0)
                CopyCatPrimaryButton(
                    title: "Start scanning",
                    icon: "PawIcon",
                    iconMaxHeight: HomeChrome.ctaPaw,
                    isEnabled: canStartScan,
                    minWidth: HomeChrome.primaryCTAMinWidth,
                    action: startScanningTapped
                )
                .keyboardShortcut(.defaultAction)
                .accessibilityIdentifier("startScanButton")
                Spacer(minLength: 0)
            }
            .padding(.top, 48)

            safetyRow
                .padding(.top, HomeChrome.ctaToSafety)
        }
        .frame(width: width, alignment: .leading)
    }

    private var canStartScan: Bool {
        !model.selectedFolders.isEmpty && !model.isScanning && model.screen == .folderSelection
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Reclaim space.")
                    .font(HomeChrome.heroFont)
                    .foregroundStyle(CopyCatChrome.textPrimary)
                    .tracking(HomeChrome.heroTracking)
                (
                    Text("Find ")
                        .foregroundStyle(CopyCatChrome.textPrimary)
                    + Text("hidden copies.")
                        .foregroundStyle(CopyCatChrome.primary)
                )
                .font(HomeChrome.heroFont)
                .tracking(HomeChrome.heroTracking)
            }
            .lineSpacing(6)

            Text("Recover storage without risking the files that matter.")
                .font(HomeChrome.subtitleFont)
                .foregroundStyle(CopyCatChrome.textSecondary)
                .frame(maxWidth: 440, alignment: .leading)
        }
    }

    private func dropzone(width: CGFloat) -> some View {
        Button(action: presentFolderPicker) {
            HStack(spacing: 16) {
                CopyCatVisibleAssetImage(
                    name: "FolderIcon",
                    visibleHeight: HomeChrome.dropzoneFolderIcon
                )
                .frame(width: 48, height: 44, alignment: .center)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Choose folders or drives…")
                        .font(HomeChrome.primaryBodyFont)
                        .foregroundStyle(CopyCatChrome.textPrimary)
                    Text("Drag and drop folders or drives here to scan")
                        .font(HomeChrome.secondaryBodyFont)
                        .foregroundStyle(CopyCatChrome.textSecondary)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(CopyCatChrome.textTertiary)
                    .padding(.trailing, 20)
            }
            .padding(.leading, 16)
            .frame(width: width, height: HomeChrome.dropzoneHeight, alignment: .leading)
            .background(isDropTargeted || isDropzoneHovered ? CopyCatChrome.surfaceHover : CopyCatChrome.surface)
            .clipShape(RoundedRectangle(cornerRadius: HomeChrome.dropzoneRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: HomeChrome.dropzoneRadius, style: .continuous)
                    .strokeBorder(
                        CopyCatChrome.primary.opacity(
                            isDropTargeted ? 0.98 : HomeChrome.dropzoneBorderOpacity
                        ),
                        style: StrokeStyle(
                            lineWidth: isDropTargeted ? 2.25 : HomeChrome.dropzoneBorderWidth,
                            dash: [HomeChrome.dropzoneDash, HomeChrome.dropzoneGap]
                        )
                    )
            }
            .contentShape(RoundedRectangle(cornerRadius: HomeChrome.dropzoneRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .onHover { isDropzoneHovered = $0 }
        .accessibilityIdentifier("addFolderButton")
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
            handleDrop(providers)
        }
    }

    private func selectedLocations(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Selected locations")
                .font(HomeChrome.sectionTitleFont)
                .foregroundStyle(CopyCatChrome.textSecondary)

            if model.selectedFolders.isEmpty {
                Text("Add a folder or drive above to begin.")
                    .font(HomeChrome.secondaryBodyFont)
                    .foregroundStyle(CopyCatChrome.textTertiary)
            } else {
                locationCards(width: width)
            }
        }
        .frame(width: width, alignment: .leading)
    }

    @ViewBuilder
    private func locationCards(width: CGFloat) -> some View {
        let cards = VStack(alignment: .leading, spacing: Self.locationCardSpacing) {
            ForEach(model.selectedFolders, id: \.self) { url in
                let sizeBytes = sizeByPath[url.path]
                CopyCatLocationCard(
                    title: url.lastPathComponent.isEmpty ? url.path : url.lastPathComponent,
                    path: url.path,
                    sizeLabel: sizeBytes.map { "\(formattedBytes($0)) selected" } ?? "Estimating size…",
                    estimateLabel: scanEstimateLabel(for: sizeBytes),
                    isVolume: url.path.hasPrefix("/Volumes/"),
                    onRemove: { model.removeFolder(url) }
                )
                .frame(width: width)
            }
        }

        // Grow for the first two cards; scroll afterward — never into the mascot.
        if model.selectedFolders.count <= Self.locationVisibleCount {
            cards
        } else {
            ScrollView(.vertical, showsIndicators: true) {
                cards
            }
            .frame(height: Self.locationListScrollHeight)
        }
    }

    private var safetyRow: some View {
        HStack {
            Spacer(minLength: 0)
            HStack(spacing: 10) {
                CopyCatVisibleAssetImage(
                    name: "ShieldIcon",
                    visibleHeight: HomeChrome.shieldIcon
                )
                Text("CopyCat only reads files during scanning. Your files are safe.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(CopyCatChrome.textTertiary)
            }
            Spacer(minLength: 0)
        }
    }

    private func startScanningTapped() {
        #if DEBUG
        print("[CopyCat DEBUG] Start scanning CTA pressed — count=\(model.selectedFolders.count)")
        #endif
        model.startScan()
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

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        var handled = false
        for provider in providers {
            guard provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) else { continue }
            handled = true
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                let url: URL? = {
                    if let data = item as? Data { return URL(dataRepresentation: data, relativeTo: nil) }
                    if let url = item as? URL { return url }
                    return nil
                }()
                guard let url else { return }
                var isDirectory: ObjCBool = false
                guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory),
                      isDirectory.boolValue else { return }
                Task { @MainActor in model.addFolders([url]) }
            }
        }
        return handled
    }

    private func refreshSizeEstimates(for folders: [URL]) async {
        let paths = folders.map(\.path)
        let sizes: [String: UInt64] = await Task.detached(priority: .utility) {
            var result: [String: UInt64] = [:]
            for folder in folders {
                result[folder.path] = FolderSizeEstimator.approximateByteCount(at: folder)
            }
            return result
        }.value
        guard !Task.isCancelled else { return }
        if model.selectedFolders.map(\.path) == paths {
            sizeByPath = sizes
        }
    }

    private func scanEstimateLabel(for bytes: UInt64?) -> String {
        guard let bytes else { return "Estimated scan: …" }
        let minutes = max(1, Int((Double(bytes) / 80_000_000.0 / 60.0).rounded()))
        if minutes < 2 { return "Estimated scan: under 2 min" }
        if minutes <= 60 { return "Estimated scan: about \(minutes) min" }
        return "Estimated scan: about \(max(1, (minutes + 30) / 60)) hr"
    }
}

#Preview("Home") {
    HomeView()
        .environment(AppModel())
        .frame(width: 1080, height: 720)
}
