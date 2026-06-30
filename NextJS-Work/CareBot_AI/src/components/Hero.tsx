import Image from "next/image";

const bullets = [
  { text: "Describe symptoms — get the right specialist instantly", color: "#003DF5" },
  { text: "Book appointments in under 60 seconds", color: "#16A34A" },
  { text: "Works across 30+ medical specialties", color: "#0096DE" },
  { text: "HIPAA-compliant, end-to-end encrypted", color: "#9333EA" },
];

// const stats = [
//   { value: "10K+", label: "Patients Served" },
//   { value: "30+", label: "Specialties" },
//   { value: "< 60s", label: "Avg. Booking" },
//   { value: "4.9★", label: "Rating" },
// ];

export default function Hero({
  tickerVisible = true,
}: {
  tickerVisible?: boolean;
}) {
  return (
    <section
      className="relative min-h-screen bg-gradient-to-br from-[#EEF2FF] via-[#F0F4FF] to-[#E8EDFF] flex items-center overflow-hidden"
      style={{ paddingTop: tickerVisible ? "114px" : "76px" }}
    >
      {/* Background orbs */}
      <div className="pointer-events-none absolute -top-32 -left-32 w-[500px] h-[500px] rounded-full bg-[#C7D3FF] opacity-25 blur-[120px]" />
      <div className="pointer-events-none absolute bottom-0 right-0 w-[420px] h-[420px] rounded-full bg-[#A5B8FF] opacity-20 blur-[100px]" />
      {/* Subtle dot grid */}
      <div
        className="pointer-events-none absolute inset-0 opacity-[0.025]"
        style={{
          backgroundImage: "radial-gradient(#003DF5 1px, transparent 1px)",
          backgroundSize: "28px 28px",
        }}
      />

      <div className="relative max-w-screen-2xl mx-auto px-4 sm:px-6 w-full py-12 sm:py-16 lg:py-20 flex flex-col lg:flex-row items-center gap-10 lg:gap-16">
        {/* ── Left column ── */}
        <div className="w-full lg:w-[55%] flex flex-col gap-6">
          {/* Badge row */}
          <div className="flex flex-wrap items-center gap-2.5">
            <span className="inline-flex items-center gap-2 bg-[#0D1B4B] text-white text-[11px] font-bold px-4 py-2 rounded-full tracking-widest uppercase shadow-md">
              <svg
                width="12"
                height="12"
                viewBox="0 0 24 24"
                fill="none"
                aria-hidden="true"
              >
                <path
                  d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"
                  stroke="white"
                  strokeWidth="2.2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
              </svg>
              AI-First Platform
            </span>
            <span className="inline-flex items-center gap-2 bg-white/80 backdrop-blur border border-[#D6DCF0] text-[#374151] text-[11px] font-semibold px-4 py-2 rounded-full shadow-sm">
              {/* <span className="relative flex h-2 w-2 shrink-0">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75" />
                <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-500" />
              </span> */}
              Trusted by 10,000+ Patients
            </span>
          </div>

          {/* Headline */}
          <h1 className="text-[32px] sm:text-[44px] lg:text-[58px] font-extrabold text-[#0D1B4B] leading-[1.08] tracking-[-1px] sm:tracking-[-1.5px]">
            Book Your Doctor{" "}
            <span className="relative inline-block">
              <span className="relative z-10">Instantly</span>
              <svg
                className="absolute -bottom-1 left-0 w-full"
                viewBox="0 0 220 10"
                preserveAspectRatio="none"
                aria-hidden="true"
              >
                <path
                  d="M2 7 Q110 2 218 7"
                  stroke="#003DF5"
                  strokeWidth="3.5"
                  fill="none"
                  strokeLinecap="round"
                />
              </svg>
            </span>
            <br />
            <span className="text-[#7B88C2]">with AI Assistance</span>
          </h1>

          {/* Description */}
          <p className="text-[15px] sm:text-[16px] text-[#4B5563] leading-[1.8] max-w-[500px]">
            CareBot AI is a{" "}
            <strong className="text-[#0D1B4B] font-semibold">
              conversational medical assistant
            </strong>{" "}
            that understands your symptoms, finds the right specialist, and
            books appointments all in one chat.
          </p>

          {/* Bullets */}
          <ul className="flex flex-col gap-3">
            {bullets.map(({ text, color }) => (
              <li key={text} className="flex items-center gap-3">
                <span
                  className="w-5 h-5 rounded-full flex items-center justify-center shrink-0"
                  style={{ backgroundColor: color + "18" }}
                >
                  <svg width="11" height="11" viewBox="0 0 24 24" fill="none" aria-hidden="true">
                    <path d="M20 6L9 17l-5-5" stroke={color} strokeWidth="2.8" strokeLinecap="round" strokeLinejoin="round" />
                  </svg>
                </span>
                <span className="text-[14px] sm:text-[15px] font-medium text-[#374151]">{text}</span>
              </li>
            ))}
          </ul>

          {/* CTAs */}
          <div className="flex flex-wrap items-center gap-3 mt-1">
            <a
              href="#contact"
              className="inline-flex items-center gap-2.5 bg-[#003DF5] hover:bg-[#0031CC] text-white text-[15px] font-bold px-7 py-3.5 rounded-xl transition-all duration-200 shadow-[0_4px_20px_rgba(0,61,245,0.35)] hover:shadow-[0_6px_28px_rgba(0,61,245,0.45)] hover:-translate-y-0.5 active:scale-[0.97]"
            >
              Get Started Free
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
              className="inline-flex items-center gap-2 bg-white hover:bg-[#F5F7FF] text-[#0D1B4B] text-[15px] font-bold px-7 py-3.5 rounded-xl border border-[#C7D0EE] transition-all duration-200 shadow-sm hover:shadow-md hover:-translate-y-0.5 active:scale-[0.97]"
            >
              See How It Works
            </a>
          </div>

          {/* Stats strip */}
          {/* <div className="mt-1 flex items-center gap-0 border-t border-[#D6DCF0] pt-5">
            {stats.map(({ value, label }, i) => (
              <div key={label} className="flex items-center">
                <div className="flex flex-col px-4 sm:px-5 first:pl-0">
                  <span className="text-[20px] sm:text-[22px] font-extrabold text-[#0D1B4B] leading-none">
                    {value}
                  </span>
                  <span className="text-[11px] sm:text-[12px] text-[#6B7280] mt-0.5 font-medium whitespace-nowrap">
                    {label}
                  </span>
                </div>
                {i < stats.length - 1 && (
                  <div className="w-px h-8 bg-[#D6DCF0] shrink-0" />
                )}
              </div>
            ))}
          </div> */}
        </div>

        {/* ── Right column  Illustration ── */}
        <div className="w-full lg:w-[45%] flex items-center justify-center pb-8 pr-6 lg:pb-0 lg:pr-0">
          <Image
            src="/illustration.png"
            alt="CareBot AI – book a doctor instantly with AI assistance"
            width={720}
            height={720}
            priority
            className="w-full max-w-[720px] h-auto rounded-2xl"
          />
        </div>
      </div>
    </section>
  );
}
