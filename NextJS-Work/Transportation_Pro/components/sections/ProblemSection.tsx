"use client";
import { Minus, Plus } from "lucide-react";
import Link from "next/link";
import { useState } from "react";

const faqs = [
  {
    q: "How quickly can we get started on the platform?",
    a: "Most businesses are fully operational within a single day. You add your parties, routes, and user accounts  and your team can start entering shipments the same day. No lengthy IT setup or technical expertise required.",
  },
  {
    q: "Is the platform GST compliant?",
    a: "Yes, completely. Every invoice, freight bill, and financial report is GST-ready by default. The system auto-applies the correct tax structure so your billing is always compliant  no manual adjustments needed.",
  },
  {
    q: "Does it support Taka & Bale tracking for textile businesses?",
    a: "Absolutely. TransportPro is one of the very few platforms built with textile logistics in mind. You can log Taka counts and Bale numbers per invoice, with advanced Taka summation logic built into the reports.",
  },
  {
    q: "Can we manage multiple trucks, parties, and routes?",
    a: "Yes  there is no hard limit. The platform is designed to scale with your operations. You can add as many trucks, parties, destinations, and users as your business needs, all managed from the admin panel.",
  },
  {
    q: "What payment modes are supported for deliveries?",
    a: "The Unified Delivery Interface supports Cash, Cheque, RTGS, and Credit payments. Each mode is tracked and recorded separately so your accounts team always has accurate, reconciled records.",
  },
  {
    q: "Can I print receipts and reports directly from the platform?",
    a: "Yes. The Standalone Print Engine is built specifically for transport operations. It generates transport receipts, freight bills, and reports in high-fidelity print formats with localized layout support.",
  },
  {
    q: "What reports does the platform generate?",
    a: "The platform includes 8+ logistics-focused reports: Pending Delivery Report, Invoice Report, Freight Report, Commission Report, Bill Detail Report, Stock Report, Party-wise Reports, and Taka Summation Reports  all exportable.",
  },
  {
    q: "Is our business data secure?",
    a: "Yes. Data is stored securely with role-based access control. The admin can define exactly what each user can view or modify  ensuring sensitive financial and party data is only accessible to the right people.",
  },
  {
    q: "Do you offer support after we go live?",
    a: "Yes. Our team provides ongoing support after onboarding. You can reach us via WhatsApp, email, or phone. Most issues are resolved within 2 business hours.",
  },
  {
    q: "Can the platform be customised for our specific workflow?",
    a: "Yes. If your transport workflow has specific requirements not covered by the standard modules, reach out to us. We regularly adapt the platform to fit individual business operations.",
  },
];

export default function ProblemSection() {
  const [open, setOpen] = useState<number | null>(0);

  return (
    <section
      id="faq"
      className="bg-[#F0F8FF] py-20 lg:py-28"
      aria-labelledby="faq-heading"
    >
      <div className="max-w-360 mx-auto px-4 sm:px-6 lg:px-10">
        <div className="grid lg:grid-cols-[380px_1fr] gap-14 items-start">
          {/* Left  sticky header */}
          <div className="lg:sticky lg:top-32 flex flex-col gap-6">
            <div>
              <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-white border border-[#0C1B33]/10 mb-5">
                <span
                  className="w-1.5 h-1.5 rounded-full bg-[#0C1B33]"
                  aria-hidden="true"
                />
                <span className="text-[13px] font-semibold text-[#0C1B33]/60 tracking-widest uppercase">
                  FAQ
                </span>
              </div>
              <h2
                id="faq-heading"
                className="text-[42px] sm:text-[46px] font-bold text-[#0C1B33] leading-[1.1] tracking-tight mb-4"
              >
                Frequently Asked
                <br />
                Questions
              </h2>
              <p className="text-[16.5px] text-[#0C1B33]/50 leading-relaxed">
                Everything you need to know about TransportPro before getting
                started. Can&apos;t find your answer?
              </p>
            </div>

            {/* CTA card */}
            <div className="p-6 rounded-2xl bg-[#0C1B33] flex flex-col gap-4">
              <div
                className="w-10 h-10 rounded-xl bg-white/10 border border-white/15 flex items-center justify-center"
                aria-hidden="true"
              >
                <svg
                  className="w-5 h-5 text-white"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                >
                  <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
                </svg>
              </div>
              <div>
                <p className="text-white font-semibold text-[16.5px] mb-1">
                  Still have questions?
                </p>
                <p className="text-white/45 text-[14.5px] leading-relaxed">
                  Talk directly to our team we&apos;ll answer anything about the
                  transport management platform or your specific workflow.
                </p>
              </div>
              <Link
                href="/#contact"
                aria-label="Contact TransportPro support team"
                className="inline-flex items-center gap-2 text-[15px] font-semibold text-white/70 hover:text-white transition-colors"
              >
                Chat with us →
              </Link>
            </div>
          </div>

          {/* Right  accordion */}
          <div className="flex flex-col gap-2" role="list">
            {faqs.map(({ q, a }, i) => {
              const isOpen = open === i;
              const questionId = `faq-q-${i}`;
              const answerId = `faq-a-${i}`;
              return (
                <div
                  key={i}
                  role="listitem"
                  className={`rounded-2xl border transition-all duration-200 overflow-hidden ${
                    isOpen
                      ? "bg-white border-[#0C1B33]/15 shadow-md shadow-[#0C1B33]/5"
                      : "bg-white border-[#0C1B33]/8 hover:border-[#0C1B33]/15"
                  }`}
                >
                  <button
                    id={questionId}
                    aria-expanded={isOpen}
                    aria-controls={answerId}
                    className="w-full flex items-center justify-between gap-4 px-6 py-5 text-left"
                    onClick={() => setOpen(isOpen ? null : i)}
                  >
                    <span
                      className={`text-[16px] font-semibold leading-snug transition-colors ${isOpen ? "text-[#0C1B33]" : "text-[#0C1B33]/70"}`}
                    >
                      {q}
                    </span>
                    <div
                      className={`w-7 h-7 rounded-lg flex items-center justify-center shrink-0 transition-colors ${isOpen ? "bg-[#0C1B33] text-white" : "bg-[#0C1B33]/6 text-[#0C1B33]/50"}`}
                      aria-hidden="true"
                    >
                      {isOpen ? (
                        <Minus className="w-3.5 h-3.5" />
                      ) : (
                        <Plus className="w-3.5 h-3.5" />
                      )}
                    </div>
                  </button>

                  <div
                    id={answerId}
                    role="region"
                    aria-labelledby={questionId}
                    hidden={!isOpen}
                  >
                    {isOpen && (
                      <div className="px-6 pb-5">
                        <p className="text-[15px] text-[#0C1B33]/55 leading-relaxed border-t border-[#0C1B33]/6 pt-4">
                          {a}
                        </p>
                      </div>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </div>
    </section>
  );
}
