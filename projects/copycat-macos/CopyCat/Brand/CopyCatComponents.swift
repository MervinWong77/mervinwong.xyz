import AppKit
import SwiftUI

// MARK: - Product chrome (8 px grid)

/// App-wide window geometry — single source of truth for every screen.
enum CopyCatWindow {
    static let minWidth: CGFloat = 1080
    static let minHeight: CGFloat = 720
    static let contentMaxWidth: CGFloat = 1200
    static let horizontalInset: CGFloat = 72
    static let topInset: CGFloat = 56
    static let bottomInset: CGFloat = 32
    /// Scanning / two-region layouts.
    static let regionGapComfortable: CGFloat = 48
    static let regionGapCompact: CGFloat = 28
    /// Left column target on Scanning (flexible; never forces overflow).
    static let scanningLeftIdealWidth: CGFloat = 500
    static let scanningLeftMinWidth: CGFloat = 420
    /// Keep the journey mascot fully inside the window (ears / glass / tail).
    static let scanningMascotTrailingSafe: CGFloat = 56
    /// Keep a gutter between left metrics and the mascot body.
    static let scanningMascotLeadingSafe: CGFloat = 28
}

enum CopyCatChrome {
    static let windowWidth: CGFloat = CopyCatWindow.minWidth
    static let windowHeight: CGFloat = CopyCatWindow.minHeight

    static let contentInset: CGFloat = CopyCatWindow.horizontalInset
    static let topInset: CGFloat = CopyCatWindow.topInset
    static let bottomInset: CGFloat = CopyCatWindow.bottomInset

    static let space1: CGFloat = 8
    static let space2: CGFloat = 16
    static let space3: CGFloat = 24
    static let space4: CGFloat = 32
    static let space5: CGFloat = 40
    static let space6: CGFloat = 48

    static let radius10: CGFloat = 10
    static let radius12: CGFloat = 12
    static let radius16: CGFloat = 16
    static let radius20: CGFloat = 20

    static let backgroundTop = Color(red: 0x0E / 255, green: 0x12 / 255, blue: 0x15 / 255)
    static let backgroundBottom = Color(red: 0x10 / 255, green: 0x14 / 255, blue: 0x17 / 255)
    static let surface = Color(red: 0x17 / 255, green: 0x1D / 255, blue: 0x21 / 255)
    static let surfaceHover = Color(red: 0x1D / 255, green: 0x25 / 255, blue: 0x2A / 255)
    static let border = Color(red: 0x2A / 255, green: 0x34 / 255, blue: 0x3A / 255)

    static let primary = Color(red: 0x22 / 255, green: 0x88 / 255, blue: 0xAA / 255)
    static let primaryHover = Color(red: 0x2A / 255, green: 0xC8 / 255, blue: 0xBC / 255)
    static let ctaShadow = Color(red: 0x22 / 255, green: 0xB8 / 255, blue: 0xAA / 255)
    static let glow = Color(red: 0x22 / 255, green: 0xB8 / 255, blue: 0xAA / 255)
    /// Warm gold — confirmation emphasis only.
    static let confirmGold = Color(red: 0xE0 / 255, green: 0xB0 / 255, blue: 0x56 / 255)

    static let textPrimary = Color(red: 0xF5 / 255, green: 0xF7 / 255, blue: 0xF7 / 255)
    static let textSecondary = Color(red: 0x99 / 255, green: 0xA6 / 255, blue: 0xA8 / 255)
    static let textTertiary = Color(red: 0x68 / 255, green: 0x76 / 255, blue: 0x7C / 255)

    static let progressTrack = Color(red: 0x1A / 255, green: 0x22 / 255, blue: 0x27 / 255)
    static let danger = Color(red: 0xEE / 255, green: 0x44 / 255, blue: 0x44 / 255)
}

// MARK: - Motion

enum CopyCatMotion {
    static let fade: Double = 0.20
    static let slide: Double = 0.30
    static let breathe: Double = 2.8
    static let tailSway: Double = 3.2
    static let metric: Double = 0.20
    static let discoveryVisible: Double = 2.2
    /// Calm walking cadence between paw plants (500–700ms).
    static let pawWalkStepMs: Int = 600
    static let scanGlassMinGap: Double = 4.0
    static let scanGlassMaxGap: Double = 6.0

    @ViewBuilder
    static func animated<V: View>(
        reduceMotion: Bool,
        _ animation: Animation,
        value: some Equatable,
        @ViewBuilder content: () -> V
    ) -> some View {
        if reduceMotion {
            content()
        } else {
            content().animation(animation, value: value)
        }
    }
}

// MARK: - Aspect-preserving asset

struct CopyCatAssetImage: View {
    let name: String
    var maxWidth: CGFloat? = nil
    var maxHeight: CGFloat? = nil

