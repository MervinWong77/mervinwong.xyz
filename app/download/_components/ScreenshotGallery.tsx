"use client";

import Image from "next/image";
import { useState } from "react";

type Shot = {
  id: string;
  title: string;
  caption: string;
  src: string;
  width: number;
  height: number;
};

export function ScreenshotGallery({ shots }: { shots: readonly Shot[] }) {
  const [active, setActive] = useState(0);
  const current = shots[active] ?? shots[0];

  if (!current) return null;

  return (
    <div className="space-y-6">
      <div className="relative overflow-hidden rounded-2xl border border-[var(--cc-border)] bg-[var(--cc-surface)] shadow-[0_30px_80px_rgb(0_0_0_/0.45)]">
        <div className="flex items-center gap-2 border-b border-[var(--cc-border)] px-4 py-3">
          <span className="size-2.5 rounded-full bg-[#ff5f57]" />
          <span className="size-2.5 rounded-full bg-[#febc2e]" />
          <span className="size-2.5 rounded-full bg-[#28c840]" />
          <span className="ml-3 text-xs text-[var(--cc-text-tertiary)]">
            {current.title}
          </span>
        </div>
        <div className="relative aspect-[16/10] bg-[#0b0f12]">
          <Image
            key={current.id}
            src={current.src}
            alt={`CopyCat ${current.title} screen`}
            fill
            className="object-cover object-top"
            sizes="(max-width: 1100px) 100vw, 1100px"
            priority={active === 0}
          />
        </div>
      </div>

      <p className="text-center text-sm text-[var(--cc-text-secondary)]">
        {current.caption}
      </p>

      <div
        className="flex flex-wrap justify-center gap-2"
        role="tablist"
        aria-label="Product screenshots"
      >
        {shots.map((shot, index) => {
          const selected = index === active;
          return (
            <button
              key={shot.id}
              type="button"
              role="tab"
              aria-selected={selected}
              onClick={() => setActive(index)}
              className={`rounded-lg px-3.5 py-2 text-sm transition ${
                selected
                  ? "bg-[var(--cc-surface-hover)] text-[var(--cc-text)] ring-1 ring-[var(--cc-primary)]/50"
                  : "text-[var(--cc-text-secondary)] hover:bg-[var(--cc-surface)] hover:text-[var(--cc-text)]"
              }`}
            >
              {shot.title}
            </button>
          );
        })}
      </div>
    </div>
  );
}
