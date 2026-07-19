# CopyCat Design Deliverables

**Audience:** Product design team  
**Consumer:** Senior SwiftUI engineering  
**Rule:** Implementation does not begin until every item below is delivered or explicitly waived in writing.  
**Preferred direction (locked):** Scanning Experience – Option 4 (Journey Flow). The mascot is experiential, not decorative.

---

## 1. Design System

Deliver a single source of truth (Figma styles / tokens file) covering **light and dark** appearances unless a token is explicitly appearance-invariant.

### 1.1 Color

- Brand primary (teal and approved variants: hover, pressed, muted, on-primary)
- Brand secondary / accent (if any; otherwise document “none”)
- Neutrals: background, secondary background, tertiary fill, separators, borders
- Semantic: success, warning, error, info (default + on-color text/icon)
- Text: primary, secondary, tertiary, quaternary, placeholder, link, disabled
- Overlay / scrim colors and opacities
- Selection / highlight colors
- Focus ring color
- Mascot-specific palette (body, eyes, accent, shadow) if not derived from brand tokens
- Explicit mapping: which tokens map to SwiftUI `Color` / Asset Catalog / semantic NSColor

### 1.2 Typography

- Font families (display, text, mono if any) with licensing notes for bundling
- Type ramp: every named style (e.g. Large Title, Title, Title2, Title3, Headline, Body, Callout, Subheadline, Footnote, Caption, Caption2, and any custom Journey/Metric styles)
- For each style: size (pt), weight, line height, tracking/kerning, paragraph spacing
- Dynamic Type: which styles scale; min/max; fixed exceptions (if any) with justification
- Truncation / line-limit rules per style usage
- Numeric styles (tabular numbers for metrics?) yes/no

### 1.3 Spacing & layout

- Spacing scale (e.g. 2/4/8/12/16/20/24/32/40/48/64) — exhaustive list
- Content max widths per window/context
- Window chrome insets / safe content margins
- Sidebar width (default, min, max)
- Inspector width (default, min, max)
- Grid / column rules for results and review layouts
- Vertical rhythm between section header → content → footer
- Journey Flow layout slots (mascot stage, narrative copy, primary metrics, details)

### 1.4 Shape

- Corner radius scale (controls, cards, sheets, windows if custom)
- Continuous vs circular corners specification
- Pill / chip radii
- Divider thickness and inset rules

### 1.5 Elevation & materials

- Shadow tokens (x, y, blur, spread, color, opacity) per elevation level
- Material usage: `.ultraThinMaterial`, `.regularMaterial`, custom vibrancy — where each is allowed
- Blur radii for overlays
- Border styles: width, color token, inside/outside
- Elevation levels mapped to components (0–N)

### 1.6 Motion tokens

- Duration scale (instant, fast, normal, slow, dramatic)
- Easing / spring parameters (response, dampingFraction, blendDuration) for each named curve
- Reduced Motion fallbacks for every named animation
- Stagger intervals for lists/cards
- Journey progress animation timing tokens

### 1.7 Iconography tokens

- Icon size scale (12/14/16/18/20/24/32/…)
- Icon weight / rendering mode (template vs original)
- Badge sizes and offsets relative to icons

### 1.8 Window & chrome

- Default window size, minimum size, maximum size (if any)
- Ideal size for Journey scanning window
- Ideal size for results / review
- Whether windows are resizable; snap/ideal sizes
- Title bar style (hidden title, unified toolbar, etc.)
- Traffic light clearance / leading content inset
- Multi-window policy (prototype windows allowed in DEBUG only? production windows list)

### 1.9 Density & platform

- Comfortable vs compact density (if both exist)
- macOS version visual baseline (Sonoma / Sequoia / …)
- Explicit “do not invent tokens” rule: missing token = stop implementation

---

## 2. Component Library

For **every** component below, design must deliver: purpose, anatomy, all states, measurements, typography, color tokens, assets, interaction notes, accessibility labels/hints, and SwiftUI mapping name.

**Required states (apply where relevant):** default, hover, pressed, focused (keyboard), disabled, selected, loading, error, empty, success, indeterminate.

### 2.1 Foundations

| Component | Purpose | States | Required assets |
|-----------|---------|--------|-----------------|
| App Window Chrome | Native window frame behaviour | — | Spec only |
| Content Background | Root fill / material | light/dark | tokens |
| Divider | Horizontal/vertical rules | — | tokens |
| Scroll Container | Scroll edges, fade, inset | scrolling/end | — |
| Focus Ring | Keyboard focus affordance | focused | tokens |
| Skeleton Placeholder | Loading shimmer | loading, reduced-motion | — |

