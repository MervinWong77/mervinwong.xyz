const focus =
  "focus-visible:outline-solid focus-visible:outline-2 focus-visible:outline-offset-3 focus-visible:outline-stone-900"

const press =
  "transition-[background-color,border-color,color,transform] duration-150 ease-[cubic-bezier(0.23,1,0.32,1)] active:scale-[0.98]"

export const display = "font-display"

export const section = "mt-20 scroll-mt-8 md:mt-28"

export const sectionTitle = `${display} text-[2.15rem] font-medium leading-none tracking-[-0.03em] text-stone-950 md:text-[2.75rem]`

export const projectTitle = `${display} text-[1.65rem] font-medium leading-tight tracking-[-0.02em] text-stone-950 md:text-[2rem]`

export const prose =
  "max-w-[68ch] text-[1.0625rem] leading-[1.7] text-stone-800 md:text-lg"

export const support = "text-[0.95rem] leading-relaxed text-stone-600"

export const caption = `${display} text-base font-medium italic leading-snug tracking-wide text-stone-700 md:text-lg`

export const label = "text-sm font-semibold tracking-wide text-stone-600"

export const positioning =
  "text-lg font-semibold tracking-wide text-stone-950 md:text-xl"

export const btn = `inline-flex min-h-11 items-center justify-center gap-2 rounded-lg px-4 text-[0.95rem] font-semibold leading-none ${press} ${focus}`

export const btnPrimary = `${btn} bg-stone-900 text-stone-50 hover:bg-stone-700`

export const btnSecondary = `${btn} border border-stone-300 bg-transparent text-stone-900 hover:border-stone-500 hover:bg-stone-950/[0.03]`

export const btnIcon = `inline-flex size-11 shrink-0 items-center justify-center rounded-full border border-stone-300/90 bg-white/95 text-stone-800 ${press} hover:border-stone-500 hover:bg-white disabled:cursor-not-allowed disabled:opacity-40 ${focus}`

export const navLink = `inline-flex min-h-11 items-center text-[0.95rem] font-medium text-stone-700 underline decoration-transparent decoration-1 underline-offset-[0.32em] transition-[color,text-decoration-color] duration-200 ease-[cubic-bezier(0.23,1,0.32,1)] hover:text-stone-950 hover:decoration-stone-800 focus-visible:text-stone-950 focus-visible:decoration-stone-800 ${focus}`

export const textLink = `font-semibold text-stone-950 underline decoration-stone-400 decoration-[1.5px] underline-offset-[0.22em] transition-colors duration-150 hover:decoration-stone-950 ${focus}`

export const iconGlyph = "size-[1.125rem]"

export const control = `inline-flex size-11 items-center justify-center rounded-full text-stone-800 transition-[background-color,color,transform] duration-150 ease-[cubic-bezier(0.23,1,0.32,1)] hover:bg-stone-100 active:scale-[0.98] disabled:cursor-not-allowed disabled:opacity-40 ${focus}`