    var body: some View {
        Image(name)
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(maxWidth: maxWidth, maxHeight: maxHeight)
    }
}

/// Displays an asset cropped to opaque alpha bounds at an exact *visible* height.
struct CopyCatVisibleAssetImage: View {
    let name: String
    var visibleHeight: CGFloat
    var visibleWidth: CGFloat? = nil

    var body: some View {
        let art = CopyCatMascotArt.croppedImage(named: name)
        let aspect = art.size.width / max(art.size.height, 1)
        let height = visibleHeight
        let width = visibleWidth ?? (height * aspect)
        Image(nsImage: art)
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(width: width, height: height)
    }
}

// MARK: - Brand header

struct CopyCatBrandHeader: View {
    var showSettings: Bool = false
    var onSettings: (() -> Void)? = nil
    var trailing: AnyView? = nil

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 10) {
                CopyCatVisibleAssetImage(name: "PawIcon", visibleHeight: HomeChrome.headerPaw)
                Text("CopyCat")
                    .font(HomeChrome.brandNameFont)
                    .foregroundStyle(CopyCatChrome.textPrimary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)

            Spacer(minLength: 0)

            if let trailing {
                trailing
            } else if showSettings {
                CopyCatSettingsControl {
                    onSettings?()
                }
            }
        }
        .frame(height: 36)
    }
}

/// Native macOS-style Settings control — SF Symbol gear in a circular glass button.
struct CopyCatSettingsControl: View {
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 16, weight: .semibold))
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(Color.white.opacity(0.92))
                .frame(width: HomeChrome.gearHit, height: HomeChrome.gearHit)
                .contentShape(Circle())
        }
        .buttonStyle(CopyCatSettingsGlassButtonStyle(isHovered: isHovered))
        .onHover { isHovered = $0 }
        .help("Open Settings")
        .accessibilityLabel("Settings")
        .accessibilityAddTraits(.isButton)
    }
}

/// Glass circle chrome with hover + pressed feedback (no overlay stealing hits).
private struct CopyCatSettingsGlassButtonStyle: ButtonStyle {
    var isHovered: Bool

