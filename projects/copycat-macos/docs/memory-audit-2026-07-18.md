# CopyCat Memory Audit Report

**Date:** 2026-07-18  
**Machine:** 24 GB RAM macOS 26.5.2 (ARM64)  
**Circuit-breaker threshold:** 1 024 MB process RSS (25% of RAM, capped)  
**Scope:** Root-cause analysis only — **no fixes applied**  
**Tools:** `MemoryAuditRunner` milestones, `heap --sortBySize`, `vmmap -summary`, `leaks`, `xctrace` Allocations (attach failed on unsigned CLI; heap/vmmap used as CLI Instruments equivalent)

Artifacts: `/tmp/copycat-memory-audit/logs/`  
Harness: `scripts/MemoryAuditRunner/`  
Corpus stats: `/tmp/copycat-memory-audit/corpus-stats.json`

---

## Executive verdict

Two-pass size filtering **works** when sizes are unique (50 000 unique-size files → ~20 MB peak, **0 path candidates**).

On realistic trees where many unrelated files share sizes, Pass 2 still retains **nearly every file as a “collision candidate.”** Exact hashing then multiplies that set. Heap at mid-hash on a 50 000-file common-size corpus shows the dominant live objects:

| Rank | Object (heap class) | Count | Bytes | Role |
|---:|---|---:|---:|---|
| 1 | `NSConcreteData` (bytes storage) | 63 422 | **148.3 MB** | Hash read buffers / Data churn during detection |
| 2 | `ArrayStorage<ScannedFile>` | 231 arrays | **26.3 MB** | Detector + hashing inputs (`bySize` / partial / full copies) |
| 3 | `_FileCache` (CoreServices) | 50 000 | **15.3 MB** | Per-URL file cache tied to retained URLs |
| 4 | `CFString` | 200 004 | **13.7 MB** | Paths / hash hex / filenames |
| 5 | `StringStorage` | 63 431 | **9.9 MB** | Swift strings |
| 6 | `NSURL` | 50 005 | **4.7 MB** | Candidate / hashed file URLs |

Peak process RSS on that corpus: **~357 MB** during hashing (not yet home-directory scale). Extrapolating to a multi-hundred-thousand-file library with high size-collision rates explains system-level “out of application memory” on a 24 GB Mac when candidates approach “most of the tree,” then hashing retains Data + multi-copy `ScannedFile` graphs, plus OS file cache pressure from reading every candidate.

**True leaks:** `leaks` reported **0 leaks / 0 leaked bytes** mid-scan.  
**Retention is intentional / structural**, not a classic retain-cycle leak.

---

## 1. Reproduction

### Corpora

| Corpus | Files | Bytes | Unique sizes | Purpose |
|---|---:|---:|---:|---|
| smoke | 5 | 90 | 3 | Baseline |
| unique-50k | 50 000 | ~1.25 GB logical (sparse) | 50 000 | Prove Pass 1 path-free |
| common-size-50k | 50 000 | ~114 MB | **64** | Stress Pass 2 candidate explosion |
| mixed-5k-500pairs | 6 000 | ~143 MB | 5 500 | Known 1 000 hash candidates / 500 groups |

User’s original OOM folder was **not confirmed** in this session; common-size-50k is the synthetic stand-in for “large library with few unique sizes.”

### Results summary

| Corpus | Duration | Peak candidates | Peak hashInputs | Peak RSS | Peak phys_footprint | Final RSS (+settle) | Breaker fired? |
|---|---:|---:|---:|---:|---:|---:|---|
| smoke | 9 ms | 4 | 4 | ~10 MB | ~2 MB | ~10 MB | No |
| unique-50k | 710 ms | **0** | 0 | **~20 MB** | ~12 MB | ~20 MB | No |
| common-size-50k | 6.1 s | **50 000** | **50 000** | **~357 MB** | **~349 MB** | ~342 MB RSS / ~60 MB foot | No |
| mixed | 516 ms | 1 000 | 1 000 | ~155 MB | ~146 MB | ~155 MB | No |

