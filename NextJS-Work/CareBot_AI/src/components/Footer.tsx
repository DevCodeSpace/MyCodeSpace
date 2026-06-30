const navLinks = [
  {
    heading: "Product",
    links: [
      { label: "Features", href: "#features" },
      { label: "How It Works", href: "#how-it-works" },
      { label: "Why Us", href: "#why-us" },
      { label: "Testimonials", href: "#testimonials" },
    ],
  },
  {
    heading: "Support",
    links: [
      { label: "FAQ", href: "#faq" },
      { label: "Contact Us", href: "#contact" },
      { label: "Request a Demo", href: "#contact" },
      { label: "Hospital Onboarding", href: "#contact" },
    ],
  },
  {
    heading: "Legal",
    links: [
      { label: "Privacy Policy", href: "#" },
      { label: "Terms of Service", href: "#" },
      { label: "Cookie Policy", href: "#" },
      { label: "HIPAA Compliance", href: "#" },
    ],
  },
];

const socials = [
  {
    label: "Twitter / X",
    href: "#",
    icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
        <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
      </svg>
    ),
  },
  {
    label: "LinkedIn",
    href: "#",
    icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
        <path d="M16 8a6 6 0 0 1 6 6v7h-4v-7a2 2 0 0 0-2-2 2 2 0 0 0-2 2v7h-4v-7a6 6 0 0 1 6-6zM2 9h4v12H2z" />
        <circle cx="4" cy="4" r="2" />
      </svg>
    ),
  },
  {
    label: "Instagram",
    href: "#",
    icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
        <rect x="2" y="2" width="20" height="20" rx="5" ry="5" />
        <path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z" />
        <line x1="17.5" y1="6.5" x2="17.51" y2="6.5" />
      </svg>
    ),
  },
  {
    label: "YouTube",
    href: "#",
    icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
        <path d="M22.54 6.42a2.78 2.78 0 0 0-1.95-1.96C18.88 4 12 4 12 4s-6.88 0-8.59.46A2.78 2.78 0 0 0 1.46 6.42 29 29 0 0 0 1 12a29 29 0 0 0 .46 5.58A2.78 2.78 0 0 0 3.41 19.6C5.12 20 12 20 12 20s6.88 0 8.59-.46a2.78 2.78 0 0 0 1.95-1.95A29 29 0 0 0 23 12a29 29 0 0 0-.46-5.58z" />
        <polygon points="9.75 15.02 15.5 12 9.75 8.98 9.75 15.02" fill="#0D1B4B" />
      </svg>
    ),
  },
];

// const stats = [
//   { value: "10K+", label: "Patients" },
//   { value: "30+", label: "Specialties" },
//   { value: "<60s", label: "Booking Time" },
//   { value: "98%", label: "Satisfaction" },
// ];

