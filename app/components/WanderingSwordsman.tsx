"use client";

import Image from "next/image";
import { useEffect, useRef, useState } from "react";

const messages = [
  "Glad you stopped by.",
  "Take your time exploring.",
  "Some moments are worth keeping.",
  "Welcome to my little corner of the internet.",
] as const;

type BubbleSide = "above" | "left" | "right";

type Pose = {
  x: number;
  y: number;
  bubble: BubbleSide;
};

type Metrics = {
  w: number;
  h: number;
  bubbleW: number;
  bubbleH: number;
};

type Box = {
  left: number;
  top: number;
  right: number;
  bottom: number;
};

const DOCK_METRICS: Metrics = { w: 72, h: 78, bubbleW: 168, bubbleH: 58 };

function laneMetrics(laneWidth: number): Metrics | null {
  if (laneWidth < 96) return null;
  const bubbleW = Math.min(176, Math.floor(laneWidth));
  const w = Math.min(148, Math.max(84, bubbleW - 8));
  return {
    w,
    h: Math.round(w * 1.36),
    bubbleW,
    bubbleH: bubbleW < 140 ? 74 : 62,
  };
}

function footprint(pose: Pose, m: Metrics): Box {
  let left = pose.x;
  let top = pose.y;
  let right = pose.x + m.w;
  let bottom = pose.y + m.h;

  if (pose.bubble === "above") {
    const bubbleLeft = pose.x + m.w / 2 - m.bubbleW / 2;
    left = Math.min(left, bubbleLeft);
    right = Math.max(right, bubbleLeft + m.bubbleW);
    top -= m.bubbleH + 10;
  } else if (pose.bubble === "left") {
    left -= m.bubbleW + 8;
    const bubbleTop = pose.y + m.h * 0.22;
    top = Math.min(top, bubbleTop);
    bottom = Math.max(bottom, bubbleTop + m.bubbleH);
  } else {
    right += m.bubbleW + 8;
    const bubbleTop = pose.y + m.h * 0.18;
    top = Math.min(top, bubbleTop);
    bottom = Math.max(bottom, bubbleTop + m.bubbleH);
  }

  return { left, top, right, bottom };
}

function hits(box: Box, blocks: DOMRect[], pad: number) {
  return blocks.some(
    (block) =>
      !(
        box.right < block.left - pad ||
        box.left > block.right + pad ||
        box.bottom < block.top - pad ||
        box.top > block.bottom + pad
      ),
  );
}

function inViewport(box: Box, vw: number, floor: number) {
  return box.left >= 8 && box.top >= 8 && box.right <= vw - 8 && box.bottom <= floor - 8;
}

function outsideColumn(box: Box, column: DOMRect) {
  return box.right < column.left - 6 || box.left > column.right + 6;
}

function keepClearRects() {
  return Array.from(document.querySelectorAll<HTMLElement>("[data-keep-clear]")).map(
    (el) => el.getBoundingClientRect(),
  );
}

function columnRect() {
  return document.querySelector("[data-scroll-root] main")?.getBoundingClientRect() ?? null;
}

function musicFloor() {
  const bar = document.querySelector("[data-music-bar]")?.getBoundingClientRect();
  return bar && bar.height > 0 ? bar.top : window.innerHeight;
}

function dockRect() {
  const dock = document.querySelector("[data-wander-dock]")?.getBoundingClientRect();
  if (!dock || dock.width < 140 || dock.height < 72) return null;
  return dock;
}

function collectMarginPoses(column: DOMRect, floor: number, blocks: DOMRect[]) {
  const vw = window.innerWidth;
  const lanes = [
    { left: 10, right: column.left - 8 },
    { left: column.right + 8, right: vw - 10 },
  ];
  const laneWidth = Math.max(...lanes.map((lane) => lane.right - lane.left));
  const metrics = laneMetrics(laneWidth);
  if (!metrics) return { metrics: null, poses: [] as Pose[] };

  const poses: Pose[] = [];
  const ys: number[] = [];
  for (let y = 18; y <= floor - metrics.h - 12; y += 92) ys.push(y);

  for (const lane of lanes) {
    const width = lane.right - lane.left;
    const footW = Math.max(metrics.w, metrics.bubbleW);
    if (width < footW) continue;
    const x = lane.left + (width - footW) / 2 + (footW - metrics.w) / 2;
    for (const y of ys) {
      const pose = { x, y, bubble: "above" as const };
      const box = footprint(pose, metrics);
      if (!inViewport(box, vw, floor) || !outsideColumn(box, column)) continue;
      if (hits(box, blocks, 6)) continue;
      poses.push(pose);
    }
  }

  return { metrics, poses };
}