### 2.2 Actions

| Component | Purpose | States | Required assets |
|-----------|---------|--------|-----------------|
| Button Primary | Main CTA | all + destructive variant if any | — |
| Button Secondary | Secondary CTA | all | — |
| Button Tertiary / Plain | Low emphasis | all | — |
| Button Destructive | Delete / cleanup | all | — |
| Button Icon | Toolbar/icon-only | all + tooltip | SF/custom icon |
| Segmented Control | Mode switches | all | — |
| Toggle / Switch | Settings | on/off/disabled/focused | — |
| Checkbox | Multi-select | checked/unchecked/mixed/disabled | — |
| Radio | Exclusive choice | selected/unselected | — |
| Link Button | Inline navigation | hover/pressed/focused | — |

### 2.3 Navigation & structure

| Component | Purpose | States | Required assets |
|-----------|---------|--------|-----------------|
| Sidebar | Primary nav | collapsed/expanded/selected row | icons |
| Sidebar Item | Nav destination | hover/selected/disabled | icon |
| Toolbar | Window actions | — | icons |
| Tab Bar / Segment Nav | Section switching (if used) | selected | — |
| Breadcrumb | Path context | hover/pressed | chevron |
| Section Header | Group label + optional action | — | — |
| Disclosure Group | Progressive disclosure | expanded/collapsed | chevron |
| Inspector Panel | Detail column | open/closed | — |
| Split View | Sidebar + detail | resized | — |
| Sheet / Modal | Modal tasks | presenting/dismissing | — |
| Popover | Contextual UI | — | — |
| Context Menu | Right-click actions | — | icons |

### 2.4 Inputs

| Component | Purpose | States | Required assets |
|-----------|---------|--------|-----------------|
| Text Field | Generic input | empty/filled/error/disabled/focused | — |
| Search Field | Filter results | empty/typing/clear | magnifyingglass |
| Stepper | Numeric (if any) | — | — |
| Slider | Thresholds (if any) | — | — |
| Drop Zone | Folder drop target | idle/drag-over/invalid/disabled | illustration optional |
| File/Folder Picker Trigger | Opens NSOpenPanel | — | — |

### 2.5 CopyCat domain components

| Component | Purpose | States | Required assets |
|-----------|---------|--------|-----------------|
| Folder Card | Selected scan root | default/hover/selected/removing/unavailable | folder icon / badge |
| Folder List Row | Compact folder entry | hover/selected | — |
| Journey Progress | Option 4 scan journey indicator | stages: start/searching/found/finishing/done | stage icons optional |
| Journey Stage Label | Current narrative stage | — | — |
| Mascot Stage | Host for mascot animation | searching/found/idle/complete/error | mascot assets |
| Scan Narrative Title | “CopyCat is searching…” hierarchy | searching/found/complete/cancelled/failed | — |
| Scan Folder Line | Current location line | truncation middle | folder icon |
| Progress Bar Determinate | Known progress | animating/complete | — |
| Progress Bar Indeterminate | Unknown progress | animating / reduced-motion | — |
| Discovery Metric | Large duplicates / recoverable | zero/nonzero/updating | — |
| Metric Card | Secondary metric (details) | — | icon |
| Status Chip / Pill | Mode, memory, etc. | — | icon |
| Badge | Counts on icons/rows | — | — |
| Duplicate Group Card | Result group summary | collapsed/expanded/selected/hover | file thumbnails optional |
| Duplicate File Row | File within group | hover/selected/keep/delete-marked | file icon / preview |
| File Preview Thumbnail | Image/doc preview | loading/error/missing | generated or placeholder |
| Keep / Remove Control | Per-file decision | keep/remove/undecided | — |
| Recoverable Space Callout | Celebration of savings | updating | — |
| Toast / Banner | Transient feedback | success/warning/error/info + dismiss | icon |
| Empty State Block | No content | — | illustration |
| Error State Block | Recoverable failure | — | illustration |
| Permission Callout | Full Disk / folder access | denied/granted/prompt | illustration |
| External Volume Banner | Drive missing/ejected | disconnected/reconnected | illustration |
| Details Disclosure | Engineering/secondary stats | expanded/collapsed | — |
| Table Header | Results table | sort asc/desc/unsorted | — |
| Table Row | Results density row | hover/selected/focused | — |
| Cleanup Summary Card | Pre-delete confirmation stats | — | — |
| Finished Celebration | Post-cleanup success | — | mascot + illustration |
| Settings Row | Label + control | — | — |
| About Block | Version / credits | — | app icon |
| Debug Diagnostics Panel | DEBUG-only (engineering) | — | monospace; design can mark N/A for Release |