Notes:

- unique-50k: `freqEntries` peaked at 50 000 then dropped to 0 after `takeCollisionSizes`; candidates stayed 0 → **two-pass verified**.
- common-size-50k: Pass 1 only 64 size entries; Pass 2 retained **all 50 000** paths because every size collided. Hashing peaked ~357 MB.
- After completion, RSS stayed ~342 MB while phys_footprint fell to ~60 MB (compression / reclaim); live `DuplicateGroup` / `ScannedFile` results still retained (~256 groups in this corpus due to accidental content collisions in the fixture generator).

---

## 2. Ownership graph

```text
MemoryAuditRunner / CopyCat.app
 └── ScanCoordinator (actor, scan Task)
      ├── SizeFrequencyMap.counts: [UInt64:UInt32]     // Pass 1 only; cleared after take
      ├── collisionSizes: Set<UInt64>                  // Pass 2 filter; lives until hash starts
      ├── collisionCandidates: [FileCandidate]         // Pass 2; cleared at hashing_start
      ├── filesForHashing: [ScannedFile]               // held for entire ExactDuplicateDetector.detect
      ├── ExactDuplicateDetector (stack locals)
      │    ├── bySize: [UInt64:[ScannedFile]]
      │    ├── withPartial / byPartial
      │    ├── withFull / byFull
      │    └── groups: [DuplicateGroup]  → yielded
      ├── PerformanceTelemetry + FilesPerSecondMeter.samples (tiny, trimmed)
      └── AsyncStream<ScanEvent> → consumer
           └── AppModel (production)
                ├── progress: ScanProgress           // latest only
                ├── groups: [DuplicateGroup]         // RETAINED after finish
                └── ScanProgressView (7× onChange) + mascot director
```

**Alive after completion (production):** `AppModel.groups` (and thus all exact `ScannedFile`s with hashes), `selectedFolders`, idle UI. Coordinator task locals should be released when the stream finishes; results ownership moves to `AppModel`.

---

## 3. Long-lived collections audit

| Collection | Owner | Purpose | Max observed | Should shrink? | Cleared? | Still retained why |
|---|---|---|---:|---|---|---|
| `SizeFrequencyMap.counts` | Coordinator | Pass 1 size counts | 50 000 (unique) / 64 (common) | Yes after take | Yes | — |
| `collisionSizes` | Coordinator | Pass 2 filter | 64 → 50 000 files match | Yes after hash | Dropped with scope | — |
| `collisionCandidates` | Coordinator | Pass 2 metadata | **50 000** | Yes before hash | Yes at hashing_start | — |
| `filesForHashing` | Coordinator | Detector input | **50 000** | Yes after detect | When detect returns | Held **during entire** detect |
| `bySize` / partial / full maps | Detector | Hash pipeline | O(candidates) × copies | Yes per group | Local scope | Live at peak with input array |
| `groups` | Detector → AppModel | Results | 256 / 500 | Only on new scan | AppModel clears on new scan | **Intentional post-scan** |
| `AsyncStream` buffer | Coordinator | Events | `_DequeBuffer<ScanEvent>` seen in heap | Should be small | Drained by consumer | Unbounded if UI stalls |
| Telemetry samples | Coordinator | files/sec | Window ~2 s | Yes (trim) | Yes | Negligible |
| Animation director | UI | Mascot | Tokens only | Yes | onDisappear reset | Negligible |
| Progress history | — | — | **None** | — | — | No log history found |
| Thumbnail / Quick Look / image cache | — | — | **None in app code** | — | — | N/A |

---

## 4. Unbounded growth patterns

