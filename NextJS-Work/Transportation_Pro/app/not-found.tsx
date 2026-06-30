import type { Metadata } from "next";
import Link from "next/link";
import { siteConfig } from "../lib/siteConfig";

export const metadata: Metadata = {
  title: "Page Not Found",
  description: "The page you are looking for does not exist. Return to TransportPro home.",
  robots: { index: false, follow: false },
  alternates: { canonical: `${siteConfig.url}/404` },
};

export default function NotFound() {
  return (
    <section className="min-h-[70vh] flex items-center justify-center bg-[#F0F8FF] px-4">
      <div className="text-center max-w-md">
        <p className="text-[88px] font-bold text-[#0C1B33] leading-none tracking-tight">
          404
        </p>
        <h1 className="text-[26px] font-bold text-[#0C1B33] mt-4 mb-3">
          Page Not Found
        </h1>
        <p className="text-[16px] text-[#0C1B33]/50 leading-relaxed mb-8">
          The page you&apos;re looking for doesn&apos;t exist or has been moved.
        </p>
        <Link
          href="/"
          className="inline-flex items-center gap-2 px-7 py-3.5 text-[14.5px] font-semibold text-white bg-[#0C1B33] rounded-xl hover:bg-[#0C1B33]/90 transition-all hover:shadow-xl hover:shadow-[#0C1B33]/25 hover:-translate-y-0.5"
        >
          Back to Home
        </Link>
      </div>
    </section>
  );
}