### 2.6 Feedback & dialogs

| Component | Purpose | States | Required assets |
|-----------|---------|--------|-----------------|
| Alert | Destructive confirms | — | — |
| Confirmation Dialog | Multi-step confirm | — | — |
| Progress Dialog | Blocking long work (if any) | — | — |
| Help Tip / Coach Mark | First-run (if any) | — | — |

### 2.7 Delivery requirement per component

Design must provide for each:

1. Figma component with variants for every state  
2. Spacing redlines  
3. Content guidelines (max characters, truncation)  
4. VoiceOver label/hint/value rules  
5. Keyboard interaction (Tab, Space, Return, Esc, arrows)  
6. Mapping to intended SwiftUI primitive (`Button`, `Table`, custom, etc.)

---

## 3. Screen Inventory

Production screens (and critical system surfaces). For each: purpose, states, assets, components, interactions, animations, responsive behaviour, loading/empty/error/success.

### 3.1 Welcome / Onboarding (if shipped)

- **Purpose:** First launch value prop; Option 4 journey promise  
- **States:** first launch, returning user skip, reduced motion  
- **Assets:** welcome illustration, mascot idle/wave, app icon  
- **Components:** Primary/Secondary buttons, pagination (if multi-step)  
- **Interactions:** Continue, Skip, Quit  
- **Animations:** enter/exit, mascot wave  
- **Responsive:** min window; content reflow  
- **Loading / Empty / Error / Success:** N/A or soft load of preferences  

### 3.2 Home / Folder Selection

- **Purpose:** Choose scan roots; start Journey scan  
- **States:** no folders, one folder, many folders, drag-over, invalid drop, permission needed, external volume present/absent  
- **Assets:** empty-home illustration, drop-zone art, folder icons  
- **Components:** Drop Zone, Folder Card/Row, Primary “Scan”, Secondary “Add Folder”, Sidebar (if any)  
- **Interactions:** add/remove folders, drag-drop, double-click, Start Scan disabled rules  
- **Animations:** card insert/remove, drag highlight, mascot “dragging folder” if specified  
- **Responsive:** list vs grid breakpoint  
- **Loading:** resolving bookmarks  
- **Empty:** no folders yet  
- **Error:** access denied, bookmark stale  
- **Success:** ready to scan (CTA enabled)  

### 3.3 Permissions

- **Purpose:** Explain and recover folder / Full Disk Access needs  
- **States:** not determined, denied, restricted, granted  
- **Assets:** permission illustration  
- **Components:** Permission Callout, Open System Settings button, retry  
- **Interactions:** deep link to Settings, re-check  
- **Animations:** subtle only  
- **Empty/Error/Success:** denied vs granted  

### 3.4 Scanning — Journey Flow (Option 4) **PRIMARY**

- **Purpose:** Real-time scan experience driven by engine events  
- **States:** starting, enumerating, grouping, hashing, duplicate-found pulse, classifying, finished-pending-navigation, cancelled, failed, memory-limit failed, reduced motion  
- **Assets:** full mascot set for journey (see §4), journey progress glyphs, optional background atmosphere  
- **Components:** Mascot Stage, Scan Narrative Title, Scan Folder Line, Journey Progress, Progress Bar, Discovery Metrics (duplicates + recoverable), Details Disclosure, Cancel, Toast (optional), DEBUG diagnostics (not designed for Release)  
- **Interactions:** Cancel; expand Details; no accidental navigation away without cancel policy (specify)  
- **Animations:** mascot walk/search/celebrate tied to **real** events; metric count-up; progress; journey stage transitions  
- **Responsive:** compact vs comfortable Journey layout; window min size  
- **Loading:** initial frame before first progress event  
- **Empty:** zero duplicates mid-scan (still searching)  
- **Error:** failed / memory limit / cancelled copy + mascot  
- **Success:** completed journey beat before results  

