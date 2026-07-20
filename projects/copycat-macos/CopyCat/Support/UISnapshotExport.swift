#if DEBUG
import AppKit
import SwiftUI
import CopyCatEngine

/// DEBUG hooks for deterministic UI snapshots (not used in production builds).
enum CopyCatSnapshotHooks {
    static var forceDiscoveryToast = false
}

/// DEBUG-only snapshots.
/// - `COPYCAT_SNAPSHOT=home` → Home v2 static at 1080×720
/// - `COPYCAT_SNAPSHOT=1` → review-workflow PNGs
enum UISnapshotExport {
    static func runIfRequested() {
        let mode = ProcessInfo.processInfo.environment["COPYCAT_SNAPSHOT"]
        guard let mode, !mode.isEmpty else { return }

        let work: @MainActor () -> Void = {
            if mode == "home" {
                runHomeSnapshot()
                return
            }
            if mode == "recovery" {
                runRecoveryProofSnapshots()
                return
            }
            if mode == "layout" {
                runLayoutValidationSnapshots()
                return
            }
            if mode == "settings" {
                runSettingsProofSnapshots()
                return
            }
            if mode == "visual" {
                runVisualSizeValidationSnapshots()
                return
            }
            if mode == "glow" {
                runGlowValidationSnapshots()
                return
            }
            if mode == "placement" {
                runPlacementValidationSnapshots()
                return
            }
            if mode == "1" {
                runReviewWorkflowSnapshots()
            }
        }

        if Thread.isMainThread {
            MainActor.assumeIsolated(work)
        } else {
            DispatchQueue.main.sync {
                MainActor.assumeIsolated(work)
            }
        }
    }

    @MainActor
    private static func runReviewWorkflowSnapshots() {

        let folder = FileManager.default.temporaryDirectory
            .appendingPathComponent("copycat-review-workflow", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        } catch {
            fputs("UISnapshotExport mkdir failed: \(error)\n", stderr)
            exit(1)
        }

        let fixtures = ReviewSnapshotFixtures.makeGroups()
        let size = CGSize(width: 1080, height: 720)
        var failures = 0

        func capture(_ name: String, configure: (AppModel) -> Void) {
            let model = AppModel()
            model.screen = .review
            model.review.load(from: fixtures)
            configure(model)
            let view = ContentView().environment(model)
            if !render(view, size: size, to: folder.appendingPathComponent(name)) {
                failures += 1
            }
        }

        // 1. Review screen with the first duplicate group loaded
        capture("01-review-first-group.png") { _ in }

        // 2. A group containing 2 files
        capture("02-group-two-files.png") { model in
            if let id = model.review.groups.first(where: { $0.files.count == 2 })?.id {
                model.review.goToGroup(id: id)
            }
        }

        // 3. A group containing many files
        capture("03-group-many-files.png") { model in
            if let id = model.review.groups.first(where: { $0.files.count >= 5 })?.id {
                model.review.goToGroup(id: id)
            }
        }

        // 4. One file kept, others selected for Trash (default recommendation state)
        capture("04-keep-and-trash-selection.png") { model in
            if let id = model.review.groups.first(where: { $0.files.count >= 3 })?.id {
                model.review.goToGroup(id: id)
            }
            model.review.applyRecommendedToCurrent()
        }

        // 5. Confirmation state before moving files
        capture("05-confirmation.png") { model in
            model.showCleanupConfirm = true
        }

        // 6. Immediately after cleanup: next group, updated stats, Undo toast
        capture("06-after-cleanup-undo-toast.png") { model in
            model.debugSimulateCurrentGroupCleanupSuccess(
                recoveredBytes: fixtures[0].recoverableBytes,
                fileCount: max(fixtures[0].files.count - 1, 1)
            )
        }

        // 7. After Skip — first group moved to end of queue
        capture("07-after-skip.png") { model in
            let firstTitle = model.review.groups.first?.title
            model.review.skipCurrentGroup()
            // Keep a breadcrumb in the progress area via current selection;
            // sidebar order is the proof (former first title should be last).
            _ = firstTitle
        }

        // 8. Finished screen when no groups remain
        capture("08-finished.png") { model in
            model.debugSimulateAllGroupsResolved(
                recoveredBytes: 842_000_000,
                fileCount: 12,
                reviewedGroups: fixtures.count
            )
        }

        // 9a. Finished with Undo available (button)
        capture("09a-finished-undo-button.png") { model in
            model.debugSimulateAllGroupsResolved(
                recoveredBytes: 128_000_000,
                fileCount: 2,
                reviewedGroups: fixtures.count,
                withUndo: true
            )
        }

        // 9b. After Undo from finished (same path as Undo button / ⌘Z)
        capture("09b-after-undo-from-finished.png") { model in
            model.debugSimulateAllGroupsResolved(
                recoveredBytes: 128_000_000,
                fileCount: 2,
                reviewedGroups: fixtures.count,
                withUndo: true
            )
            model.debugRestoreQueueFromPendingUndo()
        }

        guard failures == 0 else {
            fputs("UISnapshotExport incomplete (\(failures) failures)\n", stderr)
            exit(2)
        }
        print("UISnapshotExport wrote PNGs to \(folder.path)")
        exit(0)
    }