export default function Footer() {
  const year = new Date().getFullYear();

  return (
    <footer className="bg-[#0D1B4B] text-white overflow-hidden">

      {/* Top CTA band */}
      <div
        className="relative overflow-hidden"
        style={{ background: "linear-gradient(135deg, #003DF5 0%, #0096DE 100%)" }}
      >
        <div
          aria-hidden="true"
          className="absolute -top-16 -right-16 w-64 h-64 rounded-full opacity-10 bg-white"
        />
        <div
          aria-hidden="true"
          className="absolute -bottom-12 -left-12 w-48 h-48 rounded-full opacity-10 bg-white"
        />
        <div className="max-w-screen-2xl mx-auto px-6 py-14 relative z-10 flex flex-col md:flex-row items-center justify-between gap-6">
          <div>
            <h3 className="text-[24px] lg:text-[30px] font-extrabold leading-snug">
              Book Smarter. Live Healthier.
            </h3>
            <p className="mt-1 text-[15px] text-white/75">
              Start your first AI-assisted appointment in under 60 seconds.
            </p>
          </div>
          <div className="flex items-center gap-3 shrink-0">
            <a
              href="#contact"
              className="inline-flex items-center gap-2 bg-white text-[#003DF5] hover:bg-[#EEF2FF] text-[14px] font-bold px-6 py-3.5 rounded-full transition-colors duration-200 shadow-[0_4px_16px_rgba(0,0,0,0.15)]"
            >
              Request a Demo
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" aria-hidden="true">
                <path d="M5 12h14M13 6l6 6-6 6" stroke="#003DF5" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round" />
              </svg>
            </a>
            <a
              href="#features"
              className="inline-flex items-center gap-2 border border-white/30 hover:border-white text-white text-[14px] font-bold px-6 py-3.5 rounded-full transition-colors duration-200"
            >
              Explore Features
            </a>
          </div>
        </div>
      </div>

      {/* Main footer body */}
      <div className="max-w-screen-2xl mx-auto px-6 py-16">
        <div className="grid grid-cols-1 lg:grid-cols-[320px_1fr] gap-12">

          {/* Brand column */}
          <div className="flex flex-col gap-6">
            {/* Logo + name */}
            <a href="#" className="flex items-center gap-2.5 shrink-0">
              <img src="/carebot_logo.svg" alt="CareBot AI" className="h-11 w-auto" />
              <span className="text-[22px] font-extrabold tracking-[-0.5px]">
                CareBot<span className="text-[#003DF5]">AI</span>
              </span>
            </a>

            <p className="text-[14px] text-white/60 leading-relaxed max-w-[280px]">
              AI-powered healthcare appointment booking. Describe your symptoms, get matched instantly, confirm in under 60 seconds.
            </p>

            {/* Stats mini row */}
            {/* <div className="grid grid-cols-2 gap-3">
              {stats.map(({ value, label }) => (
                <div key={label} className="bg-white/5 rounded-xl px-4 py-3 border border-white/8">
                  <div className="text-[20px] font-black text-[#0096DE] leading-none">{value}</div>
                  <div className="text-[11px] text-white/50 mt-0.5 font-medium uppercase tracking-wide">{label}</div>
                </div>
              ))}
            </div> */}

            {/* Socials */}
            <div className="flex items-center gap-2">
              {socials.map(({ label, href, icon }) => (
                <a
                  key={label}
                  href={href}
                  aria-label={label}
                  className="w-9 h-9 rounded-xl bg-white/8 hover:bg-[#003DF5] border border-white/10 flex items-center justify-center text-white/60 hover:text-white transition-all duration-200"
                >
                  {icon}
                </a>
              ))}
            </div>
          </div>

          {/* Nav columns */}
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-8">
            {navLinks.map(({ heading, links }) => (
              <div key={heading}>
                <h4 className="text-[11px] font-black uppercase tracking-[0.18em] text-white/40 mb-4">
                  {heading}
                </h4>
                <ul className="flex flex-col gap-2.5">
                  {links.map(({ label, href }) => (
                    <li key={label}>
                      <a
                        href={href}
                        className="text-[14px] text-white/60 hover:text-white transition-colors duration-150"
                      >
                        {label}
                      </a>
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </div>

        </div>
      </div>

      {/* Bottom bar */}
      <div className="border-t border-white/8">
        <div className="max-w-screen-2xl mx-auto px-6 py-5 flex flex-col sm:flex-row items-center justify-between gap-3">
          <p className="text-[13px] text-white/40">
            © {year} CareBot AI. All rights reserved.
          </p>
          {/* <div className="flex items-center gap-1.5 text-[13px] text-white/40">
            <span>Made with</span>
            <span className="text-[#E11D48]">♥</span>
            <span>for better healthcare</span>
          </div> */}
          <div className="flex items-center gap-4">
            <a href="#" className="text-[13px] text-white/40 hover:text-white transition-colors duration-150">Privacy</a>
            <a href="#" className="text-[13px] text-white/40 hover:text-white transition-colors duration-150">Terms</a>
            <a href="#" className="text-[13px] text-white/40 hover:text-white transition-colors duration-150">Cookies</a>
          </div>
        </div>
      </div>

    </footer>
  );
}
