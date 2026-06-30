"use client";
import { Mail, MapPin, MessageCircle, Phone, Send } from "lucide-react";
import { useEffect, useState } from "react";

// Email intentionally not in static HTML — built client-side to prevent scraper harvesting
const contactDetails = [
  { icon: MapPin, label: "Office Location", value: "Surat, Gujarat" },
  { icon: Phone, label: "Call / WhatsApp", value: "+91 7405545576" },
  {
    icon: MessageCircle,
    label: "Response Time",
    value: "Within 2 business hours",
  },
];

type FormState = {
  name: string;
  company: string;
  phone: string;
  email: string;
  industry: string;
  message: string;
};
type FieldErrors = Partial<Record<keyof FormState, string>>;

function validateField(field: keyof FormState, value: string): string {
  switch (field) {
    case "name":
      if (!value.trim()) return "Full name is required.";
      if (value.trim().length < 2) return "Name must be at least 2 characters.";
      if (value.trim().length > 100)
        return "Name must be under 100 characters.";
      return "";
    case "phone": {
      if (!value.trim()) return "Phone number is required.";
      const cleaned = value.replace(/[\s\-()]/g, "");
      if (!/^(\+91|91|0)?[6-9]\d{9}$/.test(cleaned))
        return "Enter a valid Indian mobile number (e.g. +91 7405545576).";
      return "";
    }
    case "email": {
      if (!value.trim()) return "Email address is required.";
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(value)) return "Enter a valid email address.";
      return "";
    }
    case "industry": {
      return "";
    }
    case "message":
      if (value.length > 1000) return "Message must be under 1000 characters.";
      return "";
    default:
      return "";
  }
}

