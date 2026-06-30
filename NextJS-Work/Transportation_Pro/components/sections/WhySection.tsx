import {
  ArrowRight,
  BadgeCheck,
  BarChart3,
  FileSpreadsheet,
  Layers,
  Receipt,
  Zap,
} from "lucide-react";
import Link from "next/link";

const reasons = [
  {
    icon: Layers,
    title: "One Platform. Zero Gaps.",
    desc: "From the first shipment entry to the final financial report  every operation lives in one system. No switching tabs, no duplicate data entry.",
  },
  {
    icon: BadgeCheck,
    title: "GST-Ready by Default",
    desc: "Every invoice, report, and bill is GST-compliant out of the box. No manual adjustments, no compliance headaches  ever.",
  },
  {
    icon: Receipt,
    title: "Built for Textile Transport",
    desc: "Unique Taka & Bale management makes TransportPro the only platform that truly understands the textile logistics workflow.",
  },
  {
    icon: Zap,
    title: "Fast to Start, Easy to Scale",
    desc: "Your team is operational on day one. As your business grows, add parties, users, and routes without any technical overhead.",
  },
  {
    icon: FileSpreadsheet,
    title: "Full Financial Visibility",
    desc: "Know exactly what you earn, owe, and are owed  at any moment. Commission, freight, and outstanding bills always in sight.",
  },
  {
    icon: BarChart3,
    title: "Real-time Decisions",
    desc: "Live stock, delivery performance, and party analytics give your team the data they need to act fast and stay ahead.",
  },
];

const compares = [
  { label: "Multi-module coverage", us: true, them: false },
  { label: "Auto freight calculation", us: true, them: false },
  { label: "Taka & Bale tracking", us: true, them: false },
  { label: "GST-ready invoicing", us: true, them: true },
  { label: "Standalone print engine", us: true, them: false },
  { label: "Real-time stock dashboard", us: true, them: false },
  { label: "8+ logistics reports", us: true, them: false },
  { label: "Multi-payment mode support", us: true, them: true },
];

