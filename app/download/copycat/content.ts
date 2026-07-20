export const copycatProduct = {
  name: "CopyCat",
  tagline: "Find your hidden copies.",
  description:
    "A premium macOS companion that finds exact duplicate files, shows what you can recover, and only moves what you approve to Trash.",
  shortDescription:
    "Exact duplicate finder for macOS — recover storage without losing the files that matter.",
  version: "0.1.0",
  build: 1,
  platform: "macOS",
  minOs: "macOS 14 Sonoma",
  downloadAvailable: false,
  downloadUrl: "/downloads/copycat/latest/CopyCat.dmg",
  downloadFilename: "CopyCat.dmg",
  releaseDateLabel: "Coming soon",
  assets: {
    icon: "/downloads/copycat/brand/app-icon-512.png",
    iconLarge: "/downloads/copycat/brand/app-icon-1024.png",
    brandMark: "/downloads/copycat/brand/brand-mark-white.svg",
  },
} as const;

export const screenshots = [
  {
    id: "home",
    title: "Home",
    caption: "Choose folders or drives, then start scanning.",
    src: "/downloads/copycat/screenshots/home.png",
    width: 1080,
    height: 720,
  },
  {
    id: "scan",
    title: "Scan",
    caption: "Live progress while CopyCat compares file contents.",
    src: "/downloads/copycat/screenshots/scan.png",
    width: 1080,
    height: 720,
  },
  {
    id: "review",
    title: "Review",
    caption: "Decide what to keep — with clear recommendations.",
    src: "/downloads/copycat/screenshots/review.png",
    width: 1440,
    height: 900,
  },
  {
    id: "select",
    title: "Select",
    caption: "Keep one copy, trash the rest, recover the space.",
    src: "/downloads/copycat/screenshots/review-select.png",
    width: 1440,
    height: 900,
  },
  {
    id: "confirm",
    title: "Confirm",
    caption: "Nothing moves until you approve.",
    src: "/downloads/copycat/screenshots/confirm.png",
    width: 1440,
    height: 900,
  },
  {
    id: "finished",
    title: "Finished",
    caption: "Celebrate the space you got back — with undo nearby.",
    src: "/downloads/copycat/screenshots/finished.png",
    width: 1080,
    height: 720,
  },
] as const;

export const features = [
  {
    title: "Exact matches only",
    body: "Full SHA-256 verification means every group is truly identical — not “looks similar.”",
    mascot: "/downloads/copycat/mascot/search.png",
    mascotAlt: "CopyCat searching with a magnifying glass",
  },
  {
    title: "Discover recoverable space",
    body: "See how much storage you can reclaim before you clean a single file.",
    mascot: "/downloads/copycat/mascot/found.png",
    mascotAlt: "CopyCat finding a duplicate",
  },
  {
    title: "Review with confidence",
    body: "Group-by-group review with keep recommendations, Quick Look, and clear paths.",
    mascot: "/downloads/copycat/mascot/proud.png",
    mascotAlt: "CopyCat looking proud",
  },
  {
    title: "Safe cleanup",
    body: "Approved duplicates go to Trash. CopyCat never permanently deletes for you.",
    mascot: "/downloads/copycat/mascot/cleanup.png",
    mascotAlt: "CopyCat cleaning up",
  },
  {
    title: "A clever companion",
    body: "The cat communicates state — waiting feels intelligent, cleanup feels trustworthy.",
    mascot: "/downloads/copycat/mascot/wave.png",
    mascotAlt: "CopyCat waving",
  },
  {
    title: "Private by design",
    body: "Scans stay on your Mac. No account, no cloud upload, no telemetry dashboard.",
    mascot: "/downloads/copycat/mascot/sleep.png",
    mascotAlt: "CopyCat sleeping peacefully",
  },
] as const;

export const requirements = [
  { label: "macOS", value: "14 Sonoma or later" },
  { label: "Chip", value: "Apple silicon or Intel" },
  { label: "Disk", value: "About 50 MB for the app" },
  { label: "Permissions", value: "Folder access for the locations you choose to scan" },
  { label: "Network", value: "Not required — fully offline" },
] as const;

export const changelog = [
  {
    version: "0.1.0",
    date: "Preview",
    title: "First public preview",
    items: [
      "Exact duplicate detection via size filtering and full SHA-256 verification",
      "Home flow for choosing folders and drives",
      "Animated scanning experience with live discovery metrics",
      "Duplicate review with keep recommendations",
      "Safe cleanup to Trash with confirmation and undo",
      "Twilight Teal dark interface with CopyCat mascot states",
    ],
  },
] as const;

export const faqs = [
  {
    question: "Does CopyCat delete files permanently?",
    answer:
      "No. When you approve cleanup, CopyCat moves selected duplicates to Trash. You can restore them from Trash like any other file — and the finished screen keeps undo close at hand.",
  },
  {
    question: "Are “similar” photos or near-duplicates detected?",
    answer:
      "Not in 0.1.0. CopyCat finds exact duplicates only — files with identical content. That keeps results trustworthy and unambiguous.",
  },
  {
    question: "Does my data leave my Mac?",
    answer:
      "No. Scanning and hashing happen locally. There is no account sign-in and no cloud upload for your files.",
  },
  {
    question: "What do I need to grant access to?",
    answer:
      "Only the folders or drives you choose to scan. CopyCat reads file contents to verify duplicates; it does not need full-disk access unless you point it at locations that require it.",
  },
  {
    question: "Which Macs are supported?",
    answer:
      "macOS 14 Sonoma or later, on Apple silicon or Intel Macs.",
  },
] as const;
