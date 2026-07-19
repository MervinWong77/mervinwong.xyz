# CopyCat — Premium Product Design Proposal

**Role:** Lead product design  
**Status:** Proposal for approval — **no SwiftUI implementation until signed off**  
**Inspiration:** Scanning concept board (Options 1–6) + CleanMyMac · Raycast · Craft · Arc · Apple HIG  
**Not:** literal clone of any single board option · Windows utility · admin dashboard · developer tool

---

## 1. Product vision

### What CopyCat is

CopyCat is a **premium macOS companion** that finds exact duplicate files and helps you safely recover disk space—with a cat that makes waiting feel intelligent and cleanup feel trustworthy.

### What CopyCat is not

- Not a “Mac cleaner” that deletes without consent  
- Not Activity Monitor with a cat sticker  
- Not a scan report generator  
- Not a dashboard of engineering metrics  

### Brand promise

> *CopyCat finds identical files on your Mac, shows you what you can recover, and only moves what you approve to Trash.*

### Emotional product arc

| Moment | User should feel |
|--------|------------------|
| Home | “This looks beautiful and safe.” |
| Scanning | “Something intelligent is happening.” |
| Results | “Wow—I can recover a lot of space.” |
| Cleanup | “I trust this app.” |
| Done | “That was worth it.” |

### Product principles (non-negotiable)

1. **Personality with purpose** — The cat communicates state; never fills empty space.  
2. **Outcome over controls** — Recoverable space and progress outrank settings chrome.  
3. **Discovery, not telemetry** — Celebrate twins found; bury MB/s unless expanded.  
4. **Safety is visible** — “Nothing deleted until you confirm” is ambient, not a legal footer.  
5. **Native premium** — SF Pro, materials, traffic-light respect, keyboard literacy.  
6. **One job per screen** — Home chooses; Scan waits with life; Results decide; Cleanup trusts.

### Name of this design language

**“Twilight Teal”** — calm dark surfaces, living teal accent, warm discovery gold, charcoal cat silhouette.

---

## 2. Mood board

### Visual references (feel, not copy)

| Reference | Steal this | Leave this |
|-----------|------------|------------|
| **CleanMyMac** | Hero outcome, celebration, soft confidence | Aggressive upsell density |
| **Raycast** | Crisp hierarchy, intentional empty space, keyboard soul | Pure utility grayness |
| **Craft** | Soft materials, editorial type scale, calm breathing room | Doc-app chrome |
| **Arc** | Distinctive personality without toy chaos | Browser spatial metaphor |
| **Apple Storage / HIG** | Recommendations clarity, system materials | Generic System Settings look |
| **Concept board Opt 1** | Discovery moment energy (“Found a twin!”) | Four equal metric pods |
| **Concept board Opt 2** | Centered focus, progress as hero | Cat trapped in a gauge forever |
| **Concept board Opt 4** | Journey pacing, paw-print motion idea | Heavy top stepper always visible |
| **Concept board Opt 6** | Warmth, human copy (“We’re on it”) | Over-glow / soft focus blur |

### Mood keywords

Quiet confidence · Clever companion · Soft luxury · Living progress · Safe delight

### Anti-mood

Control panels · Equal card grids · Hard borders everywhere · Purple SaaS gradients · Comic chaos

### Texture & material feel

- Deep charcoal window field (not pure black void)  
- Soft elevated surfaces (thin highlight edge + quiet shadow)  
- Occasional ultra-thin material behind mascot stage  
- Teal as light, not as paint can  

---

## 3. Color palette

### Brand core

| Token | Hex | Role |
|-------|-----|------|
| `Teal.500` | `#0D9488` | Primary accent, CTAs, progress |
| `Teal.400` | `#14B8A6` | Hover / active glow |
| `Teal.600` | `#0F766E` | Pressed / deep accent |
| `Teal.950` | `#042F2E` | Teal-tinted dark wells |

### Surfaces (Dark-first product; Light supported)

