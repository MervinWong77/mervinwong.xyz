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
      className="pointer-events-none fixed bottom-[-0.5rem] left-3 z-30 select-none sm:bottom-[-0.6rem] sm:left-6 md:bottom-[-0.75rem] md:left-10"
      aria-hidden
    >
      <div className="relative">
        <div className="animate-swordsman-float relative h-[12.75rem] w-[10rem] opacity-62 sm:h-[14.25rem] sm:w-[11rem] md:h-[17rem] md:w-[12.75rem]">
          <Image
            src="/characters/characters.png"
            alt=""
            fill
            priority={false}
            className="object-contain drop-shadow-[0_20px_30px_rgba(73,59,51,0.15)]"
          />
          <div className="absolute inset-x-0 bottom-0 h-[58%] bg-gradient-to-t from-[#fbfaf9] via-[#fbfaf9]/62 to-transparent" />
        </div>

        <div
          ref={bubbleRef}
          className="animate-swordsman-float absolute bottom-[7.1rem] left-[6.4rem] max-w-[11.25rem] rounded-2xl border border-stone-200/85 bg-white/88 px-3 py-2 text-[11px] leading-relaxed text-stone-600 shadow-[0_14px_28px_-18px_rgba(28,25,23,0.32)] backdrop-blur-sm sm:bottom-[8rem] sm:left-[7.2rem] sm:text-xs md:bottom-[9.6rem] md:left-[8.6rem]"
        >
          {messages[0]}
        </div>
      </div>
    </div>
  );
}
