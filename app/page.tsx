import { About } from "./components/About";
import { Footer } from "./components/Footer";
import { GradientBackdrop } from "./components/GradientBackdrop";
import { Hero } from "./components/Hero";
import { InteractiveSpot } from "./components/InteractiveSpot";
import { MusicPlayer } from "./components/MusicPlayer";
import { SocialLinks } from "./components/SocialLinks";
import { ThingsInto } from "./components/ThingsInto";

export default function Home() {
  return (
    <div className="relative min-h-screen text-stone-900">
      <GradientBackdrop />
      <main className="relative mx-auto max-w-5xl px-5 sm:px-8">
        <Hero />
        <About />
        <ThingsInto />
        <SocialLinks />
        <InteractiveSpot />
        <Footer />
      </main>
      <MusicPlayer />
    </div>
  );
}
