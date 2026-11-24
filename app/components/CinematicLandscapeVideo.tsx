"use client";

import { Pause, Play } from "lucide-react";
import { btnIcon, caption, iconGlyph } from "./ui";
import { useEffect, useRef, useState } from "react";

export function CinematicLandscapeVideo() {
  const sectionRef = useRef<HTMLElement>(null);
  const videoRef = useRef<HTMLVideoElement>(null);
  const userPaused = useRef(false);
  const [revealed, setRevealed] = useState(false);
  const [reduceMotion, setReduceMotion] = useState(false);
  const [playing, setPlaying] = useState(false);

  useEffect(() => {
    const media = window.matchMedia("(prefers-reduced-motion: reduce)");
    const apply = () => setReduceMotion(media.matches);
    apply();
    media.addEventListener("change", apply);
    return () => media.removeEventListener("change", apply);
  }, []);

  useEffect(() => {
    const el = sectionRef.current;
    if (!el || typeof IntersectionObserver === "undefined") {
      setRevealed(true);
      return;
    }

    const observer = new IntersectionObserver(
      ([entry]) => {
        setRevealed(entry?.isIntersecting ?? false);
      },
      { threshold: 0.2 }
    );

    observer.observe(el);
    return () => observer.disconnect();
  }, []);

  useEffect(() => {
    const video = videoRef.current;
    if (!video) return;

    if (!revealed || reduceMotion || userPaused.current) {
      if (!video.paused) video.pause();
      return;
    }

    if (!video.getAttribute("src")) {
      video.src = "/videos/Yunnan.mp4";
      video.load();
    }

    void video.play().then(
      () => setPlaying(true),
      () => setPlaying(false)
    );
  }, [revealed, reduceMotion]);

  function togglePlayback() {
    const video = videoRef.current;
    if (!video) return;

    if (video.paused) {
      userPaused.current = false;
      if (!video.getAttribute("src")) {
        video.src = "/videos/Yunnan.mp4";
        video.load();
      }
      void video.play().then(
        () => setPlaying(true),
        () => setPlaying(false)
      );
      return;
    }

    userPaused.current = true;
    video.pause();
    setPlaying(false);
  }

  return (
    <section
      id="yunnan"
      ref={sectionRef}
      className="mt-16 scroll-mt-8 md:mt-20"
      aria-labelledby="yunnan-video-caption"
    >
      <div
        className={`yunnan-reveal transition-[opacity,transform] duration-[1100ms] ease-[cubic-bezier(0.22,1,0.36,1)] motion-reduce:transition-none ${
          revealed || reduceMotion
            ? "translate-y-0 opacity-100"
            : "translate-y-8 opacity-0"
        }`}
      >
        <div data-keep-clear className="group relative mx-auto max-w-[min(100%,72rem)]">
          <div className="relative overflow-hidden rounded-2xl bg-stone-200/60 shadow-[0_24px_70px_-20px_rgba(28,25,23,0.14)] ring-1 ring-stone-200/90 transition duration-700 ease-out will-change-transform motion-safe:group-hover:-translate-y-0.5 motion-safe:group-hover:shadow-[0_32px_80px_-24px_rgba(28,25,23,0.18)] md:rounded-[1.75rem]">
            <div className="aspect-video w-full sm:aspect-[21/9]">
              <video
                ref={videoRef}
                className="h-full w-full object-cover"
                poster="/videos/yunnan-still.jpg"
                muted
                loop
                playsInline
                preload="none"
                aria-label="Moments from Yunnan, China"
                onPlay={() => setPlaying(true)}
                onPause={() => setPlaying(false)}
              />
            </div>
            <button
              type="button"
              onClick={togglePlayback}
              aria-pressed={playing}
              aria-label={playing ? "Pause film" : "Play film"}
              className={`${btnIcon} absolute bottom-3 right-3 bg-white/95`}
            >
              {playing ? (
                <Pause className={iconGlyph} strokeWidth={1.75} aria-hidden />
              ) : (
                <Play className={iconGlyph} strokeWidth={1.75} aria-hidden />
              )}
            </button>
          </div>

          <p
            id="yunnan-video-caption"
            className={`${caption} mt-5 block text-center md:mt-6`}
            style={{
              fontFamily: "var(--font-fraunces), ui-serif, Georgia, serif",
            }}
          >
            Moments from Yunnan, China.
          </p>
        </div>
      </div>
    </section>
  );
}
