import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Downloads · Mervin Wong",
  description: "Downloadable builds and releases.",
  robots: {
    index: false,
    follow: false,
  },
};

export default function DownloadPage() {
  return (
    <main className="mx-auto max-w-2xl px-5 py-16 sm:px-8">
      <h1 className="font-[family-name:var(--font-fraunces)] text-3xl text-stone-900">
        Downloads
      </h1>
      <p className="mt-3 text-stone-600">
        Downloadable builds will appear here.
      </p>
      <ul className="mt-8 space-y-2 text-stone-800">
        <li>
          <Link
            href="/download/copycat"
            className="underline decoration-stone-300 underline-offset-4 hover:decoration-stone-600"
          >
            CopyCat
          </Link>
        </li>
      </ul>
    </main>
  );
}
