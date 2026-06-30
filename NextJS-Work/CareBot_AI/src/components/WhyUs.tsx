const stats = [
  {
    value: "10K+",
    label: "Patients Served",
    icon: (
      <img
        src="/patients.svg"
        width={26}
        height={26}
        alt=""
        aria-hidden="true"
      />
    ),
  },
  {
    value: "30+",
    label: "Medical Specialties",
    icon: (
      <img
        src="/medical.svg"
        width={26}
        height={26}
        alt=""
        aria-hidden="true"
      />
    ),
  },
  {
    value: "<60s",
    label: "Average Booking Time",
    icon: (
      <img
        src="/average.svg"
        width={26}
        height={26}
        alt=""
        aria-hidden="true"
      />
    ),
  },
  {
    value: "98%",
    label: "Patient Satisfaction",
    icon: (
      <img
        src="/satisfaction.svg"
        width={26}
        height={26}
        alt=""
        aria-hidden="true"
      />
    ),
  },
];

const reasons = [
  {
    icon: (
      <img src="/ai.svg" width={26} height={26} alt="" aria-hidden="true" />
    ),
    accent: "#003DF5",
    bg: "#EEF2FF",
    title: "AI That Understands You",
    description:
      "No dropdowns, no forms, no phone queues. Just describe how you feel and CareBot AI handles everything  specialty matching, slot selection, and confirmation.",
  },
  {
    icon: (
      <img
        src="/average.svg"
        width={26}
        height={26}
        alt=""
        aria-hidden="true"
      />
    ),
    accent: "#0096DE",
    bg: "#E0F7FF",
    title: "Booking in Under 60 Seconds",
    description:
      "Traditional booking takes 8–15 minutes on average. CareBot AI cuts that to under a minute with guided, real-time automation.",
  },
  {
    icon: (
      <img
        src="/patient.svg"
        width={26}
        height={26}
        alt=""
        aria-hidden="true"
      />
    ),
    accent: "#16A34A",
    bg: "#F0FDF4",
    title: "Zero Errors, Fully Validated",
    description:
      "Inline validation catches mistakes before they reach the hospital  correct phone formats, valid age ranges, and live slot checks prevent double-bookings.",
  },
  {
    icon: (
      <img
        src="/complete.svg"
        width={26}
        height={26}
        alt=""
        aria-hidden="true"
      />
    ),
    accent: "#9333EA",
    bg: "#FAF5FF",
    title: "Complete Booking Record",
    description:
      "Walk away with a full summary: doctor name, hospital address, fees, and your patient details  copyable in one tap or downloadable as a PDF.",
  },
  {
    icon: (
      <img
        src="/directions.svg"
        width={26}
        height={26}
        alt=""
        aria-hidden="true"
      />
    ),
    accent: "#EA580C",
    bg: "#FFF7ED",
    title: "Directions Built Right In",
    description:
      "No searching for the clinic address separately. CareBot AI surfaces directions, maps, and hospital contact info the moment your appointment is confirmed.",
  },
  {
    icon: (
      <img src="/secure.svg" width={26} height={26} alt="" aria-hidden="true" />
    ),
    accent: "#E11D48",
    bg: "#FFF1F2",
    title: "Secure & Private by Design",
    description:
      "Your health data stays yours. Patient details are validated locally and never stored beyond the session  HIPAA-aligned from the ground up.",
  },
];

export default function WhyUs() {
  return (
    <section
      id="why-us"
      className="bg-[#F6F6F7] py-16 lg:py-24 overflow-hidden"
    >
      <div className="max-w-screen-2xl mx-auto px-4 sm:px-6">
        {/* Section header */}
        <div className="text-center mb-10 lg:mb-16">
          <span className="inline-flex items-center gap-2 bg-[#EEF2FF] text-[#003DF5] text-[11px] font-bold px-4 py-2 rounded-full tracking-widest uppercase mb-5">
            Why CareBot AI
          </span>
          <h2 className="text-[26px] sm:text-[34px] lg:text-[48px] font-extrabold text-[#0D1B4B] tracking-[-0.5px] sm:tracking-[-1px] leading-[1.1]">
            Healthcare Booking,{" "}
            <span className="text-[#003DF5]">Finally Done Right</span>
          </h2>
          <p className="mt-4 text-[15px] sm:text-[16px] text-[#6B7280] max-w-[560px] mx-auto leading-relaxed">
            We didn't just digitise the old process we rebuilt it from scratch
            around the patient.
          </p>
        </div>

        {/* Stats bar */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4 mb-12 lg:mb-16">
          {stats.map(({ value, label, icon }) => (
            <div
              key={label}
              className="flex flex-col items-center text-center bg-white rounded-2xl border border-[#E8EDF5] px-4 py-6 sm:px-6 sm:py-8 shadow-[0_2px_12px_rgba(0,0,0,0.05)]"
            >
              <span className="text-[24px] sm:text-[28px] mb-2">{icon}</span>
              <span className="text-[24px] sm:text-[32px] lg:text-[42px] font-black text-[#003DF5] leading-none tracking-[-1px]">
                {value}
              </span>
              <span className="mt-1.5 text-[11px] sm:text-[13px] font-semibold text-[#6B7280] uppercase tracking-wider">
                {label}
              </span>
            </div>
          ))}
        </div>

        {/* Reasons grid  full width, 3 columns on desktop */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5 lg:gap-6">
          {reasons.map(({ icon, accent, bg, title, description }) => (
            <div
              key={title}
              className="group relative flex gap-5 rounded-2xl border border-[#E8EDF5] bg-white p-6 shadow-[0_2px_12px_rgba(0,0,0,0.04)] hover:shadow-[0_8px_32px_rgba(0,0,0,0.09)] hover:-translate-y-0.5 transition-all duration-200 overflow-hidden"
            >
              {/* Left accent bar */}
              {/* <div
                className="absolute left-0 top-6 bottom-6 w-[3px] rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-200"
                style={{ backgroundColor: accent }}
              /> */}

              {/* Icon */}
              <div
                className="w-12 h-12 rounded-xl flex items-center justify-center text-[22px] shrink-0 mt-0.5"
                style={{ backgroundColor: bg }}
              >
                {icon}
              </div>

              {/* Text */}
              <div className="flex flex-col gap-1.5 min-w-0">
                <h3 className="text-[15px] sm:text-[16px] font-extrabold text-[#0D1B4B] leading-snug">
                  {title}
                </h3>
                <p className="text-[13px] text-[#6B7280] leading-relaxed">
                  {description}
                </p>
              </div>
            </div>
          ))}
        </div>

        {/* Bottom CTA */}
        <div className="mt-12 lg:mt-16 flex flex-col sm:flex-row items-center justify-center gap-4">
          <a
            href="#contact"
            className="w-full sm:w-auto inline-flex items-center justify-center gap-2 bg-[#003DF5] hover:bg-[#0030CC] text-white text-[15px] font-bold px-8 py-4 rounded-full transition-colors duration-200 shadow-[0_4px_20px_rgba(0,61,245,0.28)]"
          >
            Get Started Free
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
          </a>
          <a
            href="#how-it-works"
            className="w-full sm:w-auto inline-flex items-center justify-center gap-2 bg-white border border-[#E3E3E3] hover:border-[#003DF5] text-[#0D1B4B] text-[15px] font-bold px-8 py-4 rounded-full transition-colors duration-200"
          >
            See How It Works
          </a>
        </div>
      </div>
    </section>
  );
}
