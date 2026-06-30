import {
  ArrowRight,
  BarChart3,
  Calculator,
  ClipboardList,
  Database,
  FileText,
  Layers,
  Package,
  Printer,
  Receipt,
  Shield,
  Truck,
} from "lucide-react";
import Link from "next/link";

const features = [
  {
    icon: Truck,
    title: "Efficient Shipment Loading",
    desc: "High-speed loading interface to manage truck numbers, destination routes, and party assignments  built for speed at the dock.",
    tag: "Operations",
  },
  {
    icon: Package,
    title: "Professional Delivery Workflow",
    desc: "Structured delivery management to log consignee details, GST information, and receipting  no paperwork missed.",
    tag: "Delivery",
  },
  {
    icon: BarChart3,
    title: "Operational Analytics Dashboard",
    desc: "Visual summary of your business  active parties, package delivery performance, and real-time inventory status at a glance.",
    tag: "Analytics",
  },
  {
    icon: FileText,
    title: "Financial Integrity Reports",
    desc: "Detailed commission, freight, and bill reports that give clear visibility into revenue streams and outstanding amounts.",
    tag: "Finance",
  },
  {
    icon: Shield,
    title: "Master Administrative Control",
    desc: "Centralized admin panel to manage user accounts, party masters, data accuracy, and system-wide access control.",
    tag: "Admin",
  },
  {
    icon: Printer,
    title: "Standalone Print Engine",
    desc: "Dedicated printing module that generates transport receipts and reports with high-fidelity, localized print support.",
    tag: "Print",
  },
  {
    icon: Receipt,
    title: "Taka & Bale Management",
    desc: "Specialized textile shipment tracking  log Taka counts and Bale numbers per invoice, designed for textile-specific operations.",
    tag: "Textile",
  },
  {
    icon: Calculator,
    title: "Loading & Freight Calculation",
    desc: "Centralized truck loading system that auto-calculates base freight and generates party-wise invoices instantly.",
    tag: "Billing",
  },
  {
    icon: Layers,
    title: "Unified Delivery Interface",
    desc: "End-to-end delivery tracking with receipt numbers, tempo details, and full payment support  Cash, Cheque, RTGS, and Credit.",
    tag: "Delivery",
  },
  {
    icon: ClipboardList,
    title: "Logistics-Specific Reports",
    desc: "8+ purpose-built reports covering Pending Delivery, Invoice, Freight, Commission  with advanced Taka summation logic.",
    tag: "Reports",
  },
  {
    icon: Database,
    title: "Real-time Stock Dashboard",
    desc: "Live warehouse and stock insights  total parties, current stock levels, and package transit trends updated in real time.",
    tag: "Stock",
  },
];

export default function FeaturesSection() {
  return (
    <section
      id="features"
      className="bg-white py-20 lg:py-28"
      aria-labelledby="features-heading"
    >
      <div className="max-w-360 mx-auto px-4 sm:px-6 lg:px-10">
        {/* Section Header */}
        <div className="max-w-2xl mb-14">
          <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-[#F0F8FF] border border-[#0C1B33]/10 mb-5">
            <span
              className="w-1.5 h-1.5 rounded-full bg-[#0C1B33]"
              aria-hidden="true"
            />
            <span className="text-[13px] font-semibold text-[#0C1B33]/60 tracking-widest uppercase">
              Platform Modules
            </span>
          </div>
          <h2
            id="features-heading"
            className="text-[42px] sm:text-[48px] font-bold text-[#0C1B33] leading-[1.1] tracking-tight mb-4"
          >
            Everything Your Transport
            <br />
            Business Needs
          </h2>
          <p className="text-[17.5px] text-[#0C1B33]/50 leading-relaxed">
            11 powerful modules working together from loading docks to financial
            statements, every operation covered in one transport management
            platform.
          </p>
        </div>

        {/* Feature Cards Grid */}
        <ul className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 list-none p-0 m-0">
          {features.map(({ icon: Icon, title, desc, tag }) => (
            <li key={title}>
              <article className="group relative flex flex-col gap-4 p-6 rounded-2xl bg-white border border-[#0C1B33]/8 hover:border-[#0C1B33]/20 hover:shadow-lg hover:shadow-[#0C1B33]/5 transition-all duration-200 hover:-translate-y-0.5 h-full">
                <span
                  className="absolute top-5 right-5 text-[12px] font-semibold text-[#0C1B33]/25 tracking-widest uppercase"
                  aria-label={`Category: ${tag}`}
                >
                  {tag}
                </span>
                <div
                  className="w-11 h-11 rounded-xl bg-[#F0F8FF] border border-[#0C1B33]/6 flex items-center justify-center shrink-0 group-hover:bg-[#0C1B33] transition-colors duration-200"
                  aria-hidden="true"
                >
                  <Icon className="w-5 h-5 text-[#0C1B33] group-hover:text-white transition-colors duration-200" />
                </div>
                <div className="flex flex-col gap-1.5">
                  <h3 className="text-[16.5px] font-semibold text-[#0C1B33] leading-snug">
                    {title}
                  </h3>
                  <p className="text-[15px] text-[#0C1B33]/50 leading-relaxed">
                    {desc}
                  </p>
                </div>
              </article>
            </li>
          ))}

          {/* CTA card */}
          <li>
            <div className="group relative flex flex-col justify-between gap-6 p-6 rounded-2xl bg-[#0C1B33] transition-all duration-200 hover:-translate-y-0.5 hover:shadow-xl hover:shadow-[#0C1B33]/30 h-full">
              <div>
                <div
                  className="w-11 h-11 rounded-xl bg-white/10 border border-white/15 flex items-center justify-center mb-4"
                  aria-hidden="true"
                >
                  <ArrowRight className="w-5 h-5 text-white" />
                </div>
                <h3 className="text-[16.5px] font-semibold text-white leading-snug mb-2">
                  Need a Custom Workflow?
                </h3>
                <p className="text-[15px] text-white/45 leading-relaxed">
                  Talk to us about your specific logistics process we tailor the
                  platform to fit your operations exactly.
                </p>
              </div>
              <Link
                href="/#contact"
                aria-label="Contact us about a custom transport workflow"
                className="inline-flex items-center gap-2 text-[15px] font-semibold text-white/70 hover:text-white transition-all group-hover:gap-3"
              >
                Get in Touch
                <ArrowRight
                  className="w-4 h-4 transition-transform group-hover:translate-x-1"
                  aria-hidden="true"
                />
              </Link>
            </div>
          </li>
        </ul>
      </div>
    </section>
  );
}
