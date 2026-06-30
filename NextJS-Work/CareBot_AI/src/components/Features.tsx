const features = [
  {
    icon: (
      <img
        src="/symptom.svg"
        width={24}
        height={24}
        alt=""
        aria-hidden="true"
      />
    ),
    title: "Symptom-Based Doctor Discovery",
    color: "#EEF2FF",
    accent: "#003DF5",
    points: [
      {
        label: "Overview",
        text: "Natural language processing identifies medical departments",
      },
      {
        label: "Intelligence",
        text: "AI analyzes issues to fetch a list of relevant specialists",
      },
      {
        label: "Matching",
        text: "Connects users with nearby available doctors instantly",
      },
    ],
  },
  {
    icon: (
      <img
        src="/conversational.svg"
        width={24}
        height={24}
        alt=""
        aria-hidden="true"
      />
    ),
    title: "Conversational Booking Flow",
    color: "#F0FDF4",
    accent: "#16A34A",
    points: [
      {
        label: "Interface",
        text: "Guided chat walks users through the entire process",
      },
      {
        label: "Function",
        text: "Step-by-step selection of doctors and time slots",
      },
      {
        label: "Clarity",
        text: "Displays live fee options for transparent healthcare planning",
      },
    ],
  },
  {
    icon: (
      <img
        src="/real-time.svg"
        width={24}
        height={24}
        alt=""
        aria-hidden="true"
      />
    ),
    title: "Real-Time Appointment Availability",
    color: "#FFF7ED",
    accent: "#EA580C",
    points: [
      {
        label: "Tracking",
        text: "Instant API checks for live slot availability",
      },
      {
        label: "Accuracy",
        text: "Prevents double-booking through real-time verification",
      },
      {
        label: "Efficiency",
        text: "Automatically redirects users if a selected slot is taken",
      },
    ],
  },
  {
    icon: (
      <img
        src="/patient.svg"
        width={24}
        height={24}
        alt=""
        aria-hidden="true"
      />
    ),
    title: "Patient Detail Validation",
    color: "#FFF1F2",
    accent: "#E11D48",
    points: [
      {
        label: "Overview",
        text: "Inline validation for names, age, and phone numbers",
      },
      {
        label: "Accuracy",
        text: "Ensures age (0–150) and 10-digit mobile formats are correct",
      },
      {
        label: "Security",
        text: "Validates all patient data before final booking submission",
      },
    ],
  },
  {
    icon: (
      <img
        src="/conversational.svg"
        width={24}
        height={24}
        alt=""
        aria-hidden="true"
      />
    ),
    title: "Animated Typing Indicator",
    color: "#FAF5FF",
    accent: "#9333EA",
    points: [
      {
        label: "Experience",
        text: "Lottie-based animations for a natural, human-like feel",
      },
      {
        label: "Engagement",
        text: "Staged message delays to simulate real-time conversation",
      },
      {
        label: "Usability",
        text: "Enhances the interactive feel of the medical chatbot",
      },
    ],
  },
  {
    icon: (
      <img
        src="/appointment.svg"
        width={24}
        height={24}
        alt=""
        aria-hidden="true"
      />
    ),
    title: "Appointment Confirmation Summary",
    color: "#F0FDF4",
    accent: "#059669",
    points: [
      {
        label: "Overview",
        text: "Structured post-booking view of all medical details",
      },
      {
        label: "Content",
        text: "Displays doctor name, hospital, time, and patient contact",
      },
      {
        label: "Transparency",
        text: "Provides a clear breakdown of fees and location info",
      },
    ],
  },
  {
    icon: (
      <img
        src="/copy-to-clipboard.svg"
        width={24}
        height={24}
        alt=""
        aria-hidden="true"
      />
    ),
    title: "Copy-to-Clipboard Detail Template",
    color: "#EFF6FF",
    accent: "#2563EB",
    points: [
      {
        label: "Function",
        text: "One-tap copying of pre-formatted patient templates",
      },
      {
        label: "Usage",
        text: "Allows users to fill in their information quickly and easily",
      },
      {
        label: "Speed",
        text: "Minimizes manual typing within the chat interface",
      },
    ],
  },
  {
    icon: (
      <img
        src="/post-booking.svg"
        width={24}
        height={24}
        alt=""
        aria-hidden="true"
      />
    ),
    title: "Post-Booking Actions",
    color: "#FFFBEB",
    accent: "#D97706",
    points: [
      {
        label: "Navigation",
        text: "Integrated options to get direct hospital directions",
      },
      {
        label: "Documentation",
        text: "Enables instant PDF summary downloads for records",
      },
      {
        label: "Workflow",
        text: "Provides a clean exit strategy or next-step transitions",
      },
    ],
  },
];

export default function Features() {
  return (
    <section id="features" className="bg-white py-16 lg:py-24">
      <div className="max-w-screen-2xl mx-auto px-4 sm:px-6">
        {/* Section header */}
        <div className="text-center mb-10 lg:mb-16">
          <span className="inline-flex items-center gap-2 bg-[#EEF2FF] text-[#003DF5] text-[11px] font-bold px-4 py-2 rounded-full tracking-widest uppercase mb-4">
            {/* <svg
              width="12"
              height="12"
              viewBox="0 0 24 24"
              fill="none"
              aria-hidden="true"
            >
              <path
                d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"
                fill="#003DF5"
              />
            </svg> */}
            Platform Features
          </span>
          <h2 className="text-[26px] sm:text-[34px] lg:text-[48px] font-extrabold text-[#0D1B4B] tracking-[-0.5px] sm:tracking-[-1px] leading-[1.1]">
            Everything You Need to{" "}
            <span className="text-[#003DF5]">Book Smarter</span>
          </h2>
          <p className="mt-4 text-[16px] text-[#6B7280] max-w-[560px] mx-auto leading-relaxed">
            CareBot AI combines intelligent automation with a human-like chat
            experience from symptom analysis to confirmed appointments.
          </p>
        </div>

        {/* Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {features.map(({ icon, title, color, accent, points }) => (
            <div
              key={title}
              className="group relative flex flex-col gap-5 rounded-2xl border border-[#E8EDF5] bg-white p-7 shadow-[0_2px_12px_rgba(0,0,0,0.05)] hover:shadow-[0_8px_32px_rgba(0,0,0,0.10)] hover:-translate-y-1 transition-all duration-200"
            >
              {/* Icon block */}
              <div
                className="w-12 h-12 rounded-xl flex items-center justify-center text-[22px] shrink-0"
                style={{ backgroundColor: color }}
              >
                {icon}
              </div>

              {/* Title */}
              <h3 className="text-[17px] font-bold text-[#0D1B4B] leading-snug">
                {title}
              </h3>

              {/* Points */}
              <ul className="flex flex-col gap-3">
                {points.map(({ label, text }) => (
                  <li key={label} className="flex items-start gap-2.5">
                    <span
                      className="mt-[3px] w-1.5 h-1.5 rounded-full shrink-0"
                      style={{ backgroundColor: accent }}
                    />
                    <span className="text-[13.5px] text-[#4B5563] leading-snug">
                      <span className="font-semibold text-[#1F2937]">
                        {label}:
                      </span>{" "}
                      {text}
                    </span>
                  </li>
                ))}
              </ul>

              {/* Accent bottom border on hover */}
              {/* <div
                className="absolute bottom-0 left-6 right-6 h-[2px] rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-200"
                style={{ backgroundColor: accent }}
              /> */}
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