    func makeBody(configuration: Configuration) -> some View {
        let fillOpacity: Double = {
            if configuration.isPressed { return 0.16 }
            if isHovered { return HomeChrome.gearHoverOpacity }
            return HomeChrome.gearFillOpacity
        }()

        configuration.label
            .background(
                Circle()
                    .fill(Color.white.opacity(fillOpacity))
            )
            .overlay {
                Circle()
                    .strokeBorder(Color.white.opacity(HomeChrome.gearBorderOpacity), lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
            .contentShape(Circle())
    }
}

// MARK: - Buttons

struct CopyCatPrimaryButton: View {
    let title: String
    var icon: String? = "PawIcon"
    var iconMaxHeight: CGFloat = 16
    var isEnabled: Bool = true
    var minWidth: CGFloat? = nil
    /// Slightly tighter padding for narrow window chrome.
    var compact: Bool = false
    let action: () -> Void

    @State private var isPressed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: action) {
            HStack(spacing: compact ? 8 : 10) {
                if let icon {
                    CopyCatVisibleAssetImage(name: icon, visibleHeight: iconMaxHeight)
                }
                Text(title)
                    .font(.system(size: compact ? 13 : 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .padding(.horizontal, compact ? 20 : 32)
            .frame(minWidth: minWidth)
            .frame(height: compact ? 42 : HomeChrome.primaryCTAHeight)
            .background {
                RoundedRectangle(cornerRadius: HomeChrome.primaryCTARadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [CopyCatChrome.primary, CopyCatChrome.primaryHover],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: HomeChrome.primaryCTARadius, style: .continuous)
                    .strokeBorder(Color.white.opacity(HomeChrome.primaryCTAHighlightOpacity), lineWidth: 1)
                    .mask(
                        VStack(spacing: 0) {
                            Rectangle().frame(height: 1)
                            Spacer(minLength: 0)
                        }
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: HomeChrome.primaryCTARadius, style: .continuous))
            .shadow(
                color: CopyCatChrome.ctaShadow.opacity(
                    isPressed ? HomeChrome.primaryCTAShadowOpacity * 0.45 : HomeChrome.primaryCTAShadowOpacity
                ),
                radius: isPressed ? 10 : HomeChrome.primaryCTAShadowRadius,
                x: 0,
                y: isPressed ? 3 : HomeChrome.primaryCTAShadowY
            )
            .scaleEffect(isPressed && !reduceMotion ? 0.98 : 1.0)
            .contentShape(RoundedRectangle(cornerRadius: CopyCatChrome.radius12, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.45)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

struct CopyCatSecondaryButton: View {
    let title: String
    var isEnabled: Bool = true
    /// Slightly tighter padding for narrow window chrome.
    var compact: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: compact ? 13 : 14, weight: .medium))
                .foregroundStyle(CopyCatChrome.textSecondary)
                .padding(.horizontal, compact ? 12 : CopyCatChrome.space2)
                .frame(height: compact ? 32 : 36)
                .background(
                    RoundedRectangle(cornerRadius: CopyCatChrome.radius10, style: .continuous)
                        .fill(CopyCatChrome.surface)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: CopyCatChrome.radius10, style: .continuous)
                        .strokeBorder(CopyCatChrome.border.opacity(0.85), lineWidth: 1)
                }
                .contentShape(RoundedRectangle(cornerRadius: CopyCatChrome.radius10, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.45)
    }
}

enum CopyCatIconSource {
    case asset(String)
    case system(String)
}

struct CopyCatIconButton: View {
    let systemOrAsset: CopyCatIconSource
    var accessibilityLabel: String
    var hitSize: CGFloat = 36
    var iconMax: CGFloat = 18
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                switch systemOrAsset {
                case .asset(let name):
                    CopyCatAssetImage(name: name, maxWidth: iconMax, maxHeight: iconMax)
                case .system(let name):
                    Image(systemName: name)
                        .font(.system(size: iconMax * 0.85, weight: .medium))
                        .foregroundStyle(CopyCatChrome.textSecondary)
                }
            }
            .frame(width: hitSize, height: hitSize)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

// MARK: - Progress + metrics

struct CopyCatProgressBar: View {
    var value: Double
    /// Fixed width when set; otherwise fills the parent (preferred for responsive layouts).
    var width: CGFloat? = 440
    var height: CGFloat = 8
    var showsShimmer: Bool = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geo in
            let capped = min(max(value, 0), 1)
            let fillWidth = max(height, geo.size.width * capped)
            ZStack(alignment: .leading) {
                Capsule().fill(CopyCatChrome.progressTrack)
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [CopyCatChrome.primary, CopyCatChrome.primaryHover],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: fillWidth)
                    .overlay {
                        if showsShimmer && !reduceMotion && capped > 0.02 {
                            progressShimmer(fillWidth: fillWidth, height: height)
                        }
                    }
                    .clipShape(Capsule())
            }
        }
        .frame(height: height)
        .frame(width: width)
        .frame(maxWidth: width == nil ? .infinity : nil)
        .clipShape(Capsule())
        .accessibilityValue(Text("\(Int((min(max(value, 0), 1)) * 100)) percent"))
    }

    @ViewBuilder
    private func progressShimmer(fillWidth: CGFloat, height: CGFloat) -> some View {
        TimelineView(.animation(minimumInterval: 1 / 30, paused: false)) { timeline in
            let period = 2.4
            let t = timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: period) / period
            let band = max(28, fillWidth * 0.32)
            let travel = fillWidth + band
            let x = CGFloat(t) * travel - band
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.22),
                            Color.white.opacity(0),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: band, height: height)
                .offset(x: x)
                .allowsHitTesting(false)
        }
    }
}

struct CopyCatMetric: View {
    let value: String
    let label: String

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(CopyCatChrome.textPrimary)
                .monospacedDigit()
                .contentTransition(reduceMotion ? .identity : .numericText())
                .animation(
                    reduceMotion ? nil : .easeInOut(duration: CopyCatMotion.metric),
                    value: value
                )
            Text(label)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(CopyCatChrome.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Location card

struct CopyCatLocationCard: View {
    let title: String
    let path: String
    let sizeLabel: String
    let estimateLabel: String
    var isVolume: Bool = false
    var onRemove: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .center, spacing: CopyCatChrome.space2) {
            CopyCatVisibleAssetImage(
                name: isVolume ? "DriveIcon" : "FolderIcon",
                visibleHeight: isVolume ? HomeChrome.locationDriveIcon : HomeChrome.locationFolderIcon
            )
            .frame(width: 48, height: 44, alignment: .center)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(CopyCatChrome.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.middle)

                Text(path)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(CopyCatChrome.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .help(path)

                HStack(spacing: CopyCatChrome.space2) {
                    HStack(spacing: 6) {
                        Circle().fill(CopyCatChrome.primary).frame(width: 6, height: 6)
                        Text(sizeLabel)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(CopyCatChrome.textSecondary)
                    }
                    Text(estimateLabel)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(CopyCatChrome.textTertiary)
                }
            }

            Spacer(minLength: 0)

            if let onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(CopyCatChrome.textTertiary)
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.trailing, 10)
                .accessibilityLabel("Remove \(title)")
            }
        }
        .padding(.leading, CopyCatChrome.space2)
        .frame(height: HomeChrome.locationCardHeight, alignment: .leading)
        .background(CopyCatChrome.surface)
        .clipShape(RoundedRectangle(cornerRadius: HomeChrome.locationCardRadius, style: .continuous))
        .shadow(
            color: Color.black.opacity(HomeChrome.locationCardShadowOpacity),
            radius: HomeChrome.locationCardShadowRadius,
            y: HomeChrome.locationCardShadowY
        )
    }
}

