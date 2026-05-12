"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { Pause, Play, Volume2, VolumeX } from "lucide-react";

const VIDEO_ID = "8O-1qB-fxjc";
const PLAYER_MOUNT_ID = "yt-bg-music-mount";
const YT_IFRAME_API = "https://www.youtube.com/iframe_api";

const YT_PLAYING = 1;
const YT_PAUSED = 2;

type YTPlayerInstance = {
  playVideo: () => void;
  pauseVideo: () => void;
  mute: () => void;
  unMute: () => void;
  isMuted: () => boolean;
  getPlayerState: () => number;
  destroy: () => void;
};

type YTPlayerConstructor = new (
  elementId: string,
  options: Record<string, unknown>
) => YTPlayerInstance;

let youtubeApiPromise: Promise<void> | null = null;

function loadYouTubeIframeApi(): Promise<void> {
  if (typeof window === "undefined") return Promise.resolve();

  const w = window as Window & {
    YT?: { Player: YTPlayerConstructor };
    onYouTubeIframeAPIReady?: () => void;
  };

  if (w.YT?.Player) return Promise.resolve();

  if (!youtubeApiPromise) {
    youtubeApiPromise = new Promise<void>((resolve) => {
      const previous = w.onYouTubeIframeAPIReady;
      w.onYouTubeIframeAPIReady = () => {
        previous?.();
        resolve();
      };

      const existing = document.querySelector<HTMLScriptElement>(
        `script[src="${YT_IFRAME_API}"]`
      );
      if (!existing) {
        const tag = document.createElement("script");
        tag.src = YT_IFRAME_API;
        tag.async = true;
        document.head.appendChild(tag);
      }
    });
  }

  return youtubeApiPromise;
}

export function MusicPlayer() {
  const playerRef = useRef<YTPlayerInstance | null>(null);
  const [playerReady, setPlayerReady] = useState(false);
  const [playing, setPlaying] = useState(false);
  const [muted, setMuted] = useState(true);

  useEffect(() => {
    let cancelled = false;

    void (async () => {
      try {
        await loadYouTubeIframeApi();
        if (cancelled) return;

        const YT = (window as Window & { YT?: { Player: YTPlayerConstructor } })
          .YT;
        if (!YT?.Player) return;

        playerRef.current?.destroy();

        new YT.Player(PLAYER_MOUNT_ID, {
          videoId: VIDEO_ID,
          width: "200",
          height: "200",
          playerVars: {
            autoplay: 1,
            mute: 1,
            loop: 1,
            playlist: VIDEO_ID,
            controls: 0,
            modestbranding: 1,
            playsinline: 1,
            rel: 0,
            iv_load_policy: 3,
            disablekb: 1,
            fs: 0,
          },
          events: {
            onReady: (e: { target: YTPlayerInstance }) => {
              if (cancelled) return;
              const p = e.target;
              playerRef.current = p;
              p.mute();
              setMuted(true);
              p.playVideo();
              setPlayerReady(true);
            },
            onStateChange: (e: { data: number }) => {
              if (cancelled) return;
              if (e.data === YT_PLAYING) setPlaying(true);
              if (e.data === YT_PAUSED) setPlaying(false);
            },
          },
        });
      } catch {
        /* API unavailable */
      }
    })();

    return () => {
      cancelled = true;
      playerRef.current?.destroy();
      playerRef.current = null;
      setPlayerReady(false);
    };
  }, []);

  const togglePlay = useCallback(() => {
    const p = playerRef.current;
    if (!p) return;
    const state = p.getPlayerState();
    if (state === YT_PLAYING) {
      p.pauseVideo();
    } else {
      p.playVideo();
    }
  }, []);

  const toggleMute = useCallback(() => {
    const p = playerRef.current;
    if (!p) return;
    if (p.isMuted()) {
      p.unMute();
      setMuted(false);
    } else {
      p.mute();
      setMuted(true);
    }
  }, []);

  return (
    <>
      <div
        className="pointer-events-none fixed top-0 -left-[9999px] h-[200px] w-[200px] overflow-hidden opacity-0"
        aria-hidden
      >
        <div id={PLAYER_MOUNT_ID} />
      </div>

      <div className="pointer-events-none fixed bottom-6 right-6 z-50 md:bottom-8 md:right-8">
        <div className="pointer-events-auto flex items-center gap-1 rounded-full border border-stone-200/85 bg-white/82 p-1 shadow-[0_16px_36px_-20px_rgba(28,25,23,0.24)] backdrop-blur-md ring-1 ring-white/70">
          <button
            type="button"
            disabled={!playerReady}
            onClick={togglePlay}
            aria-pressed={playing}
            aria-label={playing ? "Pause background music" : "Play background music"}
            className="flex h-10 w-10 items-center justify-center rounded-full text-stone-700 transition hover:bg-stone-100/80 hover:text-stone-900 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-stone-400 disabled:cursor-not-allowed disabled:opacity-40 active:scale-95"
          >
            {playing ? (
              <Pause className="h-4.5 w-4.5" strokeWidth={1.75} aria-hidden />
            ) : (
              <Play className="h-4.5 w-4.5" strokeWidth={1.75} aria-hidden />
            )}
          </button>
          <button
            type="button"
            disabled={!playerReady}
            onClick={toggleMute}
            aria-pressed={!muted}
            aria-label={muted ? "Unmute background music" : "Mute background music"}
            className="flex h-10 w-10 items-center justify-center rounded-full text-stone-700 transition hover:bg-stone-100/80 hover:text-stone-900 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-stone-400 disabled:cursor-not-allowed disabled:opacity-40 active:scale-95"
          >
            {muted ? (
              <VolumeX className="h-4.5 w-4.5" strokeWidth={1.75} aria-hidden />
            ) : (
              <Volume2 className="h-4.5 w-4.5" strokeWidth={1.75} aria-hidden />
            )}
          </button>
        </div>
      </div>
    </>
  );
}
