import SwiftUI
import CopyCatEngine

/// Layout metrics for Review — cards keep priority; queue shrinks first.
private enum ReviewBreakpoints {
    static let wide: CGFloat = 1500
    static let medium: CGFloat = 1200

    static let queueWide: CGFloat = 240
    static let queueMedium: CGFloat = 220
    static let queueNarrow: CGFloat = 200

    /// Minimum readable width for a decision card.
    static let cardMinWidth: CGFloat = 300
    static let cardSpacing: CGFloat = 12
    static let panelGutter: CGFloat = 20
    static let panelPadding: CGFloat = 24
}

struct DuplicateReviewView: View {
    @Environment(AppModel.self) private var model
    @State private var focusedFileID: UUID?

    private var session: ReviewSession { model.review }

    /// True when the queue is empty because groups were already reviewed (not a zero-result scan).
    private var isAllGroupsReviewed: Bool {
        session.initialGroupCount > 0 || session.reviewedGroupCount > 0
    }

    var body: some View {
        CopyCatAppShell(
            showSettings: false,
            // Empty state uses mascot-stage glow only — no orphan page spotlight.
            showAtmosphere: session.currentGroup != nil,
            atmosphereAlignment: .topTrailing,
            trailing: AnyView(headerTrailing)
        ) {
            ZStack {
                if let group = session.currentGroup {
                    GeometryReader { geo in
                        workspace(group, totalWidth: geo.size.width)
                    }
                } else {
                    reviewEmptyState
                }

                if model.showCleanupConfirm {
                    cleanupConfirmation
                }

                if let pending = model.pendingTrashUndo, !model.showCleanupConfirm {
                    undoBanner(fileCount: pending.fileCount)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, 24)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: model.pendingTrashUndo?.fileCount)
        .onKeyPress(.space) { quickLookFocusedOrFirst(); return .handled }
        .onKeyPress(.return) { revealFocusedOrFirst(); return .handled }
        .onKeyPress(.delete) { model.requestCurrentGroupCleanup(); return .handled }
        .onKeyPress(.leftArrow) { session.goToPreviousGroup(); return .handled }
        .onKeyPress(.rightArrow) { session.goToNextGroup(); return .handled }
        .confirmationDialog(
            "Move \(session.totalSelectedDeleteCount) files to Trash?",
            isPresented: Binding(
                get: { model.showAdvancedBulkConfirm },
                set: { model.showAdvancedBulkConfirm = $0 }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete All Selected", role: .destructive) {
                model.performAdvancedBulkCleanup()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Advanced: recover \(formattedBytes(session.totalSelectedDeleteBytes)) across all remaining groups.")
        }
        .alert("Cleanup Error", isPresented: Binding(
            get: { session.cleanupErrorMessage != nil },
            set: { if !$0 { session.cleanupErrorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(session.cleanupErrorMessage ?? "")
        }
        .confirmationDialog(
            occupiedDialogTitle,
            isPresented: Binding(
                get: { model.occupiedRestorePrompt != nil },
                set: { if !$0 { model.dismissOccupiedRestorePrompt() } }
            ),
            titleVisibility: .visible
        ) {
            Button("Reveal in Trash") { model.revealOccupiedRestoreInTrash() }
            Button("Restore Beside Original") { model.restoreOccupiedBesideOriginal() }
            Button("Leave in Trash", role: .cancel) { model.dismissOccupiedRestorePrompt() }
        } message: {
            Text("A file already exists at the original location. CopyCat will not overwrite it.")
        }
    }

    private var headerTrailing: some View {
        HStack(spacing: 10) {
            CopyCatSecondaryButton(title: "New Scan") {
                model.resetToFolderSelection()
            }
            Menu {
                Section("Select") {
                    Button("Recommended") { session.applyRecommendedToCurrent() }
                    Button("Older Copies") { session.selectOlderCopiesInCurrent() }
                    Button("Outside Library") { session.selectOutsideLibraryInCurrent() }
                    Button("Invert") { session.invertSelectionInCurrent() }
                }
                Section("Advanced") {
                    Button("Select All Recommended") { session.applyAllRecommended() }
                    Button("Select Older Copies") { session.selectOlderCopies() }
                    Button("Delete All Selected…") { model.requestAdvancedBulkCleanup() }
                        .disabled(session.totalSelectedDeleteCount == 0)
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(CopyCatChrome.textSecondary)
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
            }
            .menuStyle(.borderlessButton)
            .accessibilityLabel("More actions")
        }
    }

    private var occupiedDialogTitle: String {
        let count = model.occupiedRestorePrompt?.items.count ?? 0
        return count == 1 ? "Original location is occupied" : "\(count) original locations are occupied"
    }

    private var reviewEmptyState: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            VStack(spacing: 28) {
                CopyCatMascotStage(
                    resourceName: isAllGroupsReviewed ? "CopyCatProud" : "CopyCatSleep",
                    role: .dialog,
                    showGlow: true,
                    pawCount: 0,
                    idleMotion: true
                )
                .allowsHitTesting(false)
                .accessibilityHidden(true)

                VStack(spacing: 10) {
                    Text(isAllGroupsReviewed ? "You're all clear" : "No duplicates found")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(CopyCatChrome.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(
                        isAllGroupsReviewed
                            ? "All duplicate groups have been reviewed."
                            : "CopyCat didn't find any duplicate files in the selected locations."
                    )
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(CopyCatChrome.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 420)
                }

                VStack(spacing: 12) {
                    CopyCatPrimaryButton(
                        title: "Scan another folder",
                        icon: "PawIcon",
                        iconMaxHeight: 16,
                        minWidth: 220
                    ) {
                        model.resetToFolderSelection()
                    }
                    .keyboardShortcut(.defaultAction)

                    CopyCatSecondaryButton(title: "Back to Home") {
                        model.resetToFolderSelection()
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(isAllGroupsReviewed ? "You're all clear" : "No duplicates found")
    }

    private func workspace(_ group: ReviewGroupItem, totalWidth: CGFloat) -> some View {
        let queueWidth = Self.queueWidth(for: totalWidth)
        let isNarrow = totalWidth < ReviewBreakpoints.medium

        return VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Review duplicates")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(CopyCatChrome.textPrimary)
                Text(progressLine)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(CopyCatChrome.textTertiary)
                    .lineLimit(2)
            }
            .padding(.top, 12)

            HStack(alignment: .top, spacing: ReviewBreakpoints.panelGutter) {
                queuePanel
                    .frame(width: queueWidth)

                reviewPanel(group, isNarrow: isNarrow, queueWidth: queueWidth, totalWidth: totalWidth)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.top, 16)
        }
    }

    private static func queueWidth(for totalWidth: CGFloat) -> CGFloat {
        if totalWidth > ReviewBreakpoints.wide {
            return ReviewBreakpoints.queueWide
        }
        if totalWidth >= ReviewBreakpoints.medium {
            return ReviewBreakpoints.queueMedium
        }
        return ReviewBreakpoints.queueNarrow
    }

    /// Width available inside the review panel content (after queue + gutters + padding).
    /// `totalWidth` is already inside `CopyCatAppFrame` (insets applied).
    private static func comparisonWidth(totalWidth: CGFloat, queueWidth: CGFloat) -> CGFloat {
        let gutter = ReviewBreakpoints.panelGutter
        let padding = ReviewBreakpoints.panelPadding * 2
        return max(0, totalWidth - queueWidth - gutter - padding)
    }

    private var progressLine: String {
        "\(session.reviewedGroupCount) of \(session.initialGroupCount) reviewed · \(session.remainingGroupCount) remaining · \(formattedBytes(session.totalRecoveredBytes)) recovered"
    }

    private var queuePanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Queue")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(CopyCatChrome.textTertiary)
                .padding(.horizontal, 14)
                .padding(.top, 12)
                .padding(.bottom, 6)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(Array(session.groups.enumerated()), id: \.element.id) { index, group in
                        CopyCatQueueItem(
                            title: group.title,
                            sizeLabel: formattedBytes(group.selectedDeleteBytes > 0 ? group.selectedDeleteBytes : group.recoverableBytes),
                            isSelected: index == session.currentIndex
                        ) {
                            session.goToGroup(id: group.id)
                        }
                    }
                }
                .padding(.bottom, 10)
            }
        }
        .background(CopyCatChrome.surface)
        .clipShape(RoundedRectangle(cornerRadius: CopyCatChrome.radius16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: CopyCatChrome.radius16, style: .continuous)
                .strokeBorder(CopyCatChrome.border.opacity(0.7), lineWidth: 1)
        }
        .frame(maxHeight: .infinity)
    }

    private func reviewPanel(
        _ group: ReviewGroupItem,
        isNarrow: Bool,
        queueWidth: CGFloat,
        totalWidth: CGFloat
    ) -> some View {
        let comparisonWidth = Self.comparisonWidth(totalWidth: totalWidth, queueWidth: queueWidth)

        return VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(group.title)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(CopyCatChrome.textPrimary)
                                .lineLimit(2)
                                .truncationMode(.middle)
                            Text("\(group.files.count) identical copies")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(CopyCatChrome.textSecondary)
                        }
                        Spacer(minLength: 8)
                        Text("Recover \(formattedBytes(group.selectedDeleteBytes))")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(CopyCatChrome.primary)
                            .lineLimit(1)
                    }

                    comparisonArea(group, availableWidth: comparisonWidth, isNarrow: isNarrow)
                }
                .padding(ReviewBreakpoints.panelPadding)
            }

