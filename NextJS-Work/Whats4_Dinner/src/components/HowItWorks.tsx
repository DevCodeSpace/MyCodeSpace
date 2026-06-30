const adminSteps = [
  {
    number: "01",
    accent: "#E63946",
    accentLight: "#FFF0F1",
    icon: (
      <img
        src="/register.svg"
        width={22}
        height={22}
        alt=""
        aria-hidden="true"
        style={{
          filter:
            "brightness(0) saturate(100%) invert(32%) sepia(93%) saturate(2154%) hue-rotate(338deg) brightness(95%) contrast(92%)",
        }}
      />
    ),
    title: "Register & Submit",
    desc: "Create your restaurant account, fill in your profile details and submit for Super Admin review.",
    bullets: [
      "Name, location & cuisine type",
      "Upload restaurant images",
      "Provide contact information",
    ],
  },
  {
    number: "02",
    accent: "#F5A623",
    accentLight: "#FFF9EC",
    icon: (
      <img
        src="/fast.svg"
        width={22}
        height={22}
        alt=""
        aria-hidden="true"
        style={{
          filter:
            "brightness(0) saturate(100%) invert(69%) sepia(74%) saturate(1318%) hue-rotate(357deg) brightness(101%) contrast(92%)",
        }}
      />
    ),
    title: "Get Approved",
    desc: "Super Admin reviews your submission. You receive approval or rejection with a clear reason  full transparency at every step.",
    bullets: [
      "Fast review turnaround",
      "Rejection includes reason",
      "Activate or deactivate anytime",
    ],
  },
  {
    number: "03",
    accent: "#7CB47A",
    accentLight: "#F0FAF0",
    icon: (
      <img
        src="/create.svg"
        width={22}
        height={22}
        alt=""
        aria-hidden="true"
        style={{
          filter:
            "brightness(0) saturate(100%) invert(71%) sepia(18%) saturate(563%) hue-rotate(69deg) brightness(89%) contrast(87%)",
        }}
      />
    ),
    title: "Create Your Deals",
    desc: "Launch flash deals with time caps or set up recurring weekly offers. Edit, pause or end any deal from your dashboard.",
    bullets: [
      "Flash & weekly deal types",
      "Set caps & schedules",
      "Edit or end anytime",
    ],
  },
  {
    number: "04",
    accent: "#A1131D",
    accentLight: "#FFF0F1",
    icon: (
      <img
        src="/qrcode.svg"
        width={22}
        height={22}
        alt=""
        aria-hidden="true"
        style={{
          filter:
            "brightness(0) saturate(100%) invert(13%) sepia(91%) saturate(3691%) hue-rotate(347deg) brightness(86%) contrast(95%)",
        }}
      />
    ),
    title: "Track Redemptions",
    desc: "Staff scan unique QR codes in-venue. View every claim and redemption in real time  filter by date, deal or restaurant.",
    bullets: [
      "Unique QR per claimed deal",
      "Real-time scan history",
      "Filter & export records",
    ],
  },
];

