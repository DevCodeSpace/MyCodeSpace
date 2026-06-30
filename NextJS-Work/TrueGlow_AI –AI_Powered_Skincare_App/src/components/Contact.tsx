"use client";

import { useState } from "react";

const contactReasons = [
  "General Inquiry",
  "Technical Support",
  "Account & Billing",
  "Partnership Inquiry",
  "Feature Request",
  "Privacy & Data",
];

const trustItems = [
  {
    icon: (
      <img
        src="/secure.svg"
        width={18}
        height={18}
        alt=""
        aria-hidden="true"
        style={{
          filter:
            "brightness(0) saturate(100%) invert(57%) sepia(72%) saturate(503%) hue-rotate(93deg) brightness(94%) contrast(92%)",
        }}
      />
    ),
    accentBg: "#F0FDF4",
    title: "Your data stays private",
    desc: "We never share or sell your information.",
  },
  {
    icon: (
      <svg
        width="18"
        height="18"
        viewBox="0 0 24 24"
        fill="none"
        aria-hidden="true"
      >
        <circle cx="12" cy="12" r="10" stroke="#F4C95D" strokeWidth="1.8" />
        <path
          d="M12 6v6l4 2"
          stroke="#F4C95D"
          strokeWidth="1.8"
          strokeLinecap="round"
        />
      </svg>
    ),
    accentBg: "#FFFBEB",
    title: "We respond within 24 hours",
    desc: "Our support team is fast and friendly.",
  },
  {
    icon: (
      <svg
        width="18"
        height="18"
        viewBox="0 0 24 24"
        fill="none"
        aria-hidden="true"
      >
        <circle cx="12" cy="12" r="10" stroke="#98B8F8" strokeWidth="1.8" />
        <path
          d="M8 12l2.5 2.5L16 9"
          stroke="#98B8F8"
          strokeWidth="1.8"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </svg>
    ),
    accentBg: "#EFF6FF",
    title: "Trusted by 50K+ users",
    desc: "Join a growing community of glow-havers.",
  },
];

