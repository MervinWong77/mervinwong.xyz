import SwiftUI

/// Exact Home v2 visual constants from the approved design sheet.
/// Do not reuse default SwiftUI spacing — every value here is measured.
enum HomeChrome {
    // MARK: Window (aliases CopyCatWindow — do not diverge)

    static let windowMinWidth: CGFloat = CopyCatWindow.minWidth
    static let windowMinHeight: CGFloat = CopyCatWindow.minHeight
    static let contentWidth: CGFloat = 760
    static let contentLeading: CGFloat = CopyCatWindow.horizontalInset
    static let topInset: CGFloat = CopyCatWindow.topInset
    static let bottomInset: CGFloat = CopyCatWindow.bottomInset

    // MARK: Colors

    static let backgroundTop = Color(red: 0x0E / 255, green: 0x12 / 255, blue: 0x15 / 255)
    static let backgroundBottom = Color(red: 0x10 / 255, green: 0x14 / 255, blue: 0x17 / 255)
    static let surface = Color(red: 0x17 / 255, green: 0x1D / 255, blue: 0x21 / 255)
    static let hover = Color(red: 0x1D / 255, green: 0x25 / 255, blue: 0x2A / 255)
    static let border = Color(red: 0x2A / 255, green: 0x34 / 255, blue: 0x3A / 255)
    static let primary = Color(red: 0x22 / 255, green: 0x88 / 255, blue: 0xAA / 255)
    static let primaryHover = Color(red: 0x2A / 255, green: 0xC8 / 255, blue: 0xBC / 255)
    static let ctaShadow = Color(red: 0x22 / 255, green: 0xB8 / 255, blue: 0xAA / 255)
    static let accent = Color(red: 0xF4 / 255, green: 0xB9 / 255, blue: 0x42 / 255)
    static let textPrimary = Color(red: 0xF5 / 255, green: 0xF7 / 255, blue: 0xF7 / 255)
    static let textSecondary = Color(red: 0x99 / 255, green: 0xA6 / 255, blue: 0xA8 / 255)
    static let textTertiary = Color(red: 0x68 / 255, green: 0x76 / 255, blue: 0x7C / 255)

    // MARK: Spacing (explicit)

    static let headerToHero: CGFloat = 72
    static let heroTitleToSubtitle: CGFloat = 32
    static let subtitleToDropzone: CGFloat = 72
    static let dropzoneToSelectedTitle: CGFloat = 24
    static let selectedTitleToCard: CGFloat = 8
    static let cardToCTA: CGFloat = 100
    static let ctaToSafety: CGFloat = 19

    // MARK: Mascot (delegates to CopyCatMascotMetrics — Home = 100%)

    static let mascotResourceName = "CopyCatIdle"
    static let mascotSize: CGFloat = CopyCatMascotMetrics.homeContentSide
    static let mascotNarrowSize: CGFloat = CopyCatMascotMetrics.homeNarrowContentSide
    static let mascotTop: CGFloat = 72
    static let mascotTrailing: CGFloat = 40

    // MARK: Atmosphere (SwiftUI — no raster glow / paw-trail assets yet)

    static let glowSize: CGFloat = 520
    static let glowBlur: CGFloat = 56
    static let glowOpacity: Double = 0.72
    static let glowColor = Color(red: 0x22 / 255, green: 0xB8 / 255, blue: 0xAA / 255)

    static let pawTrailCount = 5
    static let pawTrailBaseSize: CGFloat = 28
    static let pawTrailResourceName = "PawIcon"

    // MARK: Components

    static let dropzoneHeight: CGFloat = 80
    static let dropzoneRadius: CGFloat = 16
    static let dropzoneBorderWidth: CGFloat = 1.75
    static let dropzoneDash: CGFloat = 6
    static let dropzoneGap: CGFloat = 6
    static let dropzoneBorderOpacity: Double = 0.72
    static let dropzoneFolderIcon: CGFloat = 32

    static let locationCardHeight: CGFloat = 100
    static let locationCardRadius: CGFloat = 16
    static let locationCardShadowOpacity: Double = 0.28
    static let locationCardShadowRadius: CGFloat = 20
    static let locationCardShadowY: CGFloat = 8
    static let locationFolderIcon: CGFloat = 32
    static let locationDriveIcon: CGFloat = 34

