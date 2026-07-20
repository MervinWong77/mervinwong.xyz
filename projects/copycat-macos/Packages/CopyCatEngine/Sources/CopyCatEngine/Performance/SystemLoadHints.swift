import Foundation

/// Lightweight, conservative system-load hints for Balanced politeness.
/// No user-facing controls; never fails a scan.
public enum SystemLoadHints {
    public enum Pressure: String, Sendable {
        case normal
        case elevated
    }

    /// Elevated when Low Power Mode is on or thermal state is serious/critical.
    public static var pressure: Pressure {
        let info = ProcessInfo.processInfo
        if info.isLowPowerModeEnabled { return .elevated }
        switch info.thermalState {
        case .serious, .critical:
            return .elevated
        default:
            break
        }
        return .normal
    }

    /// Yield more often under elevated pressure; otherwise keep the Balanced default.
    public static func hashYieldEveryFiles(base: Int) -> Int {
        switch pressure {
        case .normal:
            return max(1, base)
        case .elevated:
            return max(4, base / 2)
        }
    }
}
