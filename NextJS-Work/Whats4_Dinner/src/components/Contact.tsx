"use client";

import Image from "next/image";
import Link from "next/link";
import { useState } from "react";

const contactReasons = [
  "Request a Demo",
  "Restaurant Onboarding",
  "Partnership Inquiry",
  "Technical Support",
  "General Question",
];

const trustBadges = [
  {
    icon: (
      <svg
        width="16"
        height="16"
        viewBox="0 0 24 24"
        fill="none"
        aria-hidden="true"
      >
        <path
          d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"
          stroke="#7CB47A"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </svg>
    ),
    text: "Your data is never shared or sold",
  },
  {
    icon: (
      <svg
        width="16"
        height="16"
        viewBox="0 0 24 24"
        fill="none"
        aria-hidden="true"
      >
        <circle cx="12" cy="12" r="10" stroke="#E63946" strokeWidth="2" />
        <polyline
          points="12 6 12 12 16 14"
          stroke="#E63946"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </svg>
    ),
    text: "We respond within 24 hours",
  },
  {
    icon: (
      <svg
        width="16"
        height="16"
        viewBox="0 0 24 24"
        fill="none"
        aria-hidden="true"
      >
        <path
          d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"
          stroke="#F5A623"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
        <polyline
          points="9 22 9 12 15 12 15 22"
          stroke="#F5A623"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </svg>
    ),
    text: "Trusted by 120+ restaurants",
  },
];