    static let primaryCTAHeight: CGFloat = 52
    static let primaryCTARadius: CGFloat = 12
    static let primaryCTAMinWidth: CGFloat = 240
    static let primaryCTAShadowOpacity: Double = 0.28
    static let primaryCTAShadowRadius: CGFloat = 22
    static let primaryCTAShadowY: CGFloat = 8
    static let primaryCTAHighlightOpacity: Double = 0.14

    static let headerPaw: CGFloat = 23
    static let ctaPaw: CGFloat = 19
    static let statusPaw: CGFloat = 16
    static let folderIcon: CGFloat = 32
    static let driveIcon: CGFloat = 34
    static let shieldIcon: CGFloat = 23
    /// Circular glass Settings control (approved Home).
    static let gearIcon: CGFloat = 16
    static let gearHit: CGFloat = 36
    static let gearTrailing: CGFloat = 20
    static let gearHoverOpacity: Double = 0.12
    static let gearFillOpacity: Double = 0.07
    static let gearBorderOpacity: Double = 0.18

    // MARK: Typography

    static let heroFont = Font.system(size: 44, weight: .bold)
    static let heroLineHeight: CGFloat = 54
    static let heroTracking: CGFloat = -0.8

    static let subtitleFont = Font.system(size: 17, weight: .regular)
    static let subtitleLineHeight: CGFloat = 24

    static let sectionTitleFont = Font.system(size: 15, weight: .semibold)
    static let sectionTitleLineHeight: CGFloat = 22

    static let primaryBodyFont = Font.system(size: 15, weight: .medium)
    static let primaryBodyLineHeight: CGFloat = 22

    static let secondaryBodyFont = Font.system(size: 13, weight: .regular)
    static let secondaryBodyLineHeight: CGFloat = 18

    static let brandNameFont = Font.system(size: 20, weight: .semibold)
}

/// Soft teal wash behind the mascot — radial gradient + blur + opacity.
struct SoftTealBackgroundGlow: View {
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        HomeChrome.glowColor.opacity(0.72),
                        HomeChrome.glowColor.opacity(0.28),
                        HomeChrome.glowColor.opacity(0),
                    ],
                    center: .center,
                    startRadius: 28,
                    endRadius: HomeChrome.glowSize * 0.52
                )
            )
            .frame(width: HomeChrome.glowSize, height: HomeChrome.glowSize)
            .blur(radius: HomeChrome.glowBlur)
            .opacity(HomeChrome.glowOpacity)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

/// Animated paw prints using repeated `PawIcon` images (scale + opacity).
struct PawTrailView: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30, paused: false)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            ZStack {
                ForEach(0..<HomeChrome.pawTrailCount, id: \.self) { index in
                    paw(at: index, time: t)
                }
            }
        }
        .frame(width: 200, height: 260)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func paw(at index: Int, time: TimeInterval) -> some View {
        let stagger = Double(index) * 0.55
        let wave = (sin(time * 1.35 - stagger) + 1) * 0.5
        let opacity = 0.12 + wave * 0.38
        let scale = 0.72 + wave * 0.28
        // Arc stepping down-left from the mascot.
        let x = CGFloat(index) * -22 + 40
        let y = CGFloat(index) * 38 - 20
        let rotation = Angle.degrees(-18 + Double(index) * 8)

        return Image(HomeChrome.pawTrailResourceName)
            .resizable()
            .interpolation(.high)
            .aspectRatio(contentMode: .fit)
            .frame(width: HomeChrome.pawTrailBaseSize, height: HomeChrome.pawTrailBaseSize)
            .scaleEffect(scale)
            .opacity(opacity)
            .rotationEffect(rotation)
            .offset(x: x, y: y)
    }
}

/// Fixed 330×330 mascot slot with atmosphere (glow + paw trail).
struct MascotPlaceholder: View {
    var body: some View {
        ZStack {
            SoftTealBackgroundGlow()
            PawTrailView()
                .offset(x: -90, y: 70)
            Image(HomeChrome.mascotResourceName)
                .resizable()
                .interpolation(.high)
                .aspectRatio(contentMode: .fit)
                .frame(width: HomeChrome.mascotSize, height: HomeChrome.mascotSize)
        }
        .frame(width: HomeChrome.mascotSize, height: HomeChrome.mascotSize)
        .accessibilityHidden(true)
    }
}