| Pattern | Present? | Evidence |
|---|---|---|
| `@Published` / Observable append-only progress log | No | Single `progress` value replaced |
| Pass 2 candidate append without cap | **Yes** | Grows to all files sharing any colliding size |
| Hash Data retention / churn | **Yes** | 148 MB `NSConcreteData` mid-hash |
| URL / `_FileCache` per candidate | **Yes** | 50 000 `_FileCache` + `NSURL` |
| SHA-256 string cache (global) | No dedicated cache | Hex strings on `ScannedFile` |
| AsyncStream unbounded buffer | Possible | `_DequeBuffer<ScanEvent>` in heap; end-of-run backlog 0 when consumer keeps up |
| UI once-per-file | No | ~253 progress yields / 50 k files in Pass 1 (~every 200 files) |
| Hashing event storm | **Yes** | eventsYielded 760 → 1 358 during hash (~600 events) |

---

## 5. UI updates

**Production path** ([`AppModel.startScan`](CopyCat/AppModel.swift)):

```swift
for await event in stream {
    await MainActor.run { self.handle(event) }
}
```

Every stream event hops to the MainActor (not once per file, but once per yielded event).

**ScanProgressView** has **7** `onChange` handlers (`message`, `phase`, `filesSeen`, `bytesSeen`, `groupsFound`, `candidateFiles`, `isScanning`) each driving the animation director / labels.

**SwiftUI lists during scan:** none (mascot + stats only).  
**Results:** `List` + nested `ForEach` over `model.groups` / files — only after finish.

**Measured events (common-size-50k):** 1 365 received (1 333 progress, 30 performance) for 50 000 files — rate-limited enumeration, but hashing still chatty.

**ui-backlog mode (5 ms/event):** peak RSS still ~357 MB (same order); end backlog hint 0 because the consumer eventually drains. Does not exonerate MainActor cost on the real app under animation + SwiftUI.

---

## 6. Hash pipeline

| Check | Finding |
|---|---|
| Partial hashes released | Stored on `ScannedFile` copies in detector maps until group finishes; not a global cache |
| Full hashes released | Same; retained in final `DuplicateGroup.files` |
| Data buffers | `PartialHasher` / `FullHasher` use `Data` / 1 MiB chunks; heap shows large `NSConcreteData` volume mid-hash |
| File handles | `defer { close() }` in both hashers — OK |
| `autoreleasepool` | **Absent** around enumerator / hash loops; heap shows `@autoreleasepool content` (~1.3 MB) — secondary |

---

## 7. Two-pass verification

| Stage | unique-50k | common-size-50k |
|---|---|---|
| Pass 1 `freqEntries` | 50 000 → 0 after take | 64 → 0 after take |
| Paths in Pass 1 | **None** (size only via `fileSize`) | **None** |
| `collisionSizes` | 0 | 64 |
| Pass 2 `candidates` | **0** | **50 000** |
| Conclusion | Two-pass OK | Two-pass **does not** bound paths when size cardinality is low |

---

## 8. Leak report

| Category | Finding |
|---|---|
| True memory leaks | **None** (`leaks`: 0) |
| Intentional retention | `AppModel.groups` after scan; hash strings on result files |
| Caches | CoreServices `_FileCache` per retained URL (framework) |
| Reference cycles | Not observed |
| Delayed release | phys_footprint drops after complete while RSS stays high briefly |
| SwiftUI retention | Not dominant in engine-only harness; results `List` holds groups in app |
| Autorelease growth | Present but **secondary** vs Data + ScannedFile arrays |
| OS file cache | Reading tens of thousands of files adds system pressure beyond process heap |

---

## 9. Memory table (sorted by retained impact at peak)

From mid-hash `heap` on common-size-50k (~248 MB phys_footprint sample; full run peak ~357 MB RSS):