// MARK: - Queue item

struct CopyCatQueueItem: View {
    let title: String
    let sizeLabel: String
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? CopyCatChrome.textPrimary : CopyCatChrome.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .help(title)
                Text(sizeLabel)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(CopyCatChrome.textTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: CopyCatChrome.radius10, style: .continuous)
                    .fill(rowFill)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 6)
        .onHover { isHovered = $0 }
    }

    private var rowFill: Color {
        if isSelected { return CopyCatChrome.primary.opacity(0.18) }
        if isHovered { return CopyCatChrome.surfaceHover.opacity(0.5) }
        return .clear
    }
}

// MARK: - Decision control

struct CopyCatDecisionControl: View {
    let decision: FileDecision
    let onDecision: (FileDecision) -> Void

    var body: some View {
        HStack(spacing: 0) {
            segment(title: "Keep", selected: decision == .keep) {
                onDecision(.keep)
            }
            segment(title: "Trash", selected: decision == .delete) {
                onDecision(.delete)
            }
        }
        .padding(1.5)
        .background(CopyCatChrome.progressTrack)
        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .strokeBorder(CopyCatChrome.border.opacity(0.75), lineWidth: 1)
        }
    }

    private func segment(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(selected ? CopyCatChrome.textPrimary : CopyCatChrome.textTertiary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 7.5, style: .continuous)
                        .fill(selected ? CopyCatChrome.primary.opacity(0.34) : .clear)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Sticky action bar

struct CopyCatStickyActionBar<Leading: View, Trailing: View>: View {
    @ViewBuilder var leading: () -> Leading
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        HStack(spacing: CopyCatChrome.space2) {
            leading()
            Spacer(minLength: 8)
            trailing()
        }
        .padding(.horizontal, CopyCatChrome.space2)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: CopyCatChrome.radius16, style: .continuous)
                .fill(CopyCatChrome.surface.opacity(0.96))
        )
        .overlay {
            RoundedRectangle(cornerRadius: CopyCatChrome.radius16, style: .continuous)
                .strokeBorder(CopyCatChrome.border.opacity(0.75), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.16), radius: 10, y: 3)
    }
}

// MARK: - Shared mascot sizing (perceived alpha height)

/// Product-wide mascot scale roles — sized by *visible* content, not PNG canvas.
enum CopyCatMascotRole: Equatable {
    case home
    case journey
    case dialog
    case toast
}

/// Explicit perceived visual-height targets (opaque alpha bounds).
enum CopyCatMascotMetrics {
    /// Home hero visible mascot height.
    static let homeVisibleHeight: CGFloat = 310
    static let homeNarrowVisibleHeight: CGFloat = 290
    /// Scanning / Verifying / Found / Cleanup — one shared journey height.
    static let journeyVisibleHeight: CGFloat = 285
    static let journeyCompactVisibleHeight: CGFloat = 270
    static let dialogVisibleHeight: CGFloat = 195
    static let toastVisibleHeight: CGFloat = 38

    /// Glow diameter as a multiple of visible mascot *width* (2.5–3×).
    static let glowDiameterFactor: CGFloat = 2.75
    /// Soft radial stops (fade to clear — no hard edge).
    static let glowInnerOpacity: Double = 0.22
    static let glowMidOpacity: Double = 0.18
    static let glowOuterOpacity: Double = 0.10
    /// Layout reservation around the mascot body (glow may bleed beyond this).
    static let stageBleedFactor: CGFloat = 1.45

    /// Walking-path paw trail (scanning / home).
    static let pawTrailCount = 5
    /// Relative vertical offsets along a walking path (baseline, then staggered).
    static let pawTrailVerticalOffsets: [CGFloat] = [0, 6, -4, 8, -6]
    /// Lift the whole trail so positive offsets are not clipped under the stage.
    static let pawTrailFloorLift: CGFloat = -18
    static let pawTrailHorizontalSpacing: CGFloat = 16
    /// Opacity by age since plant (0 = newest). Continuous walk, not an entrance burst.
    static let pawWalkOpacityByAge: [Double] = [0.48, 0.34, 0.24, 0.16, 0.10]
    static let pawTrailStaticOpacity: Double = 0.18

    static func visibleHeight(
        role: CopyCatMascotRole,
        narrowHome: Bool = false,
        compactJourney: Bool = false
    ) -> CGFloat {
        switch role {
        case .home:
            return narrowHome ? homeNarrowVisibleHeight : homeVisibleHeight
        case .journey:
            return compactJourney ? journeyCompactVisibleHeight : journeyVisibleHeight
        case .dialog:
            return dialogVisibleHeight
        case .toast:
            return toastVisibleHeight
        }
    }

