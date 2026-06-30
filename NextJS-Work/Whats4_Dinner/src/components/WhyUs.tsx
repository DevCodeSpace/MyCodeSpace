const benefits = [
  {
    icon: (
      <img
        src="/fast.svg"
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
    bg: "#F0FAF0",
    accent: "#7CB47A",
    title: "Fast Onboarding & Approval",
    desc: "Submit your restaurant profile and get reviewed by a Super Admin. Approval with reason tracking means you always know your status  no guessing.",
  },
  {
    icon: (
      <img
        src="/flash.svg"
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
    bg: "#FFF0F1",
    accent: "#E63946",
    title: "Flash & Weekly Deal Control",
    desc: "Launch flash deals in minutes or set up recurring weekly specials. Pause, edit or end any deal at any time  full control, zero friction.",
  },
  {
    icon: (
      <img
        src="/staff.svg"
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
    bg: "#FFF9EC",
    accent: "#F5A623",
    title: "Staff & Permission Management",
    desc: "Add staff, assign roles and grant QR scan access per person. The owner stays in control  permissions are granular and easy to update.",
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
            "brightness(0) saturate(100%) invert(33%) sepia(11%) saturate(1046%) hue-rotate(176deg) brightness(93%) contrast(87%)",
        }}
      />
    ),
    bg: "#F5F5F5",
    accent: "#4A5568",
    title: "QR Redemption Tracking",
    desc: "Every claimed deal gets a unique QR code. Your staff scans it in-venue for verified redemptions. View full scan history, filter by date or deal.",
  },
  {
    icon: (
      <img
        src="/multi.svg"
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
    bg: "#FFF0F1",
    accent: "#A1131D",
    title: "Multi-Branch Management",
    desc: "Run multiple locations from one account. Each branch has its own address, map coordinates and deal settings  managed centrally.",
  },
  {
    icon: (
      <img
        src="/profile.svg"
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
    bg: "#F0FAF0",
    accent: "#7CB47A",
    title: "Profile & Media Management",
    desc: "Edit your restaurant name, phone, location, cuisine type and images anytime. Keep your listing accurate and attractive to customers.",
  },
];

const steps = [
  {
    number: "01",
    title: "Register & Submit",
    desc: "Create your restaurant profile and submit for review.",
  },
  {
    number: "02",
    title: "Get Approved",
    desc: "Super Admin reviews and approves your request.",
  },
  {
    number: "03",
    title: "Create Your Deals",
    desc: "Launch flash or weekly deals from your dashboard.",
  },
  {
    number: "04",
    title: "Track Redemptions",
    desc: "Staff scan QR codes. You see every claim in real time.",
  },
];

export default function ForRestaurants() {
  return (
    <section
      id="for-restaurants"
      className="bg-soft-gray py-16 sm:py-20 lg:py-24 overflow-hidden"
    >
      <div className="max-w-screen-2xl mx-auto px-4 sm:px-6">
        {/* Header */}
        <div className="max-w-2xl mb-10 sm:mb-12 lg:mb-16">
          <span className="inline-flex items-center gap-2 bg-[#FFF0F1] text-primary border border-[#FFD6D9] text-[11px] font-bold px-3.5 py-1.5 rounded-full tracking-widest uppercase mb-5 font-(family-name:--font-inter)">
            {/* <svg width="10" height="10" viewBox="0 0 24 24" fill="none" aria-hidden="true">
              <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" fill="#E63946" />
            </svg> */}
            For Restaurants
          </span>
          <h2 className="text-[26px] sm:text-[36px] lg:text-[48px] font-extrabold text-primary-text tracking-[-1px] leading-[1.1] font-(family-name:--font-poppins)">
            Built for restaurant owners,{" "}
            <span className="text-primary">not spreadsheets</span>
          </h2>
          <p className="mt-4 text-[15px] sm:text-[16px] text-slate-gray leading-relaxed font-(family-name:--font-inter)">
            What&apos;s 4 Dinner gives your restaurant a complete deal
            management toolkit from onboarding to real-time redemption tracking
            without the complexity.
          </p>
        </div>

        {/* Two column  benefits + steps */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-10 lg:items-stretch">
          {/* Benefits grid */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            {benefits.map(({ icon, bg, accent, title, desc }) => (
              <div
                key={title}
                className="group flex flex-col gap-4 rounded-2xl border border-[#E8E8E8] bg-white p-5 hover:shadow-[0_6px_24px_rgba(0,0,0,0.07)] hover:-translate-y-0.5 transition-all duration-200"
              >
                <div
                  className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0"
                  style={{ backgroundColor: bg }}
                >
                  {icon}
                </div>
                <div>
                  <h3 className="text-[14.5px] font-bold text-primary-text leading-snug mb-1.5 font-(family-name:--font-poppins)">
                    {title}
                  </h3>
                  <p className="text-[13px] text-slate-gray leading-relaxed font-(family-name:--font-inter)">
                    {desc}
                  </p>
                </div>
                <div
                  className="h-0.5 w-8 rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-200 mt-auto"
                  style={{ backgroundColor: accent }}
                />
              </div>
            ))}
          </div>

          {/* Right  how it works for restaurants */}
          <div className="flex flex-col gap-6 lg:h-full">
            {/* Step cards */}
            <div className="bg-white rounded-2xl border border-[#E8E8E8] overflow-hidden flex-1 flex flex-col">
              {/* Card header */}
              <div className="px-4 sm:px-6 py-4 sm:py-5 border-b border-[#F3F4F6]">
                <p className="text-[12px] font-black uppercase tracking-[0.18em] text-slate-gray font-(family-name:--font-inter)">
                  Restaurant Journey
                </p>
                <h3 className="text-[18px] font-extrabold text-primary-text mt-1 font-(family-name:--font-poppins)">
                  From signup to your first redemption
                </h3>
              </div>

              {/* Steps */}
              <div className="flex-1 flex flex-col divide-y divide-[#F3F4F6]">
                {steps.map(({ number, title, desc }, i) => (
                  <div
                    key={number}
                    className="flex items-start gap-3 sm:gap-4 px-4 sm:px-6 py-5 flex-1"
                  >
                    <span
                      className="text-[13px] font-black tabular-nums shrink-0 mt-0.5 w-8 h-8 rounded-full flex items-center justify-center"
                      style={{
                        backgroundColor: i === 0 ? "#E63946" : "#FFF0F1",
                        color: i === 0 ? "#fff" : "#E63946",
                        border: i > 0 ? "1.5px solid #FFD6D9" : "none",
                      }}
                    >
                      {number}
                    </span>
                    <div className="pt-0.5">
                      <p className="text-[14px] font-bold text-primary-text font-(family-name:--font-poppins)">
                        {title}
                      </p>
                      <p className="text-[13px] text-slate-gray mt-0.5 font-(family-name:--font-inter)">
                        {desc}
                      </p>
                    </div>
                  </div>
                ))}
              </div>

              {/* CTA inside card */}
              <div className="px-4 sm:px-6 py-4 sm:py-5 bg-[#FFF8F8] border-t border-[#FFE8E9] flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 sm:gap-4">
                <p className="text-[13px] text-slate-gray font-(family-name:--font-inter)">
                  Ready to list your restaurant?
                </p>
                <a
                  href="#contact"
                  className="inline-flex items-center gap-2 bg-primary hover:bg-primary-dark text-white text-[13px] font-bold px-5 py-2.5 rounded-full transition-colors duration-150 shadow-[0_4px_14px_rgba(230,57,70,0.25)]"
                >
                  Get Started
                  <svg
                    width="13"
                    height="13"
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
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