    @MainActor
    private static func runVisualSizeValidationSnapshots() {
        let out = FileManager.default.temporaryDirectory
            .appendingPathComponent("copycat-visual-size", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: out, withIntermediateDirectories: true)
        } catch {
            fputs("UISnapshotExport mkdir failed: \(error)\n", stderr)
            exit(1)
        }

        let size = CGSize(width: CopyCatWindow.minWidth, height: CopyCatWindow.minHeight)
        var failures = 0

        func capture(_ name: String, configure: (AppModel) -> Void) {
            CopyCatSnapshotHooks.forceDiscoveryToast = false
            let model = AppModel()
            configure(model)
            if !render(ContentView().environment(model), size: size, to: out.appendingPathComponent(name)) {
                failures += 1
            }
        }

        capture("01-home-empty.png") { model in
            model.screen = .folderSelection
            model.selectedFolders = []
        }

        capture("02-home-one-location.png") { model in
            model.screen = .folderSelection
            model.selectedFolders = [URL(fileURLWithPath: "/Users/mervin/Documents")]
        }

        capture("03-scanning.png") { model in
            configureScanning(model, withToast: false)
        }

        capture("04-verifying-with-toast.png") { model in
            configureScanning(model, withToast: true)
            model.progress = ScanProgress(
                phase: .hashing,
                filesSeen: 12_480,
                bytesSeen: 4_200_000_000,
                candidateFiles: 220,
                groupsFound: 4,
                message: ScanProgressLabels.fullHashing
            )
        }

