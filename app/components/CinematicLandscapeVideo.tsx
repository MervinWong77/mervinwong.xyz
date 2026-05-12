"use client";

import { useEffect, useRef, useState } from "react";

export function CinematicLandscapeVideo() {
  const sectionRef = useRef<HTMLElement>(null);
  const [revealed, setRevealed] = useState(false);

  useEffect(() => {
    const el = sectionRef.current;
    if (!el || typeof IntersectionObserver === "undefined") {
      setRevealed(true);
      return;
    }

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry?.isIntersecting) {
          setRevealed(true);
          observer.disconnect();
        }
      },
      { threshold: 0.12, rootMargin: "0px 0px -8% 0px" }
    );

    observer.observe(el);
    return () => observer.disconnect();
  }, []);

  return (
    <section
      ref={sectionRef}
      className="mt-14 md:mt-20"
      aria-labelledby="yunnan-video-caption"
    >
      <div
        className={`transition-[opacity,transform] duration-[1100ms] ease-[cubic-bezier(0.22,1,0.36,1)] will-change-[opacity,transform] ${
          revealed
            ? "translate-y-0 opacity-100"
            : "translate-y-8 opacity-0"
        }`}
      >
        <div className="group relative mx-auto max-w-[min(100%,72rem)]">
          <div
            className="relative overflow-hidden rounded-2xl bg-stone-200/60 shadow-[0_24px_70px_-20px_rgba(28,25,23,0.14)] ring-1 ring-stone-200/90 transition duration-700 ease-out will-change-transform group-hover:-translate-y-0.5 group-hover:shadow-[0_32px_80px_-24px_rgba(28,25,23,0.18)] md:rounded-[1.75rem]"
          >
            <div className="aspect-video w-full sm:aspect-[21/9]">
              <video
                className="h-full w-full object-cover"
                autoPlay
                muted
                loop
                playsInline
                preload="metadata"
                aria-label="Landscape footage from Yunnan, China"
              >
                <source src="/videos/Yunnan.mp4" type="video/mp4" />
              </video>
            </div>
          </div>

          <p
            id="yunnan-video-caption"
            className="mt-5 text-center text-[0.9375rem] font-medium italic tracking-wide text-stone-500 md:mt-6 md:text-base"
            style={{ fontFamily: "var(--font-fraunces), ui-serif, Georgia, serif" }}
          >
            Moments from Yunnan, China.
          </p>
        </div>
      </div>
    </section>
  );
}
