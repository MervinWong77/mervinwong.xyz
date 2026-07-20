import Link from "next/link";
import { Apple } from "lucide-react";

type DownloadCtaProps = {
  available: boolean;
  href: string;
  version: string;
  filename: string;
  size?: "md" | "lg";
};

export function DownloadCta({
  available,
  href,
  version,
  filename,
  size = "lg",
}: DownloadCtaProps) {
  const sizing =
    size === "lg"
      ? "h-14 px-7 text-[15px] gap-2.5"
      : "h-11 px-5 text-sm gap-2";

  if (!available) {
    return (
      <div className="flex flex-col items-start gap-3 sm:flex-row sm:items-center">
        <span
          className={`inline-flex items-center justify-center rounded-xl border border-[var(--cc-primary)]/55 bg-[var(--cc-surface)] font-semibold text-[var(--cc-text)] shadow-[0_0_0_1px_rgb(34_184_170_/0.08),0_12px_36px_rgb(34_184_170_/0.12)] ${sizing}`}
        >
          <Apple className="size-4 text-[var(--cc-primary-hover)]" aria-hidden />
          Coming soon for macOS
        </span>
        <p className="text-sm text-[var(--cc-text-tertiary)]">
          v{version} · {filename}
        </p>
      </div>
    );
  }

  return (
    <div className="flex flex-col items-start gap-3 sm:flex-row sm:items-center">
      <Link
        href={href}
        className={`inline-flex items-center justify-center rounded-xl bg-[var(--cc-primary)] font-semibold text-white shadow-[0_10px_32px_rgb(34_184_170_/0.28)] transition hover:bg-[var(--cc-primary-hover)] ${sizing}`}
      >
        <Apple className="size-4" aria-hidden />
        Download for macOS
      </Link>
      <p className="text-sm text-[var(--cc-text-tertiary)]">
        v{version} · {filename}
      </p>
    </div>
  );
}
