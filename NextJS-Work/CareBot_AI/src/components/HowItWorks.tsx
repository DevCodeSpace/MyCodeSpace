const steps = [
  {
    number: "01",
    icon: (
      <img
        src="/describe.svg"
        width={24}
        height={24}
        alt=""
        aria-hidden="true"
      />
    ),
    title: "Describe Your Symptoms",
    description:
      "Open CareBot AI and type what you're feeling  in plain language. No medical jargon needed. Our AI understands you naturally.",
    accent: "#003DF5",
    accentLight: "#EEF2FF",
    details: [
      "Works with everyday language",
      "Supports multiple symptoms at once",
      "Available 24 / 7, no waiting",
    ],
  },
  {
    number: "02",
    icon: (
      <img
        src="/ai-matches.svg"
        width={24}
        height={24}
        alt=""
        aria-hidden="true"
      />
    ),
    title: "AI Matches You to the Right Specialist",
    description:
      "Our engine analyses your symptoms and instantly identifies the most relevant medical department and nearby available doctors.",
    accent: "#0096DE",
    accentLight: "#E0F7FF",
    details: [
      "Smart specialty matching",
      "Real-time doctor availability",
      "Filters by location & fees",
    ],
  },
  {
    number: "03",
    icon: (
      <img
        src="/pick.svg"
        width={24}
        height={24}
        alt=""
        aria-hidden="true"
      />
    ),
    title: "Pick a Slot & Enter Your Details",
    description:
      "Choose from live appointment slots, select a convenient time, and fill in your patient details all inside the chat window.",
    accent: "#16A34A",
    accentLight: "#F0FDF4",
    details: [
      "Live slot availability",
      "Guided step-by-step form",
      "Inline validation keeps it error-free",
    ],
  },
  {
    number: "04",
    icon: (
      <img
        src="/booking.svg"
        width={24}
        height={24}
        alt=""
        aria-hidden="true"
      />
    ),
    title: "Booking Confirmed Instantly",
    description:
      "Get a full appointment summary with doctor info, hospital address, time, fees, and next steps ready to copy or download as PDF.",
    accent: "#EA580C",
    accentLight: "#FFF7ED",
    details: [
      "Instant confirmation summary",
      "One-tap clipboard copy",
      "PDF download & directions",
    ],
  },
];

export default function HowItWorks() {
  return (
    <section
      id="how-it-works"
      className="bg-white py-16 lg:py-24 overflow-hidden"
    >
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
              <path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z" fill="#003DF5" />
            </svg> */}
            How It Works
          </span>
          <h2 className="text-[26px] sm:text-[34px] lg:text-[48px] font-extrabold text-[#0D1B4B] tracking-[-0.5px] sm:tracking-[-1px] leading-[1.1]">
            From Symptoms to{" "}
            <span className="text-[#003DF5]">Confirmed Booking</span>
            <br className="hidden sm:block" /> in Under 60 Seconds
          </h2>
          <p className="mt-4 text-[16px] text-[#6B7280] max-w-135 mx-auto leading-relaxed">
            CareBot AI guides you through the entire appointment process o phone
            calls, no forms, no frustration.
          </p>
        </div>

        {/* Steps grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {steps.map(
            (
              {
                number,
                icon,
                title,
                description,
                accent,
                accentLight,
                details,
              },
              i,
            ) => (
              <div
                key={number}
                className="group relative flex flex-col rounded-2xl border border-[#E8EDF5] bg-white p-7 shadow-[0_2px_12px_rgba(0,0,0,0.05)] hover:shadow-[0_8px_32px_rgba(0,0,0,0.10)] hover:-translate-y-1 transition-all duration-200 overflow-hidden"
              >
                {/* Large faint step number watermark */}
                <span
                  className="absolute top-4 right-5 text-[64px] font-black leading-none select-none pointer-events-none"
                  style={{ color: accentLight, opacity: 0.9 }}
                >
                  {number}
                </span>

                {/* Icon */}
                <div
                  className="w-14 h-14 rounded-2xl flex items-center justify-center text-[28px] mb-5 shrink-0 relative z-10"
                  style={{ backgroundColor: accentLight }}
                >
                  {icon}
                </div>

                {/* Step label */}
                <span
                  className="text-[10px] font-black tracking-[0.2em] uppercase mb-2 relative z-10"
                  style={{ color: accent }}
                >
                  Step {number}
                </span>

                {/* Title */}
                <h3 className="text-[17px] font-extrabold text-[#0D1B4B] leading-snug mb-3 relative z-10">
                  {title}
                </h3>

                {/* Divider */}
                <div
                  className="w-10 h-0.5 rounded-full mb-4 relative z-10"
                  style={{ backgroundColor: accent, opacity: 0.35 }}
                />

                {/* Description */}
                <p className="text-[13.5px] text-[#6B7280] leading-relaxed mb-5 relative z-10">
                  {description}
                </p>

                {/* Detail bullets */}
                <ul className="flex flex-col gap-2.5 mt-auto relative z-10">
                  {details.map((d) => (
                    <li key={d} className="flex items-center gap-2.5">
                      <span
                        className="w-1.5 h-1.5 rounded-full shrink-0"
                        style={{ backgroundColor: accent }}
                      />
                      <span className="text-[13px] text-[#374151] font-medium">
                        {d}
                      </span>
                    </li>
                  ))}
                </ul>

                {/* Bottom accent bar on hover */}
                {/* <div
                  className="absolute bottom-0 left-0 right-0 h-0.75 opacity-0 group-hover:opacity-100 transition-opacity duration-200"
                  style={{ backgroundColor: accent }}
                /> */}
              </div>
            ),
          )}
        </div>

        {/* Connector arrow row desktop decorative */}
        <div
          className="hidden lg:flex items-center justify-center gap-0 mt-8 mb-2 pointer-events-none select-none"
          aria-hidden="true"
        >
          {[0, 1, 2].map((i) => (
            <div key={i} className="flex items-center">
              <div className="w-[calc((100vw-5rem)/6)] max-w-45 h-px bg-linear-to-r from-[#E8EDF5] to-[#C7D2FE]" />
              <svg
                width="18"
                height="18"
                viewBox="0 0 24 24"
                fill="none"
                className="text-[#C7D2FE] mx-1"
              >
                <path
                  d="M5 12h14M13 6l6 6-6 6"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
              </svg>
            </div>
          ))}
        </div>

        {/* CTA row */}
        <div className="mt-10 lg:mt-14 flex flex-col sm:flex-row items-center justify-center gap-4">
          <a
            href="#features"
            className="w-full sm:w-auto inline-flex items-center justify-center gap-2 bg-[#003DF5] hover:bg-[#0030CC] text-white text-[15px] font-bold px-8 py-4 rounded-full transition-colors duration-200 shadow-[0_4px_20px_rgba(0,61,245,0.28)]"
          >
            Explore All Features
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
            href="#contact"
            className="w-full sm:w-auto inline-flex items-center justify-center gap-2 bg-white border border-[#E3E3E3] hover:border-[#003DF5] text-[#0D1B4B] text-[15px] font-bold px-8 py-4 rounded-full transition-colors duration-200"
          >
            Request a Demo
          </a>
        </div>
      </div>
    </section>
  );
}
