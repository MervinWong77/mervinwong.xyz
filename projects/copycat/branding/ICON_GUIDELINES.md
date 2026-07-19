# CopyCat Icon Guidelines

Permanent brand mark: **twin compact cat silhouettes** (C2-11 final).

Source of truth:

- [`Brand/Icon/CopyCat-BrandMark-Black.svg`](../../Brand/Icon/CopyCat-BrandMark-Black.svg)
- [`Brand/Icon/CopyCat-BrandMark-White.svg`](../../Brand/Icon/CopyCat-BrandMark-White.svg)

Do not redraw from PNGs. Edit the SVG, then re-export rasters.

---

## Concept

Two identical filled cat heads. The rear copy is offset up-right so the mark reads as **CopyCat** first—not as documents.

- No facial features, whiskers, fur, or tails
- No strokes, gradients, or shadows
- Filled geometry only

---

## Construction grid

Canvas: **1024 × 1024**

| Guide | Inset from edge | Purpose |
|-------|-----------------|---------|
| Safe area | **10%** (102 px) | Keep all artwork inside; macOS squircle may clip corners |
| Content area | **15%** (154 px) | Preferred optical frame for the mark |
| Center | 512, 512 | Geometric center; mark is optically nudged slightly down |

Construction overlay (design only):

- `Brand/Icon/CopyCat-BrandMark-Construction.svg`

### Twin-layer relationship

- Front and rear paths share **identical geometry**
- Rear offset ≈ **96 × −70** units on the 1024 canvas (before the global optical translate)
- Target: rear silhouette about **85–90%** readable—clear “copy,” not two separate icons

### Ear tips

- Tip-to-tip span on each head is tuned so **all four tips stay distinct at 16×16**
- Prefer sharp triangular ears; avoid soft tips that disappear when downscaled

---

## Safe area

```
+--------------------------------------+
|              10% margin              |
|   +------------------------------+   |
|   |         content area         |   |
|   |                              |   |
|   |         [ twin cats ]        |   |
|   |                              |   |
|   +------------------------------+   |
|                                      |
+--------------------------------------+
```

Never place the mark flush to the canvas edge. Leave margin for Dock masking and Launchpad tiles.

---

## Minimum size

| Context | Minimum |
|---------|---------|
| Absolute floor | **16×16** px |
| Dock / Spotlight | Prefer **32×32** and above |
| Marketing / web | Prefer **128×128** and above |

If a size is smaller than 16 px, do not use the full mark—use the wordmark **CopyCat** instead.

---

## Colour

Current masters (brand colour TBD):

| File | Use |
|------|-----|
| `CopyCat-BrandMark-Black.svg` | Default on light surfaces |
| `CopyCat-BrandMark-White.svg` | On dark surfaces |
| `CopyCat-BrandMark-Black-on-White.svg` | App icon / preview plate |
| `CopyCat-BrandMark-White-on-Black.svg` | Inverse plate |

Rules until a brand colour is chosen:

1. Use **one solid colour** only for the mark
2. Do not add gradients, glows, or multi-tone fills
3. App icon PNGs currently use **black on white**
4. When a brand colour ships, recolour from the SVG—do not recolour bitmaps by eye

Recommended contrast: mark vs background ≥ **4.5:1** for UI chrome; higher for Dock tiles.

---

## Clear space

Keep empty space around the mark of at least **¼ of the mark’s height** on all sides when placing it near:

- Wordmarks
- Other logos
- UI chrome
- Photography edges

Do not:

- Rotate the mark
- Skew or add perspective
- Outline or stroke the silhouette
- Place effects (shadows, glows) on the mark
- Separate the two cats or change their offset
- Add a document / file motif to “explain” the product

---

## App icon export

macOS `AppIcon.appiconset` lives at:

`CopyCat/Resources/Assets.xcassets/AppIcon.appiconset/`

Required sizes (1x / 2x): 16, 32, 128, 256, 512 (plus 1024 via 512@2x).

Master raster: `Brand/Icon/CopyCat-BrandMark-1024.png`

Re-export workflow:

1. Edit SVG masters  
2. Rasterize black-on-white to 1024  
3. Generate the size ladder into `AppIcon.appiconset`  
4. Build the app and spot-check Dock + Spotlight  

---

## Voice check

Someone should look at it and think:

> “That’s the CopyCat app.”

Not:

> “That’s a duplicate-file utility.”


---

## Brand colour

**Locked:** Teal `#0F766E`

App icon plate uses this colour with a near-white mark (`#F5F5F5`).

Final app icon composition: `Brand/Icon/CopyCat-AppIcon.svg`  
(Brand-mark geometry remains frozen in `CopyCat-BrandMark-*.svg`.)
