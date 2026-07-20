# CopyCat

**CopyCat** is a native macOS app that finds **exact duplicate files** on your Mac.

It is **not** a “Mac cleaner.” It does not automatically delete anything. The goal is a **safe, local-first duplicate finder**: scan folders and drives, review matches, and (in a later phase) move unwanted copies to the macOS Trash yourself.

- No cloud  
- No accounts  
- No analytics  
- No subscriptions  

Everything runs on your Mac.

---

## Current status (Phase 1B)

Working today:

- Xcode macOS app (SwiftUI, App Sandbox)
- Multi-folder / drive selection
- Recursive file enumeration with default exclusions
- Metadata collection (name, size, dates, URL)
- Exact duplicate detection: **size → partial SHA-256 → full SHA-256**
- Scan progress and cancellation
- Minimal results list of exact duplicate groups
- Unit-tested scanning engine (`CopyCatEngine`)

Not yet implemented:

- Filename similarity (LIKELY / POSSIBLE)
- Keep / Trash selection and bulk helpers
- Moving files to Trash
- Quick Look preview panel
- Scan history / SwiftData
- Polished three-column results UI
- Website download pages

---

## Architecture

Scanning logic lives in a UI-free Swift package so it stays unit-testable and independent of SwiftUI.

```
copycat-macos/
  CopyCat/                      # SwiftUI app shell
  Packages/CopyCatEngine/       # Scanning engine (SPM)
  CopyCat.xcodeproj             # Generated via XcodeGen
  project.yml
```

```
App (SwiftUI)
  └── ScanCoordinator (CopyCatEngine)
        ├── FileEnumerator
        ├── MetadataReader
        ├── ExactDuplicateDetector
        │     ├── PartialHasher  (first 64 KiB SHA-256)
        │     └── FullHasher     (full-file SHA-256)
        └── AsyncStream<ScanEvent>
```

**Pipeline**

1. Enumerate files under selected roots (skip excluded directory names).  
2. Collect metadata — **no hashing yet**.  
3. Group by size (ignore unique sizes and empty files).  
4. Partial-hash candidates that share a size.  
5. Full-hash only when partial hashes match.  
6. Emit exact groups (identical full SHA-256).

---

## Safety principles

1. Never delete automatically.  
2. Never permanently delete (Trash only, when cleanup ships).  
3. Always explain why files matched.  
4. Exact content matches stay separate from filename similarity.  
5. Privacy first — local-only processing.  
6. Skip common protected / noisy folders by default.

Default exclusions: `Library`, `Applications`, `.git`, `node_modules`, `.next`, `DerivedData`, `Caches`, `.Trash`.

---

## Phase roadmap

| Phase | Focus | Status |
|-------|--------|--------|
| **1** | Scanning engine + exact duplicates + unit tests | Done (engine) |
| **1B** | Xcode app shell, folder picker, progress, minimal results | **Current** |
| **2** | Richer SwiftUI results, preview, Reveal in Finder polish | Next |
| **3** | Keep rules, bulk helpers, Move to Trash, review + report | Planned |
| **4** | Settings, history, CSV export, accessibility, performance | Planned |

Future (not MVP): similar images, duplicate folders, AI comparison, cloud storage, scheduled scans, menu bar mode.

---

## Requirements

- macOS 14 Sonoma or later  
- Xcode 15+ (developed with Xcode 26)  
- Apple Silicon recommended  

Optional: [XcodeGen](https://github.com/yonaskolb/XcodeGen) to regenerate the project from `project.yml`.

---

## Build and run

### Open in Xcode

```bash
cd copycat-macos
open CopyCat.xcodeproj
```

Select the **CopyCat** scheme, destination **My Mac**, then **Run** (⌘R).

### Command line

```bash
cd copycat-macos
xcodebuild -scheme CopyCat -destination 'platform=macOS' build
```

### Regenerate the Xcode project

If you change `project.yml` or add files under `CopyCat/`:

```bash
brew install xcodegen   # once
xcodegen generate
```

### Engine unit tests

```bash
cd Packages/CopyCatEngine
swift test
```

---

## How to use (Phase 1B)

1. Launch **CopyCat**.  
2. Click **Add Folder…** and select one or more folders or mounted drives.  
3. Click **Start Scan**.  
4. Watch progress; use **Cancel** if needed.  
5. Review exact duplicate groups in the results list.  
6. Right-click a file for **Reveal in Finder** or **Copy Path**.  
7. Click **New Scan** to start over.

---

## Current limitations

- Only **exact** content duplicates (same SHA-256).  
- No Trash / cleanup actions yet.  
- No filename-similarity matching.  
- Results UI is a simple list (not the final three-column layout).  
- No pause/resume (cancel only).  
- No scan history or export.  
- App Sandbox: access is limited to folders you explicitly select.  
- Security-scoped bookmarks are not persisted across launches yet.  
- Bundle identifier is still `xyz.mervinwong.Tidy` pending a final ID decision.

---

## License

Private / unpublished for now. All rights reserved.
