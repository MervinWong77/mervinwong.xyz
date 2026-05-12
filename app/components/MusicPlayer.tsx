"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { Music, Pause } from "lucide-react";

type AmbientHandle = {
  stop: () => void;
};

function createSoftPad(ctx: AudioContext): AmbientHandle {
  const master = ctx.createGain();
  master.gain.setValueAtTime(0, ctx.currentTime);

  const filter = ctx.createBiquadFilter();
  filter.type = "lowpass";
  filter.frequency.setValueAtTime(420, ctx.currentTime);
  filter.Q.setValueAtTime(0.7, ctx.currentTime);

  master.connect(filter);
  filter.connect(ctx.destination);

  const freqs = [196, 246.94, 293.66];
  const oscillators: OscillatorNode[] = [];

  freqs.forEach((freq, i) => {
    const osc = ctx.createOscillator();
    osc.type = "sine";
    osc.frequency.setValueAtTime(freq, ctx.currentTime);
    const band = ctx.createGain();
    band.gain.setValueAtTime(0.018 + i * 0.004, ctx.currentTime);
    osc.connect(band);
    band.connect(master);
    osc.start();
    oscillators.push(osc);
  });

  master.gain.linearRampToValueAtTime(0.12, ctx.currentTime + 1.8);

  return {
    stop: () => {
      const t = ctx.currentTime;
      master.gain.cancelScheduledValues(t);
      master.gain.setValueAtTime(master.gain.value, t);
      master.gain.linearRampToValueAtTime(0, t + 0.6);
      window.setTimeout(() => {
        oscillators.forEach((o) => {
          try {
            o.stop();
          } catch {
            /* already stopped */
          }
        });
      }, 650);
    },
  };
}

export function MusicPlayer() {
  const [playing, setPlaying] = useState(false);
  const ctxRef = useRef<AudioContext | null>(null);
  const padRef = useRef<AmbientHandle | null>(null);

  const teardown = useCallback(async () => {
    padRef.current?.stop();
    padRef.current = null;
    if (ctxRef.current && ctxRef.current.state !== "closed") {
      try {
        await ctxRef.current.suspend();
      } catch {
        /* ignore */
      }
    }
  }, []);

  const toggle = useCallback(async () => {
    if (playing) {
      await teardown();
      setPlaying(false);
      return;
    }

    const Ctx =
      window.AudioContext ||
      (
        window as unknown as {
          webkitAudioContext?: typeof AudioContext;
        }
      ).webkitAudioContext;
    if (!Ctx) {
      setPlaying(false);
      return;
    }

    if (!ctxRef.current || ctxRef.current.state === "closed") {
      ctxRef.current = new Ctx();
    }

    const ctx = ctxRef.current;
    if (ctx.state === "suspended") {
      await ctx.resume();
    }

    padRef.current?.stop();
    padRef.current = createSoftPad(ctx);
    setPlaying(true);
  }, [playing, teardown]);

  useEffect(() => {
    return () => {
      padRef.current?.stop();
      padRef.current = null;
      void ctxRef.current?.close();
      ctxRef.current = null;
    };
  }, []);

  return (
    <div className="pointer-events-none fixed bottom-6 right-6 z-50 flex flex-col items-end gap-2 md:bottom-8 md:right-8">
      <p className="pointer-events-none max-w-[11rem] rounded-lg bg-white/85 px-3 py-1.5 text-[10px] leading-snug text-stone-500 shadow-sm ring-1 ring-stone-200/70 backdrop-blur-sm">
        Optional soft pad — off by default. Tap to play or pause.
      </p>
      <button
        type="button"
        onClick={() => void toggle()}
        aria-pressed={playing}
        aria-label={playing ? "Pause ambient sound" : "Play ambient sound"}
        className="pointer-events-auto flex h-12 w-12 items-center justify-center rounded-full border border-stone-200/90 bg-white/90 text-stone-700 shadow-md shadow-stone-200/50 backdrop-blur-md transition hover:scale-105 hover:border-stone-300 hover:text-stone-900 hover:shadow-lg focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-stone-400 active:scale-95"
      >
        {playing ? (
          <Pause className="h-5 w-5" strokeWidth={1.75} aria-hidden />
        ) : (
          <Music className="h-5 w-5" strokeWidth={1.75} aria-hidden />
        )}
      </button>
    </div>
  );
}
