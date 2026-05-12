export function Footer() {
  return (
    <footer className="mt-24 border-t border-stone-200/60 pt-10 pb-28 md:mt-32 md:pb-10">
      <p className="text-center text-sm text-stone-500">
        © {new Date().getFullYear()} Mervin Wong · Made with care
      </p>
    </footer>
  );
}
