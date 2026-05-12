import type { Metadata } from "next";
import { DM_Sans, Fraunces } from "next/font/google";
import "./globals.css";

const dmSans = DM_Sans({
  variable: "--font-dm-sans",
  subsets: ["latin"],
  display: "swap",
});

const fraunces = Fraunces({
  variable: "--font-fraunces",
  subsets: ["latin"],
  display: "swap",
});

const siteUrl =
  process.env.NEXT_PUBLIC_SITE_URL?.replace(/\/$/, "") ??
  "https://mervinwong.xyz";

const siteDescription =
  "A calm digital space — technology, creativity, food, plants, travel, and digital experiences.";

export const metadata: Metadata = {
  metadataBase: new URL(siteUrl),
  title: "Mervin Wong",
  description: siteDescription,
  alternates: {
    canonical: "/",
  },
  openGraph: {
    type: "website",
    locale: "en_US",
    url: "/",
    siteName: "Mervin Wong",
    title: "Mervin Wong",
    description: siteDescription,
  },
  twitter: {
    card: "summary_large_image",
    title: "Mervin Wong",
    description: siteDescription,
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="en"
      className={`${dmSans.variable} ${fraunces.variable} h-full scroll-smooth antialiased`}
    >
      <body className={`${dmSans.className} min-h-full`}>{children}</body>
    </html>
  );
}
