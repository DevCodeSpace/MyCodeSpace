import Image from "next/image";

const stats = [
  { value: "98%", label: "Scan Accuracy" },
  { value: "50K+", label: "Active Users" },
  { value: "4.9★", label: "App Rating" },
];

const bullets = [
  {
    icon: (
      <svg
        width="15"
        height="15"
        viewBox="0 0 24 24"
        fill="none"
        aria-hidden="true"
      >
        <path
          d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 14l-4-4 1.41-1.41L11 13.17l6.59-6.59L19 8l-8 8z"
          fill="#F4C95D"
        />
      </svg>
    ),
    text: "Instant face scan  results in seconds",
  },
  {
    icon: (
      <svg
        width="15"
        height="15"
        viewBox="0 0 24 24"
        fill="none"
        aria-hidden="true"
      >
        <path
          d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 14l-4-4 1.41-1.41L11 13.17l6.59-6.59L19 8l-8 8z"
          fill="#F4C95D"
        />
      </svg>
    ),
    text: "AI detects tone, texture & skin concerns",
  },
  {
    icon: (
      <svg
        width="15"
        height="15"
        viewBox="0 0 24 24"
        fill="none"
        aria-hidden="true"
      >
        <path
          d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 14l-4-4 1.41-1.41L11 13.17l6.59-6.59L19 8l-8 8z"
          fill="#F4C95D"
        />
      </svg>
    ),
    text: "Personalized skincare routine & product tips",
  },
  {
    icon: (
      <svg
        width="15"
        height="15"
        viewBox="0 0 24 24"
        fill="none"
        aria-hidden="true"
      >
        <path
          d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 14l-4-4 1.41-1.41L11 13.17l6.59-6.59L19 8l-8 8z"
          fill="#F4C95D"
        />
      </svg>
    ),
    text: "Track skin progress with timestamped history",
  },
];

export default function Hero() {
  return (
    <section className="relative min-h-screen bg-[#FFF8F3] flex items-center pt-[72px] overflow-hidden">
      {/* Decorative circle  top right */}
      <div
        aria-hidden="true"
        className="pointer-events-none absolute -top-24 -right-24 w-120 h-120 rounded-full border border-[#F4C95D]/20"
      />
      <div
        aria-hidden="true"
        className="pointer-events-none absolute -top-12 -right-12 w-80 h-80 rounded-full border border-[#F4C95D]/15"
      />

      <div className="relative max-w-screen-2xl mx-auto px-6 w-full py-10 sm:py-16 lg:py-20 flex flex-col lg:flex-row items-center gap-12 lg:gap-16">
        {/* ── Left  content ── */}
        <div className="w-full max-w-[calc(100vw-3rem)] min-w-0 lg:max-w-none lg:w-[50%] flex flex-col gap-8">
          {/* Eyebrow badge */}
          <div className="flex items-center gap-2.5">
            <span className="inline-flex items-center gap-2 bg-[#0F172A] text-[#F4C95D] text-[11px] font-bold px-3.5 py-1.5 rounded-full tracking-widest uppercase font-(family-name:--font-noto)">
              {/* <span className="w-1.5 h-1.5 rounded-full bg-[#F4C95D]" /> */}
              AI-Powered Skin Analysis
            </span>
            <span className="inline-flex items-center gap-1.5 border border-[#0F172A]/15 text-[#0F172A]/50 text-[11px] font-medium px-3.5 py-1.5 rounded-full font-(family-name:--font-noto)">
              iOS &amp; Android
            </span>
          </div>

          {/* Headline */}
          <h1 className="text-[28px] sm:text-[38px] lg:text-[58px] font-extrabold text-[#0F172A] leading-[1.06] tracking-[-1.5px] font-(family-name:--font-noto)">
            Know Your Skin. <br />
            <span className="text-[#F4C95D]">Glow</span> With Confidence.
          </h1>

          {/* Description */}
          <p className="text-[16px] text-sub-text-dark leading-[1.85] max-w-full sm:max-w-125 font-(family-name:--font-noto)">
            TrueGlow AI scans your face, analyzes your skin tone, texture and
            concerns, then delivers{" "}
            <span className="text-[#0F172A] font-semibold">
              personalized skincare recommendations
            </span>{" "}
            powered by advanced AI in seconds.
          </p>

          {/* Bullet list */}
          <ul className="flex flex-col gap-3.5">
            {bullets.map(({ icon, text }) => (
              <li key={text} className="flex items-center gap-3">
                <span className="shrink-0">{icon}</span>
                <span className="text-[14px] text-sub-text-dark font-medium leading-snug font-(family-name:--font-noto)">
                  {text}
                </span>
              </li>
            ))}
          </ul>

          {/* CTAs */}
          <div className="flex flex-col sm:flex-row sm:flex-wrap items-stretch sm:items-center gap-3 mt-1">
            <a
              href="#features"
              className="inline-flex w-full sm:w-auto items-center justify-center gap-2.5 bg-[#0F172A] text-white text-[14.5px] font-bold px-7 py-3.5 rounded-xl hover:bg-[#1e293b] active:scale-[0.97] transition-all duration-150 shadow-[0_4px_20px_rgba(15,23,42,0.18)] font-(family-name:--font-noto)"
            >
              Analyze My Skin
              <svg
                width="15"
                height="15"
                viewBox="0 0 16 16"
                fill="none"
                aria-hidden="true"
              >
                <path
                  d="M3 8h10M9 4l4 4-4 4"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
              </svg>
            </a>
            <a
              href="#how-it-works"
              className="inline-flex w-full sm:w-auto items-center justify-center gap-2.5 bg-[#F4C95D] text-[#0F172A] text-[14.5px] font-bold px-7 py-3.5 rounded-xl hover:bg-[#e8b84b] active:scale-[0.97] transition-all duration-150 font-(family-name:--font-noto)"
            >
              See How It Works
            </a>
          </div>

          {/* Stats row */}
          <div className="flex flex-wrap items-center gap-x-8 gap-y-3 pt-6 border-t border-[#0F172A]/10">
            {stats.map(({ value, label }) => (
              <div key={label} className="flex flex-col gap-1">
                <span className="text-[26px] font-extrabold text-[#0F172A] leading-none tracking-[-0.5px] font-(family-name:--font-noto)">
                  {value}
                </span>
                <span className="text-[12px] text-sub-text-medium font-medium font-(family-name:--font-noto)">
                  {label}
                </span>
              </div>
            ))}
          </div>
        </div>

        {/* ── Right  illustration ── */}
        <div className="hidden lg:flex lg:w-[50%] items-center justify-center">
          <Image
            src="/Illustration.png"
            alt="TrueGlow AI skin analysis illustration"
            width={720}
            height={720}
            priority
            className="w-full max-w-[720px] h-auto object-contain"
          />
        </div>
      </div>
    </section>
  );
}
