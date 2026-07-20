import { Plus_Jakarta_Sans } from "next/font/google";
import "./copycat-theme.css";

const plusJakarta = Plus_Jakarta_Sans({
  subsets: ["latin"],
  display: "swap",
  variable: "--font-cc",
});

export default function DownloadLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <div
      className={`${plusJakarta.variable} download-shell font-[family-name:var(--font-cc)]`}
    >
      {children}
    </div>
  );
}
