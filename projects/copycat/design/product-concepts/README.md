# CopyCat — Three Product Concepts

**Status:** Design exploration only. **No implementation until one concept is approved.**

These three directions are intentionally incompatible with each other. Choosing one means rejecting the interaction model of the others—not mixing pieces.

---

## Concept A — “Recover”

### Product philosophy

CopyCat is an **emotional storage recovery ritual**, not a file utility.

The product’s job is to make “I got my disk space back” feel inevitable and calm. Controls are almost invisible. Trust is conveyed through restraint, not through feature lists. The user should feel guided—like CleanMyMac’s hero moments or Apple’s Storage management—rather than operating a tool.

**North star sentence:** *Start. Wait. Celebrate space returned.*

### Information architecture

```
Recover (home)
  └─ one CTA: Recover Storage
       └─ Journey (scanning as atmosphere)
            └─ Verdict
                 ├─ Nothing to recover → Done
                 └─ Space found → One-tap Review
                      └─ Confirm → Trash → Celebration
```

No Settings-first, no folder grids, no metric dashboards on entry. Folders are chosen once, almost as a permission step, then disappear from mental model.

### Wireframe

```
┌──────────────────────────────────────────────────────────┐
│  CopyCat                                            · · ·│
│                                                          │
│                                                          │
│              [  soft visual / mascot stage  ]             │
│                                                          │
│                   Recover Storage                        │
│            Free space taken by identical files           │
│                                                          │
│                 ┌────────────────────┐                   │
│                 │  Recover Storage   │                   │
│                 └────────────────────┘                   │
│                                                          │
│              Choose folders…  (text link)                │
│                                                          │
│                                                          │
│   Safe · Nothing deleted until you confirm               │
└──────────────────────────────────────────────────────────┘

Scan (full-bleed atmosphere):
┌──────────────────────────────────────────────────────────┐
│                                                          │
│              Looking for identical files…                │
│                    ████████░░░░  62%                     │
│                                                          │
│                      18.4 GB found                       │
│                     (single number)                      │
│                                                          │
│                        Cancel                            │
└──────────────────────────────────────────────────────────┘

Verdict:
┌──────────────────────────────────────────────────────────┐
│                                                          │
│                   You can recover                        │
│                      18.4 GB                             │
│                                                          │
│              ┌──────────────────────┐                    │
│              │   Review & free up   │                    │
│              └──────────────────────┘                    │
│                     Not now                              │
└──────────────────────────────────────────────────────────┘
```

### User journey

1. Open app → immediately understand the promise (recover storage).
2. Optionally pick folders (defaults: common user folders after one permission).
3. Tap **Recover Storage**.
4. Experience a quiet journey; only “space found” matters.
5. Land on a verdict: amount recoverable.
6. Review is a short, focused keep/delete pass—or “free the recommended set.”
7. Trash + celebration. Done.

### Why this layout is better

It collapses the product to **one job**. Current CopyCat fails because it behaves like a scanner console. This concept sells the outcome first. Cognitive load drops because there is almost nothing to configure before value appears.

### Inspiration

- **CleanMyMac** — hero “clean” moments, celebration
- **Apple Storage** — outcome-led (Recommendations)
- **Things 3** — calm emptiness, one clear action
- **Craft** — soft atmosphere, not chrome

### Strengths

- Strongest emotional clarity and brand differentiation
- Fastest path from launch → perceived value
- Easiest marketing story
- Mascot finally has a role (journey companion)

### Weaknesses

- Power users may feel trapped / under-informed
- Defaults for folders are politically hard on macOS (sandbox)
- Less suitable if CopyCat later becomes a general duplicate browser
- Review must stay extremely short or the magic breaks

---

## Concept B — “Library”

### Product philosophy

CopyCat is a **Finder for duplicates**: a native browser of your Mac’s identical files.

The product’s job is to make duplicates feel like a place you visit—like a smart folder—not a wizard you endure. Selection, columns, Quick Look, and keyboard navigation are first-class. Trust comes from familiarity with macOS, not from a landing pitch.

**North star sentence:** *Browse your Mac’s twins the way you browse files.*

### Information architecture

```
Sidebar
  ├─ Locations (user folders / volumes)
  ├─ Smart scopes (Desktop, Downloads, External, Recent scans)
  └─ Duplicate sets (after scan)

Main
  ├─ Column / list browser of groups
  └─ Inspector (preview, metadata, keep/delete)

Toolbar
  ├─ Scan location
  ├─ Search / filter
  └─ Move to Trash
```

Home *is* the browser empty state—not a separate marketing page.

### Wireframe

```
┌──────────────┬───────────────────────────────────────────┐
│ LOCATIONS    │  Downloads                    Scan  ⌘R    │
│ ▼ Folders    ├───────────────────────────────────────────┤
│   Desktop    │  Name              Size    Modified       │
│   Documents  │  ┌ twin set ───────────────────────────┐  │
│   Downloads● │  │ vacation.mov      2.7 GB   Jun 12   │  │
│   Pictures   │  │  ✓ Keep   ~/Movies/...              │  │
│   Movies     │  │  ○ Trash  ~/Downloads/...           │  │
│ ▼ Volumes    │  └─────────────────────────────────────┘  │
│   T9 Drive   │  ┌ twin set ───────────────────────────┐  │
│              │  │ ...                                 │  │
│ SMART        │  └─────────────────────────────────────┘  │
│   All twins  │                                           │
│   Outside    │                              Inspector ▸  │
│   Library    │                                           │
│              │                                           │
│              ├───────────────────────────────────────────┤
│              │  3 sets selected · 6.2 GB · Move to Trash │
└──────────────┴───────────────────────────────────────────┘
```

