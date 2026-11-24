import type { Metadata } from "next";
import { About } from "./components/About";
import { CinematicLandscapeVideo } from "./components/CinematicLandscapeVideo";
import { Experience } from "./components/Experience";
import { Experiment } from "./components/Experiment";
import { Footer } from "./components/Footer";
import { GradientBackdrop } from "./components/GradientBackdrop";
import { Hero } from "./components/Hero";
import { InteractiveSpot } from "./components/InteractiveSpot";
import { MusicPlayer } from "./components/MusicPlayer";
import { SelectedWork } from "./components/SelectedWork";
import { SocialLinks } from "./components/SocialLinks";
import { ThingsInto } from "./components/ThingsInto";
import { WanderingSwordsman } from "./components/WanderingSwordsman";
import {
  getSiteUrl,
  pageDescription,
  pageTitle,
  shareImage,
  socialLinks,
} from "./content/site";

export const metadata: Metadata = {
  title: pageTitle,
  description: pageDescription,
  alternates: {
    canonical: "/",
  },
  openGraph: {
    type: "website",
    locale: "en_MY",
    url: "/",
    siteName: "Mervin Wong",
    title: pageTitle,
    description: pageDescription,
    images: [shareImage],
  },
  twitter: {
    card: "summary_large_image",
    title: pageTitle,
    description: pageDescription,
    images: [shareImage.url],
  },
};

export default function Home() {
  const personJsonLd = {
    "@context": "https://schema.org",
    "@type": "Person",
    name: "Mervin Wong",
    url: getSiteUrl(),
    description: pageDescription,
    sameAs: socialLinks.map((link) => link.href),
  };

  return (
    <div className="relative grid h-dvh grid-rows-[minmax(0,1fr)_auto] text-stone-900">
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify(personJsonLd).replace(/</g, "\\u003c"),
        }}
      />
      <GradientBackdrop />
      <div data-scroll-root className="relative min-h-0 overflow-y-auto scroll-smooth">
        <main className="relative mx-auto max-w-5xl px-5 sm:px-8">
          <Hero />
          <CinematicLandscapeVideo />
          <About />
          <Experience />
          <SelectedWork />
          <Experiment />
          <ThingsInto />
          <InteractiveSpot />
          <SocialLinks />
          <Footer />
        </main>
      </div>
      <WanderingSwordsman />
      <div
        data-music-bar
        className="relative z-40 flex flex-col items-end gap-1 px-3 py-2 sm:flex-row sm:items-end sm:justify-between sm:gap-3 sm:px-5 xl:justify-end xl:px-6"
      >
        <div
          className="relative h-24 w-full sm:min-w-0 sm:flex-1 xl:hidden"
          data-wander-dock=""
        />
        <MusicPlayer />
      </div>
    </div>
  );
}