    /// Layout reservation around the visible mascot (glow intentionally may overflow).
    static func stageSide(visibleHeight: CGFloat) -> CGFloat {
        visibleHeight * stageBleedFactor
    }

    /// Ambient glow diameter from perceived mascot width, soft-capped so the
    /// radial fade completes before window/content edges (avoids a clipped box).
    static func glowDiameter(mascotWidth: CGFloat, visibleHeight: CGFloat) -> CGFloat {
        let target = mascotWidth * glowDiameterFactor
        let maxComfortable = visibleHeight * 2.05
        return min(target, maxComfortable)
    }

    // Backward-compatible aliases used by Home layout helpers.
    static var homeContentSide: CGFloat { homeVisibleHeight }
    static var homeNarrowContentSide: CGFloat { homeNarrowVisibleHeight }

    static func contentSide(
        role: CopyCatMascotRole,
        narrowHome: Bool = false,
        compactJourney: Bool = false
    ) -> CGFloat {
        visibleHeight(role: role, narrowHome: narrowHome, compactJourney: compactJourney)
    }

    static func stageSide(contentSide: CGFloat) -> CGFloat {
        stageSide(visibleHeight: contentSide)
    }
}

/// Crops bitmaps to opaque *character* bounds so transparent padding cannot shrink
/// perceived size. Soft teal atmospheric bloom baked into some PNGs is cleared so
/// it cannot render as a square glow plate (artwork files are not modified).
enum CopyCatMascotArt {
    private static var cache: [String: NSImage] = [:]
    private static let lock = NSLock()

    static func croppedImage(named name: String) -> NSImage {
        lock.lock()
        defer { lock.unlock() }
        if let cached = cache[name] { return cached }

        guard let source = NSImage(named: name),
              let cgSource = source.cgImage(forProposedRect: nil, context: nil, hints: nil)
        else {
            let fallback = NSImage(named: name) ?? NSImage(size: NSSize(width: 1, height: 1))
            cache[name] = fallback
            return fallback
        }

        let w = cgSource.width
        let h = cgSource.height
        let bytesPerRow = w * 4
        var pixels = [UInt8](repeating: 0, count: h * bytesPerRow)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        guard let ctx = CGContext(
            data: &pixels,
            width: w,
            height: h,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            cache[name] = source
            return source
        }
        ctx.draw(cgSource, in: CGRect(x: 0, y: 0, width: w, height: h))

        var minX = w, minY = h, maxX = 0, maxY = 0
        for y in 0..<h {
            for x in 0..<w {
                let i = (y * w + x) * 4
                let r = CGFloat(pixels[i]) / 255
                let g = CGFloat(pixels[i + 1]) / 255
                let b = CGFloat(pixels[i + 2]) / 255
                let a = CGFloat(pixels[i + 3]) / 255
                if isAtmosphericGlow(r: r, g: g, b: b, a: a) {
                    pixels[i] = 0
                    pixels[i + 1] = 0
                    pixels[i + 2] = 0
                    pixels[i + 3] = 0
                    continue
                }
                if pixels[i + 3] > 12 {
                    minX = min(minX, x)
                    minY = min(minY, y)
                    maxX = max(maxX, x)
                    maxY = max(maxY, y)
                }
            }
        }

        guard minX <= maxX, minY <= maxY,
              let cleaned = ctx.makeImage(),
              let cut = cleaned.cropping(
                to: CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
              )
        else {
            cache[name] = source
            return source
        }

        let cropped = NSImage(
            cgImage: cut,
            size: NSSize(width: cut.width, height: cut.height)
        )
        cropped.isTemplate = false
        cache[name] = cropped
        return cropped
    }

    /// Soft teal bloom behind the character — not fur, eyes, or props.
    private static func isAtmosphericGlow(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> Bool {
        guard a > 0.02, a < 0.72 else { return false }
        guard g > r + 0.045, b > r + 0.02, g > 0.14, r < 0.48 else { return false }
        let luma = 0.299 * r + 0.587 * g + 0.114 * b
        return luma < 0.52
    }
}

// MARK: - Mascot ambient glow

/// Soft multi-layer radial wash behind the mascot.
/// Drawn as radial fills on square frames that fade to **full** transparency before
/// the frame edge — so even if a parent clips, there is no glowing rectangle.
struct CopyCatMascotAmbientGlow: View {
    var mascotWidth: CGFloat
    var visibleHeight: CGFloat
    var breathe: Bool = false

    private var diameter: CGFloat {
        CopyCatMascotMetrics.glowDiameter(mascotWidth: mascotWidth, visibleHeight: visibleHeight)
    }

