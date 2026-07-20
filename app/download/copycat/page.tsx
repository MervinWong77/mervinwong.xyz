import type { Metadata } from "next";
import Image from "next/image";
import Link from "next/link";
import { getCopyCatRelease } from "./release";

export const metadata: Metadata = {
  title: "Download CopyCat · Mervin Wong",
  description: "Private beta download for CopyCat on macOS.",
  robots: {
    index: false,
    follow: false,
  },
};

export default function CopyCatDownloadPage() {
  const release = getCopyCatRelease();

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-lg flex-col px-5 py-16 sm:px-8">
      <div className="flex flex-1 flex-col items-start">
        <Image
          src={release.icon}
          alt="CopyCat app icon"
          width={96}
          height={96}
          className="size-24 rounded-[22px] shadow-[0_16px_40px_rgb(0_0_0_/0.45)]"
          priority
        />

        <h1 className="mt-6 text-3xl font-semibold tracking-tight text-[var(--cc-text)]">
          {release.name}
        </h1>
        <p className="mt-2 text-[var(--cc-text-secondary)]">{release.summary}</p>

        <dl className="mt-8 w-full space-y-3 text-sm">
          <div className="flex justify-between gap-4 border-b border-[var(--cc-border)] pb-3">
            <dt className="text-[var(--cc-text-tertiary)]">Version</dt>
            <dd className="font-medium text-[var(--cc-text)]">
              {release.version}
            </dd>
          </div>
          <div className="flex justify-between gap-4 border-b border-[var(--cc-border)] pb-3">
            <dt className="text-[var(--cc-text-tertiary)]">File size</dt>
            <dd className="font-medium text-[var(--cc-text)]">
              {release.fileSizeLabel}
            </dd>
          </div>
          <div className="flex justify-between gap-4 border-b border-[var(--cc-border)] pb-3">
            <dt className="text-[var(--cc-text-tertiary)]">Requires</dt>
            <dd className="text-right font-medium text-[var(--cc-text)]">
              {release.minOs}
            </dd>
          </div>
          <div className="flex flex-col gap-1 pt-1 sm:flex-row sm:justify-between sm:gap-4">
            <dt className="text-[var(--cc-text-tertiary)]">SHA-256</dt>
            <dd className="break-all font-mono text-xs leading-relaxed text-[var(--cc-text-secondary)] sm:max-w-[70%] sm:text-right">
              {release.sha256}
            </dd>
          </div>
        </dl>

        <a
          href={release.href}
          download={release.filename}
          className="mt-10 inline-flex h-12 w-full items-center justify-center rounded-xl bg-[var(--cc-primary)] px-5 text-sm font-semibold text-white transition hover:bg-[var(--cc-primary-hover)] sm:w-auto"
        >
          Download CopyCat for macOS
        </a>

        <p className="mt-5 max-w-md text-sm leading-relaxed text-[var(--cc-text-tertiary)]">
          Private beta build. macOS may show a security warning because this
          build is not yet notarized.
        </p>

        <Link
          href="/download"
          className="mt-10 text-sm text-[var(--cc-text-secondary)] transition hover:text-[var(--cc-text)]"
        >
          ← Back to Downloads
        </Link>
      </div>
    </main>
  );
}