**Design must provide an event → mascot/animation mapping table** (engine phase / groupsFound increase / finished / cancelled / failed → visual).

### 3.5 No Duplicates

- **Purpose:** Scan completed with zero groups  
- **States:** default, suggest other folders  
- **Assets:** no-duplicates illustration, mascot finished/resting  
- **Components:** Empty State, Primary CTA (scan elsewhere), Secondary (done)  
- **Interactions:** return home, new scan  
- **Animations:** gentle completion  

### 3.6 Results

- **Purpose:** Browse exact duplicate groups; understand recoverable space  
- **States:** loading groups, populated, filtering, sorting, selection, large list performance density, zero after filter  
- **Assets:** file type icons/placeholders, optional thumbnails  
- **Components:** Duplicate Group Card/Table, File Row, Search Field, Sort, Section Header, Recoverable Callout, Toolbar actions (Review, Cleanup)  
- **Interactions:** select group, expand, open in Finder, reveal, multi-select policy  
- **Animations:** list appear, expand/collapse  
- **Responsive:** table vs card layout breakpoint  
- **Loading / Empty / Error / Success:** as above  

### 3.7 Review (keep / remove decisions)

- **Purpose:** Mark which copies to remove per group  
- **States:** undecided, partially decided, all decided, conflict (all marked remove), thumbnail loading  
- **Assets:** previews, badges Keep/Remove  
- **Components:** Duplicate File Row, Keep/Remove controls, Inspector, breadcrumbs, sticky summary  
- **Interactions:** keyboard keep/remove, select original heuristic display (if shown — design must specify rules display only; engine may not choose)  
- **Animations:** row state change, summary update  
- **Error:** missing file mid-review  

### 3.8 Cleanup Confirmation

- **Purpose:** Confirm deletion / move to Trash  
- **States:** ready, deleting, partial failure, success  
- **Assets:** warning illustration if destructive  
- **Components:** Cleanup Summary Card, Alert/Dialog, Progress  
- **Interactions:** confirm, cancel, open Trash  
- **Animations:** progress  
- **Error:** permission, locked file, partial failure list  

### 3.9 Finished / Celebration

- **Purpose:** Confirm space recovered; emotional close of Journey  
- **States:** success with stats, success with zero deleted  
- **Assets:** celebration mascot, success illustration  
- **Components:** Finished Celebration, Primary Done, Secondary View Trash / Scan Again  
- **Animations:** celebration (Reduced Motion alternative mandatory)  

### 3.10 Settings

- **Purpose:** Preferences (exclusions, behaviour, appearance if any)  
- **States:** default, validation error  
- **Assets:** —  
- **Components:** Settings Rows, Toggles, Lists of excluded names, About link  
- **Note:** No performance governor UI unless product explicitly adds it later — design must not invent engine knobs not in architecture  

### 3.11 About

- **Purpose:** Version, credits, licenses  
- **Assets:** app icon, wordmark  
- **Components:** About Block  

### 3.12 External Drive Disconnected

- **Purpose:** Handle volume loss mid-scan or mid-review  
- **States:** disconnected during scan, during review, on home  
- **Assets:** missing-drive illustration, mascot confused  
- **Components:** Banner/Error State, Retry/Cancel/Remove folder  
- **Interactions:** resume policy (design + eng agree; eng cannot invent)  

### 3.13 Scan Error (generic)

- **Purpose:** Failed scan messaging  
- **States:** generic failure, memory-limit failure (copy must match engine string or approved variant)  
- **Assets:** error illustration, mascot  
- **Components:** Error State Block, Retry, Back  

### 3.14 Menu Bar / Commands (if any)

- Spec application menu items, keyboard shortcuts, disabled rules  

### 3.15 Future / out of scope (mark explicitly)

Design must label non-goals for this milestone (e.g. iCloud browser, similarity AI UI) so engineering does not stub phantom screens.

---

## 4. Mascot Assets

Mascot is driven by **real scan events**. Design must deliver a **state machine** + assets for each state, including transitions and Reduced Motion stills.

### 4.1 Required state machine deliverable

Table columns: `State ID` · `Trigger (engine/UI event)` · `Looping?` · `Duration` · `Next states` · `Audio (Y/N)` · `Reduced Motion still`

### 4.2 Core emotional / activity states

- Idle  
- Idle blink  
- Idle look-left / look-right  
- Idle tail wag  
- Sleeping / resting  
- Thinking  
- Wave / greet  
- Confused  
- Sad / permission denied  
- Proud / finished  