    var body: some View {
        let d = diameter
        ZStack {
            glowLayer(
                size: d,
                peak: CopyCatMascotMetrics.glowOuterOpacity
            )
            glowLayer(
                size: d * 0.78,
                peak: CopyCatMascotMetrics.glowMidOpacity
            )
            glowLayer(
                size: d * 0.48,
                peak: CopyCatMascotMetrics.glowInnerOpacity
            )
        }
        .frame(width: d, height: d)
        .scaleEffect(breathe ? 1.03 : 1.0)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func glowLayer(size: CGFloat, peak: Double) -> some View {
        // endRadius reaches the mid-edge at opacity 0 → corners stay fully clear (no box).
        RadialGradient(
            colors: [
                CopyCatChrome.glow.opacity(peak),
                CopyCatChrome.glow.opacity(peak * 0.45),
                CopyCatChrome.glow.opacity(peak * 0.12),
                CopyCatChrome.glow.opacity(0),
            ],
            center: .center,
            startRadius: 0,
            endRadius: size * 0.50
        )
        .frame(width: size, height: size)
    }
}

// MARK: - Mascot stage

struct CopyCatMascotStage: View {
    let resourceName: String
    var role: CopyCatMascotRole = .home
    var narrowHome: Bool = false
    var compactJourney: Bool = false
    var showGlow: Bool = true
    var pawCount: Int = 0
    var idleMotion: Bool = true
    var scanMotion: Bool = false
    /// Continuous walking paw trail while scanning (not a one-shot pulse).
    var reactivePawTrail: Bool = false
    /// Where the mascot art sits inside the stage slot (scanning uses trailing).
    var stageContentAlignment: Alignment = .center

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var breathe = false
    @State private var tailAngle: Double = 0
    @State private var glassOffset: CGFloat = 0
    @State private var scanMotionTask: Task<Void, Never>?
    @State private var pawWalkTask: Task<Void, Never>?
    /// Generation when each paw was last planted (−1 = not yet).
    @State private var pawPlantGeneration: [Int] = Array(
        repeating: -1,
        count: CopyCatMascotMetrics.pawTrailCount
    )
    @State private var pawWalkHead = 0
    @State private var pawWalkGeneration = 0

    private var visibleHeight: CGFloat {
        CopyCatMascotMetrics.visibleHeight(
            role: role,
            narrowHome: narrowHome,
            compactJourney: compactJourney
        )
    }

    private var stageSide: CGFloat {
        CopyCatMascotMetrics.stageSide(visibleHeight: visibleHeight)
    }

    private var activePawCount: Int {
        min(max(pawCount, 0), CopyCatMascotMetrics.pawTrailCount)
    }

    private var motionEnabled: Bool { idleMotion && !reduceMotion }
    private var tailMotionEnabled: Bool { scanMotion && !reduceMotion }

    var body: some View {
        let art = CopyCatMascotArt.croppedImage(named: resourceName)
        let aspect = art.size.width / max(art.size.height, 1)
        let artWidth = visibleHeight * aspect

        ZStack {
            if showGlow {
                CopyCatMascotAmbientGlow(
                    mascotWidth: artWidth,
                    visibleHeight: visibleHeight,
                    breathe: breathe && motionEnabled
                )
            }

            ZStack(alignment: .bottom) {
                Image(nsImage: art)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: artWidth, height: visibleHeight, alignment: .bottom)
                    .scaleEffect(breathe && motionEnabled ? 1.015 : 1.0, anchor: .bottom)
                    .rotationEffect(.degrees(tailMotionEnabled ? tailAngle : 0), anchor: .bottom)
                    .offset(x: (scanMotion && !reduceMotion) ? glassOffset : 0)

                if activePawCount > 0 {
                    HStack(spacing: CopyCatMascotMetrics.pawTrailHorizontalSpacing) {
                        ForEach(0..<activePawCount, id: \.self) { index in
                            CopyCatVisibleAssetImage(
                                name: "PawIcon",
                                visibleHeight: max(13, visibleHeight * 0.055)
                            )
                            .opacity(pawDisplayOpacity(at: index))
                            .rotationEffect(.degrees(-16 + Double(index) * 8))
                            .offset(
                                x: CGFloat(index - (activePawCount - 1) / 2) * 3,
                                y: pawTrailY(at: index)
                            )
                        }
                    }
                    .offset(y: CopyCatMascotMetrics.pawTrailFloorLift)
                    .allowsHitTesting(false)
                }
            }
            .frame(width: artWidth, height: visibleHeight, alignment: .bottom)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: stageContentAlignment)
        }
        // Layout slot follows mascot stage size — glow may soft-bleed inside the parent
        // region, but must not inflate this frame or shove the art into the left column.
        .frame(width: stageSide, height: stageSide, alignment: .center)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onAppear { startIdleMotion() }
        .onDisappear {
            stopScanMotion()
            stopPawWalk()
        }
        .onChange(of: scanMotion) { _, enabled in
            if enabled { startScanMotionLoop() } else { stopScanMotion() }
            syncPawWalk()
        }
        .onChange(of: reactivePawTrail) { _, _ in
            syncPawWalk()
        }
        .onChange(of: reduceMotion) { _, reduced in
            if reduced {
                breathe = false
                tailAngle = 0
                glassOffset = 0
                stopScanMotion()
                stopPawWalk()
                applyStaticPawTrail()
            } else {
                startIdleMotion()
                syncPawWalk()
            }
        }
    }

