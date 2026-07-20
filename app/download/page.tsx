import type { Metadata } from "next";
import Image from "next/image";
import Link from "next/link";
import { ArrowUpRight } from "lucide-react";
import { DownloadFooter } from "./_components/DownloadFooter";
import { DownloadHeader } from "./_components/DownloadHeader";
import { copycatProduct } from "./copycat/content";

export const metadata: Metadata = {
  title: "Downloads · Mervin Wong",
  description:
    "Downloadable builds and releases — including CopyCat for macOS.",
  robots: {
    index: false,
    follow: false,
  },
};

export default function DownloadPage() {
  return (
    <>
      <DownloadHeader brandHref="/download" brandLabel="Downloads" />

      <main className="relative mx-auto w-full max-w-6xl px-5 pb-20 pt-10 sm:px-8 sm:pt-16">
        <div className="max-w-2xl cc-animate-fade-up">
          <p className="text-sm font-medium tracking-wide text-[var(--cc-primary-hover)]">
            Product downloads
          </p>
          <h1 className="mt-3 text-4xl font-semibold tracking-tight text-[var(--cc-text)] sm:text-5xl">
            Downloads
          </h1>
          <p className="mt-4 max-w-xl text-base leading-relaxed text-[var(--cc-text-secondary)] sm:text-lg">
            Builds and releases for apps I ship. Start with CopyCat — a premium
            duplicate finder for macOS.
          </p>
        </div>

        <section
          aria-labelledby="featured-heading"
          className="mt-12 cc-animate-fade-up-delay-1"
        >
          <h2 id="featured-heading" className="sr-only">
            Featured
          </h2>

          <Link
            href="/download/copycat"
            className="group relative block overflow-hidden rounded-3xl border border-[var(--cc-border)] bg-[var(--cc-surface)]/80 transition hover:border-[var(--cc-primary)]/45 hover:bg-[var(--cc-surface-hover)]"
          >
            <div
              aria-hidden
              className="pointer-events-none absolute -right-16 top-0 size-[420px] rounded-full bg-[var(--cc-glow)]/20 blur-3xl cc-glow"
            />

            <div className="grid items-center gap-8 p-6 sm:p-8 lg:grid-cols-[1.1fr_0.9fr] lg:gap-10 lg:p-10">
              <div className="relative z-10">
                <div className="flex items-center gap-4">
                  <Image
                    src={copycatProduct.assets.icon}
                    alt="CopyCat app icon"
                    width={72}
                    height={72}
                    className="size-[72px] rounded-[18px] shadow-[0_16px_40px_rgb(0_0_0_/0.45)]"
                    priority
                  />
                  <div>
                    <p className="text-xs font-semibold uppercase tracking-[0.14em] text-[var(--cc-primary-hover)]">
                      Featured
                    </p>
                    <h3 className="mt-1 text-2xl font-semibold tracking-tight text-[var(--cc-text)] sm:text-3xl">
                      {copycatProduct.name}
                    </h3>
                  </div>
                </div>

                <p className="mt-5 max-w-lg text-base leading-relaxed text-[var(--cc-text-secondary)]">
                  {copycatProduct.shortDescription}
                </p>

                <div className="mt-6 flex flex-wrap items-center gap-3 text-sm text-[var(--cc-text-tertiary)]">
                  <span className="rounded-lg border border-[var(--cc-border)] bg-[var(--cc-bg-top)]/60 px-2.5 py-1">
                    {copycatProduct.platform}
                  </span>
                  <span className="rounded-lg border border-[var(--cc-border)] bg-[var(--cc-bg-top)]/60 px-2.5 py-1">
                    v{copycatProduct.version}
                  </span>
                  <span className="rounded-lg border border-[var(--cc-border)] bg-[var(--cc-bg-top)]/60 px-2.5 py-1">
                    {copycatProduct.minOs}+
                  </span>
                </div>

                <span className="mt-8 inline-flex items-center gap-1.5 text-sm font-semibold text-[var(--cc-primary-hover)] transition group-hover:gap-2.5">
                  View product page
                  <ArrowUpRight className="size-4" aria-hidden />
                </span>
              </div>

              <div className="relative z-10">
                <div className="relative overflow-hidden rounded-2xl border border-[var(--cc-border)] bg-[#0b0f12] shadow-[0_24px_60px_rgb(0_0_0_/0.4)]">
                  <div className="flex items-center gap-2 border-b border-[var(--cc-border)] px-3 py-2.5">
                    <span className="size-2 rounded-full bg-[#ff5f57]" />
                    <span className="size-2 rounded-full bg-[#febc2e]" />
                    <span className="size-2 rounded-full bg-[#28c840]" />
                  </div>
                  <div className="relative aspect-[16/10]">
                    <Image
                      src="/downloads/copycat/screenshots/home.png"
                      alt="CopyCat home screen"
                      fill
                      className="object-cover object-top"
                      sizes="(max-width: 1024px) 100vw, 480px"
                      priority
                    />
                  </div>
                </div>
              </div>
            </div>
          </Link>
        </section>

        <section
          aria-labelledby="more-heading"
          className="mt-10 cc-animate-fade-up-delay-2"
        >
          <h2
            id="more-heading"
            className="text-sm font-medium text-[var(--cc-text-tertiary)]"
          >
            More coming later
          </h2>
          <p className="mt-2 max-w-md text-sm text-[var(--cc-text-secondary)]">
            Additional apps and tools will show up here as they ship.
          </p>
        </section>
      </main>

      <DownloadFooter />
    </>
  );
}
