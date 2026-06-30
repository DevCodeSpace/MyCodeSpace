import type { Metadata } from "next";
import { Open_Sans } from "next/font/google";
import "./globals.css";

const openSans = Open_Sans({
  variable: "--font-open-sans",
  subsets: ["latin"],
  weight: ["400", "500", "600", "700", "800"],
  display: "swap",
});

export const metadata: Metadata = {
  title: "CareBot AI | Medical Appointment Assistant | Book Doctors Instantly",
  description:
    "CareBot AI is a conversational AI-powered medical appointment assistant. Describe your symptoms, discover the right specialist, and book appointments instantly.",
  icons: {
    icon: "/carebot_logo.svg",
    shortcut: "/carebot_logo.svg",
    apple: "/carebot_logo.svg",
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
      className={`${openSans.variable} font-sans h-full antialiased`}
      suppressHydrationWarning
    >
      <body className="min-h-full flex flex-col bg-bg text-[#000000]">
        {children}
      </body>
    </html>
  );
}
