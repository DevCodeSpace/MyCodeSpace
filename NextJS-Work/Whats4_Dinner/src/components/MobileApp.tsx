import Image from "next/image";

const roles = [
  {
    icon: (
      <img
        src="/restaurant.svg"
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
    accent: "#E63946",
    bg: "#FFF0F1",
    role: "Owner",
    desc: "Manage deals, branches, staff permissions and view analytics  all from your phone.",
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
            "brightness(0) saturate(100%) invert(71%) sepia(18%) saturate(563%) hue-rotate(69deg) brightness(89%) contrast(87%)",
        }}
      />
    ),
    accent: "#7CB47A",
    bg: "#F0FAF0",
    role: "Customer",
    desc: "Discover nearby deals, claim offers, scan QR codes and rate restaurants.",
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
    accent: "#F5A623",
    bg: "#FFF9EC",
    role: "Staff",
    desc: "Scan QR codes in-venue to verify and redeem customer deals instantly.",
  },
];

const mobileFeatures = [
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
            "brightness(0) saturate(100%) invert(27%) sepia(99%) saturate(1500%) hue-rotate(338deg) brightness(104%) contrast(91%)",
        }}
      />
    ),
    title: "Flash & Weekly Deals",
    desc: "Browse time-limited flash deals and recurring weekly offers from restaurants nearby.",
  },
  {
    icon: (
      <img
        src="/nearby.svg"
        width={20}
        height={20}
        alt=""
        aria-hidden="true"
        style={{
          filter:
            "brightness(0) saturate(100%) invert(71%) sepia(18%) saturate(563%) hue-rotate(69deg) brightness(89%) contrast(87%)",
        }}
      />
    ),
    title: "Nearby Deal Discovery",
    desc: "GPS-powered search finds the best deals around you. Filter by cuisine, rating or distance.",
  },
  {
    icon: (
      <img
        src="/redemption.svg"
        width={20}
        height={20}
        alt=""
        aria-hidden="true"
        style={{
          filter:
            "brightness(0) saturate(100%) invert(69%) sepia(74%) saturate(1318%) hue-rotate(357deg) brightness(101%) contrast(92%)",
        }}
      />
    ),
    title: "QR Code Redemption",
    desc: "Claim a deal and get a unique QR code. Staff scan it in-venue for instant verified redemption.",
  },
  {
    icon: (
      <img
        src="/notification.svg"
        width={20}
        height={20}
        alt=""
        aria-hidden="true"
        style={{
          filter:
            "brightness(0) saturate(100%) invert(33%) sepia(11%) saturate(1046%) hue-rotate(176deg) brightness(93%) contrast(87%)",
        }}
      />
    ),
    title: "Push Notifications",
    desc: "Get real-time alerts for deal expiry, claim updates and new offers via Firebase messaging.",
  },
  {
    icon: (
      <img
        src="/rate.svg"
        width={20}
        height={20}
        alt=""
        aria-hidden="true"
        style={{
          filter:
            "brightness(0) saturate(100%) invert(69%) sepia(74%) saturate(1318%) hue-rotate(357deg) brightness(101%) contrast(92%)",
        }}
      />
    ),
    title: "Ratings & Reviews",
    desc: "Rate restaurants and share dining experiences. Customer feedback helps surface the best deals.",
  },
  {
    icon: (
      <img
        src="/language.svg"
        width={20}
        height={20}
        alt=""
        aria-hidden="true"
        style={{
          filter:
            "brightness(0) saturate(100%) invert(71%) sepia(18%) saturate(563%) hue-rotate(69deg) brightness(89%) contrast(87%)",
        }}
      />
    ),
    title: "Multi-Language Support",
    desc: "English and German supported out of the box. Switch language dynamically at any time.",
  },
];