export default function WhySection() {
  return (
    <section
      id="why"
      className="bg-[#0C1B33] py-20 lg:py-28 overflow-hidden"
      aria-labelledby="why-heading"
    >
      <div className="max-w-360 mx-auto px-4 sm:px-6 lg:px-10">
        {/* Header */}
        <div className="flex flex-col lg:flex-row lg:items-end lg:justify-between gap-6 mb-16">
          <div className="max-w-xl">
            <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-white/8 border border-white/10 mb-5">
              <span
                className="w-1.5 h-1.5 rounded-full bg-[#F0F8FF]"
                aria-hidden="true"
              />
              <span className="text-[13px] font-semibold text-white/50 tracking-widest uppercase">
                Why TransportPro
              </span>
            </div>
            <h2
              id="why-heading"
              className="text-[42px] sm:text-[48px] font-bold text-white leading-[1.1] tracking-tight"
            >
              Built for Transport.
              <br />
              <span className="text-white/40">Not Adapted for It.</span>
            </h2>
          </div>
          <p className="text-[17px] text-white/40 leading-relaxed max-w-sm lg:text-right">
            Generic software forces your operations to fit its mould.
            TransportPro is designed ground-up for how logistics businesses
            actually work.
          </p>
        </div>

        {/* Main Grid */}
        <div className="grid lg:grid-cols-[1fr_380px] gap-8 items-start">
          {/* Left  Reason cards */}
          <ul className="grid sm:grid-cols-2 gap-4 list-none p-0 m-0">
            {reasons.map(({ icon: Icon, title, desc }) => (
              <li key={title}>
                <article className="group flex flex-col gap-4 p-5 rounded-2xl border border-white/8 bg-white/4 hover:bg-white/7 hover:border-white/15 transition-all duration-200 h-full">
                  <div
                    className="w-10 h-10 rounded-xl bg-white/8 border border-white/10 flex items-center justify-center shrink-0 group-hover:bg-[#F0F8FF]/10 transition-colors"
                    aria-hidden="true"
                  >
                    <Icon className="w-5 h-5 text-[#F0F8FF]/70" />
                  </div>
                  <div>
                    <h3 className="text-[16.5px] font-semibold text-white mb-1.5 leading-snug">
                      {title}
                    </h3>
                    <p className="text-[15px] text-white/40 leading-relaxed">
                      {desc}
                    </p>
                  </div>
                </article>
              </li>
            ))}
          </ul>

          {/* Right  Comparison table (semantic <table> for SEO) */}
          <div className="rounded-2xl border border-white/10 overflow-hidden">
            <table className="w-full border-collapse">
              <caption className="sr-only">
                TransportPro vs other transport management software feature
                comparison
              </caption>
              <thead>
                <tr className="bg-white/6 border-b border-white/10">
                  <th
                    scope="col"
                    className="text-left px-5 py-3 text-[11px] font-bold text-white/30 uppercase tracking-widest"
                  >
                    Feature
                  </th>
                  <th
                    scope="col"
                    className="px-5 py-3 text-[11px] font-bold text-white/80 uppercase tracking-widest text-center w-20"
                  >
                    TransportPro
                  </th>
                  <th
                    scope="col"
                    className="px-5 py-3 text-[11px] font-bold text-white/25 uppercase tracking-widest text-center w-20"
                  >
                    Others
                  </th>
                </tr>
              </thead>
              <tbody>
                {compares.map(({ label, us, them }, i) => (
                  <tr
                    key={label}
                    className={`border-b border-white/6 last:border-b-0 ${i % 2 === 0 ? "bg-transparent" : "bg-white/3"}`}
                  >
                    <td className="px-5 py-3.5 text-[14.5px] text-white/60 font-medium">
                      {label}
                    </td>
                    <td className="px-5 py-3.5 text-center">
                      {us ? (
                        <span
                          className="inline-flex items-center justify-center w-5 h-5 rounded-full bg-emerald-500/15"
                          aria-label="Included"
                        >
                          <svg
                            className="w-3 h-3 text-emerald-400"
                            viewBox="0 0 12 12"
                            fill="none"
                            aria-hidden="true"
                          >
                            <path
                              d="M2 6l3 3 5-5"
                              stroke="currentColor"
                              strokeWidth="1.5"
                              strokeLinecap="round"
                              strokeLinejoin="round"
                            />
                          </svg>
                        </span>
                      ) : (
                        <span
                          className="inline-block w-2 h-0.5 rounded-full bg-white/15"
                          aria-label="Not included"
                        />
                      )}
                    </td>
                    <td className="px-5 py-3.5 text-center">
                      {them ? (
                        <span
                          className="inline-flex items-center justify-center w-5 h-5 rounded-full bg-white/5"
                          aria-label="Included"
                        >
                          <svg
                            className="w-3 h-3 text-white/30"
                            viewBox="0 0 12 12"
                            fill="none"
                            aria-hidden="true"
                          >
                            <path
                              d="M2 6l3 3 5-5"
                              stroke="currentColor"
                              strokeWidth="1.5"
                              strokeLinecap="round"
                              strokeLinejoin="round"
                            />
                          </svg>
                        </span>
                      ) : (
                        <span
                          className="inline-flex items-center justify-center w-5 h-5 rounded-full bg-red-500/10"
                          aria-label="Not available"
                        >
                          <svg
                            className="w-3 h-3 text-red-400/60"
                            viewBox="0 0 12 12"
                            fill="none"
                            aria-hidden="true"
                          >
                            <path
                              d="M3 3l6 6M9 3l-6 6"
                              stroke="currentColor"
                              strokeWidth="1.5"
                              strokeLinecap="round"
                            />
                          </svg>
                        </span>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>

            {/* CTA inside table */}
            <div className="p-5 bg-white/4 border-t border-white/10">
              <Link
                href="/#contact"
                aria-label="See the full TransportPro platform  book a demo"
                className="group w-full flex items-center justify-center gap-2 py-3 text-[15px] font-semibold text-[#0C1B33] bg-white rounded-xl hover:bg-[#F0F8FF] transition-all hover:shadow-lg hover:shadow-black/20"
              >
                See the Full Platform
                <ArrowRight
                  className="w-4 h-4 group-hover:translate-x-0.5 transition-transform"
                  aria-hidden="true"
                />
              </Link>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