| Token | Dark | Light | Role |
|-------|------|-------|------|
| `Surface.Base` | `#121414` | `#F4F6F6` | Window background |
| `Surface.Raised` | `#1C1F1F` | `#FFFFFF` | Soft panels |
| `Surface.Sunken` | `#0C0E0E` | `#E8EBEB` | Inset wells / drop zones |
| `Border.Subtle` | `#2A2F2F` | `#D5DADA` | Hairlines only when needed |
| `Text.Primary` | `#F3F5F5` | `#141816` | Headlines, values |
| `Text.Secondary` | `#9AA3A3` | `#5C6666` | Supporting copy |
| `Text.Tertiary` | `#6B7373` | `#8A9393` | Meta, captions |

### Semantic accents (sparingly)

| Token | Hex | Role |
|-------|-----|------|
| `Gold.Discovery` | `#E8B84A` | Recoverable space highlight |
| `Mint.Success` | `#34D399` | Keep / verified / complete |
| `Coral.Caution` | `#F07167` | Trash intent / destructive confirm |
| `Violet.Whisper` | `#A78BFA` | Rare secondary sparkle (discovery chips only) |

### Rules

- **One hero accent per view** (teal). Gold only for recoverable amounts.  
- Never decorate every icon a different rainbow color.  
- Progress, links, and primary buttons share `Teal.500`.  
- Destructive actions use coral only at confirmation—not as default chrome.

> Supersedes earlier orange-primary token experiments for the commercial brand.

---

## 4. Typography

### Families

- **SF Pro Display** — titles, hero numbers  
- **SF Pro Text** — body, UI  
- **SF Mono** — DEBUG / hash expand only (never marketing UI)

### Scale

| Style | Size / Weight | Use |
|-------|---------------|-----|
| `Display` | 40 Bold | Recoverable GB on Results |
| `Title1` | 28 Semibold | Screen titles (“Find twins”) |
| `Title2` | 22 Semibold | Section titles |
| `Title3` | 17 Semibold | Card titles, group names |
| `Body` | 15 Regular | Primary copy |
| `BodyEmphasis` | 15 Medium | Emphasized lines |
| `Callout` | 13 Medium | Discovery toasts, chips |
| `Caption` | 12 Regular | Paths, meta |
| `Footnote` | 11 Regular | Legal-soft trust lines |

### Type rules

- One display number per screen maximum.  
- Paths always Caption + middle truncation.  
- Never stack Title1 + Title2 + Body that all say the same thing.  
- Scanning activity line = Title2; phase detail is not duplicated underneath.

---

## 5. Mascot style

### Character

- Domestic short-hair silhouette, **charcoal / near-black fur**  
- Soft rounded forms, subtle depth (not sticker flat, not 3D uncanny)  
- Eyes: teal-green glint when alert  
- Optional prop: **magnifying glass** only while searching  
- Optional motion cue: **paw prints** along progress path while walking  
- No clothes by default (backpack only if journey beat needs travel metaphor—optional, rare)

### Personality

Curious · Calm · Clever · Quietly proud · Never sarcastic · Never chaotic

### State → pose mapping (engine-driven)

| App state | Mascot | Motion |
|-----------|--------|--------|
| Idle / Home | Sitting, occasional blink | Micro breath, 200–350ms |
| Preparing | Stands, looks toward CTA | Soft settle |
| Scanning | Walk + search (glass) | Loop walk; paw prints along path |
| Hash / verify | Inspects “file” with glass | Slow head tilt |
| Duplicate found | Happy hit-react | One-shot celebrate 400–600ms |
| Results ready | Proud sit beside GB | Tail up, held pose |
| No duplicates | Sleeping / curled | Slow breathe |
| Cleanup running | Carries item toward Trash metaphor | Short loop |
| Error / permission | Concerned, not panicked | Still pose + Reduce Motion |
| Cancelled | Sits, looks aside | Soft fade to idle |

### Mascot rules

