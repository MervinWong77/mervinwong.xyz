import Foundation
import CopyCatEngine

/// Audit-only CLI: measures collection sizes + RSS/phys_footprint across scan milestones.
/// Also simulates AppModel's per-event MainActor hop to measure event backlog.
@main
struct MemoryAuditRunner {
    static func main() async {
        let args = Array(CommandLine.arguments.dropFirst())
        let fixturePath = args.first ?? "/tmp/copycat-memory-audit/smoke"
        let mode = args.count > 1 ? args[1] : "full" // full | ui-backlog
        let settleSeconds = args.count > 2 ? (UInt64(args[2]) ?? 30) : 30
        let fixture = URL(fileURLWithPath: fixturePath)

        print("=== MEMORY AUDIT ===")
        print("fixture=\(fixture.path)")
        print("mode=\(mode)")
        print("settleSeconds=\(settleSeconds)")
        print("memoryLimitBytes=\(ScanConfiguration(rootURLs: [fixture]).resolvedMemoryLimitBytes)")
        printIdle("idle_before_scan")

        final class MilestoneBox: @unchecked Sendable {
            var items: [(String, ScanAuditMetrics)] = []
            let lock = NSLock()
            func append(_ name: String, _ metrics: ScanAuditMetrics) {
                lock.lock(); items.append((name, metrics)); lock.unlock()
            }
            func snapshot() -> [(String, ScanAuditMetrics)] {
                lock.lock(); defer { lock.unlock() }
                return items
            }
        }
        let box = MilestoneBox()
        let hooks = ScanAuditHooks { name, metrics in
            box.append(name, metrics)
            printMilestone(name, metrics)
        }

        let coordinator = ScanCoordinator(auditHooks: hooks)
        let config = ScanConfiguration(rootURLs: [fixture])

        var eventsReceived = 0
        var progressEvents = 0
        var performanceEvents = 0
        var peakCandidatesFromProgress = 0
        var terminal = "none"
        var finalGroups = 0
        let t0 = ContinuousClock.now

        // Simulate AppModel: every event hops to MainActor (serial).
        // ui-backlog mode adds artificial delay to expose AsyncStream buffering.
        let uiDelayNanos: UInt64 = mode == "ui-backlog" ? 2_000_000 : 0 // 2ms/event

        for await event in await coordinator.scan(configuration: config) {
            eventsReceived += 1
            if uiDelayNanos > 0 {
                try? await Task.sleep(nanoseconds: uiDelayNanos)
            }
            await MainActor.run {
                switch event {
                case .progress(let p):
                    progressEvents += 1
                    peakCandidatesFromProgress = max(peakCandidatesFromProgress, p.candidateFiles)
                case .performance:
                    performanceEvents += 1
                case .groupsUpdated(let g):
                    finalGroups = g.count
                case .finished(let g, _):
                    finalGroups = g.count
                    terminal = "finished"
                case .cancelled:
                    terminal = "cancelled"
                case .failed(let message, _):
                    terminal = "failed:\(message)"
                }
            }
        }

        let elapsed = t0.duration(to: .now)
        let elapsedMs = Double(elapsed.components.seconds) * 1000
            + Double(elapsed.components.attoseconds) / 1e15

        printSample("scan_completed_plus_0s")
        if settleSeconds > 0 {
            try? await Task.sleep(nanoseconds: settleSeconds * 1_000_000_000)
        }
        printSample("scan_completed_plus_\(settleSeconds)s")

        let captured = box.snapshot()

        let peakRSS = captured.compactMap(\.1.residentBytes).max() ?? 0
        let peakFoot = captured.compactMap(\.1.physicalFootprintBytes).max() ?? 0
        let peakCandidates = captured.map(\.1.candidateCount).max() ?? 0
        let peakFreq = captured.map(\.1.frequencyEntries).max() ?? 0
        let peakCollisionSizes = captured.map(\.1.collisionSizeCount).max() ?? 0
        let peakHashInputs = captured.map(\.1.hashingInputCount).max() ?? 0
        let peakEventsYielded = captured.map(\.1.eventsYielded).max() ?? 0

        print("=== SUMMARY ===")
        print("terminal=\(terminal)")
        print("elapsedMs=\(String(format: "%.1f", elapsedMs))")
        print("finalGroups=\(finalGroups)")
        print("eventsReceived=\(eventsReceived) progressEvents=\(progressEvents) performanceEvents=\(performanceEvents)")
        print("eventsYieldedPeak=\(peakEventsYielded) backlogHint=\(max(0, peakEventsYielded - eventsReceived))")
        print("peakFrequencyEntries=\(peakFreq)")
        print("peakCollisionSizeCount=\(peakCollisionSizes)")
        print("peakCandidateCount=\(peakCandidates) peakCandidatesFromProgress=\(peakCandidatesFromProgress)")
        print("peakHashingInputCount=\(peakHashInputs)")
        print("peakRSS=\(peakRSS) (~\(peakRSS / 1024 / 1024)MB)")
        print("peakPhysFootprint=\(peakFoot) (~\(peakFoot / 1024 / 1024)MB)")
        print("AUDIT_OK")
    }

    private static func printIdle(_ name: String) {
        let rss = ProcessMemorySampler.residentByteCount() ?? 0
        let foot = ProcessMemorySampler.physicalFootprintByteCount() ?? 0
        print("MILESTONE \(name) rss=\(rss) foot=\(foot)")
    }

    private static func printSample(_ name: String) {
        let rss = ProcessMemorySampler.residentByteCount() ?? 0
        let foot = ProcessMemorySampler.physicalFootprintByteCount() ?? 0
        print("MILESTONE \(name) rss=\(rss) (~\(rss / 1024 / 1024)MB) foot=\(foot) (~\(foot / 1024 / 1024)MB)")
    }

    private static func printMilestone(_ name: String, _ m: ScanAuditMetrics) {
        let rss = m.residentBytes ?? 0
        let foot = m.physicalFootprintBytes ?? 0
        print(
            "MILESTONE \(name) phase=\(m.phase.rawValue) files=\(m.filesSeen) freqEntries=\(m.frequencyEntries) " +
            "collisionSizes=\(m.collisionSizeCount) candidates=\(m.candidateCount) hashInputs=\(m.hashingInputCount) " +
            "groups=\(m.groupsFound) eventsYielded=\(m.eventsYielded) " +
            "rss=\(rss) (~\(rss / 1024 / 1024)MB) foot=\(foot) (~\(foot / 1024 / 1024)MB)"
        )
    }
}
