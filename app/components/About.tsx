export function About() {
  return (
    <section
      className="mt-20 md:mt-28"
      aria-labelledby="about-heading"
    >
      <h2
        id="about-heading"
        className="text-xs font-semibold uppercase tracking-[0.2em] text-stone-400"
      >
        About
      </h2>
      <p className="mt-4 max-w-2xl text-lg leading-relaxed text-stone-700 md:text-xl">
        I&apos;m endlessly curious about how we shape experiences online and
        in real life. You&apos;ll usually find me somewhere between a good meal,
        a new city, a thriving plant, and whatever creative rabbit hole I fell
        into last week — always learning, always hungry for the next small
        discovery.
      </p>
    </section>
  );
}
