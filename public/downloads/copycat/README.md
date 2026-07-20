# CopyCat downloads

Static hosting for CopyCat release builds and marketing assets.

```
downloads/copycat/
├── brand/        # App icon + brand mark used by /download pages
├── mascot/       # Mascot illustrations for feature sections
├── screenshots/  # Product screenshots for the gallery
├── latest/       # Current stable build (e.g. CopyCat.dmg)
└── releases/     # Versioned archives
```

Served at `/downloads/copycat/...` via the Next.js `public/` directory.

When a build is ready, place `CopyCat.dmg` in `latest/` and set
`downloadAvailable: true` in `app/download/copycat/content.ts`.
