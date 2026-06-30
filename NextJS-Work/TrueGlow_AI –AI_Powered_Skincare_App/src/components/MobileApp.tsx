const appFeatures = [
  {
    accent: "#F4C95D",
    accentBg: "#FFFBEB",
    icon: (
      <img
        src="/ai-skin.svg"
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
    title: "AI Face Scan",
    desc: "Instant skin analysis from your camera or gallery.",
  },
  {
    accent: "#98B8F8",
    accentBg: "#EFF6FF",
    icon: (
      <img
        src="/ai-chat.svg"
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
    title: "AI Chat",
    desc: "Ask skincare questions and get real-time AI guidance.",
  },
  {
    accent: "#22C55E",
    accentBg: "#F0FDF4",
    icon: (
      <img
        src="/history.svg"
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
    title: "Scan History",
    desc: "Track your skin journey with timestamped records.",
  },
  {
    accent: "#F4C95D",
    accentBg: "#FFFBEB",
    icon: (
      <img
        src="/detailed.svg"
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
    title: "Detailed Reports",
    desc: "Structured skin scores, concerns and care tips.",
  },
  {
    accent: "#98B8F8",
    accentBg: "#EFF6FF",
    icon: (
      <img
        src="/text-to-speech.svg"
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
    title: "Text-to-Speech",
    desc: "Listen to results and AI responses hands-free.",
  },
  {
    accent: "#22C55E",
    accentBg: "#F0FDF4",
    icon: (
      <img
        src="/secure.svg"
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
    title: "Secure Login",
    desc: "Firebase auth with password recovery built in.",
  },
];

const highlights = [
  { value: "50K+", label: "Active Users" },
  { value: "4.9★", label: "App Rating" },
  { value: "98%", label: "Scan Accuracy" },
];

export default function MobileApp() {
  return (
    <section
      id="mobile-app"
      className="bg-white py-16 lg:py-24 overflow-hidden"
    >
      <div className="max-w-screen-2xl mx-auto px-6">
        {/* ── Header ── */}
        <div className="max-w-2xl mb-10 lg:mb-16">
          <span className="inline-flex items-center gap-2 bg-[#0F172A] text-[#F4C95D] text-[11px] font-bold px-3.5 py-1.5 rounded-full tracking-widest uppercase mb-5 font-(family-name:--font-noto)">
            {/* <svg
              width="10"
              height="10"
              viewBox="0 0 24 24"
              fill="none"
              aria-hidden="true"
            >
              <rect x="5" y="2" width="14" height="20" rx="3" fill="#F4C95D" />
            </svg> */}
            Mobile App
          </span>
          <h2 className="text-[26px] sm:text-[32px] lg:text-[48px] font-extrabold text-[#0F172A] tracking-[-1px] leading-[1.1] font-(family-name:--font-noto)">
            Your skin expert,{" "}
            <span className="text-[#F4C95D]">in your pocket</span>
          </h2>
          <p className="mt-4 text-[16px] text-sub-text-dark leading-relaxed font-(family-name:--font-noto)">
            TrueGlow AI is available on iOS and Android everything you need for
            intelligent skincare, always within reach.
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-14 items-center">
          {/* ── Left  features + stats ── */}
          <div className="flex flex-col gap-10">
            {/* Feature grid */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              {appFeatures.map(({ accentBg, icon, title, desc }) => (
                <div
                  key={title}
                  className="flex items-start gap-4 bg-[#F8FAFC] rounded-xl border border-border p-4 hover:shadow-[0_4px_16px_rgba(15,23,42,0.06)] hover:-translate-y-0.5 transition-all duration-200"
                >
                  <div
                    className="w-9 h-9 rounded-lg flex items-center justify-center shrink-0"
                    style={{ backgroundColor: accentBg }}
                  >
                    {icon}
                  </div>
                  <div>
                    <p className="text-[13.5px] font-bold text-[#0F172A] font-(family-name:--font-noto)">
                      {title}
                    </p>
                    <p className="text-[12px] text-[#64748B] leading-relaxed mt-0.5 font-(family-name:--font-noto)">
                      {desc}
                    </p>
                  </div>
                </div>
              ))}
            </div>

            {/* Stats strip */}
            <div className="grid grid-cols-3 gap-4">
              {highlights.map(({ value, label }) => (
                <div
                  key={label}
                  className="flex flex-col items-center text-center bg-[#0F172A] rounded-2xl px-4 py-5"
                >
                  <span className="text-[24px] font-extrabold text-[#F4C95D] leading-none tracking-tight font-(family-name:--font-noto)">
                    {value}
                  </span>
                  <span className="text-[11.5px] text-white/50 font-medium mt-1.5 font-(family-name:--font-noto)">
                    {label}
                  </span>
                </div>
              ))}
            </div>

            {/* App store buttons */}
            <div className="flex flex-col gap-3">
              <p className="text-[12px] font-bold text-sub-text-medium uppercase tracking-widest font-(family-name:--font-noto)">
                Available on
              </p>
              <div className="flex items-center gap-3 flex-wrap">
                <a
                  href="#"
                  className="inline-flex items-center gap-3 bg-[#0F172A] text-white px-5 py-3 rounded-xl hover:bg-[#1e293b] transition-colors duration-150"
                >
                  <svg
                    width="20"
                    height="20"
                    viewBox="0 0 24 24"
                    fill="white"
                    aria-hidden="true"
                  >
                    <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
                  </svg>
                  <div className="flex flex-col leading-tight">
                    <span className="text-[10px] text-white/50 font-(family-name:--font-noto)">
                      Download on the
                    </span>
                    <span className="text-[14px] font-bold font-(family-name:--font-noto)">
                      App Store
                    </span>
                  </div>
                </a>
                <a
                  href="#"
                  className="inline-flex items-center gap-3 bg-[#0F172A] text-white px-5 py-3 rounded-xl hover:bg-[#1e293b] transition-colors duration-150"
                >
                  <svg
                    width="20"
                    height="20"
                    viewBox="0 0 24 24"
                    fill="white"
                    aria-hidden="true"
                  >
                    <path d="M3.18 23.76c.3.17.63.24.97.2l12.45-12.45L13.06 8l-9.88 15.76zm16.9-10.81L17.3 11.4l-3.5 3.5 3.5 3.5 2.81-1.56c.8-.45.8-1.64-.03-2.09zM2.15.79C1.9 1.06 1.75 1.47 1.75 2v20c0 .53.15.94.4 1.21l.06.06L13.06 12 2.21.73l-.06.06zm11.88 10.24L2.58.57C2.9.4 3.27.38 3.6.56l13.08 7.44-3.65 3.03z" />
                  </svg>
                  <div className="flex flex-col leading-tight">
                    <span className="text-[10px] text-white/50 font-(family-name:--font-noto)">
                      Get it on
                    </span>
                    <span className="text-[14px] font-bold font-(family-name:--font-noto)">
                      Google Play
                    </span>
                  </div>
                </a>
              </div>
            </div>
          </div>

          {/* ── Right  phone mockup ── */}
          <div className="hidden lg:flex items-center justify-center">
            <div className="relative py-10 px-8">
              {/* Soft glow background */}
              <div className="absolute inset-0 bg-gradient-to-br from-[#FFFBEB] via-[#FFF8F3] to-[#EFF6FF] rounded-3xl" />

              {/* Phone frame */}
              <div className="relative w-[240px] h-[480px] bg-[#0F172A] rounded-[44px] shadow-[0_32px_80px_rgba(15,23,42,0.35)] border-[6px] border-[#1E293B]">
                {/* Dynamic island */}
                <div className="absolute top-3 left-1/2 -translate-x-1/2 w-20 h-5 bg-[#0A1020] rounded-full z-20" />

                {/* Screen */}
                <div className="absolute inset-[3px] rounded-[38px] bg-[#FFF8F3] overflow-hidden flex flex-col">
                  {/* Status bar */}
                  <div className="flex items-center justify-between px-5 pt-9 pb-1">
                    <span className="text-[10px] font-bold text-[#0F172A]">
                      9:41
                    </span>
                    <div className="flex items-end gap-[2px]">
                      {[4, 6, 8, 10].map((h, i) => (
                        <div
                          key={i}
                          className="w-[3px] bg-[#0F172A] rounded-sm"
                          style={{ height: h }}
                        />
                      ))}
                    </div>
                  </div>

                  {/* App header */}
                  <div className="flex items-center justify-between px-5 py-2.5">
                    <p className="text-[13px] font-extrabold text-[#0F172A]">
                      My Skin Report
                    </p>
                    <div className="w-7 h-7 rounded-full bg-[#F4C95D] flex items-center justify-center">
                      <span className="text-[11px] font-black text-[#0F172A]">
                        S
                      </span>
                    </div>
                  </div>

                  {/* Score ring */}
                  <div className="flex items-center justify-center my-3">
                    <div className="relative w-28 h-28">
                      <div className="absolute inset-0 rounded-full border-[3px] border-[#F4C95D]/20" />
                      <div className="absolute inset-0 rounded-full border-[3px] border-[#F4C95D] border-t-transparent rotate-[-60deg]" />
                      <div className="absolute inset-3 rounded-full bg-[#FFFBEB] flex flex-col items-center justify-center">
                        <p className="text-[20px] font-extrabold text-[#0F172A] leading-none">
                          87
                        </p>
                        <p className="text-[8px] text-[#94A3B8] font-semibold mt-0.5">
                          Overall
                        </p>
                      </div>
                    </div>
                  </div>

                  {/* Score bars */}
                  <div className="px-5 flex flex-col gap-2">
                    {[
                      { label: "Hydration", val: 78, color: "#98B8F8" },
                      { label: "Texture", val: 85, color: "#22C55E" },
                      { label: "Tone", val: 90, color: "#F4C95D" },
                    ].map(({ label, val, color }) => (
                      <div key={label}>
                        <div className="flex justify-between mb-1">
                          <span className="text-[9px] font-semibold text-[#64748B]">
                            {label}
                          </span>
                          <span className="text-[9px] font-bold text-[#0F172A]">
                            {val}%
                          </span>
                        </div>
                        <div className="h-1.5 bg-[#F1F5F9] rounded-full">
                          <div
                            className="h-full rounded-full"
                            style={{ width: `${val}%`, backgroundColor: color }}
                          />
                        </div>
                      </div>
                    ))}
                  </div>

                  {/* Skincare tip card */}
                  <div className="mx-4 mt-3 p-3 bg-[#0F172A] rounded-xl">
                    <p className="text-[8px] font-bold text-[#F4C95D] uppercase tracking-widest mb-1">
                      Today&apos;s Tip
                    </p>
                    <p className="text-[10px] font-medium text-white/70 leading-relaxed">
                      Use SPF 30+ moisturizer daily to boost your hydration
                      score.
                    </p>
                  </div>

                  {/* Bottom tab bar */}
                  <div className="mt-auto flex items-center justify-around px-5 py-3 border-t border-[#F1F5F9]">
                    {[
                      <svg
                        key="home"
                        width="14"
                        height="14"
                        viewBox="0 0 24 24"
                        fill="none"
                      >
                        <path
                          d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"
                          stroke="#CBD5E1"
                          strokeWidth="2"
                          strokeLinecap="round"
                        />
                      </svg>,
                      <svg
                        key="scan"
                        width="14"
                        height="14"
                        viewBox="0 0 24 24"
                        fill="none"
                      >
                        <rect
                          x="3"
                          y="3"
                          width="18"
                          height="18"
                          rx="3"
                          stroke="#0F172A"
                          strokeWidth="2"
                        />
                        <circle
                          cx="12"
                          cy="12"
                          r="4"
                          stroke="#0F172A"
                          strokeWidth="2"
                        />
                      </svg>,
                      <svg
                        key="chat"
                        width="14"
                        height="14"
                        viewBox="0 0 24 24"
                        fill="none"
                      >
                        <path
                          d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"
                          stroke="#CBD5E1"
                          strokeWidth="2"
                          strokeLinecap="round"
                        />
                      </svg>,
                      <svg
                        key="user"
                        width="14"
                        height="14"
                        viewBox="0 0 24 24"
                        fill="none"
                      >
                        <circle
                          cx="12"
                          cy="8"
                          r="4"
                          stroke="#CBD5E1"
                          strokeWidth="2"
                        />
                        <path
                          d="M4 20c0-4 3.582-7 8-7s8 3 8 7"
                          stroke="#CBD5E1"
                          strokeWidth="2"
                          strokeLinecap="round"
                        />
                      </svg>,
                    ].map((icon, i) => (
                      <div
                        key={i}
                        className="w-8 h-8 rounded-xl flex items-center justify-center"
                        style={{
                          backgroundColor: i === 1 ? "#F4C95D" : "transparent",
                        }}
                      >
                        {icon}
                      </div>
                    ))}
                  </div>
                </div>
              </div>

              {/* Floating badge — accuracy */}
              <div className="absolute top-6 -right-4 bg-white rounded-2xl border border-border px-3.5 py-2.5 shadow-[0_8px_24px_rgba(15,23,42,0.10)] flex items-center gap-2.5">
                <div
                  className="w-8 h-8 rounded-xl flex items-center justify-center shrink-0"
                  style={{ backgroundColor: "#FFFBEB" }}
                >
                  <svg
                    width="14"
                    height="14"
                    viewBox="0 0 24 24"
                    fill="none"
                    aria-hidden="true"
                  >
                    <path
                      d="M9 12l2 2 4-4m6 2a9 9 0 1 1-18 0 9 9 0 0 1 18 0z"
                      stroke="#F4C95D"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    />
                  </svg>
                </div>
                <div>
                  <p className="text-[11px] font-extrabold text-[#0F172A] leading-none">
                    98% Accuracy
                  </p>
                  <p className="text-[10px] text-[#64748B] mt-0.5">
                    AI skin detection
                  </p>
                </div>
              </div>

              {/* Floating badge — rating */}
              <div className="absolute bottom-6 -left-4 bg-white rounded-2xl border border-border px-3.5 py-2.5 shadow-[0_8px_24px_rgba(15,23,42,0.10)] flex items-center gap-2.5">
                <div className="w-8 h-8 rounded-xl bg-[#FFFBEB] flex items-center justify-center shrink-0">
                  <svg
                    width="14"
                    height="14"
                    viewBox="0 0 24 24"
                    fill="#F4C95D"
                    aria-hidden="true"
                  >
                    <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" />
                  </svg>
                </div>
                <div>
                  <p className="text-[11px] font-extrabold text-[#0F172A] leading-none">
                    4.9 / 5.0
                  </p>
                  <p className="text-[10px] text-[#64748B] mt-0.5">
                    50K+ users
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