export default function Contact() {
  const [form, setForm] = useState({
    name: "",
    email: "",
    phone: "",
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
    <section
      id="contact"
      className="bg-soft-gray py-16 sm:py-20 lg:py-24 overflow-hidden"
    >
      <div className="max-w-screen-2xl mx-auto px-4 sm:px-6">
        {/* Header */}
        <div className="max-w-2xl mb-10 sm:mb-12 lg:mb-16">
          <span className="inline-flex items-center gap-2 bg-[#FFF0F1] text-primary border border-[#FFD6D9] text-[11px] font-bold px-3.5 py-1.5 rounded-full tracking-widest uppercase mb-5 font-(family-name:--font-inter)">
            {/* <svg width="10" height="10" viewBox="0 0 24 24" fill="none" aria-hidden="true">
              <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" fill="#E63946" />
            </svg> */}
            Get in Touch
          </span>
          <h2 className="text-[26px] sm:text-[36px] lg:text-[48px] font-extrabold text-primary-text tracking-[-1px] leading-[1.1] font-(family-name:--font-poppins)">
            Ready to bring your{" "}
            <span className="text-primary">restaurant on board?</span>
          </h2>
          <p className="mt-4 text-[15px] sm:text-[16px] text-slate-gray leading-relaxed font-(family-name:--font-inter)">
            Whether you want a live demo, a partnership or just have a question
            we&apos;d love to hear from you.
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-[1fr_460px] gap-10 items-start">
          {/* Left  info */}
          <div className="flex flex-col gap-6">
            {/* CTA card */}
            <div className="relative rounded-2xl overflow-hidden p-5 sm:p-8 bg-primary-text text-white">
              <div
                aria-hidden="true"
                className="absolute -top-10 -right-10 w-48 h-48 rounded-full bg-white/5"
              />
              <div
                aria-hidden="true"
                className="absolute -bottom-8 -left-8 w-36 h-36 rounded-full bg-white/5"
              />

              <div className="relative z-10">
                <div className="w-12 h-12 rounded-2xl bg-white flex items-center justify-center  shrink-0 overflow-hidden p-2">
                  <Image
                    src="/logo.svg"
                    alt="What's 4 Dinner"
                    width={32}
                    height={32}
                    className="object-contain w-full h-full"
                  />
                </div>
                <h3 className="text-[20px] font-extrabold leading-snug mb-3 font-(family-name:--font-poppins)">
                  See What&apos;s 4 Dinner in action
                </h3>
                <p className="text-[14px] leading-relaxed text-white/70 mb-6 font-(family-name:--font-inter)">
                  Book a personalised demo and see how restaurants create deals,
                  track redemptions and manage staff all in one place.
                </p>
                <ul className="flex flex-col gap-2.5">
                  {[
                    "Live walkthrough with your team",
                    "Custom restaurant onboarding plan",
                    "No commitment required",
                  ].map((item) => (
                    <li
                      key={item}
                      className="flex items-center gap-2.5 text-[13.5px] text-white/80 font-(family-name:--font-inter)"
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
                          stroke="#7CB47A"
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

            {/* Trust badges */}
            <div className="flex flex-col gap-3">
              {trustBadges.map(({ icon, text }) => (
                <div
                  key={text}
                  className="flex items-center gap-3 bg-white rounded-xl border border-[#E8E8E8] px-5 py-3.5"
                >
                  <span className="shrink-0">{icon}</span>
                  <span className="text-[13.5px] font-medium text-primary-text font-(family-name:--font-inter)">
                    {text}
                  </span>
                </div>
              ))}
            </div>

            {/* Contact info */}
            <div className="flex flex-col gap-3 pl-1">
              {[
                { label: "Email", value: "support@whats4dinnerapp.com" },
                { label: "Response time", value: "Within 24 hours" },
              ].map(({ label, value }) => (
                <div key={label} className="flex items-center gap-2">
                  <span className="text-[12.5px] text-slate-gray font-medium font-(family-name:--font-inter)">
                    {label}:
                  </span>
                  <span className="text-[13px] font-semibold text-primary-text font-(family-name:--font-inter)">
                    {value}
                  </span>
                </div>
              ))}
            </div>
          </div>

          {/* Right  form */}
          <div className="bg-white rounded-2xl border border-[#E8E8E8] shadow-[0_2px_24px_rgba(0,0,0,0.06)] p-5 sm:p-8">
            {submitted ? (
              <div className="flex flex-col items-center justify-center text-center py-12 gap-5">
                <div className="w-16 h-16 rounded-full bg-[#F0FAF0] border border-[#C6E9C5] flex items-center justify-center text-[32px]">
                  ✅
                </div>
                <div>
                  <h3 className="text-[20px] font-extrabold text-primary-text mb-2 font-(family-name:--font-poppins)">
                    Message Sent!
                  </h3>
                  <p className="text-[14px] text-slate-gray leading-relaxed font-(family-name:--font-inter)">
                    Thanks,{" "}
                    <span className="font-semibold text-primary-text">
                      {form.name}
                    </span>
                    . We&apos;ll get back to you at{" "}
                    <span className="font-semibold text-primary-text">
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
                      phone: "",
                      reason: contactReasons[0],
                      message: "",
                    });
                  }}
                  className="text-[13px] font-semibold text-primary hover:underline font-(family-name:--font-inter)"
                >
                  Send another message
                </button>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="flex flex-col gap-5">
                <div>
                  <h3 className="text-[17px] font-extrabold text-primary-text mb-1 font-(family-name:--font-poppins)">
                    Send us a message
                  </h3>
                  <p className="text-[13px] text-slate-gray font-(family-name:--font-inter)">
                    Fill in the form and we&apos;ll be in touch shortly.
                  </p>
                </div>

                {/* Name */}
                <div className="flex flex-col gap-1.5">
                  <label
                    htmlFor="name"
                    className="text-[13px] font-semibold text-primary-text font-(family-name:--font-inter)"
                  >
                    Full Name <span className="text-primary">*</span>
                  </label>
                  <input
                    id="name"
                    name="name"
                    type="text"
                    required
                    placeholder="Enter your name"
                    value={form.name}
                    onChange={handleChange}
                    className="w-full rounded-xl border border-[#E8E8E8] bg-soft-gray px-4 py-3 text-[14px] text-primary-text placeholder:text-[#C4CAD4] outline-none focus:border-primary focus:ring-2 focus:ring-primary/10 transition-all duration-150 font-(family-name:--font-inter)"
                  />
                </div>

                {/* Email + Phone */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div className="flex flex-col gap-1.5">
                    <label
                      htmlFor="email"
                      className="text-[13px] font-semibold text-primary-text font-(family-name:--font-inter)"
                    >
                      Email <span className="text-primary">*</span>
                    </label>
                    <input
                      id="email"
                      name="email"
                      type="email"
                      required
                      placeholder="Enter your email address"
                      value={form.email}
                      onChange={handleChange}
                      className="w-full rounded-xl border border-[#E8E8E8] bg-soft-gray px-4 py-3 text-[14px] text-primary-text placeholder:text-[#C4CAD4] outline-none focus:border-primary focus:ring-2 focus:ring-primary/10 transition-all duration-150 font-(family-name:--font-inter)"
                    />
                  </div>
                  <div className="flex flex-col gap-1.5">
                    <label
                      htmlFor="phone"
                      className="text-[13px] font-semibold text-primary-text font-(family-name:--font-inter)"
                    >
                      Phone
                    </label>
                    <input
                      id="phone"
                      name="phone"
                      type="tel"
                      placeholder="Enter your phone number"
                      value={form.phone}
                      onChange={handleChange}
                      className="w-full rounded-xl border border-[#E8E8E8] bg-soft-gray px-4 py-3 text-[14px] text-primary-text placeholder:text-[#C4CAD4] outline-none focus:border-primary focus:ring-2 focus:ring-primary/10 transition-all duration-150 font-(family-name:--font-inter)"
                    />
                  </div>
                </div>

                {/* Reason */}
                <div className="flex flex-col gap-1.5">
                  <label
                    htmlFor="reason"
                    className="text-[13px] font-semibold text-primary-text font-(family-name:--font-inter)"
                  >
                    How can we help? <span className="text-primary">*</span>
                  </label>
                  <select
                    id="reason"
                    name="reason"
                    required
                    value={form.reason}
                    onChange={handleChange}
                    className="w-full rounded-xl border border-[#E8E8E8] bg-soft-gray px-4 py-3 text-[14px] text-primary-text outline-none focus:border-primary focus:ring-2 focus:ring-primary/10 transition-all duration-150 appearance-none font-(family-name:--font-inter)"
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
                    className="text-[13px] font-semibold text-primary-text font-(family-name:--font-inter)"
                  >
                    Message <span className="text-primary">*</span>
                  </label>
                  <textarea
                    id="message"
                    name="message"
                    required
                    rows={4}
                    placeholder="Tell us about your restaurant or what you're looking for..."
                    value={form.message}
                    onChange={handleChange}
                    className="w-full rounded-xl border border-[#E8E8E8] bg-soft-gray px-4 py-3 text-[14px] text-primary-text placeholder:text-[#C4CAD4] outline-none focus:border-primary focus:ring-2 focus:ring-primary/10 transition-all duration-150 resize-none font-(family-name:--font-inter)"
                  />
                </div>

                {/* Submit */}
                <button
                  type="submit"
                  disabled={loading}
                  className="w-full flex items-center justify-center gap-2 bg-primary hover:bg-primary-dark disabled:opacity-70 text-white text-[15px] font-bold py-4 rounded-full transition-colors duration-150 shadow-[0_4px_20px_rgba(230,57,70,0.28)] font-(family-name:--font-poppins)"
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

                <p className="text-[12px] text-slate-gray text-center font-(family-name:--font-inter)">
                  By submitting, you agree to our{" "}
                  <Link
                    href="/privacy-policy"
                    className="text-primary hover:underline"
                  >
                    Privacy Policy
                  </Link>
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
