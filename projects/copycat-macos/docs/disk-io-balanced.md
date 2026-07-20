# Balanced disk I/O

Presentation of the goal: **smooth, sequential disk access** and a responsive Mac — not maximum peak throughput.

## What changed

| Area | Before | After |
|------|--------|-------|
| Hash concurrency | Already 1 file at a time | Explicit `maxConcurrentHashReaders = 1` |
| Read buffers | New `Data` per `FileHandle.read` | Shared `ReusableHashReader` (512 KB, POSIX `read`) |
| Within-size order | SQLite / dictionary order | `ORDER BY path` + `stableDiskOrder` |
| Yields while hashing | Almost none | Every 16 files + between size buckets |
| Read-ahead | Default | `F_RDAHEAD` on each open |
| Telemetry | files/sec, memory | + bytes/sec, read ops, read ops/sec (queue depth N/A) |

## Policy (Balanced)

- One open file / one reader
- 512 KB reusable buffer (clamped to 256 KB–1 MB)
- Path-stable hashing order (directory locality)
- Cooperative `Task.yield` every 16 hashed files
- Utility-priority scan task (unchanged)

## Measurement

Harness: `scripts/DiskIOBenchmark` (after) and `scripts/DiskIOBaseline` (before wall-clock).

Fixture: scattered dirs, same-size 2 MB files (SSD 200 files / 400 MB, HDD 100 files / 200 MB on `MERVIN 12TB`).

### Results (2026-07-18, this machine)

| Volume | | Elapsed | files/sec | MB/s (wall) | read ops | notes |
|--------|--|---------|-----------|-------------|----------|-------|
| SSD (`/tmp`) | Before | 0.290 s | 689 | 1378 | — | FileHandle + Data |
| SSD (`/tmp`) | After | 0.283 s | 706 | 1412 | 680 | + telemetry |
| External HDD (`MERVIN 12TB`) | Before | 2.224 s | 45.0 | 89.9 | — | |
| External HDD (`MERVIN 12TB`) | After | 2.243 s | 44.6 | 89.2 | 340 | ~101 MB/s hash-read telemetry |

Wall-clock on these fixtures is **within noise** — Balanced was already single-threaded. Wins are structural:

1. **Fewer allocator / cache spikes** from reusable buffers (important on long scans).
2. **Stable path order** reduces seek thrashing when many same-size files live far apart (worse on HDD than this 3-directory fixture shows).
3. **Yields** keep AppKit/SwiftUI responsive during long hash stretches.
4. **Observable** MB/s and read-ops/sec during hashing.

Seek-heavy HDD fixture (after only): 600×64 KiB same-size files across 80 folders on `MERVIN 12TB` → **2.54 s**, **237 files/sec**, **800 read ops** (600 partial + 200 full opens), single-reader throughout.

Average disk queue depth is **not available** from public sandboxed APIs (`averageQueueDepth` stays `nil`).

### Re-run

```bash
# AFTER (current engine)
cd scripts/DiskIOBenchmark && swift run -c release DiskIOBenchmark /path/to/root
```

## Files

- `Hashing/ReusableHashReader.swift`
- `Hashing/PartialHasher.swift` / `FullHasher.swift`
- `Detection/ExactDuplicateDetector.swift`
- `Detection/CandidateSQLiteStore.swift` (`ORDER BY path`)
- `Models/PerformanceMode.swift` (I/O policy knobs)
- `Performance/PerformanceTelemetry.swift`
- `Coordination/ScanCoordinator.swift` (async hash + yields)
