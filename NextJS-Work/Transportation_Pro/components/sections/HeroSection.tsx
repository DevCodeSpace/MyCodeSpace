import { ArrowRight, CheckCircle2 } from "lucide-react";
import Link from "next/link";
import Image from "next/image";

const bullets = [
  "End-to-end shipment & delivery management",
  "GST-ready invoicing and financial reports",
  "Real-time stock, freight & logistics analytics",
  "Multi-party billing with auto freight calculation",
];

const stats = [
  { num: "11+", label: "Core Modules" },
  { num: "8+", label: "Report Types" },
  { num: "100%", label: "GST Compliant" },
  { num: "24/7", label: "Operations" },
];

export default function HeroSection() {
  return (
    <section
      className="relative bg-[#F0F8FF] overflow-hidden"
      aria-label="Transport Management Software  Hero"
    >
      <div
        className="absolute top-0 right-0 w-[560px] h-[560px] pointer-events-none"
        aria-hidden="true"
        style={{
          background:
            "radial-gradient(circle at top right, rgba(12,27,51,0.06) 0%, transparent 65%)",
        }}
      />

      <div className="relative max-w-360 mx-auto px-4 sm:px-6 lg:px-10 pt-14 pb-16 lg:pt-20 lg:pb-28">
        <div className="grid lg:grid-cols-[3fr_2fr] gap-10 xl:gap-16 items-center">
          {/* LEFT: Content */}
          <div className="space-y-7">
            <div className="inline-flex items-center rounded-full overflow-hidden border border-[#0C1B33]/12 shadow-sm">
              <div className="flex items-center gap-2 px-4 py-2 bg-[#0C1B33]">
                <svg
                  className="w-3.5 h-3.5 text-white shrink-0"
                  viewBox="0 0 24 24"
                  fill="currentColor"
                  xmlns="http://www.w3.org/2000/svg"
                  aria-hidden="true"
                >
                  <path d="M20 8h-3V4H3c-1.1 0-2 .9-2 2v11h2c0 1.66 1.34 3 3 3s3-1.34 3-3h6c0 1.66 1.34 3 3 3s3-1.34 3-3h2v-5l-3-4zM6 18.5c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5zm13.5-9l1.96 2.5H17V9.5h2.5zm-1.5 9c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5z" />
                </svg>
                <span className="text-[11.5px] font-bold text-white uppercase tracking-widest whitespace-nowrap">
                  All-in-One Platform
                </span>
              </div>
              <div className="flex items-center gap-2 px-4 py-2 bg-white">
                <span className="text-[11.5px] font-semibold text-[#0C1B33]/60 uppercase tracking-widest whitespace-nowrap">
                  Trusted by Logistics Teams
                </span>
                <span className="relative flex h-2 w-2" aria-hidden="true">
                  <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-500 opacity-50" />
                  <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-500" />
                </span>
              </div>
            </div>

            {/* h1  primary keyword target */}
            <h1 className="flex flex-col space-y-2">
              <span className="text-[38px] sm:text-[46px] lg:text-[52px] font-bold text-[#0C1B33] leading-[1.05] tracking-tight block">
                Manage Your
              </span>
              <span className="text-[38px] sm:text-[46px] lg:text-[52px] font-bold text-[#0C1B33] leading-[1.05] tracking-tight block">
                Logistics &{" "}
                <span className="relative inline-block">
                  Freight
                  <svg
                    className="absolute -bottom-1 left-0 w-full"
                    viewBox="0 0 220 8"
                    fill="none"
                    xmlns="http://www.w3.org/2000/svg"
                    aria-hidden="true"
                    preserveAspectRatio="none"
                  >
                    <path
                      d="M2 6 C50 2, 140 2, 218 6"
                      stroke="#0C1B33"
                      strokeWidth="2.5"
                      strokeLinecap="round"
                    />
                  </svg>
                </span>
              </span>
              <span className="text-[48px] sm:text-[56px] lg:text-[62px] font-bold text-[#0C1B33]/35 leading-[1.05] tracking-tight block">
                Operations Simply
              </span>
            </h1>

            <p className="text-[17.5px] text-[#0C1B33]/55 leading-[1.75] max-w-125">
              Purpose-built{" "}
              <strong className="text-[#0C1B33]/80 font-semibold">
                transport management software
              </strong>{" "}
              for logistics businesses covering shipment loading, delivery
              tracking, freight billing, and financial reporting in one
              streamlined platform.
            </p>

            <ul className="space-y-3" aria-label="Key features">
              {bullets.map((b) => (
                <li key={b} className="flex items-start gap-3">
                  <CheckCircle2
                    className="w-5 h-5 text-[#0C1B33] mt-0.5 shrink-0"
                    aria-hidden="true"
                  />
                  <span className="text-[15.5px] text-[#0C1B33]/65 font-medium leading-snug">
                    {b}
                  </span>
                </li>
              ))}
            </ul>

            <div className="flex flex-col sm:flex-row gap-3 pt-1">
              <Link
                href="/#features"
                className="group inline-flex items-center justify-center gap-2.5 px-7 py-3.5 text-[14px] font-semibold text-white bg-[#0C1B33] rounded-xl hover:bg-[#0C1B33]/90 transition-all hover:shadow-xl hover:shadow-[#0C1B33]/25 hover:-translate-y-0.5"
                aria-label="Explore all transport management features"
              >
                Explore All Features
                <ArrowRight
                  className="w-4 h-4 group-hover:translate-x-0.5 transition-transform"
                  aria-hidden="true"
                />
              </Link>
              <Link
                href="/#contact"
                className="inline-flex items-center justify-center gap-2.5 px-7 py-3.5 text-[14px] font-semibold text-[#0C1B33] bg-white rounded-xl border border-[#0C1B33]/18 hover:border-[#0C1B33]/30 hover:bg-[#F0F8FF] transition-all shadow-sm"
                aria-label="Request a free demo of TransportPro"
              >
                Request a Demo
              </Link>
            </div>
          </div>

          {/* RIGHT: Illustration slot */}
          <div
            className="hidden lg:flex items-center justify-center h-[600px] xl:h-[700px] w-full relative scale-[1.15] xl:scale-[1.25] origin-right"
            aria-hidden="true"
          >
            <Image
              src="/images/hero_illustration.webp"
              alt="TransportPro Dashboard Illustration"
              fill
              className="object-contain"
              priority
            />
          </div>
        </div>
      </div>

      {/* Stats Strip */}
      <div
        className="bg-[#0C1B33]"
        role="region"
        aria-label="Platform statistics"
      >
        <div className="max-w-360 mx-auto px-4 sm:px-6 lg:px-10">
          <dl className="grid grid-cols-2 lg:grid-cols-4 divide-x divide-white/10">
            {stats.map(({ num, label }) => (
              <div
                key={label}
                className="flex flex-col items-center justify-center py-8 px-6 gap-1 group hover:bg-white/4 transition-colors"
              >
                <dt className="text-[36px] font-bold text-white leading-none tracking-tight">
                  {num}
                </dt>
                <dd className="text-[13px] font-medium text-white/45 tracking-wide">
                  {label}
                </dd>
              </div>
            ))}
          </dl>
        </div>
      </div>
    </section>
  );
}
