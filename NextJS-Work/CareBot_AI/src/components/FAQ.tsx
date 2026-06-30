"use client";

import { useState } from "react";

const categories = [
  {
    label: "General",
    icon: (
      <img
        src="/general.svg"
        width={21}
        height={21}
        alt=""
        aria-hidden="true"
      />
    ),
    faqs: [
      {
        q: "What is CareBot AI?",
        a: "CareBot AI is an AI-powered healthcare appointment platform. You describe your symptoms in plain language, and the AI instantly matches you with the right specialist, shows live available slots, and confirms your booking  all inside a simple chat interface.",
      },
      {
        q: "Do I need to create an account to book an appointment?",
        a: "No account is required. You can book appointments as a guest by providing your name, age, and contact number directly in the chat. Your session data is not stored beyond the booking confirmation.",
      },
      {
        q: "Is CareBot AI available 24/7?",
        a: "Yes. CareBot AI is always on. You can describe symptoms, browse specialists, and confirm appointments at any hour  no waiting for office hours.",
      },
    ],
  },
  {
    label: "Booking",
    icon: (
      <img
        src="/bookings.svg"
        width={21}
        height={21}
        alt=""
        aria-hidden="true"
      />
    ),
    faqs: [
      {
        q: "How does the AI match me to the right doctor?",
        a: "Our NLP engine analyses your symptom description and maps it to the most relevant medical specialties. It then pulls a real-time list of available doctors in that specialty near you, ranked by availability and proximity.",
      },
      {
        q: "What if the slot I want is already taken?",
        a: "CareBot AI checks slot availability in real time before you confirm. If a slot is taken between your selection and confirmation, you are automatically redirected to choose another  eliminating double-bookings entirely.",
      },
      {
        q: "Can I book for someone else, like a family member?",
        a: "Yes. When filling in patient details, simply enter the family member's name, age, and contact number. The booking is made in their name and the confirmation summary reflects their details.",
      },
      {
        q: "How long does the entire booking process take?",
        a: "Most users complete a booking in under 60 seconds. The chat guides you step by step  symptom input, specialty match, slot selection, and patient details  with no unnecessary screens or redirects.",
      },
    ],
  },
  {
    label: "Privacy & Security",
    icon: (
      <img
        src="/patient.svg"
        width={21}
        height={21}
        alt=""
        aria-hidden="true"
      />
    ),
    faqs: [
      {
        q: "Is my health information safe?",
        a: "Yes. Patient details are validated locally and used only to complete your booking. We do not store health data beyond your active session, and all communication is encrypted in transit.",
      },
      {
        q: "Does CareBot AI sell my data to third parties?",
        a: "Never. Your information is used solely to facilitate your appointment. We do not share, sell, or monetise any personal or health data.",
      },
    ],
  },
  {
    label: "After Booking",
    icon: (
      <img
        src="/booking.svg"
        width={21}
        height={21}
        alt=""
        aria-hidden="true"
      />
    ),
    faqs: [
      {
        q: "What do I receive after booking is confirmed?",
        a: "You get a full appointment summary inside the chat  doctor name, hospital, address, appointment time, consultation fee, and your patient details. You can copy it to clipboard with one tap or download it as a PDF.",
      },
      {
        q: "Can I get directions to the hospital from the app?",
        a: "Yes. The post-booking summary includes a directions link that opens the hospital location directly in your preferred maps app.",
      },
      {
        q: "What if I need to cancel or reschedule?",
        a: "Cancellation and rescheduling options are shown in the post-booking actions panel. You can initiate a new booking flow at any time, and our team is available to assist with cancellations via the contact page.",
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
        <span className="text-[15px] font-semibold text-[#0D1B4B] leading-snug group-hover:text-[#003DF5] transition-colors duration-150">
          {q}
        </span>
        <span
          className="shrink-0 w-6 h-6 rounded-full border border-[#E8EDF5] flex items-center justify-center transition-all duration-200"
          style={
            open ? { backgroundColor: "#003DF5", borderColor: "#003DF5" } : {}
          }
          aria-hidden="true"
        >
          <svg
            width="12"
            height="12"
            viewBox="0 0 24 24"
            fill="none"
            className="transition-transform duration-200"
            style={{ transform: open ? "rotate(180deg)" : "rotate(0deg)" }}
          >
            <path
              d="M6 9l6 6 6-6"
              stroke={open ? "#fff" : "#6B7280"}
              strokeWidth="2.2"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </svg>
        </span>
      </button>
      {open && (
        <p className="text-[14px] text-[#6B7280] leading-relaxed pb-5 pr-4 sm:pr-10">
          {a}
        </p>
      )}
    </div>
  );
}

export default function FAQ() {
  const [activeCategory, setActiveCategory] = useState(0);

  return (
    <section id="faq" className="bg-[#F6F6F7] py-16 lg:py-24 overflow-hidden">
      <div className="max-w-screen-2xl mx-auto px-4 sm:px-6">
        {/* Section header */}
        <div className="text-center mb-10 lg:mb-16">
          <span className="inline-flex items-center gap-2 bg-[#EEF2FF] text-[#003DF5] text-[11px] font-bold px-4 py-2 rounded-full tracking-widest uppercase mb-5">
            {/* <svg
              width="12"
              height="12"
              viewBox="0 0 24 24"
              fill="none"
              aria-hidden="true"
            >
              <path
                d="M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2 2 6.477 2 12s4.477 10 10 10z"
                fill="#003DF5"
                opacity="0.15"
              />
              <path
                d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3M12 17h.01"
                stroke="#003DF5"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
              />
            </svg> */}
            FAQ
          </span>
          <h2 className="text-[26px] sm:text-[34px] lg:text-[48px] font-extrabold text-[#0D1B4B] tracking-[-0.5px] sm:tracking-[-1px] leading-[1.1]">
            Questions? <span className="text-[#003DF5]">We Have Answers.</span>
          </h2>
          <p className="mt-4 text-[16px] text-[#6B7280] max-w-135 mx-auto leading-relaxed">
            Everything you need to know about booking with CareBot AI from your
            first symptom to your confirmed appointment.
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-[260px_1fr] gap-8 items-start">
          {/* Category sidebar */}
          <div className="flex flex-row lg:flex-col gap-2 overflow-x-auto lg:overflow-visible pb-2 lg:pb-0">
            {categories.map(({ label, icon }, i) => (
              <button
                key={label}
                onClick={() => setActiveCategory(i)}
                className="flex items-center gap-3 px-4 py-3 rounded-xl text-left whitespace-nowrap lg:whitespace-normal transition-all duration-150 shrink-0"
                style={
                  activeCategory === i
                    ? { backgroundColor: "#003DF5", color: "#fff" }
                    : {
                        backgroundColor: "#fff",
                        color: "#4B5563",
                        border: "1px solid #E8EDF5",
                      }
                }
              >
                <span
                  className="text-[18px]"
                  style={activeCategory === i ? { filter: "brightness(0) invert(1)" } : {}}
                >
                  {icon}
                </span>
                <span className="text-[14px] font-semibold">{label}</span>
                {activeCategory === i && (
                  <svg
                    width="14"
                    height="14"
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
            <div className="hidden lg:block mt-4 rounded-2xl bg-white border border-[#E8EDF5] p-5 shadow-[0_2px_12px_rgba(0,0,0,0.05)]">
              <p className="text-[13px] font-bold text-[#0D1B4B] mb-1">
                Still have questions?
              </p>
              <p className="text-[12.5px] text-[#6B7280] mb-4 leading-relaxed">
                Our team is happy to walk you through anything.
              </p>
              <a
                href="#contact"
                className="inline-flex items-center gap-1.5 bg-[#003DF5] hover:bg-[#0030CC] text-white text-[12px] font-bold px-4 py-2.5 rounded-full transition-colors duration-200"
              >
                Contact Us
                <svg
                  width="12"
                  height="12"
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
          <div className="bg-white rounded-2xl border border-[#E8EDF5] px-4 sm:px-7 shadow-[0_2px_12px_rgba(0,0,0,0.05)]">
            {/* Category heading */}
            <div className="flex items-center gap-3 py-6 border-b border-[#F3F4F6]">
              <span className="text-[24px]">
                {categories[activeCategory].icon}
              </span>
              <h3 className="text-[18px] font-extrabold text-[#0D1B4B]">
                {categories[activeCategory].label}
              </h3>
              <span className="ml-auto text-[12px] font-semibold text-[#9CA3AF]">
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
