import { section, support } from "./ui"

export function Footer() {
  return (
    <footer className={`${section} border-t border-stone-200 pt-8 pb-10`}>
      <p data-keep-clear className={`${support} mx-auto w-fit text-center`}>
        © {new Date().getFullYear()} Mervin Wong · Made with care
      </p>
    </footer>
  )
}