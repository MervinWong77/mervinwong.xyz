export type ExperienceRole = {
  id: string
  title: string
  organisation: string
  dates: string
  summary: string
}

export type SelectedWork = {
  id: string
  name: string
  context: string
  summary: string
}

export type PageSection = {
  id: string
  label: string
}

/**
 * Confirmed employment only. Leave this empty until official titles and
 * dates are verified. The homepage hides the section while it is empty.
 */
export const experience: ExperienceRole[] = []

/**
 * Confirmed project notes only. Leave this empty until confidentiality
 * and wording are reviewed. The homepage hides the section while it is empty.
 */
export const selectedWork: SelectedWork[] = []

export const interests = [
  {
    title: "Technology and creativity",
    description:
      "Tools, side projects, and the pleasure of making something that feels considered.",
    illustration: "/illustrations/little-corner/lc-paperplane.png",
  },
  {
    title: "Nature and plants",
    description: "Quiet growth, and a green corner wherever I can find one.",
    illustration: "/illustrations/little-corner/lc-sprout.png",
  },
  {
    title: "Aquariums",
    description: "Fish, and the slow care of a small world underwater.",
    illustration: "/illustrations/little-corner/lc-wave.png",
  },
  {
    title: "Travel and photography",
    description: "New cities, film cameras, and light worth keeping.",
    illustration: "/illustrations/little-corner/lc-mountain.png",
  },
  {
    title: "Food",
    description: "Markets, home cooking, and tables shared with people.",
    illustration: "/illustrations/little-corner/lc-coffee.png",
  },
] as const

export const experiment = {
  id: "experiment",
  label: "Personal experiments",
  body: "CopyCat is a macOS application I’m building to make file management and digital organization simpler. It started with a practical problem and grew into an ongoing exploration of product design, technology and software development.",
  status: "Private beta",
  href: "/download/copycat",
  linkLabel: "Explore CopyCat",
} as const

export const socialLinks = [
  {
    label: "LinkedIn",
    href: "https://www.linkedin.com/in/mervin-wong-ch/",
  },
  {
    label: "Instagram",
    href: "https://www.instagram.com/mervin_wong",
  },
  {
    label: "Facebook",
    href: "https://www.facebook.com/mervin.hao/",
  },
  {
    label: "GitHub",
    href: "https://github.com/MervinWong77",
  },
] as const

export const pageTitle =
  "Mervin Wong · Project management, business operations, digital solutions"

export const pageDescription =
  "Mervin Wong works across project management, business operations, and digital solutions. This is also a personal space for travel, plants, food, and quiet experiments."

export const shareImage = {
  url: "/og.png",
  width: 1200,
  height: 630,
  alt: "Mervin Wong. Project management, business operations, and digital solutions.",
} as const

/** Live site redirects the apex host to www. Keep canonical URLs on www. */
export function getSiteUrl() {
  const raw = process.env.NEXT_PUBLIC_SITE_URL?.replace(/\/$/, "")
  if (
    !raw ||
    raw === "https://mervinwong.xyz" ||
    raw === "http://mervinwong.xyz" ||
    raw === "http://www.mervinwong.xyz"
  ) {
    return "https://www.mervinwong.xyz"
  }
  return raw
}

export function navigationSections(): PageSection[] {
  const sections: PageSection[] = [
    { id: "life-in-motion", label: "Life in Motion" },
    { id: "about", label: "About" },
  ]

  if (experience.length > 0) {
    sections.push({ id: "experience", label: "Experience" })
  }
  if (selectedWork.length > 0) {
    sections.push({ id: "work", label: "Work" })
  }

  sections.push(
    { id: "experiment", label: "Experiments" },
    { id: "interests", label: "Interests" },
    { id: "corner", label: "Corner" },
    { id: "connect", label: "Connect" },
  )

  return sections
}
