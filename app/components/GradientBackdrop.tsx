export function GradientBackdrop() {
  return (
    <div
      className="pointer-events-none fixed inset-0 -z-10 overflow-hidden"
      aria-hidden
    >
      <div className="animate-soft-drift absolute -left-1/4 top-[-10%] h-[55vh] w-[55vh] rounded-full bg-gradient-to-br from-orange-100/90 via-rose-100/70 to-transparent blur-3xl" />
      <div
        className="animate-soft-drift absolute right-[-15%] top-[15%] h-[45vh] w-[45vh] rounded-full bg-gradient-to-bl from-sky-100/80 via-violet-100/50 to-transparent blur-3xl"
        style={{ animationDelay: "-6s" }}
      />
      <div
        className="animate-gentle-float absolute bottom-[5%] left-[20%] h-[35vh] w-[35vh] rounded-full bg-gradient-to-tr from-amber-50/90 via-orange-50/60 to-transparent blur-3xl"
        style={{ animationDelay: "-2s" }}
      />
      <div className="absolute inset-0 bg-[radial-gradient(ellipse_80%_60%_at_50%_-10%,rgba(255,237,213,0.35),transparent_55%)]" />
    </div>
  );
}
