import type { Metadata } from "next";
import { DM_Sans, Fraunces } from "next/font/google";
import { getSiteUrl, pageDescription, pageTitle } from "./content/site";
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

export const metadata: Metadata = {
  metadataBase: new URL(getSiteUrl()),
  title: {
    default: pageTitle,
    template: "%s",
  },
  description: pageDescription,
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
