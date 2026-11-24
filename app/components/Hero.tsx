import { socialLinks } from "../content/site"
import { SiteNav } from "./SiteNav"
import { btnSecondary, display, positioning } from "./ui"

const linkedIn = socialLinks[0]

export function Hero() {
  return (
    <header className="pt-10 md:pt-16">
      <a
        href="#about"
        className="sr-only focus:not-sr-only focus:absolute focus:left-4 focus:top-4 focus:z-50 focus:rounded-full focus:bg-white focus:px-4 focus:py-2 focus:text-sm focus:font-semibold focus:text-stone-950"
      >
        Skip to about
      </a>
      <div data-keep-clear className="max-w-2xl">
        <p className="animate-fade-up text-sm font-semibold tracking-wide text-stone-600 opacity-0 [animation-delay:80ms]">
          Hello, I&apos;m
        </p>
        <h1
          className={`${display} animate-fade-up mt-3 text-5xl font-medium leading-[0.98] tracking-[-0.03em] text-stone-950 opacity-0 [animation-delay:140ms] sm:text-6xl md:text-7xl`}
        >
          Mervin Wong
        </h1>
        <p className="animate-fade-up mt-6 max-w-xl text-lg leading-relaxed text-stone-700 opacity-0 [animation-delay:220ms] md:text-xl">
          I enjoy bringing people together, making complex things simpler and
          turning ideas into meaningful outcomes.
        </p>
        <p
          className={`${positioning} animate-fade-up mt-7 opacity-0 [animation-delay:280ms]`}
        >
          Project management · Business operations · Digital solutions
        </p>
      </div>
      <div
        data-keep-clear
        className="mt-8 flex flex-col items-start gap-4 border-t border-stone-200 pt-5 sm:mt-10 sm:flex-row sm:items-center sm:justify-between"
      >
        <div className="animate-fade-up opacity-0 [animation-delay:340ms]">
          <SiteNav />
        </div>
        <a
          href={linkedIn.href}
          target="_blank"
          rel="noopener noreferrer"
          className={`${btnSecondary} animate-fade-up opacity-0 [animation-delay:400ms]`}
        >
          Say hello
        </a>
      </div>
    </header>
  )
}
