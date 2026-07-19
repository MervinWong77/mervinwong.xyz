# Scanning UI redesign (presentation only)

Engine / scan pipeline unchanged. This redesign is SwiftUI presentation only.

## Goal

Feel like **“CopyCat is quietly searching your Mac”** — not a monitoring console.

## Before → After

| Area | Before | After |
|------|--------|-------|
| Hierarchy | Small title + mascot + property table | Hero mascot → large title → progress → metric cards → footer |
| Stats | Two-column labeled rows (dashboard) | Compact material cards (icon / label / large value) |
| Surfaces | Flat white / softFill panels | `.regularMaterial`, subtle border, light shadow |
| Type | `.title2` / `.callout` | 34 / 16 / 13 / 14→26 scale |
| Progress | Implicit via counters only | Phase label + determinate ladder or indeterminate bar |
| Window | ~880×620 | ~960×720 (min 880×640) |
| Motion | Walk + card swipe | Walk, blink, tail, sparkle, proud complete |

## Layout

1. **Top** — Mascot in rounded material hero; “CopyCat is searching…”; phase + progress
2. **Middle** — Duplicate file cards + sparkle on exact-match beats (throttled)
3. **Bottom** — Primary metrics (Duplicates, Recoverable, Files checked) + secondary (Data, Memory, Speed, Folder)
4. **Footer** — Mode / Memory / Speed pills + Cancel Scan

## Files

- `CopyCat/Brand/ScanDesignSystem.swift` — tokens, materials, type, spacing
- `CopyCat/Features/Scanning/Components/ScanMetricCard.swift`
- `CopyCat/Features/Scanning/Components/ScanProgressChrome.swift`
- `CopyCat/Features/Scanning/ScanProgressView.swift` — production screen
- Mascot polish in `CopyCatMascotView.swift` / `ScanningMascotSceneView.swift`

## Preview

Open **Window → Scanning Prototype** (or the “Scanning Prototype” window) to simulate without running a real scan.

Screenshots: `docs/scanning-ui/after-searching.png`, `docs/scanning-ui/before-after.png`
