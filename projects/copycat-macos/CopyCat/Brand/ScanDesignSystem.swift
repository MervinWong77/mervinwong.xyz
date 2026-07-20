import SwiftUI

/// Presentation tokens for the scanning experience (UI only — not engine).
enum ScanDesign {
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 40
    }

    enum Radius {
        static let card: CGFloat = 14
        static let hero: CGFloat = 22
        static let pill: CGFloat = 100
        static let control: CGFloat = 10
    }

    enum TypeScale {
        /// ~34 pt display — scales with Dynamic Type
        static let heroTitle = Font.system(.largeTitle, design: .rounded).weight(.semibold)
        /// ~16 pt supporting
        static let heroSubtitle = Font.title3
        /// ~13 pt phase
        static let phase = Font.subheadline.weight(.medium)
        /// Metric label ~13 pt
        static let metricLabel = Font.subheadline.weight(.medium)
        /// Metric value ~26 pt
        static let metricValue = Font.system(.title, design: .rounded).weight(.semibold)
        /// Footer / pills
        static let caption = Font.caption.weight(.medium)
    }

    static let contentMaxWidth: CGFloat = 560
    /// Legacy tall hero — prefer `compactMascotHeight` for the scanning experience.
    static let heroHeight: CGFloat = 240
    /// Tight mascot stage — no empty dashboard panel.
    static let compactMascotHeight: CGFloat = 148
}

struct ScanMaterialBackground: View {
    var body: some View {
        ZStack {
            DesignTokens.ColorToken.surfacePrimary
            LinearGradient(
                colors: [
                    DesignTokens.ColorToken.accentPrimary.opacity(0.06),
                    Color.clear,
                    DesignTokens.ColorToken.textPrimary.opacity(0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .ignoresSafeArea()
    }
}

struct ScanSurfaceModifier: ViewModifier {
    var cornerRadius: CGFloat = ScanDesign.Radius.card

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.regularMaterial)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(DesignTokens.ColorToken.borderDefault, lineWidth: 1)
            }
            .shadow(color: DesignTokens.ColorToken.textPrimary.opacity(0.06), radius: 10, y: 4)
    }
}

extension View {
    func scanSurface(cornerRadius: CGFloat = ScanDesign.Radius.card) -> some View {
        modifier(ScanSurfaceModifier(cornerRadius: cornerRadius))
    }
}
