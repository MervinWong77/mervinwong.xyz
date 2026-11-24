"use client";

import { navigationSections } from "../content/site";
import { navLink } from "./ui";

export function SiteNav() {
  const sections = navigationSections();

  return (
    <nav aria-label="On this page">
      <ul className="flex flex-wrap items-center gap-x-7 gap-y-1">
        {sections.map((section) => (
          <li key={section.id}>
            <a
              href={`#${section.id}`}
              onClick={(event) => {
                const target = document.getElementById(section.id);
                if (!target) return;
                event.preventDefault();
                target.scrollIntoView({ behavior: "smooth", block: "start" });
                history.pushState(null, "", `#${section.id}`);
              }}
              className={navLink}
            >
              {section.label}
            </a>
          </li>
        ))}
      </ul>
    </nav>
  );
}
