import { createHash } from "node:crypto";
import { existsSync, readFileSync, statSync } from "node:fs";
import path from "node:path";

export const ARTIFACT_FILENAME = "CopyCat.dmg";
export const ARTIFACT_HREF = `/downloads/copycat/latest/${ARTIFACT_FILENAME}`;
export const APP_ICON = "/projects/copycat/copycat-app-icon-v2.png";

export type ArtifactMeta = {
  filename: string;
  href: string;
  bytes: number;
  fileSizeLabel: string;
  sha256: string;
};

function formatBytes(bytes: number): string {
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}

export function getArtifactMeta(): ArtifactMeta {
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
    filename: ARTIFACT_FILENAME,
    href: ARTIFACT_HREF,
    bytes,
    fileSizeLabel: formatBytes(bytes),
    sha256,
  };
}
