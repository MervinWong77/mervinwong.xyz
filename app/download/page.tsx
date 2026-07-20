import type { Metadata } from "next";
import Image from "next/image";
import Link from "next/link";
import { getCopyCatRelease } from "./copycat/release";

export const metadata: Metadata = {
  title: "Downloads · Mervin Wong",
  description: "Private downloadable builds and releases.",
  robots: {
    index: false,
    follow: false,
  },
};

export default function DownloadPage() {
  const release = getCopyCatRelease();

  return (
    <main className="mx-auto min-h-screen w-full max-w-2xl px-5 py-16 sm:px-8">
      <h1 className="text-3xl font-semibold tracking-tight text-[var(--cc-text)]">
        Downloads
      </h1>
      <p className="mt-3 text-[var(--cc-text-secondary)]">
        Available apps and builds.
      </p>

      <section aria-labelledby="copycat-heading" className="mt-10">
        <Link
          href="/download/copycat"
          className="group flex flex-col gap-5 rounded-2xl border border-[var(--cc-border)] bg-[var(--cc-surface)]/70 p-5 transition hover:border-[var(--cc-primary)]/40 hover:bg-[var(--cc-surface-hover)] sm:flex-row sm:items-center sm:justify-between sm:p-6"
        >
          <div className="flex items-center gap-4">
            <Image
              src={release.icon}
              alt="CopyCat app icon"
              width={56}
              height={56}
              className="size-14 rounded-[14px]"
              priority
            />
            <div>
              <h2
                id="copycat-heading"
                className="text-lg font-semibold text-[var(--cc-text)]"
              >
                {release.name}
              </h2>
              <p className="mt-1 text-sm text-[var(--cc-text-secondary)]">
                {release.summary}
              </p>
              <p className="mt-2 text-sm text-[var(--cc-text-tertiary)]">
                v{release.version}
              </p>
            </div>
          </div>

          <span className="inline-flex h-10 items-center justify-center self-start rounded-xl border border-[var(--cc-border)] px-4 text-sm font-medium text-[var(--cc-text-secondary)] transition group-hover:border-[var(--cc-primary)]/40 group-hover:text-[var(--cc-text)] sm:self-auto">
            Details
          </span>
        </Link>
      </section>
    </main>
  );
}
