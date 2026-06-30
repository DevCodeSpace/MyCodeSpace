"use client";

import { useState } from "react";

const FILTER_ACTIVE =
  "brightness(0) saturate(100%) invert(84%) sepia(45%) saturate(868%) hue-rotate(338deg) brightness(101%) contrast(92%)";
const FILTER_INACTIVE =
  "brightness(0) saturate(100%) invert(45%) sepia(6%) saturate(548%) hue-rotate(182deg) brightness(91%) contrast(86%)";

function CategoryIcon({ src, active }: { src: string; active: boolean }) {
  return (
    <img
      src={src}
      width={16}
      height={16}
      alt=""
      aria-hidden="true"
      style={{ filter: active ? FILTER_ACTIVE : FILTER_INACTIVE }}
    />
  );
}

const categories = [
  {
    label: "General",
    iconSrc: "/general.svg",
    faqs: [
      {
        q: "What is TrueGlow AI?",
        a: "TrueGlow AI is an AI-powered skincare app that analyzes your skin from photos, identifies concerns like tone, texture and acne, and delivers personalized skincare recommendations  all from your phone.",
      },
      {
        q: "Is TrueGlow AI free to use?",
        a: "TrueGlow AI offers a free tier with core scan features. Premium plans unlock unlimited scan history, advanced AI chat consultations and detailed progress tracking.",
      },
      {
        q: "How accurate is the AI skin analysis?",
        a: "Our AI achieves 98% accuracy on key skin concern detection, trained on millions of diverse skin samples. Results are meant to guide your skincare decisions  not replace professional medical advice.",
      },
    ],
  },
  {
    label: "AI Scan",
    iconSrc: "/ai-scan.svg",
    faqs: [
      {
        q: "What does the AI scan analyze?",
        a: "The scan detects skin tone, texture, dryness, oiliness, acne, pigmentation, dark circles, pores and overall skin health score  all from a single front-facing photo.",
      },
      {
        q: "What kind of photo works best?",
        a: "Use a clear, well-lit front-facing photo with no filters. Natural lighting gives the most accurate results. The app guides you through taking the ideal scan photo.",
      },
      {
        q: "Can I scan multiple times?",
        a: "Yes. Each scan is saved with a timestamp so you can track how your skin changes over time and measure the impact of your skincare routine.",
      },
    ],
  },
  {
    label: "AI Chat",
    iconSrc: "/chats.svg",
    faqs: [
      {
        q: "What can I ask the AI chat?",
        a: "Ask anything skincare-related  product recommendations, ingredient questions, routine building, concern-specific advice or general skincare tips. The AI tailors responses to your skin profile.",
      },
      {
        q: "Does the AI chat use my scan results?",
        a: "Yes. The AI chat is aware of your latest scan results and skin history, so its advice is always personalized to your specific skin type and concerns.",
      },
      {
        q: "Is text-to-speech available in the chat?",
        a: "Yes. All AI responses can be read aloud using the built-in text-to-speech feature, making TrueGlow AI fully accessible and hands-free.",
      },
    ],
  },
  {
    label: "Privacy & Auth",
    iconSrc: "/secure.svg",
    faqs: [
      {
        q: "How is my data protected?",
        a: "TrueGlow AI uses Firebase for secure authentication and encrypted data storage. Your photos and skin data are never shared with third parties or used for advertising.",
      },
      {
        q: "How do I reset my password?",
        a: "Tap 'Forgot Password' on the login screen and enter your email. You'll receive a secure reset link within minutes.",
      },
      {
        q: "Can I delete my account and data?",
        a: "Yes. You can delete your account and all associated scan data at any time from the Privacy Controls section in your profile settings.",
      },
    ],
  },
];

