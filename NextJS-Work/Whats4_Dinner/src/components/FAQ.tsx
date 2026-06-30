"use client";

import { useState } from "react";

const categories = [
  {
    label: "General",
    iconSrc: "/general.svg",
    faqs: [
      {
        q: "What is What's 4 Dinner?",
        a: "What's 4 Dinner is a role-based restaurant deal management platform  available as a web admin panel and a mobile app. Restaurants create flash and weekly deals, customers discover and claim them via QR codes, and admins oversee the entire ecosystem.",
      },
      {
        q: "Who is the platform designed for?",
        a: "The platform serves three roles: Super Admins who manage the entire platform, Restaurant Admins (owners) who create and manage deals, and Customers who discover and redeem deals via the mobile app. Staff members can also be added with specific scan permissions.",
      },
      {
        q: "What countries is What's 4 Dinner available in?",
        a: "The platform is currently live in Australia and Germany, with English and German language support built into the mobile app.",
      },
    ],
  },
  {
    label: "Restaurants",
    iconSrc: "/restaurants.svg",
    faqs: [
      {
        q: "How do I list my restaurant on the platform?",
        a: "Register your restaurant account, complete your profile with name, location, cuisine type and images, then submit for review. A Super Admin will approve or reject your request  with a clear reason if rejected.",
      },
      {
        q: "What types of deals can I create?",
        a: "You can create Flash Deals  time-limited offers with redemption caps  or Weekly Deals that recur on selected days. You can edit, pause or end any deal at any time from your dashboard.",
      },
      {
        q: "Can I manage multiple restaurant branches?",
        a: "Yes. Multi-branch management lets you list and manage multiple locations from a single account, each with its own address, map coordinates and deal settings.",
      },
      {
        q: "How do I manage my staff?",
        a: "From your dashboard you can add, edit or remove staff members, assign them specific roles and grant or revoke QR scan access per person. Full permission control stays with the owner.",
      },
    ],
  },
  {
    label: "Deals & Redemption",
    iconSrc: "/create.svg",
    faqs: [
      {
        q: "How does QR code redemption work?",
        a: "When a customer claims a deal in the mobile app, a unique QR code is generated for that claim. The customer presents it in-venue and a staff member scans it to verify and complete the redemption. Every scan is logged with a timestamp.",
      },
      {
        q: "Can I see who has redeemed my deals?",
        a: "Yes. The Redemption Tracking dashboard shows a full scan history  filterable by date, deal or restaurant. You can also export redemption records to Excel.",
      },
      {
        q: "What happens if a customer tries to redeem the same deal twice?",
        a: "Each QR code is unique and single-use. Once scanned and redeemed, it cannot be used again. The system flags any duplicate scan attempt automatically.",
      },
    ],
  },
  {
    label: "Mobile App",
    iconSrc: "/mobile.svg",
    faqs: [
      {
        q: "What roles are available in the mobile app?",
        a: "The mobile app supports three roles: Owner (manage deals, branches, staff and analytics), Customer (discover deals, claim QR codes, rate restaurants) and Staff (scan QR codes to redeem customer deals in-venue).",
      },
      {
        q: "How does deal discovery work for customers?",
        a: "The app uses GPS to find deals near the customer's location. Smart filters let them search by cuisine type, restaurant rating or distance. Google Maps integration is included for directions.",
      },
      {
        q: "Is the app available in multiple languages?",
        a: "Yes. The app fully supports English and German, with dynamic language switching  users can change their language at any time from the app settings.",
      },
    ],
  },
];

function AccordionItem({ q, a }: { q: string; a: string }) {
  const [open, setOpen] = useState(false);

  return (
    <div className="border-b border-[#F3F4F6] last:border-0">
      <button
        onClick={() => setOpen((v) => !v)}
        className="w-full flex items-start justify-between gap-4 py-5 text-left group"
        aria-expanded={open}
      >
        <span
          className={`text-[14.5px] font-semibold leading-snug transition-colors duration-150 font-(family-name:--font-poppins) ${open ? "text-primary" : "text-primary-text group-hover:text-primary"}`}
        >
          {q}
        </span>
        <span
          className="shrink-0 w-6 h-6 rounded-full border flex items-center justify-center transition-all duration-200"
          style={
            open
              ? { backgroundColor: "#E63946", borderColor: "#E63946" }
              : { borderColor: "#E8E8E8" }
          }
          aria-hidden="true"
        >
          <svg
            width="11"
            height="11"
            viewBox="0 0 24 24"
            fill="none"
            className="transition-transform duration-200"
            style={{ transform: open ? "rotate(180deg)" : "rotate(0deg)" }}
          >
            <path
              d="M6 9l6 6 6-6"
              stroke={open ? "#fff" : "#9CA3AF"}
              strokeWidth="2.2"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </svg>
        </span>
      </button>
      {open && (
        <p className="text-[13.5px] text-slate-gray leading-relaxed pb-5 pr-10 font-(family-name:--font-inter)">
          {a}
        </p>
      )}
    </div>
  );
}