1. Driven by **real events**, not a disconnected loop.  
2. If Reduce Motion is on → crossfade still poses only.  
3. Max stage height: Home 160pt · Scan 180pt · Results 120pt.  
4. Never cover primary numbers or CTAs.  
5. If the cat isn’t saying something about state, **remove it**.

---

## 6. Component library

### Foundations

| Component | Spec |
|-----------|------|
| Spacing scale | 4 · 8 · 12 · 16 · 24 · 32 · 48 · 64 |
| Radius | Control 10 · Soft panel 16 · Hero well 22 · Pill 999 |
| Shadow | `Y:8 Blur:24 Opacity:12%` on raised only; none on flat lists |
| Hairline | 1px `Border.Subtle` — prefer spacing over boxes |
| Material | Occasional `.regularMaterial` behind mascot stage only |

### Components (product)

| Component | Purpose | Notes |
|-----------|---------|-------|
| **PrimaryButton** | Start Scan / Review / Confirm | Teal fill, white label |
| **QuietButton** | Cancel / Not now | Text secondary, no border |
| **DropWell** | Choose folders | Sunken, dashed teal at 35% |
| **LocationChip** | Suggested places | Pill, low contrast; selected = teal wash |
| **LocationRow** | Selected folder | Name + quiet path + remove |
| **MascotStage** | State host | No card chrome |
| **ProgressRail** | Determinate progress | Teal fill, 6pt height |
| **DiscoveryToast** | Mid-scan delight | Callout + optional twin thumbs |
| **HeroMetric** | Recoverable GB | Display type + Gold optional |
| **TwinGroupRow** | Results group | Title, size, count; expand |
| **KeepDeleteControl** | Per-file decision | Mint keep / coral delete |
| **TrustWhisper** | Safety line | Footnote, not a banner |
| **BottomBar** | Trash action + recoverable | Appears when selection exists |

### Explicitly out of the default language

- Equal 2×2 metric dashboards on Scan  
- Always-on 4-step steppers  
- Rainbow icon rows  
- Nested cards inside cards  

---

## 7. Home screen concept

### Feeling

“This looks beautiful and safe.”

### Hierarchy

1. Welcome (brand + one line)  
2. Choose where to scan  
3. Start Scan  

### Layout concept

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│   [Mascot idle — sitting, blink]                    │
│                                                     │
│   Find identical files                              │
│   CopyCat only moves what you approve to Trash.     │
│                                                     │
│   Where should we look?                             │
│   . . . . . . . . . . . . . . . . . . . . . . . .   │
│   .  Drop folders or browse…                      .   │
│   . . . . . . . . . . . . . . . . . . . . . . . .   │
│   Desktop  Documents  Downloads  Pictures  …        │
│                                                     │
│   Selected                                          │
│   Pictures · ~/Pictures                      Remove │
│                                                     │
│   [ Start Scan ]                                    │
│                                                     │
│   Nothing is deleted automatically.                 │
└─────────────────────────────────────────────────────┘
```

### Behaviors

- Mascot idle until Start → stands/looks toward button on hover/focus.  
- Chips open sandbox-safe folder confirmation.  
- Stats (size / ETA) only after selection—quiet, never empty fake GB.  
- No confidence manifesto wall. One trust whisper.

### Inspiration blend

Things calm + CleanMyMac welcome restraint + board Opt 6 warmth (without glow soup).

---

## 8. Scanning screen concept

### Feeling

“Something intelligent is happening.”

### Hierarchy

1. Current activity  
2. Progress  
3. Discovery moments  
4. Cancel  

### Layout concept (synthesis — not Opt 1–6 copy)

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│         Looking for twins…                          │
│                                                     │
│      🐾—🐾—🐾  [Mascot walking + glass]  🐾         │
│                                                     │
│         ████████████░░░░░░░░  62%                   │
│         ~/Pictures/2024/…                           │
│                                                     │
│     ┌─────────────────────────────────────────┐     │
│     │  Found a twin!                          │     │
│     │  [thumb]  [thumb]   +2.1 GB             │     │
│     └─────────────────────────────────────────┘     │
│                                                     │
│         14 duplicates · 18.7 GB recoverable         │
│              (one quiet supporting line)            │
│                                                     │
│                      Cancel                         │
└─────────────────────────────────────────────────────┘
```