        guard failures == 0 else {
            fputs("UISnapshotExport visual size incomplete (\(failures) failures)\n", stderr)
            exit(2)
        }
        print("UISnapshotExport wrote visual-size PNGs to \(out.path)")
        exit(0)
    }

    @MainActor
    private static func runGlowValidationSnapshots() {
        let out = FileManager.default.temporaryDirectory
            .appendingPathComponent("copycat-glow", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: out, withIntermediateDirectories: true)
        } catch {
            fputs("UISnapshotExport mkdir failed: \(error)\n", stderr)
            exit(1)
        }

        let size = CGSize(width: CopyCatWindow.minWidth, height: CopyCatWindow.minHeight)
        var failures = 0

        func capture(_ name: String, configure: (AppModel) -> Void) {
            CopyCatSnapshotHooks.forceDiscoveryToast = false
            let model = AppModel()
            configure(model)
            if !render(ContentView().environment(model), size: size, to: out.appendingPathComponent(name)) {
                failures += 1
            }
        }

        capture("01-home.png") { model in
            model.screen = .folderSelection
            model.selectedFolders = [URL(fileURLWithPath: "/Users/mervin/Documents")]
        }

        capture("02-hunting.png") { model in
            configureScanning(model, withToast: false)
            model.progress = ScanProgress(
                phase: .enumerating,
                filesSeen: 12_480,
                bytesSeen: 4_200_000_000,
                candidateFiles: 220,
                groupsFound: 3,
                message: "/Users/mervin/Documents/Photos/2024/IMG_2048.jpg"
            )
        }

        capture("03-verifying.png") { model in
            configureScanning(model, withToast: true)
            model.progress = ScanProgress(
                phase: .hashing,
                filesSeen: 12_480,
                bytesSeen: 4_200_000_000,
                candidateFiles: 220,
                groupsFound: 4,
                message: ScanProgressLabels.fullHashing
            )
        }

        capture("04-cleanup.png") { model in
            model.screen = .review
            model.review.load(from: ReviewSnapshotFixtures.makeGroups())
            model.review.applyRecommendedToCurrent()
            model.showCleanupConfirm = true
        }

        capture("05-complete.png") { model in
            model.review.load(from: ReviewSnapshotFixtures.makeGroups())
            model.debugSimulateAllGroupsResolved(
                recoveredBytes: 128_000_000,
                fileCount: 4,
                reviewedGroups: 3,
                withUndo: true
            )
        }

        guard failures == 0 else {
            fputs("UISnapshotExport glow incomplete (\(failures) failures)\n", stderr)
            exit(2)
        }
        print("UISnapshotExport wrote glow PNGs to \(out.path)")
        exit(0)
    }

    @MainActor
    private static func runPlacementValidationSnapshots() {
        let out = FileManager.default.temporaryDirectory
            .appendingPathComponent("copycat-placement", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: out, withIntermediateDirectories: true)
        } catch {
            fputs("UISnapshotExport mkdir failed: \(error)\n", stderr)
            exit(1)
        }

        var failures = 0

        func capture(_ name: String, size: CGSize, configure: (AppModel) -> Void) {
            CopyCatSnapshotHooks.forceDiscoveryToast = false
            let model = AppModel()
            configure(model)
            if !render(ContentView().environment(model), size: size, to: out.appendingPathComponent(name)) {
                failures += 1
            }
        }

        let configureVerifyingWithToast: (AppModel) -> Void = { model in
            configureScanning(model, withToast: true)
            model.progress = ScanProgress(
                phase: .hashing,
                filesSeen: 12_480,
                bytesSeen: 4_200_000_000,
                candidateFiles: 220,
                groupsFound: 4,
                message: ScanProgressLabels.fullHashing
            )
        }

        capture(
            "01-scanning-1080x720.png",
            size: CGSize(width: 1080, height: 720),
            configure: configureVerifyingWithToast
        )
        capture(
            "02-scanning-1200x720.png",
            size: CGSize(width: 1200, height: 720),
            configure: configureVerifyingWithToast
        )

        guard failures == 0 else {
            fputs("UISnapshotExport placement incomplete (\(failures) failures)\n", stderr)
            exit(2)
        }
        print("UISnapshotExport wrote placement PNGs to \(out.path)")
        exit(0)
    }

    @MainActor
    private static func runSettingsProofSnapshots() {
        let out = FileManager.default.temporaryDirectory
            .appendingPathComponent("copycat-settings-proof", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: out, withIntermediateDirectories: true)
        } catch {
            fputs("UISnapshotExport mkdir failed: \(error)\n", stderr)
            exit(1)
        }

        let size = CGSize(width: CopyCatWindow.minWidth, height: CopyCatWindow.minHeight)
        var failures = 0

        func capture(_ name: String, configure: (AppModel) -> Void) {
            let model = AppModel()
            configure(model)
            if !render(ContentView().environment(model), size: size, to: out.appendingPathComponent(name)) {
                failures += 1
            }
        }

        capture("01-home-settings-control.png") { model in
            model.screen = .folderSelection
        }

        capture("02-settings-opened.png") { model in
            model.screen = .folderSelection
            model.openSettings()
        }

        // Prove openSettings mutates navigation state.
        let probe = AppModel()
        probe.screen = .folderSelection
        probe.openSettings()
        let stateOK = probe.screen == .settings
        let proof = out.appendingPathComponent("03-openSettings-state.txt")
        try? "openSettings() -> screen=\(probe.screen) ok=\(stateOK)\n".write(
            to: proof,
            atomically: true,
            encoding: .utf8
        )
        print("Settings state proof: screen=\(probe.screen) ok=\(stateOK)")

        guard failures == 0, stateOK else {
            fputs("UISnapshotExport settings proof failed\n", stderr)
            exit(2)
        }
        print("UISnapshotExport wrote settings PNGs to \(out.path)")
        exit(0)
    }

    @MainActor
    private static func runLayoutValidationSnapshots() {
        let out = FileManager.default.temporaryDirectory
            .appendingPathComponent("copycat-layout-validation", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: out, withIntermediateDirectories: true)
        } catch {
            fputs("UISnapshotExport mkdir failed: \(error)\n", stderr)
            exit(1)
        }

        var failures = 0

        func capture(_ name: String, size: CGSize, configure: (AppModel) -> Void) {
            let model = AppModel()
            configure(model)
            let view = ContentView().environment(model)
            if !render(view, size: size, to: out.appendingPathComponent(name)) {
                failures += 1
            }
        }

        let minSize = CGSize(width: CopyCatWindow.minWidth, height: CopyCatWindow.minHeight)

        capture("01-home-1080x720.png", size: minSize) { model in
            model.screen = .folderSelection
            model.selectedFolders = []
        }

        capture("02-scanning-1080x720.png", size: minSize) { model in
            configureScanning(model, withToast: false)
        }

        capture("03-scanning-1200x720.png", size: CGSize(width: 1200, height: 720)) { model in
            configureScanning(model, withToast: false)
        }

        // Narrowest supported = app-wide minimum (cannot go below without clipping by contract).
        capture("04-scanning-narrowest-1080x720.png", size: minSize) { model in
            configureScanning(model, withToast: true)
        }

        capture("05-scanning-maximized-1680x1050.png", size: CGSize(width: 1680, height: 1050)) { model in
            configureScanning(model, withToast: true)
        }

        guard failures == 0 else {
            fputs("UISnapshotExport layout incomplete (\(failures) failures)\n", stderr)
            exit(2)
        }
        print("UISnapshotExport wrote layout PNGs to \(out.path)")
        print("CopyCatWindow.minWidth=\(CopyCatWindow.minWidth) minHeight=\(CopyCatWindow.minHeight)")
        exit(0)
    }

    @MainActor
    private static func configureScanning(_ model: AppModel, withToast: Bool) {
        CopyCatSnapshotHooks.forceDiscoveryToast = withToast
        model.screen = .scanning
        model.isScanning = true
        model.selectedFolders = [URL(fileURLWithPath: "/Users/mervin/Documents")]
        model.progress = ScanProgress(
            phase: .hashing,
            filesSeen: 12_480,
            bytesSeen: 4_200_000_000,
            candidateFiles: 220,
            groupsFound: withToast ? 4 : 3,
            message: "/Users/mervin/Documents/Photos/2024/IMG_2048.jpg"
        )
        if withToast {
            model.groups = ReviewSnapshotFixtures.makeGroups()
        }
    }

    @MainActor
    private static func runRecoveryProofSnapshots() {
        // App Sandbox: write under temporaryDirectory, then the recovery script copies out.
        let out = FileManager.default.temporaryDirectory
            .appendingPathComponent("copycat-recovery-proof", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: out, withIntermediateDirectories: true)
        } catch {
            fputs("UISnapshotExport mkdir failed: \(error)\n", stderr)
            exit(1)
        }

        let size = CGSize(width: 1080, height: 720)
        var failures = 0

        func capture(_ name: String, configure: (AppModel) -> Void) {
            let model = AppModel()
            configure(model)
            let view = ContentView().environment(model)
            if !render(view, size: size, to: out.appendingPathComponent(name)) {
                failures += 1
            }
        }

        capture("01-home-empty.png") { model in
            model.screen = .folderSelection
            model.selectedFolders = []
        }

        capture("02-home-one-location.png") { model in
            model.screen = .folderSelection
            model.selectedFolders = [URL(fileURLWithPath: "/Users/mervin/Documents")]
        }

        capture("03-scanning.png") { model in
            model.screen = .scanning
            model.isScanning = true
            model.selectedFolders = [URL(fileURLWithPath: "/Users/mervin/Documents")]
            model.progress = ScanProgress(
                phase: .enumerating,
                filesSeen: 12_480,
                bytesSeen: 4_200_000_000,
                candidateFiles: 220,
                groupsFound: 3,
                message: "Looking through your files…"
            )
        }

        capture("04-review-duplicates.png") { model in
            model.screen = .review
            model.review.load(from: ReviewSnapshotFixtures.makeGroups())
        }

        guard failures == 0 else {
            fputs("UISnapshotExport recovery incomplete (\(failures) failures)\n", stderr)
            exit(2)
        }
        print("UISnapshotExport wrote recovery PNGs to \(out.path)")
        exit(0)
    }

    @MainActor
    private static func runHomeSnapshot() {
        let folder = FileManager.default.temporaryDirectory
            .appendingPathComponent("copycat-home-v2", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        } catch {
            fputs("UISnapshotExport mkdir failed: \(error)\n", stderr)
            exit(1)
        }

        let model = AppModel()
        model.screen = .folderSelection
        model.selectedFolders = [URL(fileURLWithPath: "/Volumes/MERVIN 12TB")]
        let url = folder.appendingPathComponent("home-1080x720.png")
        let ok = render(
            ContentView().environment(model),
            size: CGSize(width: 1080, height: 720),
            to: url
        )
        guard ok else {
            fputs("UISnapshotExport home incomplete\n", stderr)
            exit(2)
        }
        print("UISnapshotExport wrote Home PNG to \(folder.path)")
        exit(0)
    }

    @MainActor
    private static func render<V: View>(_ view: V, size: CGSize, to url: URL) -> Bool {
        let hosting = NSHostingView(rootView: view)
        hosting.frame = NSRect(origin: .zero, size: size)
        hosting.layoutSubtreeIfNeeded()
        // Allow onAppear / forced toast state to commit before capture.
        RunLoop.current.run(until: Date().addingTimeInterval(0.12))
        hosting.layoutSubtreeIfNeeded()
        RunLoop.current.run(until: Date().addingTimeInterval(0.05))

        // Force 1× pixel dimensions (ignore Retina scale) for exact mockup comparison.
        guard let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(size.width),
            pixelsHigh: Int(size.height),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) else {
            fputs("UISnapshotExport: no bitmap rep for \(url.lastPathComponent)\n", stderr)
            return false
        }
        rep.size = size
        hosting.cacheDisplay(in: hosting.bounds, to: rep)
        guard let png = rep.representation(using: .png, properties: [:]) else {
            fputs("UISnapshotExport: png encode failed for \(url.lastPathComponent)\n", stderr)
            return false
        }
        do {
            try png.write(to: url)
            print("Wrote \(url.path) (\(png.count) bytes)")
            return true
        } catch {
            fputs("UISnapshotExport write failed: \(error)\n", stderr)
            return false
        }
    }
}