    private func pawTrailY(at index: Int) -> CGFloat {
        index < CopyCatMascotMetrics.pawTrailVerticalOffsets.count
            ? CopyCatMascotMetrics.pawTrailVerticalOffsets[index]
            : 0
    }

    private func pawDisplayOpacity(at index: Int) -> Double {
        if reduceMotion || !reactivePawTrail {
            return CopyCatMascotMetrics.pawTrailStaticOpacity
                + Double(index) * 0.02
        }
        let planted = index < pawPlantGeneration.count ? pawPlantGeneration[index] : -1
        guard planted >= 0 else { return 0 }
        let age = max(0, pawWalkGeneration - 1 - planted)
        let curve = CopyCatMascotMetrics.pawWalkOpacityByAge
        if age < curve.count {
            return curve[age]
        }
        return max(0.06, curve.last! * 0.7)
    }

    private func startIdleMotion() {
        if motionEnabled {
            withAnimation(.easeInOut(duration: CopyCatMotion.breathe).repeatForever(autoreverses: true)) {
                breathe = true
            }
        }
        if tailMotionEnabled {
            tailAngle = -2
            withAnimation(.easeInOut(duration: CopyCatMotion.tailSway).repeatForever(autoreverses: true)) {
                tailAngle = 2
            }
        }
        if scanMotion { startScanMotionLoop() }
        syncPawWalk()
    }

    private func startScanMotionLoop() {
        guard scanMotion, !reduceMotion else { return }
        stopScanMotion()
        scanMotionTask = Task { @MainActor in
            while !Task.isCancelled {
                let gap = Double.random(
                    in: CopyCatMotion.scanGlassMinGap...CopyCatMotion.scanGlassMaxGap
                )
                try? await Task.sleep(for: .seconds(gap))
                guard !Task.isCancelled, !reduceMotion, scanMotion else { return }
                withAnimation(.easeInOut(duration: 0.55)) { glassOffset = 8 }
                try? await Task.sleep(for: .seconds(0.55))
                guard !Task.isCancelled else { return }
                withAnimation(.easeInOut(duration: 0.70)) { glassOffset = -8 }
                try? await Task.sleep(for: .seconds(0.70))
                guard !Task.isCancelled else { return }
                withAnimation(.easeInOut(duration: 0.45)) { glassOffset = 0 }
                try? await Task.sleep(for: .seconds(0.45))
            }
        }
    }

    private func stopScanMotion() {
        scanMotionTask?.cancel()
        scanMotionTask = nil
        glassOffset = 0
    }

    private func syncPawWalk() {
        if reactivePawTrail, !reduceMotion, activePawCount > 0 {
            startPawWalk()
        } else {
            stopPawWalk()
            if activePawCount > 0 {
                applyStaticPawTrail()
            }
        }
    }

    private func applyStaticPawTrail() {
        // Static trail for Reduce Motion / non-scanning — no step animation.
        pawWalkTask?.cancel()
        pawWalkTask = nil
        let n = CopyCatMascotMetrics.pawTrailCount
        pawPlantGeneration = (0..<n).map { $0 }
        pawWalkGeneration = n
        pawWalkHead = 0
    }

    private func startPawWalk() {
        guard reactivePawTrail, !reduceMotion, activePawCount > 0 else { return }
        if pawWalkTask != nil { return }
        let n = CopyCatMascotMetrics.pawTrailCount
        pawPlantGeneration = Array(repeating: -1, count: n)
        pawWalkHead = 0
        pawWalkGeneration = 0
        pawWalkTask = Task { @MainActor in
            while !Task.isCancelled {
                guard reactivePawTrail, !reduceMotion, activePawCount > 0 else { return }
                plantNextPaw()
                try? await Task.sleep(
                    for: .milliseconds(CopyCatMotion.pawWalkStepMs)
                )
            }
        }
    }

    private func stopPawWalk() {
        pawWalkTask?.cancel()
        pawWalkTask = nil
    }

