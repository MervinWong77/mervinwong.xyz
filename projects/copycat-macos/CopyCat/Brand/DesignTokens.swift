import SwiftUI

/// Asset-catalog + typography tokens from design handoff.
/// Never use raw HEX in feature views — reference these or `Color("…")`.
enum DesignTokens {
    enum ColorToken {
        static let surfacePrimary = Color("SurfacePrimary")
        static let surfaceSecondary = Color("SurfaceSecondary")
        static let textPrimary = Color("TextPrimary")
        static let textSecondary = Color("TextSecondary")
        static let accentPrimary = Color("AccentPrimary")
        static let success = Color("Success")
        static let warning = Color("Warning")
        static let danger = Color("Danger")
        static let info = Color("Info")
        static let borderDefault = Color("BorderDefault")

        static let journeyIdle = Color("JourneyIdle")
        static let journeyScanning = Color("JourneyScanning")
        static let journeyVerifying = Color("JourneyVerifying")
        static let journeyDuplicates = Color("JourneyDuplicates")
        static let journeyCleanup = Color("JourneyCleanup")
        static let journeyComplete = Color("JourneyComplete")
        static let journeyError = Color("JourneyError")
    }

    enum Typography {
        static let display = Font.system(size: 40, weight: .bold, design: .default)
        static let h1 = Font.system(size: 34, weight: .bold, design: .default)
        static let h2 = Font.system(size: 28, weight: .semibold, design: .default)
        static let h3 = Font.system(size: 22, weight: .semibold, design: .default)
        static let title = Font.system(size: 17, weight: .semibold, design: .default)
        static let body = Font.system(size: 15, weight: .regular, design: .default)
        static let bodyEmphasis = Font.system(size: 15, weight: .medium, design: .default)
        static let caption = Font.system(size: 13, weight: .regular, design: .default)
        static let footnote = Font.system(size: 11, weight: .regular, design: .default)
        static let mono = Font.system(size: 12, weight: .regular, design: .monospaced)
    }

    enum Spacing {
        static let xs: CGFloat = 8
        static let sm: CGFloat = 16
        static let md: CGFloat = 24
        static let lg: CGFloat = 32
        static let page: CGFloat = 32
        static let contentMaxWidth: CGFloat = 960
    }

    enum Radius {
        static let card: CGFloat = 14
        static let control: CGFloat = 10
        static let pill: CGFloat = 100
    }
}

/// Backward-compatible brand aliases → design tokens.
enum BrandColor {
    static let teal = DesignTokens.ColorToken.accentPrimary
    static let mark = DesignTokens.ColorToken.surfaceSecondary
    static let plate = DesignTokens.ColorToken.accentPrimary
    static let ink = DesignTokens.ColorToken.textPrimary
    static let muted = DesignTokens.ColorToken.textSecondary
    static let softFill = DesignTokens.ColorToken.surfacePrimary
}
