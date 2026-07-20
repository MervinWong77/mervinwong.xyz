import SwiftUI

struct ScanMetricCard: View {
    let icon: String
    let label: String
    let value: String
    var emphasize: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: ScanDesign.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(emphasize ? BrandColor.teal : BrandColor.muted)
                .accessibilityHidden(true)

            Text(label)
                .font(ScanDesign.TypeScale.metricLabel)
                .foregroundStyle(BrandColor.muted)
                .lineLimit(1)

            Text(value)
                .font(ScanDesign.TypeScale.metricValue)
                .foregroundStyle(BrandColor.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
        .padding(ScanDesign.Spacing.md)
        .scanSurface()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label), \(value)")
    }
}

struct ScanStatusPill: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
            Text(text)
                .font(ScanDesign.TypeScale.caption)
        }
        .foregroundStyle(BrandColor.muted)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background {
            Capsule(style: .continuous)
                .fill(.quaternary.opacity(0.5))
        }
        .overlay {
            Capsule(style: .continuous)
                .strokeBorder(BrandColor.ink.opacity(0.06), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }
}
