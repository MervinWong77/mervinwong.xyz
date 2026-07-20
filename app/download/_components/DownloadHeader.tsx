import Image from "next/image";
import Link from "next/link";

type DownloadHeaderProps = {
  brandHref?: string;
  brandLabel?: string;
  ctaHref?: string;
  ctaLabel?: string;
};

export function DownloadHeader({
  brandHref = "/download",
  brandLabel = "Downloads",
  ctaHref,
  ctaLabel = "Download",
}: DownloadHeaderProps) {
  return (
    <header className="relative z-20 mx-auto flex w-full max-w-6xl items-center justify-between px-5 py-6 sm:px-8">
      <Link
        href={brandHref}
        className="group flex items-center gap-2.5 text-[var(--cc-text)] transition-opacity hover:opacity-90"
      >
        {brandHref.includes("copycat") ? (
          <>
            <Image
              src="/downloads/copycat/brand/app-icon-128.png"
              alt=""
              width={32}
              height={32}
              className="size-8 rounded-[7px] shadow-[0_0_0_1px_rgb(42_52_58)]"
            />
            <span className="text-[15px] font-semibold tracking-tight">
              CopyCat
            </span>
          </>
        ) : (
          <span className="text-[15px] font-semibold tracking-tight">
            {brandLabel}
          </span>
        )}
      </Link>

      <nav className="flex items-center gap-5 text-sm text-[var(--cc-text-secondary)]">
        <Link
          href="/download"
          className="transition-colors hover:text-[var(--cc-text)]"
        >
          All downloads
        </Link>
        {ctaHref ? (
          <Link
            href={ctaHref}
            className="rounded-xl bg-[var(--cc-primary)] px-3.5 py-2 font-semibold text-white shadow-[0_8px_24px_rgb(34_184_170_/0.22)] transition hover:bg-[var(--cc-primary-hover)]"
          >
            {ctaLabel}
          </Link>
        ) : null}
      </nav>
    </header>
  );
}