const customerSteps = [
  {
    icon: (
      <img
        src="/discover.svg"
        width={22}
        height={22}
        alt=""
        aria-hidden="true"
        style={{
          filter:
            "brightness(0) saturate(100%) invert(27%) sepia(99%) saturate(1500%) hue-rotate(338deg) brightness(104%) contrast(91%)",
        }}
      />
    ),
    title: "Discover Deals",
    desc: "Browse flash and weekly deals from restaurants near you using GPS and smart filters.",
  },
  {
    icon: (
      <img
        src="/create.svg"
        width={22}
        height={22}
        alt=""
        aria-hidden="true"
        style={{
          filter:
            "brightness(0) saturate(100%) invert(27%) sepia(99%) saturate(1500%) hue-rotate(338deg) brightness(104%) contrast(91%)",
        }}
      />
    ),
    title: "Claim & Save",
    desc: "Tap to claim a deal. A unique QR code is generated instantly in the app.",
  },
  {
    icon: (
      <img
        src="/qrcode.svg"
        width={22}
        height={22}
        alt=""
        aria-hidden="true"
        style={{
          filter:
            "brightness(0) saturate(100%) invert(27%) sepia(99%) saturate(1500%) hue-rotate(338deg) brightness(104%) contrast(91%)",
        }}
      />
    ),
    title: "Scan In-Venue",
    desc: "Show your QR at the restaurant. Staff scan to verify and redeem your deal.",
  },
  {
    icon: (
      <img
        src="/rate.svg"
        width={22}
        height={22}
        alt=""
        aria-hidden="true"
        style={{
          filter:
            "brightness(0) saturate(100%) invert(27%) sepia(99%) saturate(1500%) hue-rotate(338deg) brightness(104%) contrast(91%)",
        }}
      />
    ),
    title: "Rate & Review",
    desc: "Share your experience with a rating and review to help other diners discover great deals.",
  },
];

