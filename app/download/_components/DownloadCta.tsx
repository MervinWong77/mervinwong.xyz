type DownloadCtaProps = {
  href: string;
  version: string;
  filename: string;
  fileSizeLabel?: string;
  size?: "md" | "lg";
};

const MACOS_DOWNLOAD_ICON = "/projects/copycat/icons/macos-download.svg";

export function DownloadCta({
  href,
  version,
  filename,
  fileSizeLabel,
  size = "lg",
}: DownloadCtaProps) {
  const sizing =
    size === "lg"
      ? "h-14 px-7 text-[15px] gap-2.5"
      : "h-11 px-5 text-sm gap-2";

  const iconClass =
    size === "lg" ? "size-[18px]" : "size-4";

  return (
    <div className="flex flex-col items-start gap-3 sm:flex-row sm:items-center">
      <a
        href={href}
        download={filename}
        className={`inline-flex items-center justify-center rounded-xl bg-[var(--cc-primary)] font-semibold text-white shadow-[0_10px_32px_rgb(34_184_170_/0.28)] transition hover:bg-[var(--cc-primary-hover)] ${sizing}`}
      >
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img
          src={MACOS_DOWNLOAD_ICON}
          alt=""
          width={18}
          height={18}
          className={`${iconClass} shrink-0`}
          aria-hidden
        />
        Download CopyCat for macOS
      </a>
      <p className="text-sm text-[var(--cc-text-tertiary)]">
        v{version}
        {fileSizeLabel ? ` · ${fileSizeLabel}` : ""} · {filename}
      </p>
    </div>
  );
}