### Discovery moments (alive, not spammy)

Rotate / event-triggered lines (rate-limited):

- “Found another duplicate.”  
- “Checking your Photos library…”  
- “Looking for twins…”  
- “Almost finished…”  

When a new exact group appears → short **Found a twin!** moment (thumbs if previewable; else filenames). Then resume search pose.

### Rules

- **No** four equal metric cards.  
- **No** permanent stepper chrome (journey can be implied by mascot + copy).  
- Speed / memory / phase jargon → Disclosure “Details” only.  
- Progress never jumps backward (monotonic UI).  
- Cancel always visible, quiet.

### Inspiration blend

Board Opt 1 discovery + Opt 2 focus + Opt 4 motion metaphor − Opt 3 dashboard.

---

## 9. Results screen concept

### Feeling

“Wow, I can recover a lot of space.” → then “I trust this.”

### Hierarchy

1. Recoverable space (hero)  
2. Duplicate groups  
3. Review (keep / delete)  
4. Clean (Move to Trash)  

### Layout concept

```
┌─────────────────────────────────────────────────────┐
│  [Proud mascot]     You can recover                 │
│                     18.7 GB                         │
│                     23 twin sets · Exact matches    │
│                                                     │
│  [ Review recommended ]      Select…                │
│                                                     │
│  Twin sets                                          │
│  ┌─────────────────────────────────────────────┐    │
│  │ vacation.mov · 2.7 GB · 3 copies            │    │
│  │ ✓ Keep Movies/…   ○ Trash Downloads/…       │    │
│  └─────────────────────────────────────────────┘    │
│  …                                                  │
│                                                     │
│  ─────────────────────────────────────────────────  │
│  Move 12 items to Trash · Recover 14.2 GB   [Clean] │
└─────────────────────────────────────────────────────┘
```

### Behaviors

- Hero number is Gold or Teal—never both fighting. Prefer **Gold.Discovery** for GB.  
- Default recommendations applied; user overrides.  
- Reveal / Quick Look / Open via context + shortcuts.  
- Empty / no duplicates → sleeping cat + gentle “All clear.”  
- Cleanup confirm is calm coral, not alarm red theater.

### Inspiration blend

Apple Storage recommendation clarity + CleanMyMac payoff + Finder-grade file actions.

---

## Motion language

| Token | Value | Use |
|-------|-------|-----|
| `Motion.Micro` | 200ms ease | Hover, blink |
| `Motion.Short` | 320ms spring | Discovery toast in |
| `Motion.Celebrate` | 500ms spring | Twin found |
| `Motion.Screen` | 400ms shared | Home ↔ Scan ↔ Results |
| Reduce Motion | Crossfade / opacity only | Mandatory fallback |

---

## What we deliberately reject from the concept board

| Board idea | Verdict |
|------------|---------|
| Opt 3 full dashboard | Reject as default Scan |
| Always-visible 4-step stepper | Reject as permanent chrome |
| Compact menu-bar as v1 core | Later; not the identity product |
| Speed as a primary Scan metric | Details only |
| Equal weight metric pods | Reject |

---

## Approval checklist

Please approve or request changes on:

- [ ] Product vision & principles  
- [ ] Twilight Teal palette (esp. teal vs prior orange)  
- [ ] Type scale  
- [ ] Mascot state map  
- [ ] Component list (and exclusions)  
- [ ] Home concept  
- [ ] Scanning concept (discovery moments)  
- [ ] Results concept  

**No SwiftUI / no production UI rebuild until this proposal is approved.**

---

## Next step after approval

1. High-fidelity mockups (Light + Dark) for Home / Scan / Results  
2. Mascot pose pack export list  
3. Motion prototype for discovery toast  
4. Only then: SwiftUI implementation against the locked system  