export default function MobileApp() {
  return (
    <section
      id="mobile-app"
      className="bg-soft-gray py-16 sm:py-20 lg:py-24 overflow-hidden"
    >
      <div className="max-w-screen-2xl mx-auto px-4 sm:px-6">
        {/* Header */}
        <div className="max-w-2xl mb-10 sm:mb-12 lg:mb-16">
          <span className="inline-flex items-center gap-2 bg-[#FFF0F1] text-primary border border-[#FFD6D9] text-[11px] font-bold px-3.5 py-1.5 rounded-full tracking-widest uppercase mb-5 font-(family-name:--font-inter)">
            {/* <svg width="10" height="10" viewBox="0 0 24 24" fill="none" aria-hidden="true">
              <rect x="5" y="2" width="14" height="20" rx="2" fill="#E63946" />
            </svg> */}
            Mobile App
          </span>
          <h2 className="text-[26px] sm:text-[36px] lg:text-[48px] font-extrabold text-primary-text tracking-[-1px] leading-[1.1] font-(family-name:--font-poppins)">
            Deals in your pocket{" "}
            <span className="text-primary">iOS & Android</span>
          </h2>
          <p className="mt-4 text-[15px] sm:text-[16px] text-slate-gray leading-relaxed font-(family-name:--font-inter)">
            The What&apos;s 4 Dinner mobile app serves three distinct roles
            owner, customer and staff each with a tailored interface built for
            their exact needs.
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 lg:gap-12 items-start">
          {/* Left  role cards + features */}
          <div className="flex flex-col gap-6 sm:gap-8">
            {/* Role cards */}
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              {roles.map(({ icon, accent, bg, role, desc }) => (
                <div
                  key={role}
                  className="flex flex-col gap-3 rounded-2xl border border-[#E8E8E8] bg-white p-5 hover:shadow-[0_6px_24px_rgba(0,0,0,0.07)] hover:-translate-y-0.5 transition-all duration-200"
                >
                  <div
                    className="w-10 h-10 rounded-xl flex items-center justify-center text-[20px] shrink-0"
                    style={{ backgroundColor: bg }}
                  >
                    {icon}
                  </div>
                  <div>
                    <p
                      className="text-[13.5px] font-bold text-primary-text font-(family-name:--font-poppins)"
                      style={{ color: accent }}
                    >
                      {role}
                    </p>
                    <p className="text-[12px] text-slate-gray leading-relaxed mt-1 font-(family-name:--font-inter)">
                      {desc}
                    </p>
                  </div>
                </div>
              ))}
            </div>

            {/* Feature list */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              {mobileFeatures.map(({ icon, title, desc }) => (
                <div
                  key={title}
                  className="flex items-start gap-3 bg-white rounded-xl border border-[#EFEFEF] p-4"
                >
                  <div className="w-8 h-8 rounded-lg bg-soft-gray flex items-center justify-center shrink-0">
                    {icon}
                  </div>
                  <div>
                    <p className="text-[13.5px] font-bold text-primary-text font-(family-name:--font-poppins)">
                      {title}
                    </p>
                    <p className="text-[12px] text-slate-gray leading-relaxed mt-0.5 font-(family-name:--font-inter)">
                      {desc}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Right — app promo card */}
          <div className="flex flex-col">
            {/* Dark promo card */}
            <div className="relative rounded-2xl bg-primary-text overflow-hidden p-6 sm:p-8">
              {/* Background decorative circles */}
              <div
                aria-hidden="true"
                className="absolute -top-10 -right-10 w-44 h-44 rounded-full bg-white/5"
              />
              <div
                aria-hidden="true"
                className="absolute -bottom-8 -left-8 w-32 h-32 rounded-full bg-white/5"
              />
              <div
                aria-hidden="true"
                className="absolute top-1/2 right-10 w-16 h-16 rounded-full bg-primary/20"
              />

              <div className="relative z-10 flex flex-col gap-5">
                {/* App icon + name */}
                <div className="flex items-center gap-3">
                  <div className="w-12 h-12 rounded-2xl bg-white flex items-center justify-center  shrink-0 overflow-hidden p-2">
                    <Image
                      src="/logo.svg"
                      alt="What's 4 Dinner"
                      width={32}
                      height={32}
                      className="object-contain w-full h-full"
                    />
                  </div>
                  <div>
                    <p className="text-[15px] font-extrabold text-white leading-tight font-(family-name:--font-poppins)">
                      What&apos;s 4 Dinner
                    </p>
                    <p className="text-[11px] text-white/45 mt-0.5 font-(family-name:--font-inter)">
                      Restaurant Deal Platform
                    </p>
                  </div>
                </div>

                {/* Star rating */}
                <div className="flex items-center gap-2.5">
                  <div className="flex items-center gap-0.5">
                    {[1, 2, 3, 4, 5].map((i) => (
                      <svg
                        key={i}
                        width="14"
                        height="14"
                        viewBox="0 0 24 24"
                        aria-hidden="true"
                      >
                        <path
                          d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"
                          fill={i <= 4 ? "#F5A623" : "none"}
                          stroke={i === 5 ? "#F5A623" : "none"}
                          strokeWidth="1.5"
                        />
                      </svg>
                    ))}
                  </div>
                  <span className="text-[13px] font-bold text-white font-(family-name:--font-poppins)">
                    4.8
                  </span>
                  <span className="text-[12px] text-white/35 font-(family-name:--font-inter)">
                    · 2,400+ reviews
                  </span>
                </div>

                {/* Stats row */}
                <div className="grid grid-cols-3 gap-2.5">
                  {[
                    { value: "120+", label: "Restaurants" },
                    { value: "12", label: "Cities" },
                    { value: "3", label: "User Roles" },
                  ].map(({ value, label }) => (
                    <div
                      key={label}
                      className="bg-white/[0.07] rounded-xl p-3 text-center border border-white/[0.08]"
                    >
                      <p className="text-[18px] font-black text-primary leading-none font-(family-name:--font-poppins)">
                        {value}
                      </p>
                      <p className="text-[10px] text-white/45 mt-1 font-medium font-(family-name:--font-inter)">
                        {label}
                      </p>
                    </div>
                  ))}
                </div>

                {/* Divider */}
                <div className="border-t border-white/10" />

                {/* Download label */}
                <p className="text-[10px] font-black uppercase tracking-[0.18em] text-white/30 -mb-2 font-(family-name:--font-inter)">
                  Download Now
                </p>

                {/* App store buttons */}
                <div className="flex flex-col gap-2.5">
                  <a
                    href="https://apps.apple.com/us/app/whats-4-dinner-deals/id6760448081"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-3 bg-white/[0.08] hover:bg-white/[0.14] border border-white/[0.12] rounded-xl px-4 py-3 transition-colors duration-150"
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
                    <div className="flex flex-col leading-tight flex-1">
                      <span className="text-[10px] text-white/45 font-(family-name:--font-inter)">
                        Download on the
                      </span>
                      <span className="text-[14px] font-bold text-white font-(family-name:--font-poppins)">
                        App Store
                      </span>
                    </div>
                    <svg
                      width="13"
                      height="13"
                      viewBox="0 0 24 24"
                      fill="none"
                      aria-hidden="true"
                    >
                      <path
                        d="M5 12h14M13 6l6 6-6 6"
                        stroke="white"
                        strokeWidth="2"
                        strokeOpacity="0.4"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                      />
                    </svg>
                  </a>

                  <a
                    href="https://play.google.com/store/apps/details?id=com.app.whats4dinner&pli=1"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-3 bg-white/[0.08] hover:bg-white/[0.14] border border-white/[0.12] rounded-xl px-4 py-3 transition-colors duration-150"
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
                    <div className="flex flex-col leading-tight flex-1">
                      <span className="text-[10px] text-white/45 font-(family-name:--font-inter)">
                        Get it on
                      </span>
                      <span className="text-[14px] font-bold text-white font-(family-name:--font-poppins)">
                        Google Play
                      </span>
                    </div>
                    <svg
                      width="13"
                      height="13"
                      viewBox="0 0 24 24"
                      fill="none"
                      aria-hidden="true"
                    >
                      <path
                        d="M5 12h14M13 6l6 6-6 6"
                        stroke="white"
                        strokeWidth="2"
                        strokeOpacity="0.4"
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
      </div>
    </section>
  );
}