### User journey

1. Open app → see Locations like Finder sidebar.
2. Select a location (or multi-select).
3. Scan runs as a thin progress in the toolbar/window title—not a separate “mode world.”
4. Duplicate sets appear as browsable rows/groups.
5. Arrow keys, Space (Quick Look), Return (Reveal), Delete (mark Trash).
6. Move to Trash from toolbar. Stay in the library.

### Why this layout is better

It matches **how Mac users already think about files**. The current app invents a custom workflow language (journey, cards, chips). Library reuses Finder literacy so post-scan management—the real 80% of the job—feels native instead of bolted on.

### Inspiration

- **Finder** — sidebar, columns, inspector, Quick Look
- **Path Finder / ForkLift** — dual-pane power without leaving the Mac idiom
- **Apple Music / Photos sidebars** — places, not wizards
- **Arc** — spatial “places” (sidebar as home)

### Strengths

- Best for large libraries and repeated use
- Keyboard-first power users thrive
- Review/cleanup is the product, not an afterthought
- Scales to thousands of groups without “Next card” fatigue

### Weaknesses

- Weaker first-run “wow” / marketing clarity
- Easy to feel dense if not carefully restrained
- Scan progress is less cinematic
- Harder to tell a simple story on the website

---

## Concept C — “Pulse”

### Product philosophy

CopyCat is a **live storage intelligence surface** for exact duplicates.

The product’s job is to make invisible waste visible—continuously. It feels closer to Raycast’s command palette density + CleanMyMac’s insight cards: a command center you open when the Mac feels full. Scanning is a refresh of insight, not the whole app.

**North star sentence:** *See the waste. Command the cleanup.*

### Information architecture

```
Pulse (home dashboard)
  ├─ Storage pulse (recoverable estimate / last scan)
  ├─ Hotspots (Desktop, Downloads, Externals)
  ├─ Actions (Scan now, Clean recommended, Open Library)
  └─ Recent activity

Command layer (⌘K)
  └─ Scan Desktop · Scan Downloads · Clean recommended · Reveal…

Results / Cleanup
  └─ Insight-driven lists with bulk commands
```

### Wireframe

```
┌──────────────────────────────────────────────────────────┐
│  CopyCat          ⌘K Search actions…              ⚙     │
├──────────────────────────────────────────────────────────┤
│                                                          │
│   Recoverable now                                        │
│   42.6 GB                         Last scan · 2h ago     │
│   ████████████░░░░  across 318 twin sets                 │
│                                                          │
│   ┌────────────┐  ┌────────────┐  ┌────────────┐         │
│   │ Downloads  │  │ Desktop    │  │ External   │         │
│   │ 18.2 GB    │  │ 9.4 GB     │  │ 15.0 GB    │         │
│   │ Scan ▸     │  │ Scan ▸     │  │ Scan ▸     │         │
│   └────────────┘  └────────────┘  └────────────┘         │
│                                                          │
│   Recommended cleanup                    [ Clean 12 GB ] │
│   · 46 sets outside your libraries                       │
│                                                          │
│   Recent                                                 │
│   · Freed 2.1 GB yesterday                               │
│   · Scan of Movies completed                             │
└──────────────────────────────────────────────────────────┘
```

### User journey

1. Open app → see current recoverable picture (or empty pulse inviting first scan).
2. Click a hotspot or run ⌘K “Scan Downloads.”
3. Scan updates the pulse live (numbers are the UI).
4. Tap **Clean recommended** or drill into a hotspot’s twin sets.
5. Confirm Trash. Pulse updates. History records the win.

### Why this layout is better

It reframes CopyCat from “run a scan wizard” to **“keep an eye on waste.”** That is a durable product habit (open when disk is full), and it justifies richer visuals without turning the scan screen into a dashboard. Insights pull the user; scan becomes a means.

### Inspiration

- **Raycast** — ⌘K commands, dense but crisp actions
- **CleanMyMac** — insight cards, cleanup CTAs
- **iStat / Activity ideas (lightly)** — living status, not a form
- **Arc** — modern utility chrome without Windows-control-panel energy

### Strengths

- Strongest “open again tomorrow” loop
- Rich visuals have a job (insights), not decoration
- Excellent for demos and App Store screenshots
- Natural home for recommendations and hotspots

### Weaknesses

- Highest build cost (estimates, history, hotspots, command palette)
- Risk of fake/empty stats before first scan (honesty required)
- Can slide into dashboard clutter if undisciplined
- Needs careful sandbox story for “whole Mac” insights

---

## Comparison (choose one direction)

| Dimension | A Recover | B Library | C Pulse |
|-----------|-----------|-----------|---------|
| Metaphor | Ritual / cleanse | Finder place | Command center |
| First screen job | Emotion + one CTA | Browse locations | Show waste |
| Scan role | Cinematic journey | Background refresh | Insight refresh |
| Power user fit | Low–medium | High | Medium–high |
| Marketing clarity | Highest | Medium | High |
| Implementation risk | Medium (defaults) | Medium (browser UX) | Highest (data model) |
| Danger mode | Too empty / toy-like | Too dense / utilitarian | Fake dashboard |

---

## Decision needed

Please pick **one**:

1. **A — Recover** (outcome ritual)  
2. **B — Library** (Finder for twins)  
3. **C — Pulse** (storage intelligence)

Or reject all three and request a new set.

**Do not mix.** After approval, implementation follows that concept only.
