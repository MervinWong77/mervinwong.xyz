"use client";

import { useCallback, useState } from "react";
import { RefreshCw, Sparkle } from "lucide-react";

const quotes = [
  "Small rituals — morning light, good coffee, a deep breath before the day.",
  "The best ideas often arrive when you’re not trying to force them.",
  "Curiosity is a compass; kindness is the map.",
  "Design is how it works — and how it makes someone feel.",
  "Leave room for wonder. Not everything needs a deadline.",
  "A good walk fixes more than you’d expect.",
] as const;

const exploring = [
  "Slow mornings & film cameras",
  "Seasonal cooking with friends",
  "Quiet interfaces with personality",
  "Urban green spaces & botanical gardens",
] as const;

export function InteractiveSpot() {
  const [quoteIndex, setQuoteIndex] = useState(0);

  const nextQuote = useCallback(() => {
    setQuoteIndex((i) => (i + 1) % quotes.length);
  }, []);

  const quote = quotes[quoteIndex];

  return (
    <section
      className="mt-20 md:mt-28"
      aria-labelledby="spot-heading"
    >
      <h2
        id="spot-heading"
        className="text-xs font-semibold uppercase tracking-[0.2em] text-stone-400"
      >
        A little corner
      </h2>
      <div className="mt-6 grid gap-6 md:grid-cols-2 md:gap-8">
        <div className="rounded-2xl border border-stone-200/70 bg-white/70 p-6 shadow-sm ring-1 ring-stone-100/80 backdrop-blur-sm transition hover:shadow-md">
          <div className="flex items-start justify-between gap-3">
            <p className="text-xs font-semibold uppercase tracking-wider text-stone-400">
              What&apos;s on my mind
            </p>
            <button
              type="button"
              onClick={nextQuote}
              className="inline-flex shrink-0 items-center gap-1.5 rounded-full border border-stone-200/90 bg-stone-50/90 px-3 py-1.5 text-xs font-medium text-stone-600 transition hover:border-stone-300 hover:bg-white hover:text-stone-900 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-stone-400"
            >
              <RefreshCw className="h-3.5 w-3.5" aria-hidden />
              Another thought
            </button>
          </div>
          <p
            key={quoteIndex}
            className="animate-quote-in mt-4 text-lg leading-relaxed text-stone-800"
          >
            {quote}
          </p>
        </div>

        <div className="rounded-2xl border border-stone-200/70 bg-gradient-to-br from-white/90 to-stone-50/80 p-6 shadow-sm ring-1 ring-orange-100/40 backdrop-blur-sm transition hover:-translate-y-0.5 hover:shadow-md">
          <p className="flex items-center gap-2 text-xs font-semibold uppercase tracking-wider text-stone-400">
            <Sparkle className="h-3.5 w-3.5 text-amber-500" aria-hidden />
            Currently exploring
          </p>
          <ul className="mt-4 space-y-3">
            {exploring.map((item) => (
              <li
                key={item}
                className="group flex items-center gap-2 text-stone-700 transition hover:text-stone-900"
              >
                <span className="h-1.5 w-1.5 rounded-full bg-gradient-to-br from-amber-400 to-rose-400 opacity-70 transition group-hover:scale-125 group-hover:opacity-100" />
                <span className="text-sm leading-snug md:text-base">{item}</span>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </section>
  );
}
