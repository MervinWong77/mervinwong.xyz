import { selectedWork } from "../content/site"
import { prose, projectTitle, section, sectionTitle, support } from "./ui"

export function SelectedWork() {
  if (selectedWork.length === 0) return null

  return (
    <section id="work" className={section} aria-labelledby="work-heading">
      <h2 id="work-heading" className={sectionTitle}>
        Selected work
      </h2>
      <div data-keep-clear className="mt-8 max-w-3xl space-y-8">
        {selectedWork.map((project) => (
          <article key={project.id}>
            <h3 className={projectTitle}>{project.name}</h3>
            <p className={`${support} mt-2 font-medium`}>{project.context}</p>
            <p className={`${prose} mt-3`}>{project.summary}</p>
          </article>
        ))}
      </div>
    </section>
  )
}