function collectDockPoses(dock: DOMRect) {
  const m = DOCK_METRICS;
  const y = Math.round(dock.bottom - m.h);
  const travel = dock.width - m.w - m.bubbleW - 20;
  if (travel < 0) return [];

  const steps = Math.max(1, Math.min(5, Math.floor(travel / 28)));
  const poses: Pose[] = [];

  for (let i = 0; i <= steps; i += 1) {
    const pose = {
      x: Math.round(dock.left + 6 + (travel * i) / steps),
      y,
      bubble: "right" as const,
    };
    const box = footprint(pose, m);
    const inside =
      box.left >= dock.left - 1 &&
      box.right <= dock.right + 1 &&
      box.top >= dock.top - 1 &&
      box.bottom <= dock.bottom + 2;
    if (inside) poses.push(pose);
  }

  return poses;
}

function pickPose(options: Pose[], from: Pose | null) {
  if (!options.length) return null;
  if (!from) return options[Math.floor(Math.random() * options.length)] ?? null;

  const distant = options.filter((pose) => Math.hypot(pose.x - from.x, pose.y - from.y) > 48);
  const pool = distant.length ? distant : options;
  return pool[Math.floor(Math.random() * pool.length)] ?? null;
}

function pathIsClear(from: Pose, to: Pose, m: Metrics, blocks: DOMRect[], floor: number) {
  const vw = window.innerWidth;
  for (let step = 1; step <= 5; step += 1) {
    const t = step / 5;
    const pose = {
      x: from.x + (to.x - from.x) * t,
      y: from.y + (to.y - from.y) * t,
      bubble: from.bubble,
    };
    const box = footprint(pose, m);
    if (!inViewport(box, vw, floor) || hits(box, blocks, 6)) return false;
  }
  return true;
}

function bubbleStyle(side: BubbleSide, m: Metrics): React.CSSProperties {
  if (side === "above") {
    return {
      width: m.bubbleW,
      left: m.w / 2,
      bottom: "100%",
      transform: "translate(-50%, -10px)",
    };
  }
  if (side === "left") {
    return {
      width: m.bubbleW,
      right: "100%",
      top: "22%",
      transform: "translate(-8px, 0)",
    };
  }
  return {
    width: m.bubbleW,
    left: "100%",
    top: "18%",
    transform: "translate(8px, 0)",
  };
}

function nextMessage(current: string) {
  const choices = messages.filter((message) => message !== current);
  return choices[Math.floor(Math.random() * choices.length)] ?? messages[0];
}

