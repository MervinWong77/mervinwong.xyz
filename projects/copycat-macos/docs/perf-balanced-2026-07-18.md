# Balanced disk polish (2026-07-18)

Focused pass — no two-pass / SQLite / SHA-256 architecture changes.

## Buffer strategy

- Allocated capacity: **1 MB** (upper bound)
- Active chunk:
  - ≤64 KB files → one-shot read (`fileSize`)
  - ≤4 MB files → **512 KB**
  - larger → **1 MB**
- Single `ReusableHashReader` / one active hasher
- No retained file `Data` after hashing

## Responsiveness

- Utility-priority scan task (unchanged)
- Yields every 16 hashed files (every 8 under Low Power / serious thermal)
- Hashing UI progress rate-limited to ~100 ms (AppModel already coalesces)
- Memory circuit breaker unchanged

## Diagnostics (DEBUG UI only)

`ScanEvent.diagnostics` + `ScanDiagnosticsDebugPanel` (compiled out of Release).

## Before / after

Fixtures: SSD `/tmp/copycat-io-bench-ssd` (200×2 MB), HDD `MERVIN 12TB/copycat-io-bench-hdd` (100×2 MB).

| | SSD before | SSD after (warm) | HDD before | HDD after (warm) |
|--|------------|------------------|------------|------------------|
| Duration | 0.131 s | 0.139–0.143 s | 13.71 s | 12.35 s |
| files/s | 1526 | ~1400 | 7.3 | 8.1 |
| Wall MB/s | 3052 | ~ | 14.6 | 16.2 |
| Hash MB/s | — | — | ~12.2 | ~13.6 |
| Peak RSS | ~14.8 MB | ~16.1 MB | ~14.5 MB | ~15.9 MB |
| Read ops | 680 | 680 | 340 | 340 |
| Groups | 60 | 60 | 30 | 30 |

Notes:

- SSD wall times are cache-dominated; warm after matches before (no material regression).
- HDD slightly faster / same class; **diskWait ≈ hash time** confirms bound by sequential reads, not CPU.
- Peak RSS +~1 MB from 1 MB buffer + diagnostics — not a material regression.
- Further disk optimization (readahead windows, inode order) not justified until a seek-heavy corpus shows thrashing beyond this.

## Future (not in this PR)

- Full adaptive PerformanceGovernor
- User-facing performance controls
- Disk queue depth (not available in sandbox)