### 4.3 Locomotion (Journey)

- Walk loop  
- Walk fast loop  
- Walk slow / sneak  
- Stop / settle  
- Turn left / turn right  
- Sniff  
- Search / scan (looking around while “searching”)  
- Resume walk after stop  

### 4.4 Discovery (must bind to `groupsFound` increases / duplicate reaction)

- Notice  
- Found duplicate (hit-react)  
- Celebrate short  
- Celebrate loop (if held)  
- Show / tap file cards (if cards are separate assets)  
- Sparkle / success accent (optional layer)  
- Return to search walk  

### 4.5 Journey narrative beats

- Scan started  
- Deep search (long-running hashing)  
- Almost done / classifying  
- Completed with findings  
- Completed with zero findings  
- Cancelled  
- Failed / memory limit  

### 4.6 Folder & cleanup narrative (if in scope for v1)

- Dragging folder  
- Dropping folder into drop zone  
- Carrying duplicate  
- Dropping into Trash  
- Cleanup success  

### 4.7 Asset packaging per state

For each state: source file(s), frame rate, frame count OR Rive/Lottie timeline, anchor point, safe padding, light/dark variants, 1x/2x raster if applicable, hit-box if interactive.

### 4.8 Integration contract

Design must specify:

- Preferred runtime: **Rive / Lottie / Sprite sheet / SwiftUI timeline** (pick one primary)  
- How SwiftUI switches states without visual pops  
- Whether mascot is one view with inputs vs swapped assets  
- Maximum stage size (pt) for Journey Option 4 compact layout  

---

## 5. Illustration Assets

Full-bleed or spot illustrations (separate from mascot animation):

| ID | Usage |
|----|--------|
| `illu-welcome` | Onboarding |
| `illu-empty-home` | Home with no folders |
| `illu-drop-zone` | Drag affordance |
| `illu-scanning-atmosphere` | Optional Journey background (not replacing mascot) |
| `illu-no-duplicates` | Zero results |
| `illu-results-empty-filter` | Filter emptied list |
| `illu-review` | Review intro / empty selection |
| `illu-cleanup-confirm` | Destructive confirm |
| `illu-cleanup-complete` | Finished celebration backdrop |
| `illu-permission` | Access needed |
| `illu-missing-drive` | Volume disconnected |
| `illu-error-generic` | Scan failed |
| `illu-error-memory` | Memory-limit stop (if visually distinct) |
| `illu-settings` | Settings empty/hero (if used) |
| `illu-about` | Optional |
| `illu-success-generic` | Shared success |

For each: light/dark, vector preferred, max display size, safe area, do/don’t cropping notes.

---

## 6. Icon Inventory

### 6.1 SF Symbols (preferred when available)

Design must list **exact SF Symbol names** (or approve engineering substitution):

- folder, folder.badge.plus, folder.fill  
- trash, trash.fill  
- magnifyingglass  
- xmark, xmark.circle.fill  
- checkmark, checkmark.circle.fill  
- play / stop equivalents if used  
- square.on.square / doc.on.doc (duplicates)  
- internaldrive / externaldrive  
- memorychip / gauge (details only)  
- leaf (Balanced — only if Details shows mode)  
- exclamationmark.triangle  
- gearshape  
- info.circle  
- arrow.up.forward / reveal in Finder  
- chevron.right / down  
- plus, minus  
- eye / eye.slash (if preview)  
- Any Journey stage icons  

Provide: size, weight, palette (template vs hierarchical).

### 6.2 Custom icons

- App icon (all macOS AppIcon slots)  
- Wordmark / logotype  
- File-type placeholders not covered by Quick Look  
- Keep / Remove custom marks (if not SF)  
- Journey milestone glyphs (if not SF)  
- Tray / menu bar icon (if app has one)  

### 6.3 Brand icons

- Final app icon set (16→1024, 1x/2x as required by asset catalog)  
- Marketing icon (optional, labeled out of app scope)  
- Clear “not the rejected white blob silhouette” confirmation against locked brand  

---

## 7. Motion Specifications

Named animations with duration, curve/spring, delay, stagger, Reduced Motion alternative:

