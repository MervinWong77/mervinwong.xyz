"use client";

import { useState } from "react";
import { ChevronDown } from "lucide-react";

type Faq = {
  question: string;
  answer: string;
};

export function FaqList({ items }: { items: readonly Faq[] }) {
  const [open, setOpen] = useState<number | null>(0);

  return (
    <div className="divide-y divide-[var(--cc-border)] rounded-2xl border border-[var(--cc-border)] bg-[var(--cc-surface)]/60">
      {items.map((item, index) => {
        const isOpen = open === index;
        return (
          <div key={item.question}>
            <button
              type="button"
              aria-expanded={isOpen}
              onClick={() => setOpen(isOpen ? null : index)}
              className="flex w-full items-center justify-between gap-4 px-5 py-5 text-left sm:px-6"
            >
              <span className="text-[15px] font-medium text-[var(--cc-text)]">
                {item.question}
              </span>
              <ChevronDown
                className={`size-4 shrink-0 text-[var(--cc-text-tertiary)] transition-transform ${
                  isOpen ? "rotate-180" : ""
                }`}
                aria-hidden
              />
            </button>
            <div
              className={`grid transition-[grid-template-rows] duration-300 ease-out ${
                isOpen ? "grid-rows-[1fr]" : "grid-rows-[0fr]"
              }`}
            >
              <div className="overflow-hidden">
                <p className="px-5 pb-5 text-sm leading-relaxed text-[var(--cc-text-secondary)] sm:px-6">
                  {item.answer}
                </p>
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
}
