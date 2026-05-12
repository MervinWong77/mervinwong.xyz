import {
  Cpu,
  Leaf,
  Lightbulb,
  Plane,
  Sparkles,
  UtensilsCrossed,
} from "lucide-react";

const items = [
  {
    title: "Technology",
    description: "Tools that empower people and gentle innovation.",
    icon: Cpu,
    accent: "from-sky-50 to-indigo-50/80",
    ring: "ring-sky-100/80",
  },
  {
    title: "Food",
    description: "Markets, home cooking, and shared tables.",
    icon: UtensilsCrossed,
    accent: "from-orange-50 to-amber-50/90",
    ring: "ring-orange-100/80",
  },
  {
    title: "Plants",
    description: "Quiet growth and green corners everywhere.",
    icon: Leaf,
    accent: "from-emerald-50 to-teal-50/80",
    ring: "ring-emerald-100/70",
  },
  {
    title: "Travel",
    description: "New rhythms, light, and stories from the road.",
    icon: Plane,
    accent: "from-violet-50 to-fuchsia-50/70",
    ring: "ring-violet-100/70",
  },
  {
    title: "Creative Ideas",
    description: "Sketching, side projects, and playful what-ifs.",
    icon: Lightbulb,
    accent: "from-amber-50 to-yellow-50/80",
    ring: "ring-amber-100/80",
  },
  {
    title: "Digital Experiences",
    description: "Interfaces that breathe and feel considered.",
    icon: Sparkles,
    accent: "from-rose-50 to-orange-50/70",
    ring: "ring-rose-100/70",
  },
] as const;

export function ThingsInto() {
  return (
    <section
      className="mt-20 md:mt-28"
      aria-labelledby="things-heading"
    >
      <h2
        id="things-heading"
        className="text-xs font-semibold uppercase tracking-[0.2em] text-stone-400"
      >
        Things I&apos;m into
      </h2>
      <ul className="mt-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-3 lg:gap-5">
        {items.map(({ title, description, icon: Icon, accent, ring }) => (
          <li key={title}>
            <article
              className={`group relative h-full overflow-hidden rounded-2xl border border-stone-200/60 bg-gradient-to-br ${accent} p-6 shadow-sm ring-1 ${ring} transition duration-300 ease-out hover:-translate-y-1 hover:border-stone-300/50 hover:shadow-md`}
            >
              <div className="mb-4 inline-flex rounded-xl bg-white/70 p-2.5 text-stone-700 shadow-sm ring-1 ring-stone-100/80 transition group-hover:scale-105 group-hover:text-stone-900">
                <Icon className="h-5 w-5" strokeWidth={1.75} aria-hidden />
              </div>
              <h3 className="font-medium text-stone-900">{title}</h3>
              <p className="mt-2 text-sm leading-relaxed text-stone-600">
                {description}
              </p>
            </article>
          </li>
        ))}
      </ul>
    </section>
  );
}