export function WanderingSwordsman() {
  const rootRef = useRef<HTMLDivElement>(null);
  const [metrics, setMetrics] = useState<Metrics>(DOCK_METRICS);
  const [bubble, setBubble] = useState<BubbleSide>("above");
  const [message, setMessage] = useState<(typeof messages)[number]>(messages[0]);
  const [speaking, setSpeaking] = useState(false);

  useEffect(() => {
    const root = rootRef.current;
    if (!root) return;

    const motion = window.matchMedia("(prefers-reduced-motion: reduce)");
    let reduceMotion = motion.matches;
    let cancelled = false;
    let walking = false;
    let trip = 0;
    let frame = 0;
    let idleTimer = 0;
    let fadeTimer = 0;
    let pose: Pose | null = null;
    let currentMetrics = DOCK_METRICS;
    let bubbleSide: BubbleSide = "above";
    let greeting = messages[crypto.getRandomValues(new Uint32Array(1))[0] % messages.length];

    setMessage(greeting);

    const apply = (next: Pose, m: Metrics) => {
      root.style.transform = `translate3d(${next.x}px, ${next.y}px, 0)`;
      if (
        m.w !== currentMetrics.w ||
        m.h !== currentMetrics.h ||
        m.bubbleW !== currentMetrics.bubbleW ||
        m.bubbleH !== currentMetrics.bubbleH
      ) {
        currentMetrics = m;
        setMetrics(m);
      }
      if (next.bubble !== bubbleSide) {
        bubbleSide = next.bubble;
        setBubble(next.bubble);
      }
    };

    const show = (opacity: number) => {
      root.style.opacity = String(opacity);
    };

    const scene = () => {
      const column = columnRect();
      const floor = musicFloor();
      const blocks = keepClearRects();
      const dock = dockRect();
      const margin = column ? collectMarginPoses(column, floor, blocks) : null;

      if (margin?.metrics && margin.poses.length) {
        return {
          metrics: margin.metrics,
          poses: margin.poses,
          floor,
          blocks,
          docked: false,
        };
      }

      const dockPoses = dock ? collectDockPoses(dock) : [];
      if (dockPoses.length) {
        return { metrics: DOCK_METRICS, poses: dockPoses, floor, blocks, docked: true };
      }

      return { metrics: currentMetrics, poses: [] as Pose[], floor, blocks, docked: false };
    };

    let speakTimer = 0;
    const speak = (chance: number) => {
      if (Math.random() > chance) return;
      greeting = nextMessage(greeting);
      setMessage(greeting);
      setSpeaking(true);
      window.clearTimeout(speakTimer);
      speakTimer = window.setTimeout(() => {
        if (!cancelled) setSpeaking(false);
      }, 5600);
    };

    const finishAt = (next: Pose, m: Metrics) => {
      pose = next;
      apply(next, m);
      show(1);
      walking = false;
      speak(0.34);
      if (!reduceMotion) armIdle();
    };

    const travel = (to: Pose) => {
      if (!pose) return;
      const snapshot = scene();
      const from = pose;
      const id = ++trip;
      walking = true;
      window.clearTimeout(idleTimer);

      const canSlide =
        !reduceMotion &&
        (snapshot.docked || Math.abs(from.x - to.x) < 28) &&
        pathIsClear(from, to, snapshot.metrics, snapshot.blocks, snapshot.floor);

      if (!canSlide) {
        show(0);
        fadeTimer = window.setTimeout(() => {
          if (cancelled || id !== trip) return;
          finishAt(to, snapshot.metrics);
        }, reduceMotion ? 0 : 460);
        return;
      }

      const distance = Math.hypot(to.x - from.x, to.y - from.y);
      const duration = Math.min(5400, Math.max(1700, distance * 18));
      const start = performance.now();

      const step = (now: number) => {
        if (cancelled || id !== trip) return;
        const t = Math.min(1, (now - start) / duration);
        const eased = t < 0.5 ? 2 * t * t : 1 - ((-2 * t + 2) ** 2) / 2;
        const current = {
          x: from.x + (to.x - from.x) * eased,
          y: from.y + (to.y - from.y) * eased,
          bubble: from.bubble,
        };
        pose = current;
        apply(current, snapshot.metrics);
        if (t < 1) {
          frame = requestAnimationFrame(step);
          return;
        }
        finishAt({ ...to, bubble: from.bubble }, snapshot.metrics);
      };

      frame = requestAnimationFrame(step);
    };

    const armIdle = () => {
      window.clearTimeout(idleTimer);
      const wait = 4800 + Math.random() * 7200;
      idleTimer = window.setTimeout(() => {
        if (cancelled || reduceMotion || !pose) return;
        const snapshot = scene();
        const next = pickPose(snapshot.poses, pose);
        if (!next) {
          show(0);
          pose = null;
          armIdle();
          return;
        }
        travel(next);
      }, wait);
    };

    const settle = (animate: boolean) => {
      const snapshot = scene();
      const next = pickPose(snapshot.poses, null);
      if (!next) {
        show(0);
        pose = null;
        return;
      }
      if (animate && pose && !reduceMotion) {
        travel(next);
        return;
      }
      pose = next;
      apply(next, snapshot.metrics);
      show(1);
      walking = false;
      if (!reduceMotion) armIdle();
    };

    let scrollTick = 0;
    const onShift = () => {
      if (walking) return;
      const snapshot = scene();
      if (!pose) {
        settle(false);
        return;
      }
      const box = footprint(pose, currentMetrics);
      const column = columnRect();
      const dock = dockRect();
      const blocked = snapshot.docked
        ? !dock ||
          box.left < dock.left - 2 ||
          box.right > dock.right + 2 ||
          box.top < dock.top - 2 ||
          box.bottom > dock.bottom + 4
        : !inViewport(box, window.innerWidth, snapshot.floor) ||
          hits(box, snapshot.blocks, 8) ||
          (column ? !outsideColumn(box, column) : false);

      if (!blocked) return;
      if (reduceMotion) {
        settle(false);
        return;
      }
      const next = pickPose(snapshot.poses, pose);
      if (!next) {
        show(0);
        pose = null;
        return;
      }
      travel(next);
    };

    const onScroll = () => {
      if (scrollTick) return;
      scrollTick = requestAnimationFrame(() => {
        scrollTick = 0;
        onShift();
      });
    };

    const onMotion = () => {
      reduceMotion = motion.matches;
      trip += 1;
      walking = false;
      window.clearTimeout(idleTimer);
      window.clearTimeout(fadeTimer);
      cancelAnimationFrame(frame);
      settle(false);
    };

    const onVisibility = () => {
      trip += 1;
      walking = false;
      window.clearTimeout(idleTimer);
      cancelAnimationFrame(frame);
      if (!document.hidden && !reduceMotion) armIdle();
    };

    settle(false);
    speak(1);

    const scroller = document.querySelector("[data-scroll-root]");
    scroller?.addEventListener("scroll", onScroll, { passive: true });
    window.addEventListener("resize", onScroll);
    motion.addEventListener("change", onMotion);
    document.addEventListener("visibilitychange", onVisibility);

    return () => {
      cancelled = true;
      trip += 1;
      window.clearTimeout(idleTimer);
      window.clearTimeout(fadeTimer);
      window.clearTimeout(speakTimer);
      cancelAnimationFrame(frame);
      cancelAnimationFrame(scrollTick);
      scroller?.removeEventListener("scroll", onScroll);
      window.removeEventListener("resize", onScroll);
      motion.removeEventListener("change", onMotion);
      document.removeEventListener("visibilitychange", onVisibility);
    };
  }, []);

  return (
    <div
      ref={rootRef}
      className="pointer-events-none fixed top-0 left-0 z-30 select-none opacity-0 transition-opacity duration-500 ease-[cubic-bezier(0.23,1,0.32,1)] motion-reduce:transition-none"
      aria-hidden
    >
      <div className="relative" style={{ width: metrics.w, height: metrics.h }}>
        <div className="animate-swordsman-float relative h-full w-full">
          <Image
            src="/characters/characters.png"
            alt=""
            fill
            sizes="180px"
            priority={false}
            className="object-contain object-bottom drop-shadow-[0_20px_30px_rgba(73,59,51,0.15)]"
          />
          <div className="absolute inset-x-0 bottom-0 h-[42%] bg-gradient-to-t from-[#fbfaf9] via-[#fbfaf9]/55 to-transparent" />
        </div>
        <div
          className={`absolute rounded-2xl border border-stone-200/85 bg-white/92 px-3 py-2 text-[11px] leading-relaxed text-stone-700 shadow-[0_14px_28px_-18px_rgba(28,25,23,0.32)] transition-opacity duration-500 ease-[cubic-bezier(0.23,1,0.32,1)] motion-reduce:transition-none sm:text-xs ${
            speaking ? "opacity-100" : "opacity-0"
          }`}
          style={bubbleStyle(bubble, metrics)}
        >
          {message}
        </div>
      </div>
    </div>
  );
}
