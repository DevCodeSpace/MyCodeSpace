import Link from "next/link";
import {
  BarChart3,
  CheckCircle2,
  Package,
  Settings,
  Truck,
} from "lucide-react";

const steps = [
  {
    number: "01",
    icon: Settings,
    title: "Set Up Your Business",
    desc: "Add your parties, routes, truck details, and user accounts in minutes. The platform is ready from day one.",
    points: [
      "Party master setup",
      "User access control",
      "Route configuration",
    ],
  },
  {
    number: "02",
    icon: Truck,
    title: "Load & Dispatch Shipments",
    desc: "Create shipments, assign trucks, enter Taka & Bale details, and let the system auto-calculate freight instantly.",
    points: ["Shipment entry", "Auto freight calc", "Taka & Bale tracking"],
  },
  {
    number: "03",
    icon: Package,
    title: "Track Deliveries & Collect Payment",
    desc: "Monitor delivery status end-to-end  manage receipts, update consignees, and record payments in any mode.",
    points: [
      "Live delivery status",
      "Receipt management",
      "Cash / RTGS / Credit",
    ],
  },
  {
    number: "04",
    icon: BarChart3,
    title: "Report, Analyse & Grow",
    desc: "Generate commission, freight, and bill reports. Review stock levels and gain full financial visibility  anytime.",
    points: ["8+ report types", "Commission tracking", "Stock & inventory"],
  },
];

export default function HowItWorksSection() {
  return (
    <section
      id="how-it-works"
      className="bg-[#F0F8FF] py-20 lg:py-28 overflow-hidden"
      aria-labelledby="how-it-works-heading"
    >
      <div className="max-w-360 mx-auto px-4 sm:px-6 lg:px-10">
        {/* Header */}
        <div className="flex flex-col lg:flex-row lg:items-end lg:justify-between gap-6 mb-16">
          <div className="max-w-xl">
            <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-white border border-[#0C1B33]/10 mb-5">
              <span
                className="w-1.5 h-1.5 rounded-full bg-[#0C1B33]"
                aria-hidden="true"
              />
              <span className="text-[13px] font-semibold text-[#0C1B33]/60 tracking-widest uppercase">
                How It Works
              </span>
            </div>
            <h2
              id="how-it-works-heading"
              className="text-[42px] sm:text-[48px] font-bold text-[#0C1B33] leading-[1.1] tracking-tight"
            >
              Up and Running
              <br />
              in Four Simple Steps
            </h2>
          </div>
          <p className="text-[17px] text-[#0C1B33]/50 leading-relaxed max-w-sm lg:text-right">
            No lengthy onboarding. No complex setup. Your team starts managing
            real shipments from day one.
          </p>
        </div>

        {/* Steps  ordered list for semantic step-by-step structure */}
        <div className="relative">
          <div
            className="hidden lg:block absolute top-10 left-0 right-0 h-px"
            aria-hidden="true"
          >
            <div
              className="h-full mx-20"
              style={{
                background:
                  "linear-gradient(to right, transparent, #0C1B3320 15%, #0C1B3320 85%, transparent)",
                backgroundRepeat: "no-repeat",
                backgroundSize: "100% 1px",
                borderTop: "1px dashed #0C1B3325",
              }}
            />
          </div>

          <ol className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 list-none p-0 m-0">
            {steps.map(({ number, icon: Icon, title, desc, points }) => (
              <li key={number} className="group flex flex-col gap-5">
                {/* Step number + icon */}
                <div className="relative flex items-center gap-4 lg:flex-col lg:items-start lg:gap-3">
                  <div
                    className="w-20 h-20 rounded-2xl bg-white border border-[#0C1B33]/10 flex flex-col items-center justify-center shadow-sm group-hover:shadow-md group-hover:border-[#0C1B33]/20 transition-all duration-200 shrink-0"
                    aria-hidden="true"
                  >
                    <span className="text-[10px] font-bold text-[#0C1B33]/30 tracking-widest uppercase">
                      Step
                    </span>
                    <span className="text-[28px] font-bold text-[#0C1B33] leading-none">
                      {number}
                    </span>
                  </div>
                  <div
                    className="lg:hidden w-10 h-10 rounded-xl bg-[#0C1B33] flex items-center justify-center shrink-0"
                    aria-hidden="true"
                  >
                    <Icon className="w-5 h-5 text-white" />
                  </div>
                </div>

                <div
                  className="hidden lg:flex w-10 h-10 rounded-xl bg-[#0C1B33] items-center justify-center group-hover:scale-105 transition-transform duration-200"
                  aria-hidden="true"
                >
                  <Icon className="w-5 h-5 text-white" />
                </div>

                <div className="flex flex-col gap-3">
                  <h3 className="text-[17.5px] font-semibold text-[#0C1B33] leading-snug">
                    {title}
                  </h3>
                  <p className="text-[15px] text-[#0C1B33]/50 leading-relaxed">
                    {desc}
                  </p>
                  <ul
                    className="flex flex-col gap-1.5 mt-1"
                    aria-label={`${title} includes`}
                  >
                    {points.map((p) => (
                      <li key={p} className="flex items-center gap-2">
                        <CheckCircle2
                          className="w-3.5 h-3.5 text-[#0C1B33]/30 shrink-0"
                          aria-hidden="true"
                        />
                        <span className="text-[14px] text-[#0C1B33]/50 font-medium">
                          {p}
                        </span>
                      </li>
                    ))}
                  </ul>
                </div>
              </li>
            ))}
          </ol>
        </div>

        {/* Bottom CTA */}
        <div className="mt-16 flex flex-col sm:flex-row items-center justify-between gap-5 px-8 py-6 rounded-2xl bg-[#0C1B33]">
          <div>
            <p className="text-white font-semibold text-[17.5px]">
              Ready to streamline your transport operations?
            </p>
            <p className="text-white/40 text-[15px] mt-0.5">
              Get a personalised walkthrough of the full platform.
            </p>
          </div>
          <Link href="/#contact"
            aria-label="Book a free demo of TransportPro transport management software"
            className="shrink-0 inline-flex items-center gap-2 px-6 py-3 text-[15.5px] font-semibold text-[#0C1B33] bg-white rounded-xl hover:bg-[#F0F8FF] transition-all hover:-translate-y-0.5 hover:shadow-lg hover:shadow-black/20"
          >
            Book a Free Demo
          </Link>
        </div>
      </div>
    </section>
  );
}
