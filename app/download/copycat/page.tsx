import type { Metadata } from "next";
import Image from "next/image";
import Link from "next/link";
import { getCopyCatRelease } from "./release";

export const metadata: Metadata = {
  title: "Download CopyCat · Mervin Wong",
  description:
    "Download CopyCat for macOS — latest version, release notes, and system requirements.",
  robots: {
    index: false,
    follow: false,
  },
};

export default function CopyCatDownloadPage() {
  const release = getCopyCatRelease();

  return (
    <main className="mx-auto min-h-screen w-full max-w-2xl px-5 py-16 sm:px-8">
      <Link
        href="/download"
        className="text-sm text-[var(--cc-text-secondary)] transition hover:text-[var(--cc-text)]"
      >
        ← Downloads
      </Link>

      <section className="mt-8" aria-labelledby="logo-heading">
        <h2 id="logo-heading" className="sr-only">
          App logo
        </h2>
        <Image
          src={release.icon}
          alt="CopyCat app icon"
          width={96}
          height={96}
          className="size-24 rounded-[22px] shadow-[0_16px_40px_rgb(0_0_0_/0.45)]"
          priority
        />
      </section>

      <h1 className="mt-6 text-3xl font-semibold tracking-tight text-[var(--cc-text)]">
        {release.name}
      </h1>
      <p className="mt-2 text-[var(--cc-text-secondary)]">{release.summary}</p>
      <p className="mt-3 max-w-xl text-sm leading-relaxed text-[var(--cc-text-tertiary)]">
        {release.description}
      </p>

      <section className="mt-10" aria-labelledby="version-heading">
        <h2
          id="version-heading"
          className="text-sm font-medium text-[var(--cc-text-tertiary)]"
        >
          Latest version
        </h2>
        <dl className="mt-4 space-y-3 text-sm">
          <div className="flex justify-between gap-4 border-b border-[var(--cc-border)] pb-3">
            <dt className="text-[var(--cc-text-tertiary)]">Version</dt>
            <dd className="font-medium text-[var(--cc-text)]">
              {release.version}
            </dd>
          </div>
          <div className="flex justify-between gap-4 border-b border-[var(--cc-border)] pb-3">
            <dt className="text-[var(--cc-text-tertiary)]">Released</dt>
            <dd className="font-medium text-[var(--cc-text)]">
              {release.releaseDateLabel}
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
      </section>

      <section className="mt-10" aria-labelledby="download-heading">
        <h2
          id="download-heading"
          className="text-sm font-medium text-[var(--cc-text-tertiary)]"
        >
          Download
        </h2>
        <a
          href={release.href}
          download={release.filename}
          className="mt-4 inline-flex h-12 w-full items-center justify-center rounded-xl bg-[var(--cc-primary)] px-5 text-sm font-semibold text-white transition hover:bg-[var(--cc-primary-hover)] sm:w-auto"
        >
          Download CopyCat for macOS
        </a>
        <p className="mt-3 text-sm text-[var(--cc-text-tertiary)]">
          {release.filename} · v{release.version} · {release.fileSizeLabel}
        </p>
        <p className="mt-3 max-w-md text-sm leading-relaxed text-[var(--cc-text-tertiary)]">
          Private beta build. macOS may show a security warning because this
          build is not yet notarized.
        </p>
      </section>

      <section className="mt-12" aria-labelledby="notes-heading">
        <h2
          id="notes-heading"
          className="text-sm font-medium text-[var(--cc-text-tertiary)]"
        >
          Release notes
        </h2>
        <ul className="mt-4 space-y-2.5 text-sm leading-relaxed text-[var(--cc-text-secondary)]">
          {release.releaseNotes.map((note) => (
            <li key={note} className="flex gap-3">
              <span
                aria-hidden
                className="mt-2 size-1.5 shrink-0 rounded-full bg-[var(--cc-primary)]"
              />
              <span>{note}</span>
            </li>
          ))}
        </ul>
      </section>

      <section className="mt-12" aria-labelledby="changelog-heading">
        <h2
          id="changelog-heading"
          className="text-sm font-medium text-[var(--cc-text-tertiary)]"
        >
          Changelog
        </h2>
        <div className="mt-4 space-y-6">
          {release.changelog.map((entry) => (
            <article
              key={entry.version}
              className="rounded-2xl border border-[var(--cc-border)] bg-[var(--cc-surface)]/50 p-5"
            >
              <div className="flex flex-wrap items-baseline gap-3">
                <h3 className="text-base font-semibold text-[var(--cc-text)]">
                  v{entry.version}
                </h3>
                <span className="text-sm text-[var(--cc-text-tertiary)]">
                  {entry.date}
                </span>
              </div>
              <p className="mt-1 text-sm font-medium text-[var(--cc-primary-hover)]">
                {entry.title}
              </p>
              <ul className="mt-4 space-y-2 text-sm leading-relaxed text-[var(--cc-text-secondary)]">
                {entry.items.map((item) => (
                  <li key={item} className="flex gap-3">
                    <span
                      aria-hidden
                      className="mt-2 size-1.5 shrink-0 rounded-full bg-[var(--cc-primary)]"
                    />
                    <span>{item}</span>
                  </li>
                ))}
              </ul>
            </article>
          ))}
        </div>
      </section>

      <section className="mt-12" aria-labelledby="requirements-heading">
        <h2
          id="requirements-heading"
          className="text-sm font-medium text-[var(--cc-text-tertiary)]"
        >
          System requirements
        </h2>
        <dl className="mt-4 space-y-3 text-sm">
          {release.requirements.map((item) => (
            <div
              key={item.label}
              className="flex items-baseline justify-between gap-6 border-b border-[var(--cc-border)] pb-3 last:border-0 last:pb-0"
            >
              <dt className="shrink-0 text-[var(--cc-text-tertiary)]">
                {item.label}
              </dt>
              <dd className="text-right font-medium text-[var(--cc-text)]">
                {item.value}
              </dd>
            </div>
          ))}
        </dl>
      </section>
    </main>
  );
}
