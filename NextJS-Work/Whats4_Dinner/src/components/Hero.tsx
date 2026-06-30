const bullets = [
  {
    icon: (
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" aria-hidden="true">
        <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" fill="#E63946" />
      </svg>
    ),
    text: "Flash & Weekly Deals  create, schedule and manage in minutes",
  },
  {
    icon: (
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" aria-hidden="true">
        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" stroke="#E63946" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
        <circle cx="9" cy="7" r="4" stroke="#E63946" strokeWidth="2" />
        <path d="M23 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75" stroke="#E63946" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
      </svg>
    ),
    text: "Role-based dashboards for Super Admin, Restaurant & Staff",
  },
  {
    icon: (
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" aria-hidden="true">
        <rect x="3" y="3" width="18" height="18" rx="2" stroke="#E63946" strokeWidth="2" />
        <path d="M3 9h18M9 21V9" stroke="#E63946" strokeWidth="2" strokeLinecap="round" />
      </svg>
    ),
    text: "QR-based redemption tracking with real-time scan history",
  },
  {
    icon: (
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" aria-hidden="true">
        <polyline points="22 12 18 12 15 21 9 3 6 12 2 12" stroke="#E63946" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
      </svg>
    ),
    text: "Analytics, KPI charts & Excel exports  all in one platform",
  },
];

// const stats = [
//   { value: "120+", label: "Restaurants" },
//   { value: "3",    label: "User Roles"  },
//   { value: "4.8★", label: "App Rating"  },
// ];

