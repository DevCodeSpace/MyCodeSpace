const features = [
  {
    number: "01",
    icon: (
      <img
        src="/ai-skin.svg"
        width={26}
        height={26}
        alt=""
        aria-hidden="true"
      />
    ),
    title: "AI Skin Analysis",
    subtitle: "Face Scanning",
    desc: "Upload or capture a photo and our AI instantly analyzes your skin  detecting tone, texture, dryness, acne, pigmentation and more in seconds.",
    tags: ["Face Scanning", "AI Detection", "Smart Insights"],
    accent: "#F4C95D",
    accentBg: "#FFFBEB",
  },
  {
    number: "02",
    icon: (
      <img
        src="/detailed.svg"
        width={26}
        height={26}
        alt=""
        aria-hidden="true"
      />
    ),
    title: "Detailed Results",
    subtitle: "Structured Reports",
    desc: "Get a full skin health report with categorized scores, concern breakdowns and personalized care tips  all structured for easy reading.",
    tags: ["Skin Scores", "Care Tips", "Structured Reports"],
    accent: "#98B8F8",
    accentBg: "#EFF6FF",
  },
  {
    number: "03",
    icon: (
      <img
        src="/ai-chat.svg"
        width={26}
        height={26}
        alt=""
        aria-hidden="true"
      />
    ),
    title: "AI Chat Consultation",
    subtitle: "AI Assistant",
    desc: "Ask our AI anything about your skin, routines or products. Get real-time conversational guidance tailored to your unique skin profile.",
    tags: ["AI Assistant", "Routine Guidance", "Interactive Chat"],
    accent: "#22C55E",
    accentBg: "#F0FDF4",
  },
  {
    number: "04",
    icon: (
      <img
        src="/history.svg"
        width={26}
        height={26}
        alt=""
        aria-hidden="true"
      />
    ),
    title: "Scan History",
    subtitle: "Progress Tracking",
    desc: "Every scan is saved with a timestamp. Review past analyses, compare results over time and track how your skin health improves.",
    tags: ["Past Records", "Progress Tracking", "Timestamped Data"],
    accent: "#F4C95D",
    accentBg: "#FFFBEB",
  },
  {
    number: "05",
    icon: (
      <img src="/speech.svg" width={26} height={26} alt="" aria-hidden="true" />
    ),
    title: "Text-to-Speech",
    subtitle: "Voice Output",
    desc: "Listen to your skin analysis results and AI responses read aloud. Hands-free and fully accessible for every user.",
    tags: ["Voice Output", "Accessibility", "Hands-Free Use"],
    accent: "#98B8F8",
    accentBg: "#EFF6FF",
  },
  {
    number: "06",
    icon: (
      <img src="/user.svg" width={26} height={26} alt="" aria-hidden="true" />
    ),
    title: "User Profile",
    subtitle: "Profile Management",
    desc: "Manage your personal details, skin type preferences, privacy settings and access help & support  all from one clean profile screen.",
    tags: ["Profile Management", "Help & Support", "Privacy Controls"],
    accent: "#22C55E",
    accentBg: "#F0FDF4",
  },
  {
    number: "07",
    icon: (
      <img src="/secure.svg" width={26} height={26} alt="" aria-hidden="true" />
    ),
    title: "Secure Authentication",
    subtitle: "Firebase Login",
    desc: "Sign up and log in securely via Firebase. Includes password recovery, account protection and safe user access management.",
    tags: ["Firebase Login", "Password Recovery", "Account Security"],
    accent: "#F4C95D",
    accentBg: "#FFFBEB",
  },
];

export default function Features() {
  return (
    <section id="features" className="bg-white py-16 lg:py-24">
      <div className="max-w-screen-2xl mx-auto px-6">
        {/* ── Section header ── */}
        <div className="max-w-2xl mb-10 lg:mb-16">
          <span className="inline-flex items-center gap-2 bg-[#0F172A] text-[#F4C95D] text-[11px] font-bold px-3.5 py-1.5 rounded-full tracking-widest uppercase mb-5 font-(family-name:--font-noto)">
            {/* <svg
              width="10"
              height="10"
              viewBox="0 0 24 24"
              fill="none"
              aria-hidden="true"
            >
              <circle cx="12" cy="12" r="10" fill="#F4C95D" opacity="0.2" />
              <circle cx="12" cy="12" r="4" fill="#F4C95D" />
            </svg> */}
            Key Features
          </span>
          <h2 className="text-[26px] sm:text-[32px] lg:text-[48px] font-extrabold text-[#0F172A] tracking-[-1px] leading-[1.1] font-(family-name:--font-noto)">
            Everything your skin needs,{" "}
            <span className="text-[#F4C95D]">powered by AI</span>
          </h2>
          <p className="mt-4 text-[16px] text-sub-text-dark leading-relaxed font-(family-name:--font-noto)">
            From instant face scanning to personalized routines TrueGlow AI
            gives you a complete skincare intelligence toolkit in one app.
          </p>
        </div>

        {/* ── Feature grid  3 columns, last row centered ── */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
          {features.map(
            ({
              number,
              icon,
              title,
              subtitle,
              desc,
              tags,
              accent,
              accentBg,
            }) => (
              <div
                key={number}
                className="group relative flex flex-col gap-5 rounded-2xl border border-border bg-white p-6 hover:shadow-[0_8px_32px_rgba(15,23,42,0.08)] hover:-translate-y-1 transition-all duration-200 overflow-hidden"
              >
                {/* Faint number watermark */}
                <span className="absolute top-4 right-5 text-[52px] font-extrabold leading-none select-none pointer-events-none text-[#0F172A] opacity-[0.04] font-(family-name:--font-noto)">
                  {number}
                </span>

                {/* Icon */}
                <div
                  className="w-12 h-12 rounded-xl flex items-center justify-center shrink-0"
                  style={{ backgroundColor: accentBg }}
                >
                  {icon}
                </div>

                {/* Text */}
                <div className="flex flex-col gap-1.5">
                  <p
                    className="text-[11px] font-bold tracking-widest uppercase font-(family-name:--font-noto)"
                    style={{ color: accent }}
                  >
                    {subtitle}
                  </p>
                  <h3 className="text-[16px] font-bold text-[#0F172A] leading-snug font-(family-name:--font-noto)">
                    {title}
                  </h3>
                  <p className="text-[13.5px] text-[#64748B] leading-relaxed font-(family-name:--font-noto)">
                    {desc}
                  </p>
                </div>

                {/* Tags */}
                <div className="flex flex-wrap gap-1.5 mt-auto">
                  {tags.map((tag) => (
                    <span
                      key={tag}
                      className="text-[11px] font-semibold px-2.5 py-1 rounded-full border border-border text-slate-gray bg-bg-secondary font-(family-name:--font-noto)"
                    >
                      {tag}
                    </span>
                  ))}
                </div>

                {/* Bottom accent bar on hover */}
                <div
                  className="absolute bottom-0 left-0 right-0 h-0.75 opacity-0 group-hover:opacity-100 transition-opacity duration-200"
                  style={{ backgroundColor: accent }}
                />
              </div>
            ),
          )}
        </div>
      </div>
    </section>
  );
}
