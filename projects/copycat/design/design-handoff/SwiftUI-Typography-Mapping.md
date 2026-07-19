
# SwiftUI Typography Mapping

## Font Families
- SF Pro Display: headings
- SF Pro Text: body
- SF Mono: diagnostics only

## Semantic Mapping

| Token | Usage |
|---|---|
| display | Hero numbers, onboarding |
| h1 | Screen title |
| h2 | Section title |
| h3 | Card title |
| title | Toolbar / dialogs |
| body | Primary content |
| bodyEmphasis | Highlighted content |
| caption | Supporting labels |
| footnote | Metadata |
| mono | Debug diagnostics |

## SwiftUI Example

```swift
Text("Results")
    .font(.largeTitle)
Text("143 duplicates")
    .font(.title2.weight(.semibold))
```

## Rules

- Never hardcode font sizes in feature views.
- Typography tokens are the source of truth.
- Support Dynamic Type.
- Minimum contrast must satisfy WCAG AA.
- Truncate only after two lines unless explicitly designed.
