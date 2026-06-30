"use client";

import { Send } from "lucide-react";
import { useState } from "react";

type FormState = { firstName: string; lastName: string; email: string; message: string };
type FieldErrors = Partial<Record<keyof FormState, string>>;

function validateField(field: keyof FormState, value: string): string {
  switch (field) {
    case "firstName":
      if (!value.trim()) return "First name is required.";
      if (value.trim().length < 2) return "First name must be at least 2 characters.";
      if (value.trim().length > 50) return "First name must be under 50 characters.";
      return "";
    case "email":
      if (!value.trim()) return "Email address is required.";
      if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value.trim())) return "Enter a valid email address.";
      return "";
    case "message":
      if (!value.trim()) return "Message is required.";
      if (value.trim().length < 10) return "Message must be at least 10 characters.";
      if (value.trim().length > 2000) return "Message must be under 2000 characters.";
      return "";
    default:
      return "";
  }
}

export default function SupportForm() {
  const [form, setForm] = useState<FormState>({ firstName: "", lastName: "", email: "", message: "" });
  const [fieldErrors, setFieldErrors] = useState<FieldErrors>({});
  const [sent, setSent] = useState(false);
  const [loading, setLoading] = useState(false);
  const [submitError, setSubmitError] = useState("");

  function handleChange(field: keyof FormState, value: string) {
    setForm((prev) => ({ ...prev, [field]: value }));
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
    (["firstName", "email", "message"] as (keyof FormState)[]).forEach((f) => {
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
      const res = await fetch("/api/support", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(form),
      });
      const data = await res.json();
      if (!res.ok) {
        if (data.errors) {
          setFieldErrors(data.errors);
        } else {
          setSubmitError(data.error || "Something went wrong. Please try again.");
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

  const inputBase = "w-full px-4 py-3 rounded-xl border outline-none transition-all bg-white";
  const inputClass = (field: keyof FormState) =>
    `${inputBase} ${
      fieldErrors[field]
        ? "border-red-400 focus:border-red-500 bg-red-50/20"
        : "border-[#0C1B33]/15 focus:border-[#0C1B33] focus:ring-1 focus:ring-[#0C1B33]"
    }`;

  if (sent) {
    return (
      <div className="flex flex-col items-center justify-center py-10 gap-4 text-center" role="status" aria-live="polite">
        <div className="w-14 h-14 rounded-full bg-emerald-50 border border-emerald-100 flex items-center justify-center" aria-hidden="true">
          <Send className="w-6 h-6 text-emerald-500" />
        </div>
        <div>
          <p className="text-[19px] font-semibold text-[#0C1B33] mb-1">Message Sent!</p>
          <p className="text-[15px] text-[#0C1B33]/45 leading-relaxed max-w-xs">
            Thank you for reaching out. We usually respond within 24 hours.
          </p>
        </div>
        <button
          onClick={() => { setSent(false); setFieldErrors({}); setForm({ firstName: "", lastName: "", email: "", message: "" }); }}
          className="mt-2 text-[14.5px] font-semibold text-[#0C1B33]/50 hover:text-[#0C1B33] transition-colors"
        >
          Send another message
        </button>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-5" noValidate aria-label="Support request form">

      {/* Name row */}
      <div className="grid sm:grid-cols-2 gap-5">
        <div className="space-y-1">
          <label htmlFor="sup-firstName" className="text-[14px] font-semibold text-[#0C1B33]">
            First Name <span aria-hidden="true">*</span>
          </label>
          <input
            type="text"
            id="sup-firstName"
            autoComplete="given-name"
            aria-required="true"
            aria-invalid={!!fieldErrors.firstName}
            aria-describedby={fieldErrors.firstName ? "err-firstName" : undefined}
            placeholder="Enter you first name"
            value={form.firstName}
            onChange={(e) => handleChange("firstName", e.target.value)}
            onBlur={() => handleBlur("firstName")}
            className={inputClass("firstName")}
          />
          {fieldErrors.firstName && (
            <p id="err-firstName" role="alert" className="text-[12px] text-red-500">{fieldErrors.firstName}</p>
          )}
        </div>

        <div className="space-y-1">
          <label htmlFor="sup-lastName" className="text-[14px] font-semibold text-[#0C1B33]">Last Name</label>
          <input
            type="text"
            id="sup-lastName"
            autoComplete="family-name"
            placeholder="Enter you last name"
            value={form.lastName}
            onChange={(e) => handleChange("lastName", e.target.value)}
            className={inputClass("lastName")}
          />
        </div>
      </div>

      {/* Email */}
      <div className="space-y-1">
        <label htmlFor="sup-email" className="text-[14px] font-semibold text-[#0C1B33]">
          Email Address <span aria-hidden="true">*</span>
        </label>
        <input
          type="email"
          id="sup-email"
          autoComplete="email"
          aria-required="true"
          aria-invalid={!!fieldErrors.email}
          aria-describedby={fieldErrors.email ? "err-email" : undefined}
          placeholder="Enter you email address"
          value={form.email}
          onChange={(e) => handleChange("email", e.target.value)}
          onBlur={() => handleBlur("email")}
          className={inputClass("email")}
        />
        {fieldErrors.email && (
          <p id="err-email" role="alert" className="text-[12px] text-red-500">{fieldErrors.email}</p>
        )}
      </div>

      {/* Message */}
      <div className="space-y-1">
        <div className="flex items-center justify-between">
          <label htmlFor="sup-message" className="text-[14px] font-semibold text-[#0C1B33]">
            Message <span aria-hidden="true">*</span>
          </label>
          <span className="text-[11px] text-[#0C1B33]/30">{form.message.length}/2000</span>
        </div>
        <textarea
          id="sup-message"
          rows={4}
          aria-required="true"
          aria-invalid={!!fieldErrors.message}
          aria-describedby={fieldErrors.message ? "err-message" : undefined}
          placeholder="Enter your message (e.g., issue, question, or feedback)..."
          value={form.message}
          onChange={(e) => handleChange("message", e.target.value)}
          onBlur={() => handleBlur("message")}
          className={`${inputClass("message")} resize-none`}
        />
        {fieldErrors.message && (
          <p id="err-message" role="alert" className="text-[12px] text-red-500">{fieldErrors.message}</p>
        )}
      </div>

      {/* Submit error */}
      <div aria-live="polite" aria-atomic="true">
        {submitError && (
          <p role="alert" className="text-[13.5px] text-red-500 font-medium text-center">{submitError}</p>
        )}
      </div>

      <button
        type="submit"
        disabled={loading}
        aria-disabled={loading}
        className="group inline-flex items-center justify-center gap-2.5 px-7 py-3.5 text-[14px] font-semibold text-white bg-[#0C1B33] rounded-xl hover:bg-[#0C1B33]/90 transition-all shadow-sm w-full sm:w-auto disabled:opacity-60 disabled:cursor-not-allowed"
      >
        {loading ? "Sending…" : "Send Message"}
        {!loading && (
          <Send className="w-4 h-4 group-hover:translate-x-0.5 transition-transform" aria-hidden="true" />
        )}
      </button>
    </form>
  );
}