1. App launch / first frame  
2. Window open / close  
3. Navigation push/pop or crossfade between Home ↔ Scanning ↔ Results ↔ Review ↔ Finished  
4. Sidebar show/hide  
5. Inspector show/hide  
6. Button hover / press  
7. Card appear / dismiss  
8. Folder card insert / remove  
9. Drop zone drag-enter / exit / accept / reject  
10. Journey stage change  
11. Progress bar determinate updates  
12. Progress bar indeterminate  
13. Discovery metric count-up / pulse on new duplicate  
14. Mascot state transitions (per §4)  
15. Duplicate-found celebration (UI + mascot sync)  
16. Details disclosure expand/collapse  
17. Results list insert  
18. Group expand/collapse  
19. Review keep/remove toggle  
20. Toast in/out  
21. Alert present/dismiss  
22. Cleanup progress  
23. Finished celebration  
24. Error shake or soft attention (if any)  
25. Scroll-linked effects (if any; else explicitly forbidden)  

Deliver a motion sheet: `AnimationToken` → parameters → screens used.

---

## 8. Asset Specification

### 8.1 Formats (defaults)

| Asset type | Preferred | Acceptable | Notes |
|------------|-----------|------------|-------|
| UI icons | SF Symbol or PDF template | SVG → PDF | Single scale PDF in Asset Catalog |
| App icon | PNG AppIcon set | — | All macOS slots |
| Illustrations | PDF or SVG | PNG @1x/@2x | Vector preferred |
| Mascot animation | **Rive** or **Lottie** (choose one) | PNG sprite sheet | Declare runtime |
| Sprite sheet | PNG @1x/@2x + JSON atlas | — | Frame size, fps |
| Raster photos/previews | PNG/JPEG/HEIC as needed | — | Privacy: no real user photos in design comps |

### 8.2 Retina

- All raster: @1x and @2x minimum; @3x only if design explicitly requires (unusual on Mac)  
- Vectors: PDF preserve vector data  

### 8.3 Appearance

- Light and Dark for every non-template asset that contains baked colors  
- Template assets: document tint tokens  

### 8.4 Animation packaging

- Frame rate, frame count, loop vs one-shot  
- Anchor / registration point  
- Maximum file size budgets (design + eng agree)  

### 8.5 Naming

See §11. Assets that violate naming are rejected.

---

## 9. Screen Specification Requirements

For **each** screen in §3, design must deliver a pack containing:

### 9.1 Layout

- Full-window mock (light + dark)  
- Annotated redlines: margins, gaps, alignment  
- Component instance mapping (Figma component → SwiftUI name)  
- Z-order / material stacking  

### 9.2 Content

- Final copy strings (or String Catalog keys)  
- Truncation and pluralization rules  
- Empty/error/success copy  

### 9.3 Interaction map

- Click/keyboard/gesture matrix  
- Disabled rules  
- Navigation edges (where Cancel goes, etc.)  

### 9.4 State diagrams

- Screen-level state machine  
- For Scanning Journey: event → UI + mascot (mandatory)  

### 9.5 Motion

- Links to named animations in §7  
- Reduced Motion frames  

### 9.6 Assets

- Checklist of illustration/mascot/icon IDs used  

### 9.7 Engineering notes

- What is live data vs placeholder  
- What must not be faked (exact group counts, recoverable bytes when unknown)  
- Performance: list virtualization expectations (design density)  

### 9.8 Acceptance comps

- “Looks done” screenshots at default window size and minimum window size  

**No redlines / no state machine = screen is not ready for implementation.**

---

## 10. Accessibility

Design must specify, not leave to engineering invention:

### 10.1 Reduce Motion

- Per-animation fallback (still pose or opacity-only)  
- Mascot: static pose set for every Journey state  

### 10.2 VoiceOver

- Label, hint, value for every interactive control  
- Scanning summary announcement frequency (polite, not per-file)  
- Duplicate group / file row accessibility order  
- Mascot: decorative vs informative (if informative, what is spoken)  

### 10.3 Keyboard

- Full keyboard loop; Tab order diagrams  
- Shortcuts (Cancel Esc, Scan Return, etc.)  
- Arrow key behaviour in lists/tables  
- Escape dismisses sheets  

### 10.4 Focus

- Focus ring visibility on all custom controls  
- Initial focus per screen  

### 10.5 Contrast

- WCAG-oriented contrast for text/icons on materials  
- High Contrast / Increase Contrast behaviour  
- Non-color conveyance of Keep/Remove/Error  

### 10.6 Dynamic Type

