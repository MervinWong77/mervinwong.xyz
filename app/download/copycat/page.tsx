import type { Metadata } from "next";

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
  return (
    <main className="mx-auto max-w-2xl px-5 py-16 sm:px-8">
      <h1 className="font-[family-name:var(--font-fraunces)] text-3xl text-stone-900">
        CopyCat
      </h1>
      <p className="mt-3 text-stone-600">
        macOS duplicate file finder. Download page scaffold — content coming
        soon.
      </p>

      <section className="mt-10" aria-labelledby="logo-heading">
        <h2 id="logo-heading" className="text-sm font-medium text-stone-500">
          App logo
        </h2>
        <p className="mt-2 text-stone-700">Placeholder</p>
      </section>

      <section className="mt-8" aria-labelledby="version-heading">
        <h2 id="version-heading" className="text-sm font-medium text-stone-500">
          Latest version
        </h2>
        <p className="mt-2 text-stone-700">Placeholder</p>
      </section>

      <section className="mt-8" aria-labelledby="download-heading">
        <h2
          id="download-heading"
          className="text-sm font-medium text-stone-500"
        >
          Download
        </h2>
        <p className="mt-2 text-stone-700">Placeholder</p>
      </section>

      <section className="mt-8" aria-labelledby="notes-heading">
        <h2 id="notes-heading" className="text-sm font-medium text-stone-500">
          Release notes
        </h2>
        <p className="mt-2 text-stone-700">Placeholder</p>
      </section>

      <section className="mt-8" aria-labelledby="changelog-heading">
        <h2
          id="changelog-heading"
          className="text-sm font-medium text-stone-500"
        >
          Changelog
        </h2>
        <p className="mt-2 text-stone-700">Placeholder</p>
      </section>

      <section className="mt-8" aria-labelledby="requirements-heading">
        <h2
          id="requirements-heading"
          className="text-sm font-medium text-stone-500"
        >
          System requirements
        </h2>
        <p className="mt-2 text-stone-700">Placeholder</p>
      </section>
    </main>
  );
}
