const steps = [
  {
    number: "01",
    accent: "#F4C95D",
    accentBg: "#FFFBEB",
    icon: (
      <img
        src="/upload.svg"
        width={24}
        height={24}
        alt=""
        aria-hidden="true"
        style={{
          filter:
            "brightness(0) saturate(100%) invert(84%) sepia(45%) saturate(868%) hue-rotate(338deg) brightness(101%) contrast(92%)",
        }}
      />
    ),
    title: "Upload or Capture",
    desc: "Take a selfie or upload a photo directly in the app. Our AI accepts any clear front-facing photo in seconds.",
    bullets: [
      "Front-facing photo",
      "Camera or gallery upload",
      "Instant processing",
    ],
  },
  {
    number: "02",
    accent: "#98B8F8",
    accentBg: "#EFF6FF",
    icon: (
      <img
        src="/scan.svg"
        width={24}
        height={24}
        alt=""
        aria-hidden="true"
        style={{
          filter:
            "brightness(0) saturate(100%) invert(76%) sepia(28%) saturate(1142%) hue-rotate(191deg) brightness(101%) contrast(95%)",
        }}
      />
    ),
    title: "AI Scans Your Skin",
    desc: "TrueGlow AI analyzes your skin tone, texture, moisture level, acne, pigmentation and other concerns using advanced computer vision.",
    bullets: [
      "Tone & texture detection",
      "Concern identification",
      "Deep AI analysis",
    ],
  },
  {
    number: "03",
    accent: "#22C55E",
    accentBg: "#F0FDF4",
    icon: (
      <img
        src="/detailed.svg"
        width={24}
        height={24}
        alt=""
        aria-hidden="true"
        style={{
          filter:
            "brightness(0) saturate(100%) invert(57%) sepia(72%) saturate(503%) hue-rotate(93deg) brightness(94%) contrast(92%)",
        }}
      />
    ),
    title: "Get Your Report",
    desc: "Receive a structured skin health report with categorized scores, concern details and a personalized skincare routine tailored just for you.",
    bullets: [
      "Skin health scores",
      "Concern breakdown",
      "Personalized routine",
    ],
  },
  {
    number: "04",
    accent: "#F4C95D",
    accentBg: "#FFFBEB",
    icon: (
      <img
        src="/chat.svg"
        width={24}
        height={24}
        alt=""
        aria-hidden="true"
        style={{
          filter:
            "brightness(0) saturate(100%) invert(84%) sepia(45%) saturate(868%) hue-rotate(338deg) brightness(101%) contrast(92%)",
        }}
      />
    ),
    title: "Chat with AI",
    desc: "Ask our AI assistant follow-up questions, get product recommendations or request routine guidance  anytime, in real-time conversation.",
    bullets: [
      "Ask anything skincare",
      "Product recommendations",
      "Real-time responses",
    ],
  },
  {
    number: "05",
    accent: "#98B8F8",
    accentBg: "#EFF6FF",
    icon: (
      <img
        src="/progress.svg"
        width={24}
        height={24}
        alt=""
        aria-hidden="true"
        style={{
          filter:
            "brightness(0) saturate(100%) invert(76%) sepia(28%) saturate(1142%) hue-rotate(191deg) brightness(101%) contrast(95%)",
        }}
      />
    ),
    title: "Track Progress",
    desc: "All your scans are saved with timestamps. Monitor how your skin changes over time and celebrate every improvement.",
    bullets: [
      "Timestamped records",
      "Side-by-side comparison",
      "Progress insights",
    ],
  },
];

