import {
  ArrowRight,
  Building,
  CheckCircle,
  Gift,
  GraduationCap,
  MessageCircle,
} from "lucide-react";
import Link from "next/link";

const benefits = [
  {
    Icon: Gift,
    title: "Free Demo  No Commitment",
    desc: "Full platform walkthrough, zero cost. No credit card required. Cancel anytime.",
  },
  {
    Icon: GraduationCap,
    title: "Free Onboarding & Training",
    desc: "Our team guides you step-by-step from setup to your first live shipment.",
  },
  {
    Icon: MessageCircle,
    title: "Dedicated Support",
    desc: "Reach us via call, WhatsApp, or email. Most issues resolved in under 2 hours.",
  },
  {
    Icon: Building,
    title: "Custom Fleet Plans",
    desc: "Running a large fleet? Talk to us for tailored pricing that fits your scale.",
  },
];

const checklist = [
  "Free demo  no credit card required",
  "Free onboarding & training session",
  "Ongoing support via WhatsApp & email",
  "No lock-in  cancel anytime",
];

export default function CTASection() {
  return (
    <section
      id="cta"
      className="py-24 bg-white overflow-hidden relative"
      aria-labelledby="cta-heading"
    >
      <div
        className="absolute -top-24 left-1/3 w-[500px] h-[500px] rounded-full bg-[#0C1B33]/4 blur-3xl pointer-events-none"
        aria-hidden="true"
      />

      <div className="max-w-360 mx-auto px-4 sm:px-6 lg:px-10">
        <div className="grid lg:grid-cols-2 gap-16 items-center">
          {/* Left  content */}
          <div>
            <div className="inline-flex items-center rounded-full overflow-hidden border border-[#0C1B33]/20 shadow-sm mb-6">
              <div className="flex items-center gap-1.5 px-3.5 py-2 bg-[#0C1B33]">
                <Gift className="w-3 h-3 text-white" aria-hidden="true" />
                <span className="text-[10.5px] font-bold text-white uppercase tracking-[0.12em]">
                  Get Started
                </span>
              </div>
              <div className="flex items-center px-3.5 py-2 bg-[#0C1B33]/8">
                <span className="text-[10.5px] font-bold text-[#0C1B33]/70 uppercase tracking-[0.12em]">
                  Free Demo Available
                </span>
              </div>
            </div>

            <h2
              id="cta-heading"
              className="text-4xl sm:text-[48px] font-bold text-[#0C1B33] leading-[1.1] tracking-tight mb-4"
            >
              Start Managing Your
              <br />
              Logistics For Free
            </h2>
            <p className="text-[#0C1B33]/50 text-[17px] leading-relaxed mb-8">
              Book a free demo of TransportPro and see how{" "}
              <strong className="text-[#0C1B33]/80">
                shipment loading, GST billing, and freight reports
              </strong>{" "}
              can be done in minutes not hours.
            </p>

            <ul className="space-y-2.5 mb-10" aria-label="What you get">
              {checklist.map((item) => (
                <li key={item} className="flex items-center gap-3">
                  <div
                    className="w-5 h-5 rounded-full bg-[#0C1B33] flex items-center justify-center shrink-0"
                    aria-hidden="true"
                  >
                    <CheckCircle className="w-3 h-3 text-white" />
                  </div>
                  <span className="text-[#0C1B33]/70 font-medium text-[15px]">
                    {item}
                  </span>
                </li>
              ))}
            </ul>

            <div className="flex flex-col sm:flex-row gap-4">
              <Link
                href="/#contact"
                aria-label="Book a free demo of TransportPro transport management software"
                className="group inline-flex items-center justify-center gap-2 px-7 py-4 text-[15px] font-semibold text-white bg-[#0C1B33] rounded-xl transition-all hover:bg-[#0C1B33]/90 hover:shadow-xl hover:shadow-[#0C1B33]/25 hover:-translate-y-0.5"
              >
                Book a Free Demo
                <ArrowRight
                  className="w-4 h-4 group-hover:translate-x-0.5 transition-transform"
                  aria-hidden="true"
                />
              </Link>
              <Link
                href="/#features"
                aria-label="Explore all TransportPro features and modules"
                className="inline-flex items-center justify-center gap-2 px-7 py-4 text-[15px] font-semibold text-[#0C1B33] rounded-xl border-2 border-[#0C1B33]/20 bg-white hover:border-[#0C1B33]/40 hover:bg-[#F0F8FF] transition-all"
              >
                Explore Features
              </Link>
            </div>
          </div>

          {/* Right  benefit cards */}
          <div className="grid grid-cols-2 gap-4">
            {benefits.map((b) => (
              <article
                key={b.title}
                className="group bg-white rounded-2xl border border-[#0C1B33]/8 shadow-sm hover:shadow-lg hover:border-[#0C1B33]/20 hover:-translate-y-0.5 transition-all duration-300 p-5 relative overflow-hidden"
              >
                <div
                  className="absolute top-0 left-0 right-0 h-0.5 bg-[#0C1B33] opacity-0 group-hover:opacity-100 transition-opacity duration-300"
                  aria-hidden="true"
                />
                <div
                  className="w-9 h-9 rounded-xl bg-[#0C1B33] flex items-center justify-center mb-3"
                  aria-hidden="true"
                >
                  <b.Icon className="w-4 h-4 text-white" />
                </div>
                <h3 className="text-[13px] font-bold text-[#0C1B33] mb-1">
                  {b.title}
                </h3>
                <p className="text-[#0C1B33]/45 text-xs leading-relaxed">
                  {b.desc}
                </p>
              </article>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
