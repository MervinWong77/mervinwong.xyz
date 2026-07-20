import { createHash } from "node:crypto";
import { existsSync, readFileSync, statSync } from "node:fs";
import path from "node:path";

export const ARTIFACT_FILENAME = "CopyCat.dmg";
export const ARTIFACT_HREF = `/downloads/copycat/latest/${ARTIFACT_FILENAME}`;

export type CopyCatRelease = {
  name: string;
  summary: string;
  description: string;
  version: string;
  minOs: string;
  filename: string;
  href: string;
  bytes: number;
  fileSizeLabel: string;
  sha256: string;
  releaseDateLabel: string;
  icon: string;
  releaseNotes: string[];
  changelog: {
    version: string;
    date: string;
    title: string;
    items: string[];
  }[];
  requirements: { label: string; value: string }[];
};

function formatBytes(bytes: number): string {
  const mb = bytes / (1024 * 1024);
  return `${mb.toFixed(1)} MB`;
}

function formatReleaseDate(date: Date): string {
  return date.toLocaleDateString("en-US", {
    year: "numeric",
    month: "long",
    day: "numeric",
    timeZone: "UTC",
  });
}

export function getCopyCatRelease(): CopyCatRelease {
  const filePath = path.join(
    process.cwd(),
    "public/downloads/copycat/latest",
    ARTIFACT_FILENAME,
  );

  if (!existsSync(filePath)) {
    throw new Error(
      `Missing CopyCat download artifact at public/downloads/copycat/latest/${ARTIFACT_FILENAME}`,
    );
  }

  const stats = statSync(filePath);
  const bytes = stats.size;
  const sha256 = createHash("sha256")
    .update(readFileSync(filePath))
    .digest("hex");

  return {
    name: "CopyCat",
    summary: "Duplicate finder for macOS",
    description:
      "Find exact duplicate files on your Mac, review what to keep, and recover storage by moving approved copies to Trash.",
    version: "0.1.0",
    minOs: "macOS 14 Sonoma or later",
    filename: ARTIFACT_FILENAME,
    href: ARTIFACT_HREF,
    bytes,
    fileSizeLabel: formatBytes(bytes),
    sha256,
    releaseDateLabel: formatReleaseDate(stats.mtime),
    icon: "/downloads/copycat/brand/app-icon-512.png",
    releaseNotes: [
      "First private beta of CopyCat for macOS.",
      "Exact duplicate detection using size filtering and full SHA-256 verification.",
      "Home, scan, review, and cleanup flow with safe Trash-based removal.",
      "Universal build for Apple silicon and Intel Macs.",
      "Ad-hoc signed only — macOS may show a Gatekeeper warning until notarization is added.",
    ],
    changelog: [
      {
        version: "0.1.0",
        date: formatReleaseDate(stats.mtime),
        title: "Private beta",
        items: [
          "Exact duplicate detection via size filtering and full SHA-256 verification",
          "Folder and drive selection on Home",
          "Live scanning progress with discovery metrics",
          "Duplicate review with keep recommendations",
          "Safe cleanup to Trash with confirmation",
          "Twilight Teal dark interface with CopyCat mascot states",
        ],
      },
    ],
    requirements: [
      { label: "macOS", value: "14 Sonoma or later" },
      { label: "Chip", value: "Apple silicon or Intel" },
      { label: "Disk", value: "About 50 MB for the app" },
      {
        label: "Permissions",
        value: "Folder access for the locations you choose to scan",
      },
      { label: "Network", value: "Not required — fully offline" },
    ],
  };
}
