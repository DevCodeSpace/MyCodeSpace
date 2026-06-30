import { Building2, Bus, Store, Truck } from "lucide-react";
import Link from "next/link";

const segments = [
  {
    Icon: Bus,
    title: "Small & Mid Transport Agencies",
    desc: "Local and regional transport operators managing daily dispatch, party billing, and freight collections. TransportPro replaces paper registers and Excel with a purpose-built system.",
    tag: "Agencies",
  },
  {
    Icon: Truck,
    title: "Large Fleet Operators",
    desc: "Mid to large fleets with 10–500 vehicles needing centralized loading management, real-time stock tracking, and GST-compliant invoicing across multiple routes.",
    tag: "Fleet",
  },
  {
    Icon: Building2,
    title: "Logistics Companies",
    desc: "Multi-city transport operations that require structured freight billing, commission reports, delivery receipts, and financial visibility across all branches and parties.",
    tag: "Logistics",
  },
  {
    Icon: Store,
    title: "Textile Transport Businesses",
    desc: "Transport businesses operating in Surat, Gujarat, and textile hubs across India  with specialized Taka & Bale tracking that no generic software offers.",
    tag: "Textile",
  },
];

export default function AudienceSection() {
  return (
    <section
      id="audience"
      className="py-24 bg-[#F0F8FF] overflow-hidden relative"
      aria-labelledby="audience-heading"
    >
      <div
        className="absolute -top-24 right-1/4 w-[400px] h-[400px] rounded-full bg-[#0C1B33]/5 blur-3xl pointer-events-none"
        aria-hidden="true"
      />

      <div className="max-w-360 mx-auto px-4 sm:px-6 lg:px-10">
        {/* Header */}
        <div className="grid lg:grid-cols-2 gap-12 items-end mb-14">
          <div>
            <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-white border border-[#0C1B33]/10 mb-5">
              <span
                className="w-1.5 h-1.5 rounded-full bg-[#0C1B33]"
                aria-hidden="true"
              />
              <span className="text-[13px] font-semibold text-[#0C1B33]/60 tracking-widest uppercase">
                Who It&apos;s For
              </span>
            </div>
            <h2
              id="audience-heading"
              className="text-4xl sm:text-[48px] font-bold text-[#0C1B33] leading-[1.1] tracking-tight mb-4"
            >
              Built for Every
              <br />
              Transport Business
            </h2>
            <p className="text-[#0C1B33]/50 text-[17px] leading-relaxed">
              TransportPro is designed with{" "}
              <strong className="text-[#0C1B33]/80">
                India&apos;s transport and logistics market
              </strong>{" "}
              in mind from local agencies in Surat and Gujarat to pan-India
              freight operators.
            </p>
          </div>

          {/* Info box */}
          <div className="flex items-center gap-3 p-5 bg-white rounded-2xl border border-[#0C1B33]/10 shadow-sm">
            <div
              className="w-10 h-10 rounded-xl bg-[#0C1B33] flex items-center justify-center shrink-0"
              aria-hidden="true"
            >
              <Truck className="w-5 h-5 text-white" />
            </div>
            <p className="text-[#0C1B33]/70 font-medium text-[15px] leading-snug">
              Whether you have{" "}
              <strong className="text-[#0C1B33]">5 trucks or 500</strong>
              TransportPro scales with your operations.
            </p>
          </div>
        </div>

        {/* Segment cards */}
        <ul className="grid grid-cols-1 sm:grid-cols-2 gap-6 list-none p-0 m-0">
          {segments.map((s) => (
            <li key={s.title}>
              <article className="group bg-white rounded-2xl border border-[#0C1B33]/8 shadow-sm hover:shadow-xl hover:border-[#0C1B33]/20 hover:-translate-y-1.5 transition-all duration-300 overflow-hidden relative h-full">
                <div
                  className="absolute top-0 left-0 right-0 h-0.5 bg-[#0C1B33] opacity-0 group-hover:opacity-100 transition-opacity duration-300"
                  aria-hidden="true"
                />

                {/* Icon header */}
                <div className="flex items-center gap-4 p-6 pb-4">
                  <div
                    className="w-11 h-11 rounded-xl bg-[#0C1B33] flex items-center justify-center shrink-0"
                    aria-hidden="true"
                  >
                    <s.Icon className="w-5 h-5 text-white" />
                  </div>
                  <span className="text-[11px] font-bold text-[#0C1B33]/25 uppercase tracking-widest">
                    {s.tag}
                  </span>
                </div>

                {/* Content */}
                <div className="px-6 pb-6">
                  <h3 className="font-bold text-[#0C1B33] text-[17px] leading-snug mb-2">
                    {s.title}
                  </h3>
                  <p className="text-[#0C1B33]/50 text-[15px] leading-relaxed">
                    {s.desc}
                  </p>
                </div>
              </article>
            </li>
          ))}
        </ul>

        {/* CTA */}
        <div className="mt-12 text-center">
          <Link
            href="/#contact"
            aria-label="Book a free demo  see TransportPro in action for your business type"
            className="inline-flex items-center gap-2 px-7 py-3.5 text-[15px] font-semibold text-white bg-[#0C1B33] rounded-xl hover:bg-[#0C1B33]/90 transition-all hover:shadow-xl hover:shadow-[#0C1B33]/25 hover:-translate-y-0.5"
          >
            See It in Action Free Demo
          </Link>
        </div>
      </div>
    </section>
  );
}