| Object | Peak count | Peak memory | Released after scan? | Expected? |
|---|---:|---:|---|---|
| `NSConcreteData` byte storage | ~63 k | **~148 MB** | Mostly yes (churn); residual with results | Transient hash I/O — volume too high |
| `ArrayStorage<ScannedFile>` | 231 arrays | **~26 MB** | Partially; results keep groups | Detector multi-copy — **too large** |
| `_FileCache` | 50 000 | **~15 MB** | With URL release | Framework side effect of URL retention |
| `CFString` | ~200 k | **~14 MB** | Partial | Paths/hashes |
| `StringStorage` | ~63 k | **~10 MB** | Partial | Swift strings |
| `NSURL` / path stores | ~50 k | **~6 MB+** | With candidates/results | Pass 2 + hashing |
| `SizeFrequencyMap` | ≤50 k entries | ~few MB | Yes after take | Expected Pass 1 |
| `@autoreleasepool` nodes | ~327 | ~1.3 MB | Transient | Missing pools |
| `ScanEvent` deque | 1 | small | Yes when drained | OK if UI keeps up |
| Telemetry samples | few | negligible | Yes | Expected |
| Mascot / animation | — | negligible | Yes | Expected |

---

## 10. Ranked root causes (largest → smallest)

1. **Pass-2 candidate explosion on common file sizes**  
   Any size with count ≥ 2 pulls **all** those files into path-retaining metadata. Real Mac libraries have many common sizes → candidates ≈ tree size.

2. **ExactDuplicateDetector multiplies candidate memory**  
   Input `[ScannedFile]` plus `bySize` / partial / full maps; heap shows many `ArrayStorage<ScannedFile>` and **148 MB Data**.

3. **URL / CoreServices `_FileCache` proportional to candidates**  
   ~15 MB at 50 k URLs; scales with candidate count.

4. **Post-scan result retention**  
   Groups keep hashed `ScannedFile`s; RSS remained ~342 MB after common-size run.

5. **MainActor event delivery + chatty hashing progress**  
   Not the primary megabyte owner in the CLI harness; still a latency/backlog risk in the SwiftUI app (7 `onChange`s).

6. **Missing `autoreleasepool` in large Foundation loops**  
   Secondary (~1 MB class in heap sample).

7. **Circuit breaker gap**  
   1 GB RSS limit did not fire at 357 MB; system OOM on larger trees can still occur from candidate×hash scaling + file cache before/without a clean fail.

---

## 11. Instruments / CLI status

| Tool | Result |
|---|---|
| Allocations (`xctrace`) | Template ran; **attach failed** on unsigned `MemoryAuditRunner` (trace file empty of useful samples) |
| `heap --sortBySize` | **Primary evidence** (table above) |
| `vmmap -summary` | Writable dirty ~200 MB+ mid-hash; MALLOC_SMALL dominant |
| `leaks` | **0 leaks** |
| Memory Graph (Xcode GUI) | Not captured in this headless session — heap class list substitutes |

To repeat GUI Instruments: build & sign CopyCat.app Debug, Product → Profile → Allocations/Leaks, mark generations at the same milestones; search Memory Graph for `ScannedFile`, `FileCandidate`, `DuplicateGroup`.

---

## 12. What this is not

- Not a failure of “Pass 1 retaining paths” (verified empty of paths).  
- Not a classic leak cycle.  
- Not mascot/animation dominated.  
- Not fixed by two-pass alone when size cardinality is low.

---

## Deferred (do not implement until approved)

Suggested fix order (for a future PR, **not done here**):

1. Bound or stream Pass-2 candidates (e.g. require stronger prefilter than size alone, or externalize / batch by size bucket).  
2. Stream ExactDuplicateDetector per size-bucket without retaining all candidates + all Data.  
3. Coalesce UI events (time-based MainActor publish); bound AsyncStream.  
4. `autoreleasepool` in enumerate/hash loops.  
5. Revisit circuit breaker (phys_footprint, lower cap, check during candidate growth).

---

## How to re-run

```bash
cd /Users/mervin/copycat-macos/scripts/MemoryAuditRunner
swift run -c release MemoryAuditRunner /tmp/copycat-memory-audit/common-size-50k full 10
# Mid-scan:
#   heap --sortBySize --humanReadable <pid>
#   vmmap -summary <pid>
#   leaks <pid>
```
