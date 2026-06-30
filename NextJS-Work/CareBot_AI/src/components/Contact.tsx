"use client";

import { useState } from "react";

const contactReasons = [
  "Request a Demo",
  "Partnership Inquiry",
  "Hospital Onboarding",
  "Technical Support",
  "General Question",
];

const trustBadges = [
  {
    icon: (
      <img
        src="/patient.svg"
        width={21}
        height={21}
        alt=""
        aria-hidden="true"
      />
    ),
    text: "Your data is never shared or sold",
  },
  {
    icon: (
      <img
        src="/respond.svg"
        width={21}
        height={21}
        alt=""
        aria-hidden="true"
      />
    ),
    text: "We respond within 24 hours",
  },
  {
    icon: (
      <img
        src="/booking.svg"
        width={21}
        height={21}
        alt=""
        aria-hidden="true"
      />
    ),
    text: "Trusted by 10,000+ patients",
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
    <section id="contact" className="bg-white py-16 lg:py-24 overflow-hidden">
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
                d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"
                fill="#003DF5"
                opacity="0.2"
                stroke="#003DF5"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
              />
            </svg> */}
            Get in Touch
          </span>
          <h2 className="text-[26px] sm:text-[34px] lg:text-[48px] font-extrabold text-[#0D1B4B] tracking-[-0.5px] sm:tracking-[-1px] leading-[1.1]">
            Ready to Transform{" "}
            <span className="text-[#003DF5]">Healthcare Booking?</span>
          </h2>
          <p className="mt-4 text-[16px] text-[#6B7280] max-w-135 mx-auto leading-relaxed">
            Whether you want a live demo, a hospital partnership, or just have a
            question we'd love to hear from you.
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-[1fr_440px] gap-8 lg:gap-10 items-start">
          {/* Left  info panel */}
          <div className="flex flex-col gap-8">
            {/* Big CTA card */}
            <div
              className="relative rounded-2xl overflow-hidden p-6 sm:p-8 text-white"
              style={{
                background: "linear-gradient(135deg, #003DF5 0%, #0096DE 100%)",
              }}
            >
              {/* Background decoration */}
              <div
                aria-hidden="true"
                className="absolute -top-10 -right-10 w-48 h-48 rounded-full opacity-10"
                style={{ background: "#fff" }}
              />
              <div
                aria-hidden="true"
                className="absolute -bottom-8 -left-8 w-36 h-36 rounded-full opacity-10"
                style={{ background: "#fff" }}
              />

              <span className="text-[40px] mb-4 block">🚀</span>
              <h3 className="text-[22px] font-extrabold leading-snug mb-3">
                See CareBot AI in Action
              </h3>
              <p className="text-[14px] leading-relaxed text-white/80 mb-6">
                Book a personalised demo and watch our AI match a patient to a
                specialist, pick a live slot, and confirm a booking all in under
                60 seconds.
              </p>
              <ul className="flex flex-col gap-2.5">
                {[
                  "Live walkthrough with your team",
                  "Custom hospital onboarding plan",
                  "No commitment required",
                ].map((item) => (
                  <li
                    key={item}
                    className="flex items-center gap-2.5 text-[13.5px] text-white/90"
                  >
                    <svg
                      width="16"
                      height="16"
                      viewBox="0 0 24 24"
                      fill="none"
                      aria-hidden="true"
                      className="shrink-0"
                    >
                      <path
                        d="M20 6L9 17l-5-5"
                        stroke="#fff"
                        strokeWidth="2.2"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                      />
                    </svg>
                    {item}
                  </li>
                ))}
              </ul>
            </div>

            {/* Trust badges */}
            <div className="flex flex-col gap-3">
              {trustBadges.map(({ icon, text }) => (
                <div
                  key={text}
                  className="flex items-center gap-3 bg-[#F8FAFF] rounded-xl border border-[#E8EDF5] px-5 py-3.5"
                >
                  <span className="text-[20px]">{icon}</span>
                  <span className="text-[13.5px] font-semibold text-[#374151]">
                    {text}
                  </span>
                </div>
              ))}
            </div>

            {/* Contact info */}
            <div className="flex flex-col gap-3">
              {[
                {
                  icon: (
                    <img
                      src="/email.svg"
                      width={19}
                      height={19}
                      alt=""
                      aria-hidden="true"
                    />
                  ),
                  label: "Email",
                  value: "hello@carebot.ai",
                },
                {
                  icon: (
                    <img
                      src="/phone.svg"
                      width={19}
                      height={19}
                      alt=""
                      aria-hidden="true"
                    />
                  ),
                  label: "Phone",
                  value: "+91 98765 43210",
                },
                {
                  icon: (
                    <img
                      src="/response.svg"
                      width={19}
                      height={19}
                      alt=""
                      aria-hidden="true"
                    />
                  ),
                  label: "Response time",
                  value: "Within 24 hours",
                },
              ].map(({ icon, label, value }) => (
                <div key={label} className="flex items-center gap-3">
                  <span className="text-[18px]">{icon}</span>
                  <span className="text-[13px] text-[#9CA3AF]">{label}:</span>
                  <span className="text-[13.5px] font-semibold text-[#0D1B4B]">
                    {value}
                  </span>
                </div>
              ))}
            </div>
          </div>

          {/* Right  form */}
          <div className="bg-white rounded-2xl border border-[#E8EDF5] shadow-[0_2px_24px_rgba(0,0,0,0.07)] p-5 sm:p-8">
            {submitted ? (
              <div className="flex flex-col items-center justify-center text-center py-12 gap-5">
                <div className="w-16 h-16 rounded-full bg-[#F0FDF4] flex items-center justify-center text-[32px]">
                  ✅
                </div>
                <div>
                  <h3 className="text-[20px] font-extrabold text-[#0D1B4B] mb-2">
                    Message Sent!
                  </h3>
                  <p className="text-[14px] text-[#6B7280] leading-relaxed">
                    Thanks,{" "}
                    <span className="font-semibold text-[#0D1B4B]">
                      {form.name}
                    </span>
                    . We'll get back to you at{" "}
                    <span className="font-semibold text-[#0D1B4B]">
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
                  className="text-[13px] font-semibold text-[#003DF5] hover:underline"
                >
                  Send another message
                </button>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="flex flex-col gap-5">
                <div>
                  <h3 className="text-[18px] font-extrabold text-[#0D1B4B] mb-1">
                    Send us a message
                  </h3>
                  <p className="text-[13px] text-[#9CA3AF]">
                    Fill in the form and we'll be in touch shortly.
                  </p>
                </div>

                {/* Name */}
                <div className="flex flex-col gap-1.5">
                  <label
                    htmlFor="name"
                    className="text-[13px] font-semibold text-[#374151]"
                  >
                    Full Name <span className="text-[#E11D48]">*</span>
                  </label>
                  <input
                    id="name"
                    name="name"
                    type="text"
                    required
                    placeholder="Priya Sharma"
                    value={form.name}
                    onChange={handleChange}
                    className="w-full rounded-xl border border-[#E8EDF5] bg-[#F9FAFB] px-4 py-3 text-[14px] text-[#0D1B4B] placeholder:text-[#C4CAD4] outline-none focus:border-[#003DF5] focus:ring-2 focus:ring-[#003DF5]/10 transition-all duration-150"
                  />
                </div>

                {/* Email + Phone */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div className="flex flex-col gap-1.5">
                    <label
                      htmlFor="email"
                      className="text-[13px] font-semibold text-[#374151]"
                    >
                      Email <span className="text-[#E11D48]">*</span>
                    </label>
                    <input
                      id="email"
                      name="email"
                      type="email"
                      required
                      placeholder="priya@example.com"
                      value={form.email}
                      onChange={handleChange}
                      className="w-full rounded-xl border border-[#E8EDF5] bg-[#F9FAFB] px-4 py-3 text-[14px] text-[#0D1B4B] placeholder:text-[#C4CAD4] outline-none focus:border-[#003DF5] focus:ring-2 focus:ring-[#003DF5]/10 transition-all duration-150"
                    />
                  </div>
                  <div className="flex flex-col gap-1.5">
                    <label
                      htmlFor="phone"
                      className="text-[13px] font-semibold text-[#374151]"
                    >
                      Phone
                    </label>
                    <input
                      id="phone"
                      name="phone"
                      type="tel"
                      placeholder="+91 98765 43210"
                      value={form.phone}
                      onChange={handleChange}
                      className="w-full rounded-xl border border-[#E8EDF5] bg-[#F9FAFB] px-4 py-3 text-[14px] text-[#0D1B4B] placeholder:text-[#C4CAD4] outline-none focus:border-[#003DF5] focus:ring-2 focus:ring-[#003DF5]/10 transition-all duration-150"
                    />
                  </div>
                </div>

                {/* Reason */}
                <div className="flex flex-col gap-1.5">
                  <label
                    htmlFor="reason"
                    className="text-[13px] font-semibold text-[#374151]"
                  >
                    How can we help? <span className="text-[#E11D48]">*</span>
                  </label>
                  <select
                    id="reason"
                    name="reason"
                    required
                    value={form.reason}
                    onChange={handleChange}
                    className="w-full rounded-xl border border-[#E8EDF5] bg-[#F9FAFB] px-4 py-3 text-[14px] text-[#0D1B4B] outline-none focus:border-[#003DF5] focus:ring-2 focus:ring-[#003DF5]/10 transition-all duration-150 appearance-none"
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
                    className="text-[13px] font-semibold text-[#374151]"
                  >
                    Message <span className="text-[#E11D48]">*</span>
                  </label>
                  <textarea
                    id="message"
                    name="message"
                    required
                    rows={4}
                    placeholder="Tell us a bit about what you're looking for..."
                    value={form.message}
                    onChange={handleChange}
                    className="w-full rounded-xl border border-[#E8EDF5] bg-[#F9FAFB] px-4 py-3 text-[14px] text-[#0D1B4B] placeholder:text-[#C4CAD4] outline-none focus:border-[#003DF5] focus:ring-2 focus:ring-[#003DF5]/10 transition-all duration-150 resize-none"
                  />
                </div>

                {/* Submit */}
                <button
                  type="submit"
                  disabled={loading}
                  className="w-full flex items-center justify-center gap-2 bg-[#003DF5] hover:bg-[#0030CC] disabled:opacity-70 text-white text-[15px] font-bold py-4 rounded-full transition-colors duration-200 shadow-[0_4px_20px_rgba(0,61,245,0.28)]"
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
                        width="16"
                        height="16"
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

                <p className="text-[12px] text-[#9CA3AF] text-center">
                  By submitting, you agree to our{" "}
                  <a href="#" className="text-[#003DF5] hover:underline">
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