export default function HowItWorks() {
  return (
    <section
      id="how-it-works"
      className="bg-white py-16 sm:py-20 lg:py-24 overflow-hidden"
    >
      <div className="max-w-screen-2xl mx-auto px-4 sm:px-6">
        {/* Header */}
        <div className="max-w-2xl mb-10 sm:mb-12 lg:mb-16">
          <span className="inline-flex items-center gap-2 bg-[#FFF0F1] text-primary border border-[#FFD6D9] text-[11px] font-bold px-3.5 py-1.5 rounded-full tracking-widest uppercase mb-5 font-(family-name:--font-inter)">
            {/* <svg width="10" height="10" viewBox="0 0 24 24" fill="none" aria-hidden="true">
              <path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z" fill="#E63946" />
            </svg> */}
            How It Works
          </span>
          <h2 className="text-[26px] sm:text-[36px] lg:text-[48px] font-extrabold text-primary-text tracking-[-1px] leading-[1.1] font-(family-name:--font-poppins)">
            Two journeys, <span className="text-primary">one platform</span>
          </h2>
          <p className="mt-4 text-[15px] sm:text-[16px] text-slate-gray leading-relaxed font-(family-name:--font-inter)">
            Whether you&apos;re a restaurant owner managing deals or a customer
            discovering them the experience is seamless from start to finish.
          </p>
        </div>

        {/* ── Restaurant / Admin flow ── */}
        <div className="mb-12 sm:mb-16 lg:mb-20">
          <div className="flex items-center gap-3 mb-5 sm:mb-8">
            <span className="w-7 h-7 rounded-lg bg-primary-text flex items-center justify-center shrink-0">
              <svg
                width="14"
                height="14"
                viewBox="0 0 24 24"
                fill="none"
                aria-hidden="true"
              >
                <path
                  d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"
                  stroke="white"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
              </svg>
            </span>
            <h3 className="text-[16px] font-bold text-primary-text font-(family-name:--font-poppins)">
              Restaurant &amp; Admin Journey
            </h3>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
            {adminSteps.map(
              (
                { number, accent, accentLight, icon, title, desc, bullets },
                i,
              ) => (
                <div
                  key={number}
                  className="relative flex flex-col rounded-2xl border border-[#EFEFEF] bg-white p-6 shadow-[0_2px_12px_rgba(0,0,0,0.04)] hover:shadow-[0_8px_28px_rgba(0,0,0,0.09)] hover:-translate-y-1 transition-all duration-200 overflow-hidden"
                >
                  {/* Faint step watermark */}
                  <span
                    className="absolute top-3 right-4 text-[56px] font-black leading-none select-none pointer-events-none opacity-[0.06]"
                    style={{ color: accent }}
                  >
                    {number}
                  </span>

                  {/* Icon */}
                  <div
                    className="w-12 h-12 rounded-xl flex items-center justify-center mb-5 shrink-0"
                    style={{ backgroundColor: accentLight }}
                  >
                    {icon}
                  </div>

                  {/* Step label */}
                  <span
                    className="text-[10px] font-black tracking-[0.2em] uppercase mb-2"
                    style={{ color: accent }}
                  >
                    Step {number}
                  </span>

                  <h4 className="text-[15.5px] font-extrabold text-primary-text leading-snug mb-2 font-(family-name:--font-poppins)">
                    {title}
                  </h4>

                  <div
                    className="w-8 h-0.5 rounded-full mb-3"
                    style={{ backgroundColor: accent, opacity: 0.3 }}
                  />

                  <p className="text-[13px] text-slate-gray leading-relaxed mb-4 font-(family-name:--font-inter)">
                    {desc}
                  </p>

                  <ul className="flex flex-col gap-2 mt-auto">
                    {bullets.map((b) => (
                      <li key={b} className="flex items-center gap-2">
                        <span
                          className="w-1.5 h-1.5 rounded-full shrink-0"
                          style={{ backgroundColor: accent }}
                        />
                        <span className="text-[12.5px] text-slate-gray font-medium font-(family-name:--font-inter)">
                          {b}
                        </span>
                      </li>
                    ))}
                  </ul>

                  {/* Bottom accent */}
                  <div
                    className="absolute bottom-0 left-0 right-0 h-0.5"
                    style={{
                      backgroundColor: accent,
                      opacity: i === 0 ? 1 : 0.25,
                    }}
                  />
                </div>
              ),
            )}
          </div>
        </div>

        {/* ── Customer flow ── */}
        <div>
          <div className="flex items-center gap-3 mb-5 sm:mb-8">
            <span className="w-7 h-7 rounded-lg bg-primary flex items-center justify-center shrink-0">
              <svg
                width="14"
                height="14"
                viewBox="0 0 24 24"
                fill="none"
                aria-hidden="true"
              >
                <path
                  d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"
                  stroke="white"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
                <circle cx="12" cy="7" r="4" stroke="white" strokeWidth="2" />
              </svg>
            </span>
            <h3 className="text-[16px] font-bold text-primary-text font-(family-name:--font-poppins)">
              Customer Journey
            </h3>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
            {customerSteps.map(({ icon, title, desc }, i) => (
              <div
                key={title}
                className="flex items-start gap-4 bg-soft-gray rounded-2xl border border-[#EFEFEF] p-5"
              >
                <div className="w-10 h-10 rounded-xl bg-white border border-[#E8E8E8] flex items-center justify-center text-[20px] shrink-0 shadow-[0_1px_4px_rgba(0,0,0,0.06)]">
                  {icon}
                </div>
                <div>
                  <div className="flex items-center gap-2 mb-1">
                    <span className="text-[10px] font-black text-primary tracking-widest uppercase">
                      {String(i + 1).padStart(2, "0")}
                    </span>
                    <h4 className="text-[14px] font-bold text-primary-text font-(family-name:--font-poppins)">
                      {title}
                    </h4>
                  </div>
                  <p className="text-[13px] text-slate-gray leading-relaxed font-(family-name:--font-inter)">
                    {desc}
                  </p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Bottom CTA */}
        <div className="mt-10 sm:mt-14 lg:mt-16 flex flex-col sm:flex-row items-center justify-center gap-4">
          <a
            href="#contact"
            className="inline-flex items-center gap-2 bg-primary hover:bg-primary-dark text-white text-[15px] font-bold px-8 py-4 rounded-full transition-colors duration-150 shadow-[0_4px_20px_rgba(230,57,70,0.28)] font-(family-name:--font-poppins)"
          >
            Get Started Free
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
            className="inline-flex items-center gap-2 bg-white border border-[#E8E8E8] hover:border-[#D0D0D0] text-primary-text text-[15px] font-bold px-8 py-4 rounded-full transition-colors duration-150 font-(family-name:--font-poppins)"
          >
            Explore Features
          </a>
        </div>
      </div>
    </section>
  );
}
