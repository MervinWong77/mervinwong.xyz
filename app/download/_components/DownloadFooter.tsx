import Link from "next/link";

type DownloadFooterProps = {
  productName?: string;
};

export function DownloadFooter({ productName }: DownloadFooterProps) {
  return (
    <footer className="border-t border-[var(--cc-border)]/70">
      <div className="mx-auto flex w-full max-w-6xl flex-col gap-4 px-5 py-10 text-sm text-[var(--cc-text-tertiary)] sm:flex-row sm:items-center sm:justify-between sm:px-8">
        <p>
          {productName ? (
            <>
              {productName} · by{" "}
              <Link
                href="/"
                className="text-[var(--cc-text-secondary)] transition-colors hover:text-[var(--cc-text)]"
              >
                Mervin Wong
              </Link>
            </>
          ) : (
            <>
              Downloads ·{" "}
              <Link
                href="/"
                className="text-[var(--cc-text-secondary)] transition-colors hover:text-[var(--cc-text)]"
              >
                Mervin Wong
              </Link>
            </>
          )}
        </p>
        <div className="flex items-center gap-5">
          <Link
            href="/download"
            className="transition-colors hover:text-[var(--cc-text)]"
          >
            All downloads
          </Link>
          <Link
            href="/"
            className="transition-colors hover:text-[var(--cc-text)]"
          >
            Home
          </Link>
        </div>
      </div>
    </footer>
  );
}
