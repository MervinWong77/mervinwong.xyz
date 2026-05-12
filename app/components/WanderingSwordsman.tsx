"use client";

import Image from "next/image";
import { useEffect, useRef } from "react";

const messages = [
  "Glad you stopped by.",
  "Take your time exploring.",
  "Some moments are worth keeping.",
  "Welcome to my little corner of the internet.",
] as const;

export function WanderingSwordsman() {
  const bubbleRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const randomIndex = crypto.getRandomValues(new Uint32Array(1))[0] % messages.length;
    if (bubbleRef.current) {
      bubbleRef.current.textContent = messages[randomIndex];
    }
  }, []);

  return (
    <div
      className="pointer-events-none fixed bottom-0 right-[-2.8rem] z-30 select-none sm:right-[-2.2rem] md:right-[-1.2rem]"
      aria-hidden
    >
      <div className="relative">
        <div className="animate-swordsman-float relative h-[12.5rem] w-[9.5rem] opacity-70 sm:h-[14rem] sm:w-[10.25rem] md:h-[16.5rem] md:w-[12rem]">
          <Image
            src="/characters/wandering-swordsman.svg"
            alt=""
            fill
            priority={false}
            className="object-contain drop-shadow-[0_22px_35px_rgba(73,59,51,0.18)]"
          />
          <div className="absolute inset-x-0 bottom-0 h-1/2 bg-gradient-to-t from-[#fbfaf9] via-[#fbfaf9]/45 to-transparent" />
        </div>

        <div
          ref={bubbleRef}
          className="animate-swordsman-float absolute bottom-[7.6rem] right-[5.4rem] max-w-[11rem] rounded-2xl border border-stone-200/85 bg-white/86 px-3 py-2 text-[11px] leading-relaxed text-stone-600 shadow-[0_16px_30px_-18px_rgba(28,25,23,0.35)] backdrop-blur-sm sm:bottom-[8.5rem] sm:right-[6.25rem] sm:text-xs md:bottom-[10rem] md:right-[7.4rem]"
        >
          {messages[0]}
        </div>
      </div>
    </div>
  );
}