            CopyCatStickyActionBar {
                HStack(spacing: isNarrow ? 6 : 8) {
                    CopyCatSecondaryButton(title: "Previous", compact: isNarrow) {
                        session.goToPreviousGroup()
                    }
                    .opacity(session.currentIndex <= 0 ? 0.4 : 1)
                    .disabled(session.currentIndex <= 0)
                    CopyCatSecondaryButton(title: "Skip", compact: isNarrow) {
                        session.skipCurrentGroup()
                    }
                    .opacity(session.remainingGroupCount <= 1 ? 0.35 : 1)
                    .disabled(session.remainingGroupCount <= 1)
                    CopyCatSecondaryButton(title: "Next", compact: isNarrow) {
                        session.goToNextGroup()
                    }
                    .opacity(session.currentIndex >= max(session.remainingGroupCount - 1, 0) ? 0.4 : 1)
                    .disabled(session.currentIndex >= max(session.remainingGroupCount - 1, 0))
                }
            } trailing: {
                CopyCatPrimaryButton(
                    title: primaryTrashLabel,
                    icon: nil,
                    isEnabled: canMoveCurrentSelectionToTrash,
                    minWidth: isNarrow ? 220 : 300,
                    compact: isNarrow
                ) {
                    model.requestCurrentGroupCleanup()
                }
                .keyboardShortcut(.delete, modifiers: [])
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .background(CopyCatChrome.surface.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: CopyCatChrome.radius20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: CopyCatChrome.radius20, style: .continuous)
                .strokeBorder(CopyCatChrome.border.opacity(0.65), lineWidth: 1)
        }
    }

    @ViewBuilder
    private func comparisonArea(
        _ group: ReviewGroupItem,
        availableWidth: CGFloat,
        isNarrow: Bool
    ) -> some View {
        let spacing = ReviewBreakpoints.cardSpacing
        let minCard = ReviewBreakpoints.cardMinWidth

        if group.files.count == 2 {
            let needed = minCard * 2 + spacing
            if availableWidth >= needed {
                HStack(alignment: .top, spacing: spacing) {
                    ForEach(group.files) { item in
                        fileCard(item, groupID: group.id, isNarrow: isNarrow)
                            .frame(minWidth: minCard, maxWidth: .infinity, alignment: .topLeading)
                    }
                }
            } else {
                // Preserve side-by-side comparison — never squash below readable width.
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(alignment: .top, spacing: spacing) {
                        ForEach(group.files) { item in
                            fileCard(item, groupID: group.id, isNarrow: true)
                                .frame(width: minCard, alignment: .topLeading)
                        }
                    }
                    .padding(.bottom, 4)
                }
            }
        } else {
            VStack(spacing: spacing) {
                ForEach(group.files) { item in
                    fileCard(item, groupID: group.id, isNarrow: isNarrow)
                }
            }
        }
    }

    private func fileCard(_ item: ReviewFileItem, groupID: UUID, isNarrow: Bool) -> some View {
        DuplicateFileRowView(
            item: item,
            isRecommendedKeep: item.recommendedDecision == .keep,
            isCompact: isNarrow,
            onDecision: { decision in
                focusedFileID = item.id
                session.setDecision(groupID: groupID, fileID: item.id, decision: decision)
            }
        )
        .overlay {
            if focusedFileID == item.id {
                RoundedRectangle(cornerRadius: CopyCatChrome.radius12, style: .continuous)
                    .strokeBorder(CopyCatChrome.primary.opacity(0.45), lineWidth: 1.5)
            }
        }
        .onTapGesture { focusedFileID = item.id }
    }

    private var canMoveCurrentSelectionToTrash: Bool {
        session.currentGroupDeleteCount > 0
            && (session.currentGroup?.files.contains { $0.decision == .keep } ?? false)
    }

    private var primaryTrashLabel: String {
        let count = session.currentGroupDeleteCount
        let files = count == 1 ? "1 File" : "\(count) Files"
        return "Move \(files) to Trash · Recover \(formattedBytes(session.currentGroupDeleteBytes))"
    }

    private var cleanupConfirmation: some View {
        ZStack {
            Color.black.opacity(0.50)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                CopyCatMascotStage(
                    resourceName: "CopyCatCleanup",
                    role: .dialog,
                    showGlow: true,
                    pawCount: 0,
                    idleMotion: false
                )

                Text("Ready to tidy up?")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(CopyCatChrome.textPrimary)
                    .padding(.top, 12)

                Text(formattedBytes(session.currentGroupDeleteBytes))
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(CopyCatChrome.confirmGold)
                    .padding(.top, 10)

                Text("will move to Trash")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(CopyCatChrome.textSecondary)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 8) {
                    Label("Original files will be kept", systemImage: "checkmark.circle.fill")
                    Label("Duplicates will be moved to Trash", systemImage: "trash")
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(CopyCatChrome.textSecondary)
                .padding(.top, 20)

                HStack(spacing: 12) {
                    CopyCatSecondaryButton(title: "Review Again") {
                        model.showCleanupConfirm = false
                    }
                    .keyboardShortcut(.cancelAction)

                    CopyCatPrimaryButton(
                        title: "Clean Up \(formattedBytes(session.currentGroupDeleteBytes))",
                        icon: nil,
                        minWidth: 200
                    ) {
                        model.performCurrentGroupCleanup()
                    }
                    .keyboardShortcut(.defaultAction)
                }
                .padding(.top, 28)
            }
            .padding(28)
            .frame(maxWidth: 440)
            .background {
                RoundedRectangle(cornerRadius: CopyCatChrome.radius20, style: .continuous)
                    .fill(CopyCatChrome.surface)
                    .shadow(color: .black.opacity(0.35), radius: 28, y: 12)
            }
            .overlay {
                RoundedRectangle(cornerRadius: CopyCatChrome.radius20, style: .continuous)
                    .strokeBorder(CopyCatChrome.border, lineWidth: 1)
            }
            // No clipShape — dialog mascot glow must soft-bleed, not square-cut.
        }
    }

    private func undoBanner(fileCount: Int) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(CopyCatChrome.primary)
            Text(fileCount == 1 ? "1 file moved to Trash" : "\(fileCount) files moved to Trash")
                .font(.callout.weight(.medium))
                .foregroundStyle(CopyCatChrome.textPrimary)
            Spacer(minLength: 8)
            CopyCatPrimaryButton(title: "Undo", icon: nil) {
                model.undoLastTrash()
            }
            .keyboardShortcut("z", modifiers: [.command])
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(CopyCatChrome.surface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(CopyCatChrome.border.opacity(0.85), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.22), radius: 10, y: 4)
        .padding(.horizontal, 24)
    }

    private func focusedURL() -> URL? {
        guard let group = session.currentGroup else { return nil }
        if let id = focusedFileID, let file = group.files.first(where: { $0.id == id }) {
            return file.file.url
        }
        return group.keepFile?.file.url ?? group.files.first?.file.url
    }

    private func quickLookFocusedOrFirst() {
        guard let group = session.currentGroup else { return }
        FileActions.quickLook(urls: group.files.map(\.file.url), startingAt: focusedURL())
    }

    private func revealFocusedOrFirst() {
        if let url = focusedURL() { FileActions.revealInFinder(url) }
    }
}
