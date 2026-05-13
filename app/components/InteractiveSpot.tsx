"use client";

import Image from "next/image";
import { useCallback, useState } from "react";
import { RefreshCw, Sparkle } from "lucide-react";

const thoughts = [
  "Small rituals keep the day grounded.",
  "Quiet design can still feel deeply human.",
  "I want to build things people remember softly.",
  "Some ideas need stillness before they become clear.",
  "Sometimes a slower pace is the better direction.",
  "今晚想把生活过得慢一点。",
  "有些美好，适合安静地收藏。",
  "今天也想做一点温柔的作品。",
  "晚风一吹，很多烦恼就变轻了。",
  "希望我的小角落让你感到放松。",
] as const;

const illustrations = [
  "lc-book.png",
  "lc-cloud.png",
  "lc-coffee.png",
  "lc-flower.png",
  "lc-lantern.png",
  "lc-leaf.png",
  "lc-moon.png",
  "lc-paperplane.png",
  "lc-rain.png",
  "lc-shootingstar.png",
  "lc-sprout.png",
  "lc-stars.png",
  "lc-sun.png",
  "lc-wave.png",
] as const;

const exploring = [
  "Slow mornings & film cameras",
  "Seasonal cooking with friends",
  "Quiet interfaces with personality",
  "Urban green spaces & botanical gardens",
] as const;

function pickNextIndex(current: number, total: number) {
  if (total < 2) return current;
  let next = current;
  while (next === current) {
    next = Math.floor(Math.random() * total);
  }
  return next;
}

export function InteractiveSpot() {
  const [thoughtIndex, setThoughtIndex] = useState(0);
  const [illustrationIndex, setIllustrationIndex] = useState(0);

  const nextThought = useCallback(() => {
    setThoughtIndex((i) => pickNextIndex(i, thoughts.length));
    setIllustrationIndex((i) => pickNextIndex(i, illustrations.length));
  }, []);

  const thought = thoughts[thoughtIndex];
  const illustration = illustrations[illustrationIndex];

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
        <div className="relative overflow-hidden rounded-2xl border border-stone-200/70 bg-white/70 p-6 shadow-sm ring-1 ring-stone-100/80 backdrop-blur-sm transition hover:shadow-md">
          <div className="flex items-start justify-between gap-3">
            <p className="text-xs font-semibold uppercase tracking-wider text-stone-400">
              What&apos;s on my mind
            </p>
            <button
              type="button"
              onClick={nextThought}
              className="inline-flex shrink-0 items-center gap-1.5 rounded-full border border-stone-200/90 bg-stone-50/90 px-3 py-1.5 text-xs font-medium text-stone-600 transition hover:border-stone-300 hover:bg-white hover:text-stone-900 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-stone-400"
            >
              <RefreshCw className="h-3.5 w-3.5" aria-hidden />
              Another thought
            </button>
          </div>
          <p
            key={thoughtIndex}
            className="animate-quote-in mt-4 max-w-[80%] text-lg leading-relaxed text-stone-800"
          >
            {thought}
          </p>
          <div
            key={`${illustration}-${thoughtIndex}`}
            className="animate-quote-in animate-corner-pixel-float pointer-events-none absolute bottom-5 right-6 h-20 w-20 opacity-90"
            aria-hidden
          >
            <Image
              src={`/illustrations/little-corner/${illustration}`}
              alt=""
              width={80}
              height={80}
              className="h-20 w-20 object-contain"
            />
          </div>
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
