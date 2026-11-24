import Image from "next/image"
import { interests } from "../content/site"
import { display, section, sectionTitle, support } from "./ui"

export function ThingsInto() {
  const [lead, ...rest] = interests

  return (
    <section id="interests" className={section} aria-labelledby="things-heading">
      <h2 id="things-heading" className={sectionTitle}>
        Things I&apos;m into
      </h2>
      <div className="mt-8">
        <article
          data-keep-clear
          className="flex flex-col gap-5 sm:flex-row sm:items-center sm:gap-8"
        >
          <Image
            src={lead.illustration}
            alt=""
            width={160}
            height={160}
            className="size-24 shrink-0 object-contain sm:size-28"
          />
          <div className="max-w-xl">
            <h3 className={`${display} text-[1.85rem] font-medium leading-tight tracking-[-0.02em] text-stone-950 md:text-[2.15rem]`}>
              {lead.title}
            </h3>
            <p className="mt-3 text-lg leading-relaxed text-stone-700">
              {lead.description}
            </p>
          </div>
        </article>
        <div className="mt-10 grid gap-x-12 gap-y-10 border-t border-stone-200 pt-8 sm:grid-cols-2">
          {rest.map((item) => (
            <article
              key={item.title}
              data-keep-clear
              className="flex gap-4"
            >
              <Image
                src={item.illustration}
                alt=""
                width={96}
                height={96}
                className="mt-1 size-14 shrink-0 object-contain"
              />
              <div>
                <h3 className={`${display} text-[1.45rem] font-medium leading-tight tracking-[-0.02em] text-stone-950`}>
                  {item.title}
                </h3>
                <p className={`${support} mt-2 max-w-sm`}>{item.description}</p>
              </div>
            </article>
          ))}
        </div>
      </div>
    </section>
  )
}