export default function FAQ() {
  const [activeCategory, setActiveCategory] = useState(0);

  return (
    <section
      id="faq"
      className="bg-white py-16 sm:py-20 lg:py-24 overflow-hidden"
    >
      <div className="max-w-screen-2xl mx-auto px-4 sm:px-6">
        {/* Header */}
        <div className="max-w-2xl mb-10 sm:mb-12 lg:mb-16">
          <span className="inline-flex items-center gap-2 bg-[#FFF0F1] text-primary border border-[#FFD6D9] text-[11px] font-bold px-3.5 py-1.5 rounded-full tracking-widest uppercase mb-5 font-(family-name:--font-inter)">
            <svg
              width="10"
              height="10"
              viewBox="0 0 24 24"
              fill="none"
              aria-hidden="true"
            >
              <path
                d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3M12 17h.01"
                stroke="#E63946"
                strokeWidth="2.5"
                strokeLinecap="round"
                strokeLinejoin="round"
              />
            </svg>
            FAQ
          </span>
          <h2 className="text-[26px] sm:text-[36px] lg:text-[48px] font-extrabold text-primary-text tracking-[-1px] leading-[1.1] font-(family-name:--font-poppins)">
            Questions? <span className="text-primary">We have answers.</span>
          </h2>
          <p className="mt-4 text-[15px] sm:text-[16px] text-slate-gray leading-relaxed font-(family-name:--font-inter)">
            Everything you need to know about What&apos;s 4 Dinner from listing
            your restaurant to redeeming your first deal.
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-[240px_1fr] gap-8 items-start">
          {/* Category sidebar */}
          <div className="flex flex-row lg:flex-col gap-2 overflow-x-auto lg:overflow-visible pb-2 lg:pb-0">
            {categories.map(({ label, iconSrc }, i) => (
              <button
                key={label}
                onClick={() => setActiveCategory(i)}
                className={`flex items-center gap-2.5 px-4 py-3 rounded-xl text-left whitespace-nowrap lg:whitespace-normal transition-all duration-150 shrink-0 border font-(family-name:--font-inter) ${
                  activeCategory === i
                    ? "bg-primary-text text-white border-primary-text"
                    : "bg-white text-slate-gray border-[#E8E8E8] hover:border-[#D0D0D0]"
                }`}
              >
                <img
                  src={iconSrc}
                  width={18}
                  height={18}
                  alt=""
                  aria-hidden="true"
                  style={{
                    filter:
                      activeCategory === i
                        ? "brightness(0) invert(1)"
                        : "brightness(0) saturate(100%) invert(27%) sepia(99%) saturate(1500%) hue-rotate(338deg) brightness(104%) contrast(91%)",
                  }}
                />
                <span className="text-[13.5px] font-semibold">{label}</span>
                {activeCategory === i && (
                  <svg
                    width="13"
                    height="13"
                    viewBox="0 0 24 24"
                    fill="none"
                    className="ml-auto shrink-0"
                    aria-hidden="true"
                  >
                    <path
                      d="M9 18l6-6-6-6"
                      stroke="#fff"
                      strokeWidth="2.2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    />
                  </svg>
                )}
              </button>
            ))}

            {/* Still have questions */}
            <div className="hidden lg:block mt-4 rounded-2xl bg-soft-gray border border-[#E8E8E8] p-5">
              <p className="text-[13px] font-bold text-primary-text mb-1 font-(family-name:--font-poppins)">
                Still have questions?
              </p>
              <p className="text-[12.5px] text-slate-gray mb-4 leading-relaxed font-(family-name:--font-inter)">
                Our team is happy to walk you through anything.
              </p>
              <a
                href="#contact"
                className="inline-flex items-center gap-1.5 bg-primary hover:bg-primary-dark text-white text-[12px] font-bold px-4 py-2.5 rounded-full transition-colors duration-150"
              >
                Contact Us
                <svg
                  width="11"
                  height="11"
                  viewBox="0 0 24 24"
                  fill="none"
                  aria-hidden="true"
                >
                  <path
                    d="M5 12h14M13 6l6 6-6 6"
                    stroke="currentColor"
                    strokeWidth="2.2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                </svg>
              </a>
            </div>
          </div>

          {/* Accordion panel */}
          <div className="bg-white rounded-2xl border border-[#E8E8E8] px-4 sm:px-7 shadow-[0_2px_12px_rgba(0,0,0,0.04)]">
            <div className="flex items-center gap-3 py-6 border-b border-[#F3F4F6]">
              <img
                src={categories[activeCategory].iconSrc}
                width={22}
                height={22}
                alt=""
                aria-hidden="true"
                style={{
                  filter:
                    "brightness(0) saturate(100%) invert(27%) sepia(99%) saturate(1500%) hue-rotate(338deg) brightness(104%) contrast(91%)",
                }}
              />
              <h3 className="text-[17px] font-extrabold text-primary-text font-(family-name:--font-poppins)">
                {categories[activeCategory].label}
              </h3>
              <span className="ml-auto text-[11.5px] font-semibold text-slate-gray font-(family-name:--font-inter)">
                {categories[activeCategory].faqs.length} questions
              </span>
            </div>

            {categories[activeCategory].faqs.map(({ q, a }) => (
              <AccordionItem key={q} q={q} a={a} />
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
