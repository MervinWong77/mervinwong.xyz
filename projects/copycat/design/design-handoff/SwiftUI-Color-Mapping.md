
# SwiftUI Color Mapping

## Asset Catalog

SurfacePrimary
SurfaceSecondary
TextPrimary
TextSecondary
AccentPrimary
Success
Warning
Danger
Info
BorderDefault

## Semantic Usage

- SurfacePrimary -> App background
- SurfaceSecondary -> Cards & sheets
- AccentPrimary -> Primary buttons
- Success -> Cleanup completed
- Warning -> Potentially destructive review
- Danger -> Errors only
- JourneyScanning -> Progress ring
- JourneyDuplicates -> Duplicate count
- JourneyCleanup -> Cleanup animation

## Swift Example

```swift
Color("SurfacePrimary")
Color("AccentPrimary")
Color("JourneyScanning")
```

Rules:
- Never use raw HEX in SwiftUI views.
- Always reference Asset Catalog names.
- Every token must have Light and Dark variants.
- WCAG AA minimum contrast.
