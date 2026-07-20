import SwiftUI
import CopyCatEngine

/// Quiet progress bar. Phase jargon stays out of the main story unless requested.
struct ScanProgressChrome: View {
    let phase: ScanPhase
    let message: String?
    let groupsFound: Int
    let candidateFiles: Int
    let isScanning: Bool
    var reduceMotion: Bool = false
    var showsPhaseLabel: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: ScanDesign.Spacing.xs) {
            if showsPhaseLabel {
                HStack(spacing: 8) {
                    Text("Current phase")
                        .font(ScanDesign.TypeScale.phase)
                        .foregroundStyle(BrandColor.muted)
                    Text(phaseLabel)
                        .font(ScanDesign.TypeScale.phase)
                        .foregroundStyle(BrandColor.teal)
                    Spacer(minLength: 0)
                }
            }

            Group {
                if let value = estimatedProgress {
                    ProgressView(value: value)
                        .tint(BrandColor.teal)
                        .animation(reduceMotion ? nil : .easeInOut(duration: 0.35), value: value)
                } else if isScanning {
                    ProgressView()
                        .progressViewStyle(.linear)
                        .tint(BrandColor.teal)
                } else {
                    ProgressView(value: phase == .finished ? 1 : 0)
                        .tint(BrandColor.teal)
                }
            }
            .controlSize(.small)
            .accessibilityLabel("Scan progress")
            .accessibilityValue(progressAccessibilityValue)
        }
    }

    private var phaseLabel: String {
        MascotScanStateMapping.phaseLabel(phase, message: message, groupsFound: groupsFound)
    }

    /// Soft phase ladder — presentation only; does not mirror engine internals.
    private var estimatedProgress: Double? {
        switch phase {
        case .idle:
            return 0
        case .enumerating:
            return nil
        case .grouping:
            return 0.38
        case .hashing:
            if candidateFiles > 0 {
                let ratio = min(1, Double(groupsFound) / Double(max(candidateFiles / 8, 1)))
                return 0.48 + 0.38 * ratio
            }
            return 0.55
        case .classifying:
            return 0.92
        case .finished:
            return 1
        case .cancelled, .failed:
            return nil
        }
    }

    private var progressAccessibilityValue: String {
        if let estimatedProgress {
            return "\(Int(estimatedProgress * 100)) percent, \(phaseLabel)"
        }
        return isScanning ? "In progress, \(phaseLabel)" : phaseLabel
    }
}