export default function ContactSection() {
  const [form, setForm] = useState<FormState>({
    name: "",
    company: "",
    phone: "",
    email: "",
    industry: "",
    message: "",
  });
  const [fieldErrors, setFieldErrors] = useState<FieldErrors>({});
  const [sent, setSent] = useState(false);
  const [loading, setLoading] = useState(false);
  const [submitError, setSubmitError] = useState("");
  const [email, setEmail] = useState("");

  useEffect(() => {
    setEmail(["support", "yourcompany.com"].join("@"));
  }, []);

  function handleChange(field: keyof FormState, value: string) {
    setForm((prev) => ({ ...prev, [field]: value }));
    // Clear error as user types
    if (fieldErrors[field]) {
      setFieldErrors((prev) => ({ ...prev, [field]: "" }));
    }
  }

  function handleBlur(field: keyof FormState) {
    const err = validateField(field, form[field]);
    setFieldErrors((prev) => ({ ...prev, [field]: err }));
  }

  function validateAll(): boolean {
    const errors: FieldErrors = {};
    (
      ["name", "phone", "email", "industry", "message"] as (keyof FormState)[]
    ).forEach((f) => {
      const err = validateField(f, form[f]);
      if (err) errors[f] = err;
    });
    setFieldErrors(errors);
    return Object.keys(errors).length === 0;
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!validateAll()) return;
    setLoading(true);
    setSubmitError("");
    try {
      const res = await fetch("/api/contact", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(form),
      });
      const data = await res.json();
      if (!res.ok) {
        if (data.errors) {
          setFieldErrors(data.errors);
        } else {
          setSubmitError(
            data.error || "Something went wrong. Please try again.",
          );
        }
      } else {
        setSent(true);
      }
    } catch {
      setSubmitError("Network error. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  const inputClass = (field: keyof FormState) =>
    `w-full px-4 py-3 text-[15px] text-[#0C1B33] placeholder-[#0C1B33]/25 bg-[#F0F8FF] border rounded-xl outline-none transition-all ${
      fieldErrors[field]
        ? "border-red-400 focus:border-red-500 bg-red-50/30"
        : "border-[#0C1B33]/10 focus:border-[#0C1B33]/35 focus:bg-white"
    }`;

  return (
    <section
      id="contact"
      className="bg-white py-20 lg:py-28"
      aria-labelledby="contact-heading"
    >
      <div className="max-w-360 mx-auto px-4 sm:px-6 lg:px-10">
        {/* Header */}
        <div className="max-w-xl mb-14">
          <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-white border border-[#0C1B33]/10 mb-5">
            <span
              className="w-1.5 h-1.5 rounded-full bg-[#0C1B33]"
              aria-hidden="true"
            />
            <span className="text-[13px] font-semibold text-[#0C1B33]/60 tracking-widest uppercase">
              Get in Touch
            </span>
          </div>
          <h2
            id="contact-heading"
            className="text-[42px] sm:text-[48px] font-bold text-[#0C1B33] leading-[1.1] tracking-tight mb-4"
          >
            Book a Free Demo or
            <br />
            Ask Us Anything
          </h2>
          <p className="text-[17px] text-[#0C1B33]/50 leading-relaxed">
            Request a free demo of our transport management software or ask a
            question. Our team will walk you through the platform and help you
            get started.
          </p>
        </div>

        <div className="grid lg:grid-cols-[1fr_420px] gap-8 items-start">
          {/* Left — contact details */}
          <div className="flex flex-col gap-6">
            <address className="not-italic grid sm:grid-cols-2 gap-4">
              {contactDetails.map(({ icon: Icon, label, value }) => (
                <div
                  key={label}
                  className="flex items-start gap-4 p-5 rounded-2xl bg-white border border-[#0C1B33]/8 hover:border-[#0C1B33]/18 hover:shadow-md hover:shadow-[#0C1B33]/5 transition-all"
                >
                  <div
                    className="w-10 h-10 rounded-xl bg-[#0C1B33] flex items-center justify-center shrink-0"
                    aria-hidden="true"
                  >
                    <Icon className="w-4.5 h-4.5 text-white" />
                  </div>
                  <div>
                    <p className="text-[13px] font-semibold text-[#0C1B33]/40 uppercase tracking-widest mb-0.5">
                      {label}
                    </p>
                    <p className="text-[15.5px] font-semibold text-[#0C1B33]">
                      {value}
                    </p>
                  </div>
                </div>
              ))}

      <div className="flex items-start gap-4 p-5 rounded-2xl bg-white border border-[#0C1B33]/8 hover:border-[#0C1B33]/18 hover:shadow-md hover:shadow-[#0C1B33]/5 transition-all">
        <div
          className="w-10 h-10 rounded-xl bg-[#0C1B33] flex items-center justify-center shrink-0"
          aria-hidden="true"
        >
          <Mail className="w-4.5 h-4.5 text-white" />
        </div>
        <div>
          <p className="text-[13px] font-semibold text-[#0C1B33]/40 uppercase tracking-widest mb-0.5">
            Email Us
          </p>
          <a
            href="mailto:moiz.codexlancers@gmail.com"
            className="text-[15.5px] font-semibold text-[#0C1B33] hover:underline"
          >
            moiz.codexlancers@gmail.com
          </a>
        </div>
      </div>
            </address>

            <div
              className="flex items-start gap-4 p-6 rounded-2xl bg-[#0C1B33]"
              role="note"
              aria-label="Free demo offer"
            >
              <div
                className="w-2 h-2 rounded-full bg-emerald-400 mt-1.5 shrink-0 animate-pulse"
                aria-hidden="true"
              />
              <div>
                <p className="text-white font-semibold text-[16.5px] mb-1">
                  Free Demo — No Commitment
                </p>
                <p className="text-white/45 text-[15px] leading-relaxed">
                  We&apos;ll show you a live walkthrough of the full transport
                  management platform tailored to your business type —
                  completely free, no credit card required.
                </p>
              </div>
            </div>
          </div>

          {/* Right — form */}
          <div className="bg-white rounded-2xl border border-[#0C1B33]/8 shadow-sm p-7">
            {sent ? (
              <div
                className="flex flex-col items-center justify-center py-10 gap-4 text-center"
                role="status"
                aria-live="polite"
              >
                <div
                  className="w-14 h-14 rounded-full bg-emerald-50 border border-emerald-100 flex items-center justify-center"
                  aria-hidden="true"
                >
                  <Send className="w-6 h-6 text-emerald-500" />
                </div>
                <div>
                  <p className="text-[19px] font-semibold text-[#0C1B33] mb-1">
                    Message Sent!
                  </p>
                  <p className="text-[15px] text-[#0C1B33]/45 leading-relaxed max-w-xs">
                    Thank you for reaching out. We'll get back to you within 2
                    business hours.
                  </p>
                </div>
                <button
                  onClick={() => {
                    setSent(false);
                    setSubmitError("");
                    setFieldErrors({});
                    setForm({
                      name: "",
                      company: "",
                      phone: "",
                      email: "",
                      industry: "",
                      message: "",
                    });
                  }}
                  className="mt-2 text-[14.5px] font-semibold text-[#0C1B33]/50 hover:text-[#0C1B33] transition-colors"
                >
                  Send another message
                </button>
              </div>
            ) : (
              <form
                onSubmit={handleSubmit}
                className="flex flex-col gap-4"
                aria-label="Book a free demo of TransportPro"
                noValidate
              >
                <div>
                  <p className="text-[19px] font-bold text-[#0C1B33] mb-0.5">
                    Book a Free Demo
                  </p>
                  <p className="text-[14.5px] text-[#0C1B33]/40">
                    Fill in the details and we&apos;ll be in touch shortly.
                  </p>
                </div>

                <div className="grid sm:grid-cols-2 gap-3 mt-1">
                  {/* Name */}
                  <div className="flex flex-col gap-1">
                    <label
                      htmlFor="contact-name"
                      className="text-[13px] font-semibold text-[#0C1B33]/60 uppercase tracking-widest"
                    >
                      Full Name <span aria-hidden="true">*</span>
                    </label>
                    <input
                      id="contact-name"
                      type="text"
                      autoComplete="name"
                      aria-required="true"
                      aria-invalid={!!fieldErrors.name}
                      aria-describedby={
                        fieldErrors.name ? "err-name" : undefined
                      }
                      placeholder="Your name"
                      value={form.name}
                      onChange={(e) => handleChange("name", e.target.value)}
                      onBlur={() => handleBlur("name")}
                      className={inputClass("name")}
                    />
                    {fieldErrors.name && (
                      <p
                        id="err-name"
                        role="alert"
                        className="text-[12px] text-red-500 mt-0.5"
                      >
                        {fieldErrors.name}
                      </p>
                    )}
                  </div>

                  {/* Company */}
                  <div className="flex flex-col gap-1">
                    <label
                      htmlFor="contact-company"
                      className="text-[13px] font-semibold text-[#0C1B33]/60 uppercase tracking-widest"
                    >
                      Company Name
                    </label>
                    <input
                      id="contact-company"
                      type="text"
                      autoComplete="organization"
                      placeholder="Your company"
                      value={form.company}
                      onChange={(e) => handleChange("company", e.target.value)}
                      className={inputClass("company")}
                    />
                  </div>
                </div>

                {/* Phone */}
                <div className="flex flex-col gap-1">
                  <label
                    htmlFor="contact-phone"
                    className="text-[12px] font-semibold text-[#0C1B33]/60 uppercase tracking-widest"
                  >
                    Phone / WhatsApp <span aria-hidden="true">*</span>
                  </label>
                  <input
                    id="contact-phone"
                    type="tel"
                    autoComplete="tel"
                    aria-required="true"
                    aria-invalid={!!fieldErrors.phone}
                    aria-describedby={
                      fieldErrors.phone ? "err-phone" : undefined
                    }
                    placeholder="Enter your phone number"
                    value={form.phone}
                    onChange={(e) => handleChange("phone", e.target.value)}
                    onBlur={() => handleBlur("phone")}
                    className={inputClass("phone")}
                  />
                  {fieldErrors.phone && (
                    <p
                      id="err-phone"
                      role="alert"
                      className="text-[12px] text-red-500 mt-0.5"
                    >
                      {fieldErrors.phone}
                    </p>
                  )}
                </div>
                {/* Email field */}
                <div className="flex flex-col gap-1">
                  <label
                    htmlFor="contact-email"
                    className="text-[12px] font-semibold text-[#0C1B33]/60 uppercase tracking-widest"
                  >
                    Email Address <span aria-hidden="true">*</span>
                  </label>
                  <input
                    id="contact-email"
                    type="email"
                    autoComplete="email"
                    aria-required="true"
                    aria-invalid={!!fieldErrors.email}
                    aria-describedby={
                      fieldErrors.email ? "err-email" : undefined
                    }
                    placeholder="Enter your email address"
                    value={form.email}
                    onChange={(e) => handleChange("email", e.target.value)}
                    onBlur={() => handleBlur("email")}
                    className={inputClass("email")}
                  />
                  {fieldErrors.email && (
                    <p
                      id="err-email"
                      role="alert"
                      className="text-[12px] text-red-500 mt-0.5"
                    >
                      {fieldErrors.email}
                    </p>
                  )}
                </div>
                {/* Industry field */}
                <div className="flex flex-col gap-1">
                  <label
                    htmlFor="contact-industry"
                    className="text-[12px] font-semibold text-[#0C1B33]/60 uppercase tracking-widest"
                  >
                    Industry <span aria-hidden="true">*</span>
                  </label>
                  <input
                    id="contact-industry"
                    type="text"
                    autoComplete="organization"
                    aria-required="true"
                    aria-invalid={!!fieldErrors.industry}
                    aria-describedby={
                      fieldErrors.industry ? "err-industry" : undefined
                    }
                    placeholder="e.g. Logistics, Shipping..."
                    value={form.industry}
                    onChange={(e) => handleChange("industry", e.target.value)}
                    onBlur={() => handleBlur("industry")}
                    className={inputClass("industry")}
                  />
                  {fieldErrors.industry && (
                    <p
                      id="err-industry"
                      role="alert"
                      className="text-[12px] text-red-500 mt-0.5"
                    >
                      {fieldErrors.industry}
                    </p>
                  )}
                </div>

                {/* Message */}
                <div className="flex flex-col gap-1">
                  <div className="flex items-center justify-between">
                    <label
                      htmlFor="contact-message"
                      className="text-[12px] font-semibold text-[#0C1B33]/60 uppercase tracking-widest"
                    >
                      Your Message
                    </label>
                    <span className="text-[11px] text-[#0C1B33]/30">
                      {form.message.length}/1000
                    </span>
                  </div>
                  <textarea
                    id="contact-message"
                    rows={4}
                    aria-invalid={!!fieldErrors.message}
                    aria-describedby={
                      fieldErrors.message ? "err-message" : undefined
                    }
                    placeholder="Tell us about your transport business and what you're looking for..."
                    value={form.message}
                    onChange={(e) => handleChange("message", e.target.value)}
                    onBlur={() => handleBlur("message")}
                    className={`${inputClass("message")} resize-none`}
                  />
                  {fieldErrors.message && (
                    <p
                      id="err-message"
                      role="alert"
                      className="text-[12px] text-red-500 mt-0.5"
                    >
                      {fieldErrors.message}
                    </p>
                  )}
                </div>

                {/* Submit error */}
                <div aria-live="polite" aria-atomic="true">
                  {submitError && (
                    <p
                      role="alert"
                      className="text-[13.5px] text-red-500 font-medium text-center"
                    >
                      {submitError}
                    </p>
                  )}
                </div>

                <button
                  type="submit"
                  disabled={loading}
                  aria-disabled={loading}
                  className="group w-full flex items-center justify-center gap-2.5 py-3.5 text-[15.5px] font-semibold text-white bg-[#0C1B33] rounded-xl hover:bg-[#0C1B33]/90 transition-all hover:shadow-xl hover:shadow-[#0C1B33]/25 hover:-translate-y-0.5 mt-1 disabled:opacity-60 disabled:cursor-not-allowed disabled:hover:translate-y-0 disabled:hover:shadow-none"
                >
                  {loading ? "Sending…" : "Send Message"}
                  {!loading && (
                    <Send
                      className="w-4 h-4 group-hover:translate-x-0.5 transition-transform"
                      aria-hidden="true"
                    />
                  )}
                </button>

                <p className="text-center text-[13px] text-[#0C1B33]/30">
                  No spam. We respond within 2 business hours.
                </p>
              </form>
            )}
          </div>
        </div>
      </div>
    </section>
  );
}