- Which screens reflow vs scroll  
- Truncation vs wrap rules  
- Minimum supported size  

### 10.7 Localization

- String Catalog ownership  
- Long-German / wide-language layouts  
- RTL: yes/no for v1 (explicit)  

### 10.8 Other

- Prefers non-transparency (reduce transparency) materials fallback  
- Dial / pointer alternatives if any custom controls  

---

## 11. SwiftUI Engineering Notes

### 11.1 Delivery structure (required)

```
DesignHandoff/
  README.md                 # index + version + Option 4 confirmation
  Tokens/                   # colors, type, space, radius, motion (exported)
  Components/               # Figma library link + PDF snapshots
  Screens/                  # one folder per screen ID
    Home/
    ScanningJourney/
    Results/
    ...
  Mascot/
    StateMachine.md
    Rive_or_Lottie/
    ReducedMotionStills/
  Illustrations/
  Icons/
    AppIcon/
    Custom/
  Motion/
    MotionSpec.md
  Copy/
    en.lproj strings or spreadsheet
  QA/
    LightDark comps
    MinWindow comps
```

### 11.2 Naming conventions

- Screens: `Screen/{Name}/{Name}_{State}_{Appearance}`  
- Components: `Component/{Name}/{Name}_{Variant}_{State}`  
- Mascot states: `Mascot_{StateID}_{loop|once}`  
- Illustrations: `Illu_{Scene}_{Appearance}`  
- Icons: `Icon_{Name}_Template` or `_Original`  
- No spaces; ASCII; stable IDs (do not rename after handoff without version bump)

### 11.3 Asset Catalog expectations

- AppIcon.appiconset complete  
- Illustrations as named imageset with Any/Dark if needed  
- Prefer PDF template for monochrome icons  
- Do not deliver overlapping “final” icons without deprecating old ones  

### 11.4 Animation delivery

- Single runtime choice for mascot (Rive **or** Lottie)  
- Include integration example (state name enum list matching `StateMachine.md`)  
- Provide “bind to scan events” table with exact enum strings engineering will use  

### 11.5 Component hierarchy guidance

- Atomic → composite → screen  
- Journey scanning screen composition order documented (mascot → narrative → journey → metrics → details → cancel)  
- No dashboard metric grids in Journey Option 4 unless inside Details  

### 11.6 Export sizes

- Illustrations: max display width documented (e.g. 480pt @2x)  
- Mascot stage: max pt size for compact Journey  
- App icon: full macOS set  

### 11.7 Versioning

- Handoff version (e.g. `v1.0-journey`)  
- Changelog when design iterates  
- Explicit “ready for implementation” checkbox signed by design lead  

### 11.8 Engineering stop conditions

Implementation **stops** if any of the following are missing:

1. Tokens for color/type/space/radius/motion  
2. Scanning Journey event → mascot state table  
3. Reduced Motion stills for all mascot states used in Journey  
4. Redlines for Home, Scanning Journey, Results, Review, Cleanup, Finished  
5. Copy for memory-limit and cancel/fail  
6. App icon set  
7. Motion specs for Journey + navigation  
8. Accessibility labels for primary flows  
9. Confirmation of light + dark for all non-template visuals  
10. Written waiver for any intentionally deferred item  

---

## Appendix A — Journey Option 4 non-negotiables (for design QA)

- Mascot is the experiential hero of scanning (compact stage, not empty dashboard panel).  
- Primary live numbers during scan: **duplicates found**, **recoverable space**, **current folder**, plus clear “searching” narrative.  
- Secondary engineering metrics belong in **Details**, not the main journey.  
- Animations reflect **real** scan events (phase, new groups, finished, cancelled, failed)—not a disconnected loop.  
- Premium Mac utility bar: Things / Bear / Raycast / Pixelmator / CleanMyMac — not Activity Monitor.

## Appendix B — Engine realities design must respect

(From frozen engine architecture — design around these, do not invent contradictory UI knobs.)

- Exact duplicates only (full SHA-256).  
- Recoverable bytes may be unknown until groups exist → UI must specify “—” / “Calculating…” treatment.  
- Current folder line may be selected-root based if engine does not stream per-directory paths.  
- No user-facing performance mode controls in current engine.  
- DEBUG diagnostics panel is engineering-only; not a design deliverable for Release.

---

*End of design deliverables checklist. No production SwiftUI implementation begins until this handoff is complete or explicitly waived.*