    private func plantNextPaw() {
        let count = activePawCount
        guard count > 0 else { return }
        let index = pawWalkHead % count
        withAnimation(.easeOut(duration: 0.35)) {
            if index < pawPlantGeneration.count {
                pawPlantGeneration[index] = pawWalkGeneration
            }
            pawWalkGeneration += 1
            pawWalkHead = (pawWalkHead + 1) % count
        }
    }
}

// MARK: - Discovery toast

struct CopyCatDiscoveryToast: View {
    let filename: String
    let recoverableLabel: String

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            CopyCatVisibleAssetImage(
                name: "CopyCatFound",
                visibleHeight: CopyCatMascotMetrics.toastVisibleHeight
            )

            VStack(alignment: .leading, spacing: 2) {
                Text("Found another twin")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(CopyCatChrome.textPrimary)
                Text(filename)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(CopyCatChrome.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text(recoverableLabel)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(CopyCatChrome.primaryHover)
            }
        }
        .padding(.horizontal, CopyCatChrome.space2)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(CopyCatChrome.surface)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(CopyCatChrome.border.opacity(0.9), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.28), radius: 18, y: 8)
        .frame(maxWidth: 320, alignment: .leading)
    }
}

// MARK: - Shell atmosphere

private struct CopyCatVignette: View {
    var body: some View {
        RadialGradient(
            colors: [
                Color.clear,
                Color.black.opacity(0.18),
                Color.black.opacity(0.42),
            ],
            center: .center,
            startRadius: 220,
            endRadius: 720
        )
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

private struct CopyCatGrain: View {
    var body: some View {
        Canvas { context, size in
            var rng = SeededGenerator(seed: 42)
            for _ in 0..<900 {
                let x = CGFloat.random(in: 0...size.width, using: &rng)
                let y = CGFloat.random(in: 0...size.height, using: &rng)
                let a = Double.random(in: 0.015...0.045, using: &rng)
                let r: CGFloat = Bool.random(using: &rng) ? 0.7 : 0.5
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: r, height: r)),
                    with: .color(.white.opacity(a))
                )
            }
        }
        .ignoresSafeArea()
        .blendMode(.overlay)
        .opacity(0.55)
        .allowsHitTesting(false)
    }
}

private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed == 0 ? 0xDEADBEEF : seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

// MARK: - App frame + shell

/// Shared content frame for every product screen.
/// Provides inset, max-width centering, and clipping so resize never crops chrome.
struct CopyCatAppFrame<Content: View>: View {
    var maxContentWidth: CGFloat = CopyCatWindow.contentMaxWidth
    var applyHorizontalInset: Bool = true
    var applyBottomInset: Bool = true
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: maxContentWidth, maxHeight: .infinity)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(.horizontal, applyHorizontalInset ? CopyCatWindow.horizontalInset : 0)
            .padding(.bottom, applyBottomInset ? CopyCatWindow.bottomInset : 0)
            // Do not clip — mascot ambient glow must bleed past the content frame.
    }
}

struct CopyCatAppShell<Content: View>: View {
    var showSettings: Bool = false
    var onSettings: (() -> Void)? = nil
    var showAtmosphere: Bool = true
    var atmosphereAlignment: Alignment = .topTrailing
    var trailing: AnyView? = nil
    /// When false, the screen manages its own horizontal inset (rare). Default uses CopyCatAppFrame.
    var useAppFrame: Bool = true
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [CopyCatChrome.backgroundTop, CopyCatChrome.backgroundBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            if showAtmosphere {
                // Soft page wash — pure radial, no blur (blur rasterizes into a square plate).
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                CopyCatChrome.glow.opacity(0.20),
                                CopyCatChrome.glow.opacity(0.10),
                                CopyCatChrome.glow.opacity(0.04),
                                CopyCatChrome.glow.opacity(0),
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 360
                        )
                    )
                    .frame(width: 720, height: 720)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: atmosphereAlignment)
                    .padding(.trailing, atmosphereAlignment == .trailing || atmosphereAlignment == .topTrailing ? 24 : 0)
                    .padding(.top, atmosphereAlignment == .topTrailing ? 48 : 0)
                    .allowsHitTesting(false)
            }

            CopyCatVignette()
                .allowsHitTesting(false)
            CopyCatGrain()
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                CopyCatBrandHeader(
                    showSettings: showSettings,
                    onSettings: onSettings,
                    trailing: trailing
                )
                .padding(.horizontal, CopyCatWindow.horizontalInset)
                .padding(.top, CopyCatWindow.topInset)
                // Keep chrome above any decorative layers for reliable hit testing.
                .zIndex(2)

                if useAppFrame {
                    CopyCatAppFrame {
                        content()
                    }
                    .zIndex(1)
                } else {
                    content()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .zIndex(1)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .preferredColorScheme(.dark)
    }
}
