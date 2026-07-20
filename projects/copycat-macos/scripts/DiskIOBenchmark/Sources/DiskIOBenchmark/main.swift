import Foundation
import CopyCatEngine

@main
struct DiskIOBenchmark {
    static func main() async {
        let args = CommandLine.arguments.dropFirst()
        guard let rootPath = args.first else {
            fputs("Usage: DiskIOBenchmark <root>\n", stderr)
            exit(2)
        }
        let root = URL(fileURLWithPath: rootPath)
        let config = ScanConfiguration(rootURLs: [root], excludedDirectoryNames: [])

        let coordinator = ScanCoordinator()
        let started = ContinuousClock.now
        var lastSnapshot: PerformanceSnapshot?
        var lastDiagnostics: ScanDiagnostics?
        var groups = 0
        var filesSeen = 0
        var bytesSeen: UInt64 = 0
        var peakRSS: UInt64 = 0

        for await event in await coordinator.scan(configuration: config) {
            switch event {
            case .progress(let p):
                filesSeen = p.filesSeen
                bytesSeen = p.bytesSeen
                if let perf = p.performance { lastSnapshot = perf }
            case .performance(let snap):
                lastSnapshot = snap
                if let mem = snap.memoryBytes { peakRSS = max(peakRSS, mem) }
            case .diagnostics(let diag):
                lastDiagnostics = diag
                if let mem = diag.peakResidentBytes { peakRSS = max(peakRSS, mem) }
            case .finished(let g, let p):
                groups = g.count
                filesSeen = p.filesSeen
                bytesSeen = p.bytesSeen
                if let perf = p.performance { lastSnapshot = perf }
            case .failed(let message, _):
                fputs("FAILED: \(message)\n", stderr)
                exit(1)
            case .cancelled:
                fputs("CANCELLED\n", stderr)
                exit(1)
            default:
                break
            }
        }

        let elapsed = started.duration(to: .now)
        let seconds = Double(elapsed.components.seconds)
            + Double(elapsed.components.attoseconds) / 1e18
        let mb = Double(bytesSeen) / 1_048_576
        let filesPerSec = seconds > 0 ? Double(filesSeen) / seconds : 0
        let mbPerSec = seconds > 0 ? mb / seconds : 0

        print("root=\(root.path)")
        print(String(format: "elapsed_s=%.3f", seconds))
        print("files=\(filesSeen)")
        print(String(format: "bytes_seen_mb=%.2f", mb))
        print("groups=\(groups)")
        print(String(format: "files_per_sec=%.1f", filesPerSec))
        print(String(format: "mb_per_sec_wall=%.2f", mbPerSec))
        print("peak_rss_bytes=\(peakRSS)")
        if let snap = lastSnapshot {
            print(String(format: "telemetry_files_per_sec=%@", snap.filesPerSecond.map { String(format: "%.1f", $0) } ?? "nil"))
            print(String(format: "telemetry_bytes_per_sec=%@", snap.bytesPerSecond.map { String(format: "%.1f", $0) } ?? "nil"))
            print(String(format: "telemetry_read_ops_per_sec=%@", snap.readOperationsPerSecond.map { String(format: "%.1f", $0) } ?? "nil"))
            print("telemetry_read_operations=\(snap.readOperations.map(String.init) ?? "nil")")
            print("telemetry_memory=\(snap.memoryBytes.map(String.init) ?? "nil")")
        }
        if let diag = lastDiagnostics {
            print("--- diagnostics ---")
            for line in diag.summaryLines {
                print(line)
            }
        }
    }
}
