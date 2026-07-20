import AppKit
import Foundation
import CopyCatEngine

@main
struct SmokeMain {
    static func main() async {
        let fixture = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first
            ?? "/Users/mervin/copycat-macos-smoke-fixtures")

        print("Scanning fixture: \(fixture.path)")

        let coordinator = ScanCoordinator()
        let config = ScanConfiguration(rootURLs: [fixture])

        var finishedGroups: [DuplicateGroup] = []
        var sawProgress = false
        var filesSeenPeak = 0
        var terminal = "none"

        for await event in await coordinator.scan(configuration: config) {
            switch event {
            case .progress(let p):
                sawProgress = true
                filesSeenPeak = max(filesSeenPeak, p.filesSeen)
                print("progress phase=\(p.phase.rawValue) files=\(p.filesSeen)")
            case .performance:
                break
            case .groupsUpdated(let groups):
                finishedGroups = groups
            case .finished(let groups, let p):
                finishedGroups = groups
                filesSeenPeak = max(filesSeenPeak, p.filesSeen)
                terminal = "finished"
                let mem = p.performance?.memoryBytes.map(String.init) ?? "—"
                let fps = p.performance?.filesPerSecond.map { String(format: "%.1f", $0) } ?? "—"
                print("finished groups=\(groups.count) files=\(p.filesSeen) memory=\(mem) filesPerSec=\(fps) mode=\(p.performance?.mode.displayName ?? "—")")
            case .cancelled:
                terminal = "cancelled"
            case .failed(let message, _):
                terminal = "failed:\(message)"
            }
        }

        let names = Set(finishedGroups.flatMap { $0.files.map(\.filename) })
        let expect: Set<String> = ["photo.jpg", "photo copy.jpg"]
        let reject: Set<String> = ["same-size-a.txt", "same-size-b.txt", "unique-notes.txt"]

        var ok = true
        if terminal != "finished" {
            print("FAIL terminal=\(terminal)")
            ok = false
        }
        if !sawProgress {
            print("FAIL no progress events")
            ok = false
        }
        if filesSeenPeak != 5 {
            print("FAIL filesSeenPeak=\(filesSeenPeak) expected 5")
            ok = false
        }
        if finishedGroups.count != 1 {
            print("FAIL groupCount=\(finishedGroups.count)")
            ok = false
        }
        if names != expect {
            print("FAIL grouped=\(names) expected=\(expect)")
            ok = false
        }
        if !names.isDisjoint(with: reject) {
            print("FAIL incorrectly grouped \(names.intersection(reject))")
            ok = false
        }

        let cancelCoordinator = ScanCoordinator()
        let stream = await cancelCoordinator.scan(configuration: config)
        var sawCancelled = false
        var n = 0
        for await event in stream {
            n += 1
            if n == 1 {
                await cancelCoordinator.cancel()
            }
            if case .cancelled = event {
                sawCancelled = true
            }
            if case .finished = event {
                break
            }
        }
        if !(sawCancelled || n > 0) {
            print("FAIL cancel did not complete cleanly")
            ok = false
        } else {
            print("cancel smoke ok (cancelled=\(sawCancelled), events=\(n))")
        }

        if let file = finishedGroups.first?.files.first {
            let revealOK = NSWorkspace.shared.selectFile(file.url.path, inFileViewerRootedAtPath: "")
            print("reveal API returned \(revealOK) for \(file.url.path)")
            let pb = NSPasteboard.general
            pb.clearContents()
            let copied = pb.setString(file.url.path, forType: .string)
            let readBack = pb.string(forType: .string)
            if !copied || readBack != file.url.path {
                print("FAIL copy path pasteboard")
                ok = false
            } else {
                print("copy path ok")
            }
        }

        if ok {
            print("SMOKE_ENGINE_OK")
            Foundation.exit(0)
        } else {
            print("SMOKE_ENGINE_FAIL")
            Foundation.exit(1)
        }
    }
}
