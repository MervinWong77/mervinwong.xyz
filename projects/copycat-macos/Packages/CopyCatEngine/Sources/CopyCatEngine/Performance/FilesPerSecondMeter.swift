import Foundation

/// Rolling rate estimate from monotonic counters (files, bytes, read ops).
public struct RollingRateMeter: Sendable {
    private var samples: [(ContinuousClock.Instant, UInt64)] = []
    private let window: Duration

    public init(window: Duration = .seconds(2)) {
        self.window = window
    }

    public mutating func record(_ value: UInt64, at instant: ContinuousClock.Instant = .now) {
        samples.append((instant, value))
        trim(at: instant)
    }

    public mutating func rate(
        at instant: ContinuousClock.Instant = .now,
        minimumSeconds: Double = 0.05
    ) -> Double? {
        trim(at: instant)
        guard let first = samples.first, let last = samples.last, samples.count >= 2 else {
            return nil
        }
        let elapsed = first.0.duration(to: last.0)
        let seconds = Double(elapsed.components.seconds)
            + Double(elapsed.components.attoseconds) / 1e18
        guard seconds > minimumSeconds else { return nil }
        guard last.1 >= first.1 else { return nil }
        return Double(last.1 - first.1) / seconds
    }

    public mutating func reset() {
        samples.removeAll(keepingCapacity: false)
    }

    private mutating func trim(at instant: ContinuousClock.Instant) {
        let cutoff = instant - window
        samples.removeAll { $0.0 < cutoff }
    }
}

/// Rolling files/sec estimate from discrete samples.
public struct FilesPerSecondMeter: Sendable {
    private var meter = RollingRateMeter()

    public init(window: Duration = .seconds(2)) {
        self.meter = RollingRateMeter(window: window)
    }

    public mutating func record(filesDiscovered: Int, at instant: ContinuousClock.Instant = .now) {
        meter.record(UInt64(max(0, filesDiscovered)), at: instant)
    }

    public mutating func rate(
        at instant: ContinuousClock.Instant = .now,
        minimumSeconds: Double = 0.05
    ) -> Double? {
        meter.rate(at: instant, minimumSeconds: minimumSeconds)
    }

    public mutating func reset() {
        meter.reset()
    }
}