export default function HowItWorks() {
  return (
    <section
      id="how-it-works"
      className="bg-[#F8FAFC] py-16 lg:py-24 overflow-hidden"
    >
      <div className="max-w-screen-2xl mx-auto px-6">
        {/* ── Header ── */}
        <div className="max-w-2xl mb-10 lg:mb-16">
          <span className="inline-flex items-center gap-2 bg-[#0F172A] text-[#F4C95D] text-[11px] font-bold px-3.5 py-1.5 rounded-full tracking-widest uppercase mb-5 font-(family-name:--font-noto)">
            How It Works
          </span>
          <h2 className="text-[24px] sm:text-[32px] lg:text-[48px] font-extrabold text-[#0F172A] tracking-[-1px] leading-[1.1] font-(family-name:--font-noto)">
            From photo to <span className="text-[#F4C95D]">glowing skin</span>{" "}
            in 5 steps
          </h2>
          <p className="mt-4 text-[16px] text-sub-text-dark leading-relaxed font-(family-name:--font-noto)">
            TrueGlow AI makes professional-grade skin analysis simple, fast and
            deeply personal — no dermatologist appointment needed.
          </p>
        </div>

        {/* ── Steps timeline ── */}
        <div className="flex flex-col">
          {steps.map(
            ({ number, accent, accentBg, icon, title, desc, bullets }, i) => (
              <div key={number} className="flex gap-4 sm:gap-6">
                {/* Timeline indicator */}
                <div className="flex flex-col items-center shrink-0">
                  <div
                    className="w-9 h-9 rounded-full flex items-center justify-center text-[13px] font-black text-white shrink-0 shadow-sm"
                    style={{ backgroundColor: accent }}
                  >
                    {i + 1}
                  </div>
                  {i < steps.length - 1 && (
                    <div className="w-0.5 flex-1 my-1 bg-border" />
                  )}
                </div>

                {/* Step card */}
                <div className={`flex-1 ${i < steps.length - 1 ? "pb-2" : ""}`}>
                  <div className="bg-white rounded-2xl border border-border p-4 sm:p-5 hover:shadow-[0_4px_20px_rgba(15,23,42,0.07)] hover:-translate-y-0.5 transition-all duration-200">
                    <div className="flex flex-col sm:flex-row items-start gap-4 sm:gap-8">
                      {/* Left: icon + title + description */}
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-3 mb-2">
                          <div
                            className="w-11 h-11 rounded-xl flex items-center justify-center shrink-0"
                            style={{ backgroundColor: accentBg }}
                          >
                            {icon}
                          </div>
                          <div>
                            <p
                              className="text-[10.5px] font-black tracking-[0.15em] uppercase font-(family-name:--font-noto)"
                              style={{ color: accent }}
                            >
                              Step {number}
                            </p>
                            <h3 className="text-[15px] sm:text-[17px] font-extrabold text-[#0F172A] leading-snug font-(family-name:--font-noto)">
                              {title}
                            </h3>
                          </div>
                        </div>
                        <p className="text-[13.5px] text-[#64748B] leading-relaxed font-(family-name:--font-noto) pl-[52px]">
                          {desc}
                        </p>
                      </div>

                      {/* Right: bullets — top-aligned with the card */}
                      <ul className="flex flex-col gap-2.5 sm:w-52 shrink-0">
                        {bullets.map((b) => (
                          <li key={b} className="flex items-center gap-2">
                            <span
                              className="w-5 h-5 rounded-full flex items-center justify-center shrink-0"
                              style={{ backgroundColor: accentBg }}
                            >
                              <svg
                                width="9"
                                height="9"
                                viewBox="0 0 24 24"
                                fill="none"
                                aria-hidden="true"
                              >
                                <path
                                  d="M5 12l5 5L20 7"
                                  stroke={accent}
                                  strokeWidth="2.5"
                                  strokeLinecap="round"
                                  strokeLinejoin="round"
                                />
                              </svg>
                            </span>
                            <span className="text-[12.5px] text-sub-text-dark font-medium font-(family-name:--font-noto)">
                              {b}
                            </span>
                          </li>
                        ))}
                      </ul>
                    </div>
                  </div>
                </div>
              </div>
            ),
          )}
        </div>

        {/* ── Bottom CTA ── */}
        <div className="mt-12 lg:mt-16 flex flex-col sm:flex-row items-center justify-center gap-4">
          <a
            href="#contact"
            className="inline-flex items-center gap-2 bg-[#0F172A] text-white text-[15px] font-bold px-8 py-4 rounded-xl hover:bg-[#1e293b] transition-colors duration-150 shadow-[0_4px_20px_rgba(15,23,42,0.18)] font-(family-name:--font-noto)"
          >
            Start Your Skin Analysis
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
          </a>
          <a
            href="#features"
            className="inline-flex items-center gap-2 border border-border text-[#0F172A] text-[15px] font-bold px-8 py-4 rounded-xl hover:border-sub-text-light hover:bg-[#F8FAFC] transition-colors duration-150 font-(family-name:--font-noto)"
          >
            Explore All Features
          </a>
        </div>
      </div>
    </section>
  );
}
