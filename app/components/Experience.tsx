import { experience } from "../content/site"
import { prose, projectTitle, section, sectionTitle, support } from "./ui"

export function Experience() {
  if (experience.length === 0) return null

  return (
    <section
      id="experience"
      className={section}
      aria-labelledby="experience-heading"
    >
      <h2 id="experience-heading" className={sectionTitle}>
        Experience
      </h2>
      <div data-keep-clear className="mt-8 max-w-3xl space-y-10">
        {experience.map((role) => (
          <article key={role.id}>
            <h3 className={projectTitle}>{role.title}</h3>
            <p className={`${support} mt-2 font-medium`}>
              {role.organisation}
              <span aria-hidden> · </span>
              {role.dates}
            </p>
            <p className={`${prose} mt-3`}>{role.summary}</p>
          </article>
        ))}
      </div>
    </section>
  )
}
