import { Globe, Mail, MapPin, MessageCircle, Phone, Truck } from "lucide-react";
import Link from "next/link";

const platformLinks = [
  { label: "Features & Modules", href: "/#features" },
  { label: "How It Works", href: "/#how-it-works" },
  { label: "Why TransportPro", href: "/#why" },
  { label: "Testimonials", href: "/#testimonials" },
  { label: "FAQ", href: "/#faq" },
  { label: "Request Demo", href: "/#contact" },
];

const moduleLinks = [
  { label: "Shipment Loading", href: "/#features" },
  { label: "Delivery Workflow", href: "/#features" },
  { label: "Freight Calculation", href: "/#features" },
  { label: "Taka & Bale Tracking", href: "/#features" },
  { label: "Financial Reports", href: "/#features" },
  { label: "Stock Dashboard", href: "/#features" },
];

const contactInfo = [
  { icon: MapPin, label: "Location", value: "Surat, Gujarat" },
  { icon: Mail, label: "Email", value: "moiz.codexlancers@gmail.com" },
  { icon: Phone, label: "Phone", value: "+91 7405545576" },
  { icon: MessageCircle, label: "WhatsApp", value: "Chat with us" },
  // { icon: Globe, label: "Website", value: "www.yourcompany.com" },
];

export default function Footer() {
  return (
    <footer className="bg-[#0C1B33]" aria-label="Site footer">
      <div
        className="h-px bg-linear-to-r from-transparent via-white/10 to-transparent"
        aria-hidden="true"
      />

      <div className="max-w-360 mx-auto px-4 sm:px-6 lg:px-10 pt-16 pb-10">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-[2fr_1fr_1fr_1.4fr] gap-10 lg:gap-8 mb-14">
          {/* Brand column */}
          <div className="flex flex-col gap-5">
            <Link
              href="/"
              aria-label="TransportPro  Transport Management Software homepage"
              className="flex items-center gap-3 group w-fit"
            >
              <div
                className="w-9 h-9 rounded-xl bg-white/10 border border-white/15 flex items-center justify-center group-hover:bg-white/15 transition-colors"
                aria-hidden="true"
              >
                <Truck className="w-5 h-5 text-white" />
              </div>
              <div className="flex flex-col leading-none">
                <span className="text-[18px] font-bold text-white tracking-tight">
                  TransportPro
                </span>
                <span className="text-[10px] font-medium text-white/30 tracking-widest uppercase mt-0.5">
                  Logistics Platform
                </span>
              </div>
            </Link>

            <p className="text-[15px] text-white/40 leading-relaxed max-w-64">
              Purpose-built transport management software covering every step
              from shipment loading to financial reporting.
            </p>

            <div
              className="inline-flex items-center gap-2 px-3.5 py-2 rounded-lg bg-white/5 border border-white/8 w-fit"
              role="status"
              aria-label="Platform status: All Systems Operational"
            >
              <span className="relative flex h-2 w-2" aria-hidden="true">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-50" />
                <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-400" />
              </span>
              <span className="text-[11.5px] font-semibold text-white/40">
                All Systems Operational
              </span>
            </div>

            {/* Stats */}
            <dl className="flex items-center gap-5 pt-1">
              <div>
                <dt className="text-[12.5px] text-white/30 font-medium mt-0.5">
                  Modules
                </dt>
                <dd className="text-[22px] font-bold text-white leading-none">
                  11+
                </dd>
              </div>
              <div className="w-px h-8 bg-white/8" aria-hidden="true" />
              <div>
                <dt className="text-[12.5px] text-white/30 font-medium mt-0.5">
                  Reports
                </dt>
                <dd className="text-[22px] font-bold text-white leading-none">
                  8+
                </dd>
              </div>
              <div className="w-px h-8 bg-white/8" aria-hidden="true" />
              <div>
                <dt className="text-[12.5px] text-white/30 font-medium mt-0.5">
                  Clients
                </dt>
                <dd className="text-[22px] font-bold text-white leading-none">
                  200+
                </dd>
              </div>
            </dl>
          </div>

          {/* Platform nav */}
          <nav aria-label="Platform navigation">
            <h3 className="text-[12px] font-bold uppercase tracking-widest text-white/25 mb-5">
              Platform
            </h3>
            <ul className="flex flex-col gap-3">
              {platformLinks.map((l) => (
                <li key={l.label}>
                  <Link
                    href={l.href}
                    className="text-[15px] text-white/40 hover:text-white/80 transition-colors font-medium"
                  >
                    {l.label}
                  </Link>
                </li>
              ))}
            </ul>
          </nav>

          {/* Modules nav */}
          <nav aria-label="Platform modules navigation">
            <h3 className="text-[12px] font-bold uppercase tracking-widest text-white/25 mb-5">
              Modules
            </h3>
            <ul className="flex flex-col gap-3">
              {moduleLinks.map((l) => (
                <li key={l.label}>
                  <Link
                    href={l.href}
                    className="text-[15px] text-white/40 hover:text-white/80 transition-colors font-medium"
                  >
                    {l.label}
                  </Link>
                </li>
              ))}
            </ul>
          </nav>

          {/* Contact info */}
          <div>
            <h3 className="text-[12px] font-bold uppercase tracking-widest text-white/25 mb-5">
              Contact
            </h3>
            <address className="not-italic">
              <ul className="flex flex-col gap-3.5">
                {contactInfo.map(({ icon: Icon, label, value }) => (
                  <li key={label} className="flex items-start gap-3">
                    <div
                      className="w-7 h-7 rounded-lg bg-white/6 border border-white/8 flex items-center justify-center shrink-0 mt-0.5"
                      aria-hidden="true"
                    >
                      <Icon className="w-3.5 h-3.5 text-white/35" />
                    </div>
                    <div>
                      <p className="text-[12px] text-white/25 font-semibold uppercase tracking-widest leading-none mb-0.5">
                        {label}
                      </p>
                      <p className="text-[14.5px] text-white/50 font-medium">
                        {value}
                      </p>
                    </div>
                  </li>
                ))}
              </ul>
            </address>
          </div>
        </div>

        {/* Bottom bar */}
        <div className="pt-7 border-t border-white/8 flex flex-col sm:flex-row items-center justify-between gap-4">
          <p className="text-[13.5px] text-white/20 font-medium">
            &copy; {new Date().getFullYear()} TransportPro. All rights reserved.
          </p>

          <nav
            aria-label="Legal navigation"
            className="flex items-center gap-5"
          >
            {[
              { label: "Privacy Policy", href: "/privacy-policy" },
              { label: "Terms of Use", href: "/terms-of-use" },
              { label: "Support", href: "/support" },
            ].map((item) => (
              <Link
                key={item.label}
                href={item.href}
                className="text-[13.5px] text-white/20 hover:text-white/45 transition-colors font-medium"
              >
                {item.label}
              </Link>
            ))}
          </nav>

          <p className="text-[13.5px] text-white/20 font-medium">
            Built for Transport &amp; Logistics Businesses
          </p>
        </div>
      </div>
    </footer>
  );
}