function AccordionItem({ q, a }: { q: string; a: string }) {
  const [open, setOpen] = useState(false);
  return (
    <div className="border-b border-[#F1F5F9] last:border-0">
      <button
        onClick={() => setOpen((v) => !v)}
        className="w-full flex items-start justify-between gap-4 py-5 text-left group"
        aria-expanded={open}
      >
        <span
          className={`text-[14.5px] font-semibold leading-snug transition-colors duration-150 font-(family-name:--font-noto) ${open ? "text-[#0F172A]" : "text-[#0F172A] group-hover:text-[#F4C95D]"}`}
        >
          {q}
        </span>
        <span
          className="shrink-0 w-6 h-6 rounded-full border flex items-center justify-center transition-all duration-200"
          style={
            open
              ? { backgroundColor: "#F4C95D", borderColor: "#F4C95D" }
              : { borderColor: "#E2E8F0" }
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
              stroke={open ? "#0F172A" : "#94A3B8"}
              strokeWidth="2.2"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </svg>
        </span>
      </button>
      {open && (
        <p className="text-[13.5px] text-[#475569] leading-relaxed pb-5 pr-10 font-(family-name:--font-noto)">
          {a}
        </p>
      )}
    </div>
  );
}

export default function FAQ() {
  const [activeCategory, setActiveCategory] = useState(0);

  return (
    <section id="faq" className="bg-[#F8FAFC] py-16 lg:py-24 overflow-hidden">
      <div className="max-w-screen-2xl mx-auto px-6">
        {/* ── Header ── */}
        <div className="max-w-2xl mb-10 lg:mb-16">
          <span className="inline-flex items-center gap-2 bg-[#0F172A] text-[#F4C95D] text-[11px] font-bold px-3.5 py-1.5 rounded-full tracking-widest uppercase mb-5 font-(family-name:--font-noto)">
            {/* <svg
              width="10"
              height="10"
              viewBox="0 0 24 24"
              fill="none"
              aria-hidden="true"
            >
              <circle cx="12" cy="12" r="10" fill="#F4C95D" opacity="0.2" />
              <circle cx="12" cy="12" r="4" fill="#F4C95D" />
            </svg> */}
            FAQ
          </span>
          <h2 className="text-[26px] sm:text-[32px] lg:text-[48px] font-extrabold text-[#0F172A] tracking-[-1px] leading-[1.1] font-(family-name:--font-noto)">
            Questions? <span className="text-[#F4C95D]">We have answers.</span>
          </h2>
          <p className="mt-4 text-[16px] text-[#475569] leading-relaxed font-(family-name:--font-noto)">
            Everything you need to know about TrueGlow AI from your first scan
            to privacy and security.
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-[220px_1fr] gap-8 items-start">
          {/* ── Category sidebar ── */}
          <div className="flex flex-row lg:flex-col gap-2 overflow-x-auto lg:overflow-visible pb-2 lg:pb-0">
            {categories.map(({ label, iconSrc }, i) => (
              <button
                key={label}
                onClick={() => setActiveCategory(i)}
                className={`flex items-center gap-2.5 px-4 py-3 rounded-xl text-left whitespace-nowrap lg:whitespace-normal transition-all duration-150 shrink-0 border font-(family-name:--font-noto) ${
                  activeCategory === i
                    ? "bg-[#0F172A] text-white border-[#0F172A]"
                    : "bg-white text-[#64748B] border-[#E2E8F0] hover:border-[#CBD5E1] hover:text-[#0F172A]"
                }`}
              >
                <CategoryIcon src={iconSrc} active={activeCategory === i} />
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
                      stroke="#F4C95D"
                      strokeWidth="2.2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    />
                  </svg>
                )}
              </button>
            ))}

            {/* Still have questions */}
            <div className="hidden lg:flex flex-col mt-4 rounded-2xl bg-[#0F172A] border border-[#0F172A] p-5 gap-3">
              <p className="text-[13px] font-bold text-white font-(family-name:--font-noto)">
                Still have questions?
              </p>
              <p className="text-[12.5px] text-white/50 leading-relaxed font-(family-name:--font-noto)">
                Our team is happy to help you with anything.
              </p>
              <a
                href="#contact"
                className="inline-flex items-center gap-1.5 bg-[#F4C95D] text-[#0F172A] text-[12px] font-bold px-4 py-2.5 rounded-lg hover:bg-[#e8b84b] transition-colors duration-150 font-(family-name:--font-noto)"
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

          {/* ── Accordion panel ── */}
          <div className="bg-white rounded-2xl border border-[#E2E8F0] px-7 shadow-[0_2px_12px_rgba(15,23,42,0.04)]">
            <div className="flex items-center gap-3 py-6 border-b border-[#F1F5F9]">
              <CategoryIcon src={categories[activeCategory].iconSrc} active />
              <h3 className="text-[17px] font-extrabold text-[#0F172A] font-(family-name:--font-noto)">
                {categories[activeCategory].label}
              </h3>
              <span className="ml-auto text-[11.5px] font-semibold text-[#94A3B8] font-(family-name:--font-noto)">
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
