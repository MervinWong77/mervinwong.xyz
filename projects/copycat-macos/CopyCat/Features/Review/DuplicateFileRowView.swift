import SwiftUI
import CopyCatEngine

struct DuplicateFileRowView: View {
    let item: ReviewFileItem
    let isRecommendedKeep: Bool
    var isCompact: Bool = false
    let onDecision: (FileDecision) -> Void
    @State private var showMore = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.file.filename)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(CopyCatChrome.textPrimary)
                        .lineLimit(2)
                        .truncationMode(.middle)
                        .help(item.file.filename)

                    Text(item.folderPath)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(CopyCatChrome.textSecondary.opacity(0.82))
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .help(item.folderPath)

                    metadataBlock

                    if let reason = primaryReason {
                        Text(reason)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(CopyCatChrome.textTertiary)
                            .lineLimit(2)
                    }

                    actionLinks

                    DisclosureGroup(isExpanded: $showMore) {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(detailLines, id: \.self) { line in
                                Text(line)
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundStyle(CopyCatChrome.textTertiary)
                            }
                        }
                        .padding(.top, 6)
                    } label: {
                        Text("More details")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(CopyCatChrome.textTertiary)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 8) {
                    CopyCatDecisionControl(decision: item.decision, onDecision: onDecision)
                        .frame(width: 148)

                    if item.decision == .keep && isRecommendedKeep {
                        Text("Recommended")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(CopyCatChrome.primary)
                    } else if item.decision == .delete && item.recommendedDecision == .delete {
                        Text("Recommended")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(CopyCatChrome.textTertiary)
                    }
                }
                .fixedSize(horizontal: true, vertical: false)
            }
        }
        .padding(16)
        .background(rowBackground)
        .clipShape(RoundedRectangle(cornerRadius: CopyCatChrome.radius12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: CopyCatChrome.radius12, style: .continuous)
                .strokeBorder(CopyCatChrome.border.opacity(0.55), lineWidth: 1)
        }
        .contentShape(RoundedRectangle(cornerRadius: CopyCatChrome.radius12, style: .continuous))
        .onTapGesture(count: 2) {
            FileActions.revealInFinder(item.file.url)
        }
        .contextMenu {
            Button("Reveal in Finder") { FileActions.revealInFinder(item.file.url) }
            Button("Open") { FileActions.open(item.file.url) }
            Button("Quick Look") { FileActions.quickLook(item.file.url) }
            Divider()
            Button("Keep this copy") { onDecision(.keep) }
            Button("Trash this copy") { onDecision(.delete) }
        }
    }

    /// Two stable rows — never a wrapping chip cloud.
    private var metadataBlock: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(primaryMetaLine)
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(CopyCatChrome.textSecondary.opacity(0.88))
                .lineLimit(1)
                .truncationMode(.tail)

            if let dateLine = secondaryMetaLine {
                Text(dateLine)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(CopyCatChrome.textSecondary.opacity(0.88))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
    }

    private var primaryMetaLine: String {
        var parts: [String] = [formattedBytes(item.file.size)]
        if !item.file.extension.isEmpty {
            parts.append(item.file.extension.uppercased())
        }
        if let resolution = item.media.resolutionLabel {
            parts.append(resolution)
        }
        return parts.joined(separator: " · ")
    }

    private var secondaryMetaLine: String? {
        guard let modified = item.file.modifiedDate else { return nil }
        return modified.formatted(date: .abbreviated, time: .omitted)
    }

    private var actionLinks: some View {
        HStack(spacing: isCompact ? 10 : 12) {
            linkButton("Reveal") { FileActions.revealInFinder(item.file.url) }
            linkButton("Quick Look") { FileActions.quickLook(item.file.url) }
            linkButton("Open") { FileActions.open(item.file.url) }
        }
        .lineLimit(1)
        .fixedSize(horizontal: true, vertical: false)
    }

    private var primaryReason: String? {
        let reasons = item.decision == .keep ? item.keepReasons : item.deleteReasons
        return reasons.first
    }

    private var detailLines: [String] {
        var lines: [String] = []
        if let created = item.file.createdDate {
            lines.append("Created \(created.formatted(date: .abbreviated, time: .shortened))")
        }
        if let modified = item.file.modifiedDate {
            lines.append("Modified \(modified.formatted(date: .abbreviated, time: .shortened))")
        }
        if let codec = item.media.codec, !codec.isEmpty {
            lines.append("Codec \(codec)")
        }
        if let duration = item.media.durationLabel {
            lines.append("Duration \(duration)")
        }
        let reasons = item.decision == .keep ? item.keepReasons : item.deleteReasons
        for reason in reasons.dropFirst() {
            lines.append(reason)
        }
        if let hash = item.file.fullHash {
            lines.append("Hash \(hash.prefix(16))…")
        }
        return lines
    }

    private var rowBackground: Color {
        item.decision == .keep
            ? CopyCatChrome.primary.opacity(0.07)
            : CopyCatChrome.surfaceHover.opacity(0.45)
    }

    private func linkButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .buttonStyle(.plain)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(CopyCatChrome.primary)
    }
}