// MARK: - Fixtures

private enum ReviewSnapshotFixtures {
    static func makeGroups() -> [DuplicateGroup] {
        let now = Date()
        let hash = "a3f9c2e81b704d55e92a11c0ff88bd21c4e7a019d3b6f5a8e1c0d9b7a6543210"

        let pair = DuplicateGroup(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            files: [
                file(
                    "Vacation-Final.jpg",
                    folder: "/Users/demo/Pictures",
                    size: 4_200_000,
                    created: now.addingTimeInterval(-86400 * 40),
                    modified: now.addingTimeInterval(-86400 * 2),
                    hash: hash
                ),
                file(
                    "Vacation-Final.jpg",
                    folder: "/Users/demo/Downloads",
                    size: 4_200_000,
                    created: now.addingTimeInterval(-86400 * 40),
                    modified: now.addingTimeInterval(-86400 * 30),
                    hash: hash
                ),
            ],
            category: .exact,
            reasons: [.identicalSHA256]
        )

        let manyHash = "bb11cc22dd33ee44ff556677889900aabbccddeeff00112233445566778899aa"
        let manyFiles: [ScannedFile] = (1...6).map { index in
            let folder: String
            switch index {
            case 1: folder = "/Users/demo/Pictures/Library"
            case 2: folder = "/Users/demo/Desktop"
            case 3: folder = "/Users/demo/Downloads"
            case 4: folder = "/Users/demo/Documents/Backup"
            case 5: folder = "/Volumes/Archive/Photos"
            default: folder = "/Users/demo/Movies/Exports"
            }
            return file(
                "IMG_2048.heic",
                folder: folder,
                size: 8_420_000,
                created: now.addingTimeInterval(-86400 * Double(90 - index)),
                modified: now.addingTimeInterval(-86400 * Double(20 - index)),
                hash: manyHash
            )
        }
        let many = DuplicateGroup(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
            files: manyFiles,
            category: .exact,
            reasons: [.identicalSHA256]
        )

        let trioHash = "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"
        let trio = DuplicateGroup(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
            files: [
                file(
                    "Project-Brief.pdf",
                    folder: "/Users/demo/Documents",
                    size: 1_280_000,
                    created: now.addingTimeInterval(-86400 * 12),
                    modified: now.addingTimeInterval(-86400 * 1),
                    hash: trioHash
                ),
                file(
                    "Project-Brief.pdf",
                    folder: "/Users/demo/Desktop",
                    size: 1_280_000,
                    created: now.addingTimeInterval(-86400 * 12),
                    modified: now.addingTimeInterval(-86400 * 8),
                    hash: trioHash
                ),
                file(
                    "Project-Brief copy.pdf",
                    folder: "/Users/demo/Downloads",
                    size: 1_280_000,
                    created: now.addingTimeInterval(-86400 * 10),
                    modified: now.addingTimeInterval(-86400 * 10),
                    hash: trioHash
                ),
            ],
            category: .exact,
            reasons: [.identicalSHA256]
        )

        let clipHash = "dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd"
        let clips = DuplicateGroup(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!,
            files: [
                file(
                    "Interview-Take-03.mov",
                    folder: "/Users/demo/Movies",
                    size: 842_000_000,
                    created: now.addingTimeInterval(-86400 * 5),
                    modified: now.addingTimeInterval(-86400 * 1),
                    hash: clipHash
                ),
                file(
                    "Interview-Take-03.mov",
                    folder: "/Users/demo/Desktop",
                    size: 842_000_000,
                    created: now.addingTimeInterval(-86400 * 5),
                    modified: now.addingTimeInterval(-86400 * 4),
                    hash: clipHash
                ),
            ],
            category: .exact,
            reasons: [.identicalSHA256]
        )

        // First group is a typical 3-file set; 2-file and many-file groups follow for dedicated shots.
        return [trio, pair, many, clips]
    }

    private static func file(
        _ name: String,
        folder: String,
        size: UInt64,
        created: Date,
        modified: Date,
        hash: String
    ) -> ScannedFile {
        let url = URL(fileURLWithPath: folder).appendingPathComponent(name)
        return ScannedFile(
            url: url,
            filename: name,
            extension: url.pathExtension,
            size: size,
            createdDate: created,
            modifiedDate: modified,
            partialHash: String(hash.prefix(16)),
            fullHash: hash
        )
    }
}

#endif
