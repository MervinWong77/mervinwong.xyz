"use client";

import Image from "next/image";
import { useCallback, useState } from "react";
import { RefreshCw, Sparkle } from "lucide-react";

const thoughts = [
  "The room felt quieter after the rain.",
  "Someone nearby was making coffee.",
  "今天的云移动得很慢。",
  "The lamp stayed on longer than usual.",
  "有时候只是坐着也很好。",
  "A soft breeze came in through the window.",
  "夜晚让很多事情变轻了。",
  "The page remained open for hours.",
  "今天适合慢一点。",
  "The sky looked washed out this evening.",
  "楼下传来很轻的说话声。",
  "Nothing urgent for now.",
  "风吹进来的时候，刚好。",
  "The tea went cold before I noticed.",
  "有些安静不需要解释。",
  "A little sunlight stayed on the table.",
  "今天的空气有一点温柔。",
  "The hallway lights were still on.",
  "窗外的树影摇得很轻。",
  "Some nights feel softer than others.",
  "The rain sounded distant tonight.",
  "今天没有特别想去哪里。",
  "A quiet song kept looping somewhere.",
  "风停下来的时候，很安静。",
  "The window was left slightly open.",
  "有些时刻不需要记录。",
  "The afternoon passed slowly today.",
  "今晚想早点休息。",
  "The moon looked smaller than usual.",
  "有人正在远处煮晚餐。",
] as const;

const illustrations = [
  "lc-book.png",
  "lc-cloud.png",
  "lc-coffee.png",
  "lc-mountain.png",
  "lc-flower.png",
  "lc-house.png",
  "lc-lantern.png",
  "lc-leaf.png",
  "lc-moon.png",
  "lc-paperplane.png",
  "lc-tree.png",
  "lc-rain.png",
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
    setIllustrationIndex((i) =>
      pickNextIndex(i, illustrations.length)
    );
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
        <div className="relative min-h-[205px] overflow-hidden rounded-2xl border border-stone-200/70 bg-white/70 p-6 shadow-sm ring-1 ring-stone-100/80 backdrop-blur-sm transition hover:shadow-md">
          <div className="flex items-start justify-between gap-3">
            <p className="text-xs font-semibold uppercase tracking-wider text-stone-400">
              What&apos;s on my mind
            </p>

            <button
              type="button"
              onClick={nextThought}
              className="inline-flex shrink-0 items-center gap-1.5 rounded-full border border-stone-200/60 bg-white/60 px-3 py-1.5 text-xs font-medium text-stone-600 transition hover:border-stone-300/80 hover:bg-white hover:text-stone-900 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-stone-400"
            >
              <RefreshCw
                className="h-3.5 w-3.5"
                aria-hidden
              />
              Another thought
            </button>
          </div>

          <p
            key={thoughtIndex}
            className="animate-quote-in mt-4 max-w-[70%] text-lg leading-relaxed text-stone-800"
          >
            {thought}
          </p>

          <div
            key={`${illustration}-${thoughtIndex}`}
            className="animate-quote-in animate-corner-pixel-float pointer-events-none select-none absolute -bottom-1 right-4 h-[125px] w-[125px] opacity-85"
            aria-hidden
          >
            <Image
              src={`/illustrations/little-corner/${illustration}`}
              alt=""
              width={125}
              height={125}
              className="h-[125px] w-[125px] select-none drop-shadow-[0_4px_10px_rgba(120,113,108,0.14)] [image-rendering:auto]"
            />
          </div>
        </div>

        <div className="rounded-2xl border border-stone-200/70 bg-gradient-to-br from-white/90 to-stone-50/80 p-6 shadow-sm ring-1 ring-orange-100/40 backdrop-blur-sm transition hover:-translate-y-0.5 hover:shadow-md">
          <p className="flex items-center gap-2 text-xs font-semibold uppercase tracking-wider text-stone-400">
            <Sparkle
              className="h-3.5 w-3.5 text-amber-500"
              aria-hidden
            />
            Currently exploring
          </p>

          <ul className="mt-4 space-y-3">
            {exploring.map((item) => (
              <li
                key={item}
                className="group flex items-center gap-2 text-stone-700 transition hover:text-stone-900"
              >
                <span className="h-1.5 w-1.5 rounded-full bg-gradient-to-br from-amber-400 to-rose-400 opacity-70 transition group-hover:scale-125 group-hover:opacity-100" />

                <span className="text-sm leading-snug md:text-base">
                  {item}
                </span>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </section>
  );
}