# CopyCat UI/UX Round 2 — Component Inventory

No new features. Simplify only.

---

## 1. Before / After inventory

### Home (before → after)

| Component | Before | Decision | After |
|-----------|--------|----------|-------|
| Display title “CopyCat” | Large hero | **Merge** | Single screen title (h2) |
| Marketing tagline | Long sentence | **Merge** into trust | Removed as separate block |
| “Folders to scan” heading | Yes | **Keep** | Yes |
| Dashed drop zone (padded card) | Heavy fill + dash | **Merge** | Lighter browse control |
| Selected location rows | Yes | **Keep** | Yes |
| Suggested links (4 text links) | Incomplete list | **Redesign** | Compact chips (+ Movies/Music/External) |
| Empty-state hint next to CTA | Yes | **Remove** | Disabled Start Scan is enough |
| Ignore &lt; 1 MB checkbox | Primary row | **Remove** from Home UI | Engine default unchanged; not required to scan |
| Footnote (3 clauses) | Verbose | **Merge** | “Safe by Design” + 2 bullets |
| Selected size / locations / ETA | Absent | **Add** (only when selected) | Quiet stats row when count &gt; 0 |
| Card grids / shadows / confidence panel | Already gone | — | Stay gone |

### Scan (before → after)

| Component | Before | Decision | After |
|-----------|--------|----------|-------|
| Mascot scene | Decorative stage | **Remove** | Gone (does not beat text for progress) |
| Headline (“Finding duplicates”) | Yes | **Merge** | One activity line only |
| Phase label (duplicate of headline) | Yes | **Merge** | Same single activity line |
| Progress bar | Yes | **Keep** | Primary focus |
| Folder path under bar | Yes | **Keep** (quiet) | Caption under progress |
| Elapsed under bar | Yes | **Merge** | Moves to secondary metrics |
| Files / Duplicates / Recoverable | 3 metrics | **Merge** | Files + Duplicates + Elapsed (no Recoverable) |
| Cancel | Yes | **Keep** | Bottom |
| Journey stepper / % / sidebar | Already gone | — | Stay gone |
| DEBUG diagnostics inset | DEBUG only | **Keep** | DEBUG only |

---

## 2. Components removed

- Home marketing paragraph (standalone)
- Home “Add at least one folder…” hint
- Home Ignore-small-files checkbox (UI only)
- Home triple-clause footnote
- Scan mascot + animation director wiring on this screen
- Scan duplicate headline + phase pair
- Scan “Recoverable” metric
- Nested card chrome / dashed heavy drop treatment

---

## 3. Components merged

- Trust copy → **Safe by Design** (2 bullets max)
- Scan status → **one Current Activity** string (phase-driven)
- Elapsed → part of secondary metric row
- Suggested locations → **compact chips** (Direction B)

---

## 4. Updated information hierarchy

### Home
1. Title  
2. Choose scan source (browse + chips)  
3. Selected locations  
4. Stats *(only if something selected)*: Selected Size · Locations · Est. Time  
5. Start Scan  
6. Safe by Design (2 lines)

### Scan
1. **Current activity** (single line)  
2. **Progress** (+ quiet path)  
3. Secondary: files · duplicates · elapsed  
4. **Cancel**

---

## 5. Screenshots

| Screen | File |
|--------|------|
| Home (with one selection + chips + stats) | [`screenshots/home.png`](screenshots/home.png) |
| Scan (activity → progress → secondary → cancel) | [`screenshots/scan.png`](screenshots/scan.png) |

Regenerate (DEBUG):

```bash
COPYCAT_SNAPSHOT=1 /path/to/CopyCat.app/Contents/MacOS/CopyCat
# PNGs land in the app container tmp; copy into docs/ui-ux-round2/screenshots/
```
