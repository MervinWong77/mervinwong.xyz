import { caption, prose, section, sectionTitle } from "./ui"

export function About() {
  return (
    <section id="about" className={section} aria-labelledby="about-heading">
      <h2 id="about-heading" className={sectionTitle}>
        About
      </h2>
      <div className="mt-8 max-w-[68ch]">
        <div data-keep-clear className={`${prose} max-w-none space-y-5`}>
          <p>
            I’m endlessly curious about how we shape experiences online and in
            real life. You’ll usually find me somewhere between a good meal, a
            new city, a thriving plant, and whatever I fell into last week.
          </p>
          <p>
            Professionally, I enjoy bringing structure to complexity. My
            experience spans project coordination, business operations, process
            improvement and digital initiatives. I work with people across
            different disciplines to understand challenges, connect the dots
            and turn ideas into practical outcomes.
          </p>
        </div>
        <p data-keep-clear className={`${caption} mt-8 text-2xl md:text-[1.85rem]`}>
          Always curious. Still learning.
        </p>
      </div>
    </section>
  )
}
