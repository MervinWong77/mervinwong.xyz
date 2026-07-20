import SwiftUI

/// Flat geometric CopyCat mascot with calm walk / blink / tail motion.
struct CopyCatMascotView: View {
    var facingRight: Bool = true
    var lift: CGFloat = 0
    /// 0…1 blink amount (1 = eyes closed)
    var blink: CGFloat = 0
    /// Tail wag angle in degrees
    var tailWag: Double = 0
    var proud: Bool = false

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let yLift = lift + (proud ? -6 : 0)

            // Tail
            var tail = Path()
            let tailBase = CGPoint(x: w * 0.22, y: h * 0.62 + yLift)
            let wag = CGFloat(tailWag) * .pi / 180
            let tip = CGPoint(
                x: w * 0.06 + cos(wag) * w * 0.04,
                y: h * 0.42 + yLift + sin(wag) * h * 0.08
            )
            tail.move(to: tailBase)
            tail.addQuadCurve(
                to: tip,
                control: CGPoint(x: w * 0.08, y: h * 0.55 + yLift)
            )
            context.stroke(
                tail,
                with: .color(BrandColor.teal.opacity(0.9)),
                style: StrokeStyle(lineWidth: max(4, w * 0.055), lineCap: .round)
            )

            let body = CGRect(
                x: w * 0.18,
                y: h * 0.36 + yLift,
                width: w * 0.68,
                height: h * 0.52
            )
            let earL = Path { p in
                p.move(to: CGPoint(x: w * 0.28, y: h * 0.40 + yLift))
                p.addLine(to: CGPoint(x: w * 0.36, y: h * 0.08 + yLift))
                p.addLine(to: CGPoint(x: w * 0.46, y: h * 0.38 + yLift))
                p.closeSubpath()
            }
            let earR = Path { p in
                p.move(to: CGPoint(x: w * 0.54, y: h * 0.38 + yLift))
                p.addLine(to: CGPoint(x: w * 0.64, y: h * 0.08 + yLift))
                p.addLine(to: CGPoint(x: w * 0.74, y: h * 0.40 + yLift))
                p.closeSubpath()
            }

            context.fill(Path(roundedRect: body, cornerRadius: body.height * 0.45), with: .color(BrandColor.teal))
            context.fill(earL, with: .color(BrandColor.teal))
            context.fill(earR, with: .color(BrandColor.teal))

            // Eyes
            let eyeY = h * 0.52 + yLift
            let eyeR = max(1.5, w * 0.035) * (1 - blink * 0.92)
            if eyeR > 0.4 {
                context.fill(
                    Path(ellipseIn: CGRect(x: w * 0.40 - eyeR, y: eyeY - eyeR, width: eyeR * 2, height: eyeR * 2)),
                    with: .color(BrandColor.mark)
                )
                context.fill(
                    Path(ellipseIn: CGRect(x: w * 0.58 - eyeR, y: eyeY - eyeR, width: eyeR * 2, height: eyeR * 2)),
                    with: .color(BrandColor.mark)
                )
            }

            // Soft cheek highlight when proud
            if proud {
                context.fill(
                    Path(ellipseIn: CGRect(x: w * 0.30, y: h * 0.58 + yLift, width: w * 0.12, height: h * 0.06)),
                    with: .color(Color.white.opacity(0.18))
                )
            }
        }
        .scaleEffect(x: facingRight ? 1 : -1, y: 1)
        .accessibilityHidden(true)
    }
}

struct ScanBallView: View {
    var body: some View {
        Circle()
            .fill(BrandColor.ink.opacity(0.85))
            .frame(width: 14, height: 14)
            .accessibilityHidden(true)
    }
}

struct DuplicateFileCardView: View {
    var title: String
    var showMatchBadge: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "doc.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(BrandColor.teal)
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(BrandColor.ink)
                    .lineLimit(1)
            }

            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(BrandColor.ink.opacity(0.10))
                .frame(height: 6)
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(BrandColor.ink.opacity(0.07))
                .frame(width: 70, height: 6)

            if showMatchBadge {
                Label("Exact duplicate", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(BrandColor.teal)
                    .labelStyle(.titleAndIcon)
            }
        }
        .padding(12)
        .frame(width: 128, height: showMatchBadge ? 96 : 78, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.regularMaterial)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(BrandColor.ink.opacity(0.08), lineWidth: 1)
        }
        .shadow(color: BrandColor.ink.opacity(0.08), radius: 8, y: 3)
    }
}

struct DuplicateSparkleView: View {
    var body: some View {
        ZStack {
            Image(systemName: "sparkle")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(BrandColor.teal)
                .offset(x: -18, y: -10)
            Image(systemName: "sparkle")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(BrandColor.teal.opacity(0.85))
                .offset(x: 16, y: -16)
            Image(systemName: "sparkle")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(BrandColor.teal.opacity(0.7))
                .offset(x: 4, y: 8)
        }
        .accessibilityHidden(true)
    }
}
