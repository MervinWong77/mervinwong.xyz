import { createHash } from "node:crypto";
import { existsSync, readFileSync, statSync } from "node:fs";
import path from "node:path";

export const ARTIFACT_FILENAME = "CopyCat.dmg";
export const ARTIFACT_HREF = `/downloads/copycat/latest/${ARTIFACT_FILENAME}`;

export type CopyCatRelease = {
  name: string;
  summary: string;
  version: string;
  minOs: string;
  filename: string;
  href: string;
  bytes: number;
  fileSizeLabel: string;
  sha256: string;
  icon: string;
};

function formatBytes(bytes: number): string {
  const mb = bytes / (1024 * 1024);
  return `${mb.toFixed(1)} MB`;
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

  const bytes = statSync(filePath).size;
  const sha256 = createHash("sha256")
    .update(readFileSync(filePath))
    .digest("hex");

  return {
    name: "CopyCat",
    summary: "Duplicate finder for macOS",
    version: "0.1.0",
    minOs: "macOS 14 Sonoma or later",
    filename: ARTIFACT_FILENAME,
    href: ARTIFACT_HREF,
    bytes,
    fileSizeLabel: formatBytes(bytes),
    sha256,
    icon: "/downloads/copycat/brand/app-icon-512.png",
  };
}
