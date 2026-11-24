import type { MetadataRoute } from "next";
import { getSiteUrl } from "./content/site";

const siteUrl = getSiteUrl();

/** Public sitemap — download routes are intentionally excluded. */
export default function sitemap(): MetadataRoute.Sitemap {
  return [
    {
      url: `${siteUrl}/`,
      lastModified: new Date(),
      changeFrequency: "monthly",
      priority: 1,
    },
  ];
}
