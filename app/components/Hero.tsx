export function Hero() {
  return (
    <header className="relative pt-8 md:pt-14">
      <p className="animate-fade-up mb-4 text-sm font-medium tracking-wide text-stone-500 opacity-0 [animation-delay:80ms]">
        Hello, I&apos;m
      </p>
      <h1
        className="animate-fade-up max-w-4xl text-5xl font-medium leading-[1.05] tracking-tight text-stone-900 opacity-0 [animation-delay:140ms] sm:text-6xl md:text-7xl"
        style={{ fontFamily: "var(--font-fraunces), ui-serif, Georgia, serif" }}
      >
        Mervin Wong
      </h1>
      <p className="animate-fade-up mt-6 max-w-xl text-lg leading-relaxed text-stone-600 opacity-0 [animation-delay:220ms] md:text-xl">
        I enjoy building thoughtful digital spaces and chasing ideas that feel
        human, warm, and a little unexpected.
      </p>
      <div
        className="pointer-events-none absolute -right-8 top-1/2 hidden h-40 w-40 -translate-y-1/2 rounded-full bg-gradient-to-br from-rose-200/40 to-amber-100/30 blur-2xl md:block"
        aria-hidden
      />
    </header>
  );
}