export default function Contact() {
  const [form, setForm] = useState({
    name: "",
    email: "",
    reason: contactReasons[0],
    message: "",
  });
  const [submitted, setSubmitted] = useState(false);
  const [loading, setLoading] = useState(false);

  function handleChange(
    e: React.ChangeEvent<
      HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement
    >,
  ) {
    setForm((prev) => ({ ...prev, [e.target.name]: e.target.value }));
  }

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setTimeout(() => {
      setLoading(false);
      setSubmitted(true);
    }, 1200);
  }

  return (
    <section id="contact" className="bg-white py-16 lg:py-24 overflow-hidden">
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
            Get In Touch
          </span>
          <h2 className="text-[26px] sm:text-[32px] lg:text-[48px] font-extrabold text-[#0F172A] tracking-[-1px] leading-[1.1] font-(family-name:--font-noto)">
            Have a question?{" "}
            <span className="text-[#F4C95D]">We&apos;d love to help.</span>
          </h2>
          <p className="mt-4 text-[16px] text-sub-text-dark leading-relaxed font-(family-name:--font-noto)">
            Whether it&apos;s about your skin analysis, account, partnerships or
            anything else we&apos;re here for you.
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-[1fr_480px] gap-10 items-start">
          {/* ── Left  info ── */}
          <div className="flex flex-col gap-6">
            {/* Dark CTA card */}
            <div className="relative rounded-2xl overflow-hidden p-8 bg-[#0F172A] text-white">
              <div
                aria-hidden="true"
                className="absolute -top-16 -right-16 w-48 h-48 rounded-full border border-white/5"
              />
              <div
                aria-hidden="true"
                className="absolute -bottom-10 -left-10 w-36 h-36 rounded-full border border-white/5"
              />
              <div className="relative z-10">
                <div className="w-12 h-12 rounded-xl bg-[#F4C95D] flex items-center justify-center mb-5">
                  <img
                    src="/ai-skin.svg"
                    width={34}
                    height={34}
                    alt=""
                    aria-hidden="true"
                  />
                </div>
                <h3 className="text-[20px] font-extrabold leading-snug mb-3 font-(family-name:--font-noto)">
                  Start your skin journey today
                </h3>
                <p className="text-[14px] leading-relaxed text-white/60 mb-6 font-(family-name:--font-noto)">
                  Download TrueGlow AI, scan your skin in seconds and get a
                  personalized routine built just for you no appointment needed.
                </p>
                <ul className="flex flex-col gap-2.5">
                  {[
                    "Free skin analysis on first scan",
                    "AI-powered personalized routine",
                    "No credit card required",
                  ].map((item) => (
                    <li
                      key={item}
                      className="flex items-center gap-2.5 text-[13.5px] text-white/70 font-(family-name:--font-noto)"
                    >
                      <svg
                        width="15"
                        height="15"
                        viewBox="0 0 24 24"
                        fill="none"
                        aria-hidden="true"
                        className="shrink-0"
                      >
                        <path
                          d="M20 6L9 17l-5-5"
                          stroke="#F4C95D"
                          strokeWidth="2.5"
                          strokeLinecap="round"
                          strokeLinejoin="round"
                        />
                      </svg>
                      {item}
                    </li>
                  ))}
                </ul>
              </div>
            </div>

            {/* Trust items */}
            <div className="flex flex-col gap-3">
              {trustItems.map(({ icon, accentBg, title, desc }) => (
                <div
                  key={title}
                  className="flex items-center gap-4 bg-[#F8FAFC] rounded-xl border border-border px-5 py-4"
                >
                  <div
                    className="w-9 h-9 rounded-lg flex items-center justify-center shrink-0"
                    style={{ backgroundColor: accentBg }}
                  >
                    {icon}
                  </div>
                  <div>
                    <p className="text-[13.5px] font-bold text-[#0F172A] font-(family-name:--font-noto)">
                      {title}
                    </p>
                    <p className="text-[12px] text-[#64748B] font-(family-name:--font-noto)">
                      {desc}
                    </p>
                  </div>
                </div>
              ))}
            </div>

            {/* Contact info */}
            <div className="flex flex-col gap-2 pl-1">
              {[
                { label: "Email", value: "hello@trueglowai.com" },
                { label: "Response time", value: "Within 24 hours" },
              ].map(({ label, value }) => (
                <div key={label} className="flex items-center gap-2">
                  <span className="text-[12.5px] text-sub-text-medium font-medium font-(family-name:--font-noto)">
                    {label}:
                  </span>
                  <span className="text-[13px] font-semibold text-[#0F172A] font-(family-name:--font-noto)">
                    {value}
                  </span>
                </div>
              ))}
            </div>
          </div>

          {/* ── Right  form ── */}
          <div className="bg-white rounded-2xl border border-border shadow-[0_2px_24px_rgba(15,23,42,0.06)] p-8">
            {submitted ? (
              <div className="flex flex-col items-center justify-center text-center py-12 gap-5">
                <div className="w-16 h-16 rounded-full bg-[#FFFBEB] border border-[#F4C95D]/30 flex items-center justify-center">
                  <svg
                    width="32"
                    height="32"
                    viewBox="0 0 24 24"
                    fill="none"
                    aria-hidden="true"
                  >
                    <path
                      d="M20 6L9 17l-5-5"
                      stroke="#F4C95D"
                      strokeWidth="2.5"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    />
                  </svg>
                </div>
                <div>
                  <h3 className="text-[20px] font-extrabold text-[#0F172A] mb-2 font-(family-name:--font-noto)">
                    Message Sent!
                  </h3>
                  <p className="text-[14px] text-sub-text-dark leading-relaxed font-(family-name:--font-noto)">
                    Thanks,{" "}
                    <span className="font-semibold text-[#0F172A]">
                      {form.name}
                    </span>
                    . We&apos;ll get back to you at{" "}
                    <span className="font-semibold text-[#0F172A]">
                      {form.email}
                    </span>{" "}
                    within 24 hours.
                  </p>
                </div>
                <button
                  onClick={() => {
                    setSubmitted(false);
                    setForm({
                      name: "",
                      email: "",
                      reason: contactReasons[0],
                      message: "",
                    });
                  }}
                  className="text-[13px] font-semibold text-[#F4C95D] hover:underline font-(family-name:--font-noto)"
                >
                  Send another message
                </button>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="flex flex-col gap-5">
                <div>
                  <h3 className="text-[17px] font-extrabold text-[#0F172A] mb-1 font-(family-name:--font-noto)">
                    Send us a message
                  </h3>
                  <p className="text-[13px] text-[#64748B] font-(family-name:--font-noto)">
                    Fill in the form and we&apos;ll be in touch shortly.
                  </p>
                </div>

                {/* Name */}
                <div className="flex flex-col gap-1.5">
                  <label
                    htmlFor="name"
                    className="text-[13px] font-semibold text-[#0F172A] font-(family-name:--font-noto)"
                  >
                    Full Name <span className="text-[#F4C95D]">*</span>
                  </label>
                  <input
                    id="name"
                    name="name"
                    type="text"
                    required
                    placeholder="Enter your full name"
                    value={form.name}
                    onChange={handleChange}
                    className="w-full rounded-xl border border-border bg-[#F8FAFC] px-4 py-3 text-[14px] text-[#0F172A] placeholder:text-sub-text-light outline-none focus:border-[#F4C95D] focus:ring-2 focus:ring-[#F4C95D]/10 transition-all duration-150 font-(family-name:--font-noto)"
                  />
                </div>

                {/* Email */}
                <div className="flex flex-col gap-1.5">
                  <label
                    htmlFor="email"
                    className="text-[13px] font-semibold text-[#0F172A] font-(family-name:--font-noto)"
                  >
                    Email <span className="text-[#F4C95D]">*</span>
                  </label>
                  <input
                    id="email"
                    name="email"
                    type="email"
                    required
                    placeholder="Enter your email address"
                    value={form.email}
                    onChange={handleChange}
                    className="w-full rounded-xl border border-border bg-[#F8FAFC] px-4 py-3 text-[14px] text-[#0F172A] placeholder:text-sub-text-light outline-none focus:border-[#F4C95D] focus:ring-2 focus:ring-[#F4C95D]/10 transition-all duration-150 font-(family-name:--font-noto)"
                  />
                </div>

                {/* Reason */}
                <div className="flex flex-col gap-1.5">
                  <label
                    htmlFor="reason"
                    className="text-[13px] font-semibold text-[#0F172A] font-(family-name:--font-noto)"
                  >
                    How can we help? <span className="text-[#F4C95D]">*</span>
                  </label>
                  <select
                    id="reason"
                    name="reason"
                    required
                    value={form.reason}
                    onChange={handleChange}
                    className="w-full rounded-xl border border-border bg-[#F8FAFC] px-4 py-3 text-[14px] text-[#0F172A] outline-none focus:border-[#F4C95D] focus:ring-2 focus:ring-[#F4C95D]/10 transition-all duration-150 appearance-none font-(family-name:--font-noto)"
                  >
                    {contactReasons.map((r) => (
                      <option key={r} value={r}>
                        {r}
                      </option>
                    ))}
                  </select>
                </div>

                {/* Message */}
                <div className="flex flex-col gap-1.5">
                  <label
                    htmlFor="message"
                    className="text-[13px] font-semibold text-[#0F172A] font-(family-name:--font-noto)"
                  >
                    Message <span className="text-[#F4C95D]">*</span>
                  </label>
                  <textarea
                    id="message"
                    name="message"
                    required
                    rows={4}
                    placeholder="Tell us how we can help..."
                    value={form.message}
                    onChange={handleChange}
                    className="w-full rounded-xl border border-border bg-[#F8FAFC] px-4 py-3 text-[14px] text-[#0F172A] placeholder:text-sub-text-light outline-none focus:border-[#F4C95D] focus:ring-2 focus:ring-[#F4C95D]/10 transition-all duration-150 resize-none font-(family-name:--font-noto)"
                  />
                </div>

                {/* Submit */}
                <button
                  type="submit"
                  disabled={loading}
                  className="w-full flex items-center justify-center gap-2 bg-[#0F172A] hover:bg-[#1e293b] disabled:opacity-70 text-white text-[15px] font-bold py-4 rounded-xl transition-colors duration-150 shadow-[0_4px_20px_rgba(15,23,42,0.18)] font-(family-name:--font-noto)"
                >
                  {loading ? (
                    <>
                      <svg
                        className="animate-spin"
                        width="18"
                        height="18"
                        viewBox="0 0 24 24"
                        fill="none"
                        aria-hidden="true"
                      >
                        <circle
                          cx="12"
                          cy="12"
                          r="10"
                          stroke="currentColor"
                          strokeWidth="3"
                          strokeOpacity="0.25"
                        />
                        <path
                          d="M12 2a10 10 0 0 1 10 10"
                          stroke="currentColor"
                          strokeWidth="3"
                          strokeLinecap="round"
                        />
                      </svg>
                      Sending…
                    </>
                  ) : (
                    <>
                      Send Message
                      <svg
                        width="15"
                        height="15"
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
                    </>
                  )}
                </button>

                <p className="text-[12px] text-sub-text-medium text-center font-(family-name:--font-noto)">
                  By submitting, you agree to our{" "}
                  <a href="#" className="text-[#F4C95D] hover:underline">
                    Privacy Policy
                  </a>
                  .
                </p>
              </form>
            )}
          </div>
        </div>
      </div>
    </section>
  );
}
