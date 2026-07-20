import type { Metadata } from "next";
import Image from "next/image";
import Link from "next/link";
import { DownloadCta } from "../_components/DownloadCta";
import { DownloadFooter } from "../_components/DownloadFooter";
import { DownloadHeader } from "../_components/DownloadHeader";
import { FaqList } from "../_components/FaqList";
import { ScreenshotGallery } from "../_components/ScreenshotGallery";
import {
  changelog,
  copycatProduct,
  faqs,
  features,
  requirements,
  screenshots,
} from "./content";

export const metadata: Metadata = {
  title: "Download CopyCat · Mervin Wong",
  description: copycatProduct.description,
  robots: {
    index: false,
    follow: false,
  },
  openGraph: {
    title: "CopyCat for macOS",
    description: copycatProduct.shortDescription,
    images: [copycatProduct.assets.iconLarge],
  },
};

export default function CopyCatDownloadPage() {
  return (
    <>
      <DownloadHeader
        brandHref="/download/copycat"
        ctaHref="#download"
        ctaLabel={
          copycatProduct.downloadAvailable ? "Download" : "Coming soon"
        }
      />

      <main>
        {/* Hero */}
        <section className="relative overflow-hidden px-5 pb-16 pt-6 sm:px-8 sm:pb-24 sm:pt-10">
          <div
            aria-hidden
            className="pointer-events-none absolute right-[8%] top-16 size-[380px] rounded-full bg-[var(--cc-glow)]/25 blur-3xl cc-glow"
          />

          <div className="relative mx-auto grid w-full max-w-6xl items-center gap-12 lg:grid-cols-[1.05fr_0.95fr] lg:gap-8">
            <div className="cc-animate-fade-up">
              <div className="flex items-center gap-4">
                <Image
                  src={copycatProduct.assets.icon}
                  alt="CopyCat app icon"
                  width={88}
                  height={88}
                  className="size-[72px] rounded-[20px] shadow-[0_20px_50px_rgb(0_0_0_/0.5)] sm:size-[88px] sm:rounded-[22px]"
                  priority
                />
                <div>
                  <p className="text-sm font-medium text-[var(--cc-text-secondary)]">
                    {copycatProduct.platform} · v{copycatProduct.version}
                  </p>
                  <h1 className="mt-1 text-4xl font-semibold tracking-tight text-[var(--cc-text)] sm:text-5xl">
                    {copycatProduct.name}
                  </h1>
                </div>
              </div>

              <h2 className="mt-8 max-w-xl text-3xl font-semibold tracking-tight text-[var(--cc-text)] sm:text-4xl">
                Find your hidden{" "}
                <span className="text-[var(--cc-primary-hover)]">copies.</span>
              </h2>
              <p className="mt-4 max-w-lg text-base leading-relaxed text-[var(--cc-text-secondary)] sm:text-lg">
                {copycatProduct.description}
              </p>

              <div id="download" className="mt-8 scroll-mt-28">
                <DownloadCta
                  available={copycatProduct.downloadAvailable}
                  href={copycatProduct.downloadUrl}
                  version={copycatProduct.version}
                  filename={copycatProduct.downloadFilename}
                />
              </div>

              <p className="mt-5 text-sm text-[var(--cc-text-tertiary)]">
                {copycatProduct.minOs} or later · Offline · Moves files to Trash
                only
              </p>
            </div>

            <div className="relative isolate mx-auto w-full max-w-md lg:max-w-none cc-animate-fade-up-delay-1">
              <div
                aria-hidden
                className="pointer-events-none absolute inset-x-[12%] top-[18%] aspect-square rounded-full bg-[var(--cc-glow)]/30 blur-3xl cc-glow"
              />
              <Image
                src="/downloads/copycat/mascot/wave.png"
                alt="CopyCat mascot waving"
                width={720}
                height={720}
                className="relative z-10 mx-auto w-[88%] max-w-[420px] mix-blend-lighten drop-shadow-[0_30px_60px_rgb(0_0_0_/0.55)] cc-float"
                priority
              />
            </div>
          </div>
        </section>

        {/* Screenshots */}
        <section
          aria-labelledby="gallery-heading"
          className="border-t border-[var(--cc-border)]/60 px-5 py-20 sm:px-8"
        >
          <div className="mx-auto w-full max-w-6xl">
            <div className="mx-auto max-w-2xl text-center cc-animate-fade-up">
              <h2
                id="gallery-heading"
                className="text-3xl font-semibold tracking-tight text-[var(--cc-text)]"
              >
                Built like a native Mac app
              </h2>
              <p className="mt-3 text-[var(--cc-text-secondary)]">
                From choosing folders to celebrating recovered space — every
                screen stays calm, focused, and trustworthy.
              </p>
            </div>
            <div className="mt-12">
              <ScreenshotGallery shots={screenshots} />
            </div>
          </div>
        </section>

        {/* Features */}
        <section
          aria-labelledby="features-heading"
          className="border-t border-[var(--cc-border)]/60 px-5 py-20 sm:px-8"
        >
          <div className="mx-auto w-full max-w-6xl">
            <div className="max-w-2xl">
              <h2
                id="features-heading"
                className="text-3xl font-semibold tracking-tight text-[var(--cc-text)]"
              >
                Personality with purpose
              </h2>
              <p className="mt-3 text-[var(--cc-text-secondary)]">
                CopyCat finds identical files, shows what you can recover, and
                only moves what you approve.
              </p>
            </div>

            <ul className="mt-12 grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
              {features.map((feature) => (
                <li
                  key={feature.title}
                  className="rounded-2xl border border-[var(--cc-border)] bg-[var(--cc-surface)]/50 p-6 transition hover:border-[var(--cc-primary)]/35 hover:bg-[var(--cc-surface)]"
                >
                  <div className="relative isolate mb-5 flex h-36 items-end justify-center overflow-hidden rounded-xl bg-[#0b0f12]">
                    <div
                      aria-hidden
                      className="absolute inset-x-8 top-6 h-24 rounded-full bg-[var(--cc-glow)]/20 blur-2xl"
                    />
                    <Image
                      src={feature.mascot}
                      alt={feature.mascotAlt}
                      width={220}
                      height={220}
                      className="relative z-10 h-36 w-auto object-contain mix-blend-lighten"
                    />
                  </div>
                  <h3 className="text-lg font-semibold tracking-tight text-[var(--cc-text)]">
                    {feature.title}
                  </h3>
                  <p className="mt-2 text-sm leading-relaxed text-[var(--cc-text-secondary)]">
                    {feature.body}
                  </p>
                </li>
              ))}
            </ul>
          </div>
        </section>

        {/* Version + Requirements */}
        <section className="border-t border-[var(--cc-border)]/60 px-5 py-20 sm:px-8">
          <div className="mx-auto grid w-full max-w-6xl gap-10 lg:grid-cols-2">
            <div
              id="version"
              className="rounded-2xl border border-[var(--cc-border)] bg-[var(--cc-surface)]/50 p-7 sm:p-8"
              aria-labelledby="version-heading"
            >
              <h2
                id="version-heading"
                className="text-xl font-semibold tracking-tight text-[var(--cc-text)]"
              >
                Latest version
              </h2>
              <dl className="mt-6 space-y-4 text-sm">
                <div className="flex items-baseline justify-between gap-4 border-b border-[var(--cc-border)]/70 pb-3">
                  <dt className="text-[var(--cc-text-tertiary)]">Version</dt>
                  <dd className="font-medium text-[var(--cc-text)]">
                    {copycatProduct.version}
                  </dd>
                </div>
                <div className="flex items-baseline justify-between gap-4 border-b border-[var(--cc-border)]/70 pb-3">
                  <dt className="text-[var(--cc-text-tertiary)]">Build</dt>
                  <dd className="font-medium text-[var(--cc-text)]">
                    {copycatProduct.build}
                  </dd>
                </div>
                <div className="flex items-baseline justify-between gap-4 border-b border-[var(--cc-border)]/70 pb-3">
                  <dt className="text-[var(--cc-text-tertiary)]">Released</dt>
                  <dd className="font-medium text-[var(--cc-text)]">
                    {copycatProduct.releaseDateLabel}
                  </dd>
                </div>
                <div className="flex items-baseline justify-between gap-4">
                  <dt className="text-[var(--cc-text-tertiary)]">Status</dt>
                  <dd className="font-medium text-[var(--cc-gold)]">
                    {copycatProduct.downloadAvailable
                      ? "Available"
                      : "Preview — build publishing soon"}
                  </dd>
                </div>
              </dl>

              <div className="mt-8">
                <DownloadCta
                  available={copycatProduct.downloadAvailable}
                  href={copycatProduct.downloadUrl}
                  version={copycatProduct.version}
                  filename={copycatProduct.downloadFilename}
                  size="md"
                />
              </div>
            </div>

            <div
              id="requirements"
              className="rounded-2xl border border-[var(--cc-border)] bg-[var(--cc-surface)]/50 p-7 sm:p-8"
              aria-labelledby="requirements-heading"
            >
              <h2
                id="requirements-heading"
                className="text-xl font-semibold tracking-tight text-[var(--cc-text)]"
              >
                System requirements
              </h2>
              <dl className="mt-6 space-y-4 text-sm">
                {requirements.map((item) => (
                  <div
                    key={item.label}
                    className="flex items-baseline justify-between gap-6 border-b border-[var(--cc-border)]/70 pb-3 last:border-0 last:pb-0"
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
            </div>
          </div>
        </section>

        {/* Changelog */}
        <section
          id="changelog"
          aria-labelledby="changelog-heading"
          className="border-t border-[var(--cc-border)]/60 px-5 py-20 sm:px-8"
        >
          <div className="mx-auto w-full max-w-6xl">
            <h2
              id="changelog-heading"
              className="text-3xl font-semibold tracking-tight text-[var(--cc-text)]"
            >
              Changelog
            </h2>
            <div className="mt-10 space-y-8">
              {changelog.map((release) => (
                <article
                  key={release.version}
                  className="rounded-2xl border border-[var(--cc-border)] bg-[var(--cc-surface)]/50 p-7 sm:p-8"
                >
                  <div className="flex flex-wrap items-baseline gap-3">
                    <h3 className="text-lg font-semibold text-[var(--cc-text)]">
                      v{release.version}
                    </h3>
                    <span className="text-sm text-[var(--cc-text-tertiary)]">
                      {release.date}
                    </span>
                  </div>
                  <p className="mt-1 text-sm font-medium text-[var(--cc-primary-hover)]">
                    {release.title}
                  </p>
                  <ul className="mt-5 space-y-2.5 text-sm leading-relaxed text-[var(--cc-text-secondary)]">
                    {release.items.map((item) => (
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
          </div>
        </section>

        {/* FAQ */}
        <section
          id="faq"
          aria-labelledby="faq-heading"
          className="border-t border-[var(--cc-border)]/60 px-5 py-20 sm:px-8"
        >
          <div className="mx-auto w-full max-w-3xl">
            <h2
              id="faq-heading"
              className="text-center text-3xl font-semibold tracking-tight text-[var(--cc-text)]"
            >
              FAQ
            </h2>
            <p className="mx-auto mt-3 max-w-lg text-center text-[var(--cc-text-secondary)]">
              Quick answers about safety, privacy, and what CopyCat does — and
              doesn&apos;t — do.
            </p>
            <div className="mt-10">
              <FaqList items={faqs} />
            </div>
          </div>
        </section>

        {/* Closing CTA */}
        <section className="border-t border-[var(--cc-border)]/60 px-5 py-20 sm:px-8">
          <div className="relative isolate mx-auto flex w-full max-w-6xl flex-col items-center overflow-hidden rounded-3xl border border-[var(--cc-border)] bg-[var(--cc-surface)]/60 px-6 py-14 text-center sm:px-10">
            <div
              aria-hidden
              className="pointer-events-none absolute inset-x-1/4 top-0 h-40 rounded-full bg-[var(--cc-glow)]/20 blur-3xl"
            />
            <Image
              src="/downloads/copycat/mascot/idle.png"
              alt=""
              width={180}
              height={180}
              className="relative z-10 h-28 w-auto object-contain mix-blend-lighten"
            />
            <h2 className="relative z-10 mt-4 text-2xl font-semibold tracking-tight text-[var(--cc-text)] sm:text-3xl">
              Ready when you are
            </h2>
            <p className="relative z-10 mt-3 max-w-md text-[var(--cc-text-secondary)]">
              Recover storage without losing the files that matter.
            </p>
            <div className="relative z-10 mt-8">
              <DownloadCta
                available={copycatProduct.downloadAvailable}
                href={copycatProduct.downloadUrl}
                version={copycatProduct.version}
                filename={copycatProduct.downloadFilename}
              />
            </div>
            <p className="relative z-10 mt-6 text-sm text-[var(--cc-text-tertiary)]">
              Looking for other apps?{" "}
              <Link
                href="/download"
                className="text-[var(--cc-primary-hover)] transition hover:underline"
              >
                Browse all downloads
              </Link>
            </p>
          </div>
        </section>
      </main>

      <DownloadFooter productName="CopyCat" />
    </>
  );
}