export default function Hero() {
  return (
    <section className="relative min-h-screen bg-bg flex items-center pt-[64px] sm:pt-[72px] overflow-hidden">

      {/* Subtle tinted background shape  top right */}
      <div
        aria-hidden="true"
        className="pointer-events-none absolute top-0 right-0 w-[80%] sm:w-[65%] lg:w-[55%] h-full bg-[#FFF5F5]"
        style={{ clipPath: "polygon(12% 0, 100% 0, 100% 100%, 0% 100%)" }}
      />

      {/* Faint grid overlay on the tinted side */}
      <div
        aria-hidden="true"
        className="pointer-events-none absolute top-0 right-0 w-[80%] sm:w-[65%] lg:w-[55%] h-full opacity-[0.04]"
        style={{
          backgroundImage: "linear-gradient(#1A1A1A 1px, transparent 1px), linear-gradient(90deg, #1A1A1A 1px, transparent 1px)",
          backgroundSize: "40px 40px",
          clipPath: "polygon(12% 0, 100% 0, 100% 100%, 0% 100%)",
        }}
      />

      <div className="relative max-w-screen-2xl mx-auto px-4 sm:px-6 w-full py-10 sm:py-14 lg:py-20 flex flex-col lg:flex-row items-center gap-10 lg:gap-16">

        {/* ── Left  content ── */}
        <div className="w-full lg:w-[52%] flex flex-col gap-5 sm:gap-7 lg:gap-8">

          {/* Eyebrow badge */}
          <div className="flex flex-wrap items-center gap-2 sm:gap-2.5">
            <span className="inline-flex items-center gap-2 bg-primary-text text-white text-[11px] font-semibold px-3.5 py-1.5 rounded-full tracking-widest uppercase font-(family-name:--font-inter)">
              {/* <span className="w-1.5 h-1.5 rounded-full bg-avocado" /> */}
              Restaurant Deal Platform
            </span>
            <span className="inline-flex items-center gap-1.5 border border-[#E8E8E8] text-slate-gray text-[11px] font-medium px-3.5 py-1.5 rounded-full font-(family-name:--font-inter)">
              Web &amp; Mobile
            </span>
          </div>

          {/* Headline */}
          <h1 className="text-[30px] sm:text-[40px] lg:text-[56px] font-extrabold text-primary-text leading-[1.1] lg:leading-[1.07] tracking-[-1px] sm:tracking-[-1.5px] font-(family-name:--font-poppins)">
            Grow Your Restaurant{" "}
            <span className="text-primary">with Smarter</span>
            <br />
            <span className="relative inline-block">
              Deals.
              <svg
                className="absolute -bottom-1 left-0 w-full"
                viewBox="0 0 120 8"
                preserveAspectRatio="none"
                aria-hidden="true"
              >
                <path d="M2 6 Q60 1 118 6" stroke="#E63946" strokeWidth="3" fill="none" strokeLinecap="round" />
              </svg>
            </span>
          </h1>

          {/* Description */}
          <p className="text-[14px] sm:text-[16px] text-slate-gray leading-[1.7] sm:leading-[1.8] max-w-[480px] font-(family-name:--font-inter)">
            What&apos;s 4 Dinner is a{" "}
            <strong className="text-primary-text font-semibold">role-based restaurant deal platform</strong>{" "}
            that helps owners launch flash and weekly deals, manage staff and track every redemption  all from one dashboard.
          </p>

          {/* Bullet list */}
          <ul className="flex flex-col gap-3">
            {bullets.map(({ icon, text }) => (
              <li key={text} className="flex items-start gap-3">
                <span className="mt-0.5 w-7 h-7 rounded-lg bg-[#FFF0F1] border border-[#FFD6D9] flex items-center justify-center shrink-0">
                  {icon}
                </span>
                <span className="text-[13px] sm:text-[14.5px] text-slate-gray font-medium leading-snug font-(family-name:--font-inter)">
                  {text}
                </span>
              </li>
            ))}
          </ul>

          {/* CTAs */}
          <div className="flex flex-col xs:flex-row flex-wrap items-stretch xs:items-center gap-3 mt-1">
            <a
              href="#features"
              className="inline-flex items-center justify-center gap-2 bg-primary text-white text-[14px] sm:text-[14.5px] font-bold px-6 sm:px-7 py-3 sm:py-3.5 rounded-xl hover:bg-primary-dark active:scale-[0.97] transition-all duration-150 shadow-[0_4px_16px_rgba(230,57,70,0.30)] hover:shadow-[0_6px_24px_rgba(230,57,70,0.40)] font-(family-name:--font-poppins)"
            >
              See All Features
              <svg width="15" height="15" viewBox="0 0 16 16" fill="none" aria-hidden="true">
                <path d="M3 8h10M9 4l4 4-4 4" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
              </svg>
            </a>
            <a
              href="#contact"
              className="inline-flex items-center justify-center gap-2 bg-white text-primary-text text-[14px] sm:text-[14.5px] font-bold px-6 sm:px-7 py-3 sm:py-3.5 rounded-xl border border-[#E8E8E8] hover:border-[#D0D0D0] hover:bg-soft-gray active:scale-[0.97] transition-all duration-150 font-(family-name:--font-poppins)"
            >
              Book a Demo
            </a>
          </div>

          {/* Stats row */}
          {/* <div className="flex items-center gap-5 sm:gap-8 pt-4 sm:pt-5 border-t border-[#EBEBEB]">
            {stats.map(({ value, label }) => (
              <div key={label} className="flex flex-col gap-0.5">
                <span className="text-[20px] sm:text-[24px] font-extrabold text-primary-text leading-none font-(family-name:--font-poppins)">
                  {value}
                </span>
                <span className="text-[12px] text-slate-gray font-medium font-(family-name:--font-inter)">
                  {label}
                </span>
              </div>
            ))}
          </div> */}

        </div>

        {/* ── Right  illustration placeholder ── */}
        <div className="w-full lg:w-[48%] flex items-center justify-center min-h-[180px] sm:min-h-[300px] lg:min-h-[420px]">
          {<img src="/Illustration.png" alt="Hero Illustration" className="object-contain w-full h-full" />}
        </div>

      </div>
    </section>
  );
}
