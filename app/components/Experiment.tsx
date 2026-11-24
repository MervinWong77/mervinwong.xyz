import Image from "next/image"
import Link from "next/link"
import { experiment } from "../content/site"
import { btnPrimary, prose, projectTitle, section, sectionTitle } from "./ui"

export function Experiment() {
  return (
    <section
      id={experiment.id}
      className={section}
      aria-labelledby="experiment-heading"
    >
      <h2 id="experiment-heading" className={sectionTitle}>
        {experiment.label}
      </h2>
      <article
        data-keep-clear
        className="mt-8 flex flex-col gap-6 rounded-[1.75rem] border border-stone-200 bg-white/70 p-6 shadow-[0_10px_24px_-20px_rgba(28,25,23,0.35)] sm:p-8 lg:flex-row lg:items-center lg:gap-12"
      >
        <div className="flex min-w-0 flex-col gap-5 sm:flex-row sm:items-start">
          <Image
            src="/downloads/copycat/brand/app-icon-512.png"
            alt=""
            width={512}
            height={512}
            className="size-[4.75rem] shrink-0 rounded-[1.35rem] shadow-[0_8px_16px_-12px_rgba(28,25,23,0.4)]"
          />
          <div className="min-w-0">
            <div className="flex flex-wrap items-baseline gap-x-4 gap-y-1">
              <h3 className={projectTitle}>CopyCat</h3>
              <p className="text-sm font-semibold tracking-wide text-stone-600">
                {experiment.status}
              </p>
            </div>
            <div className={`${prose} mt-3 max-w-none space-y-5`}>
              {experiment.paragraphs.map((paragraph) => (
                <p key={paragraph}>{paragraph}</p>
              ))}
            </div>
          </div>
        </div>
        <Link href={experiment.href} className={`${btnPrimary} shrink-0 self-start lg:self-center`}>
          {experiment.linkLabel}
        </Link>
      </article>
    </section>
  )
}
