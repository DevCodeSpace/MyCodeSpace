import Image from "next/image";

const navLinks = [
  {
    heading: "Product",
    links: [
      { label: "Features", href: "#features" },
      { label: "For Restaurants", href: "#for-restaurants" },
      { label: "How It Works", href: "#how-it-works" },
      { label: "Mobile App", href: "#mobile-app" },
    ],
  },
  {
    heading: "Support",
    links: [
      { label: "FAQ", href: "/#faq" },
      { label: "Contact Us", href: "mailto:support@whats4dinnerapp.com" },
      { label: "Support", href: "/support" },
      { label: "Restaurant Onboarding", href: "#contact" },
    ],
  },
  {
    heading: "Legal",
    links: [
      { label: "Privacy Policy", href: "/privacy-policy" },
      { label: "Terms of Service", href: "/terms" },
      // { label: "Cookie Policy", href: "#" },
      { label: "Delete Account", href: "https://whats4dinner-37c80.web.app/delete-account" },
    ],
  },
];

const socials = [
  {
    label: "Twitter / X",
    href: "#",
    icon: (
      <svg
        width="16"
        height="16"
        viewBox="0 0 24 24"
        fill="currentColor"
        aria-hidden="true"
      >
        <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
      </svg>
    ),
  },
  {
    label: "LinkedIn",
    href: "#",
    icon: (
      <svg
        width="16"
        height="16"
        viewBox="0 0 24 24"
        fill="currentColor"
        aria-hidden="true"
      >
        <path d="M16 8a6 6 0 0 1 6 6v7h-4v-7a2 2 0 0 0-2-2 2 2 0 0 0-2 2v7h-4v-7a6 6 0 0 1 6-6zM2 9h4v12H2z" />
        <circle cx="4" cy="4" r="2" />
      </svg>
    ),
  },
  {
    label: "Instagram",
    href: "#",
    icon: (
      <svg
        width="16"
        height="16"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
        aria-hidden="true"
      >
        <rect x="2" y="2" width="20" height="20" rx="5" ry="5" />
        <path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z" />
        <line x1="17.5" y1="6.5" x2="17.51" y2="6.5" />
      </svg>
    ),
  },
  {
    label: "Facebook",
    href: "#",
    icon: (
      <svg
        width="16"
        height="16"
        viewBox="0 0 24 24"
        fill="currentColor"
        aria-hidden="true"
      >
        <path d="M18 2h-3a5 5 0 0 0-5 5v3H7v4h3v8h4v-8h3l1-4h-4V7a1 1 0 0 1 1-1h3z" />
      </svg>
    ),
  },
];

// const stats = [
//   { value: "120+", label: "Restaurants" },
//   { value: "12",   label: "Cities"      },
//   { value: "4.8★", label: "App Rating"  },
//   { value: "3",    label: "User Roles"  },
// ];

export default function Footer() {
  const year = new Date().getFullYear();

  return (
    <footer className="bg-primary-text text-white overflow-hidden">
      {/* Top CTA band */}
      <div className="border-b border-white/8">
        <div className="max-w-screen-2xl mx-auto px-4 sm:px-6 py-10 sm:py-12 lg:py-14 flex flex-col md:flex-row items-center justify-between gap-6">
          <div>
            <h3 className="text-[18px] sm:text-[22px] lg:text-[28px] font-extrabold leading-snug font-(family-name:--font-poppins)">
              Ready to list your restaurant?
            </h3>
            <p className="mt-1 text-[13px] sm:text-[14px] text-white/60 font-(family-name:--font-inter)">
              Join 120+ restaurants already managing deals on What&apos;s 4
              Dinner.
            </p>
          </div>
          <div className="flex flex-wrap items-center gap-3 shrink-0">
            <a
              href="#contact"
              className="inline-flex items-center gap-2 bg-primary hover:bg-primary-dark text-white text-[14px] font-bold px-6 py-3.5 rounded-full transition-colors duration-150 shadow-[0_4px_16px_rgba(230,57,70,0.35)]"
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
            <a
              href="#features"
              className="inline-flex items-center gap-2 border border-white/20 hover:border-white/40 text-white text-[14px] font-bold px-6 py-3.5 rounded-full transition-colors duration-150 font-(family-name:--font-poppins)"
            >
              Explore Features
            </a>
          </div>
        </div>
      </div>

      {/* Main footer body */}
      <div className="max-w-screen-2xl mx-auto px-4 sm:px-6 py-12 sm:py-14 lg:py-16">
        <div className="grid grid-cols-1 md:grid-cols-[260px_1fr] lg:grid-cols-[300px_1fr] gap-10 lg:gap-12">
          {/* Brand column */}
          <div className="flex flex-col gap-6">
            {/* Logo + name */}
            <a href="#" className="flex items-center gap-3 shrink-0 group">
              <div className="w-12 h-12 rounded-2xl bg-white flex items-center justify-center  shrink-0 overflow-hidden p-2">
                <Image
                  src="/logo.svg"
                  alt="What's 4 Dinner"
                  width={32}
                  height={32}
                  className="object-contain w-full h-full"
                />
              </div>
              <span className="text-[17px] tracking-[-0.3px] font-(family-name:--font-poppins) leading-none">
                <span className="font-normal text-white/40">
                  What&apos;s 4{" "}
                </span>
                <span className="font-extrabold text-white">Dinner</span>
              </span>
            </a>

            <p className="text-[13.5px] text-white/50 leading-relaxed max-w-65 font-(family-name:--font-inter)">
              A role-based restaurant deal platform connecting owners, customers
              and staff available on web and mobile.
            </p>

            {/* Stats mini grid */}
            {/* <div className="grid grid-cols-2 gap-2.5">
              {stats.map(({ value, label }) => (
                <div key={label} className="bg-white/5 rounded-xl px-4 py-3 border border-white/8">
                  <div className="text-[18px] font-black text-primary leading-none font-(family-name:--font-poppins)">{value}</div>
                  <div className="text-[11px] text-white/40 mt-0.5 font-medium uppercase tracking-wide font-(family-name:--font-inter)">{label}</div>
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
                  className="w-8 h-8 rounded-lg bg-white/6 hover:bg-primary border border-white/10 flex items-center justify-center text-white/50 hover:text-white transition-all duration-150"
                >
                  {icon}
                </a>
              ))}
            </div>

            {/* Country availability */}
            <div className="flex items-center gap-2">
              <span className="text-[12px] text-white/40 font-(family-name:--font-inter)">
                Available in
              </span>
              <span className="text-[15px]" title="Australia">
                🇦🇺
              </span>
              <span className="text-[15px]" title="Germany">
                🇩🇪
              </span>
            </div>
          </div>

          {/* Nav columns */}
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-8">
            {navLinks.map(({ heading, links }) => (
              <div key={heading}>
                <h4 className="text-[10.5px] font-black uppercase tracking-[0.18em] text-white/30 mb-4 font-(family-name:--font-inter)">
                  {heading}
                </h4>
                <ul className="flex flex-col gap-2.5">
                  {links.map(({ label, href }) => (
                    <li key={label}>
                      <a
                        href={href}
                        className="text-[13.5px] text-white/55 hover:text-white transition-colors duration-150 font-(family-name:--font-inter)"
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
        <div className="max-w-screen-2xl mx-auto px-4 sm:px-6 py-5 flex flex-col sm:flex-row items-center justify-between gap-3">
          <p className="text-[12.5px] text-white/35 font-(family-name:--font-inter)">
            © {year} What&apos;s 4 Dinner. All rights reserved.
          </p>
          {/* <div className="flex items-center gap-1.5 text-[12.5px] text-white/35 font-(family-name:--font-inter)">
            <span>Made with</span>
            <span className="text-primary">♥</span>
            <span>for food lovers</span>
          </div> */}
          <div className="flex items-center gap-4">
            {[
              { label: "Privacy", href: "/privacy-policy" },
              { label: "Terms", href: "/terms" },
              // { label: "Cookies", href: "#" },
            ].map((item) => (
              <a
                key={item.label}
                href={item.href}
                className="text-[12.5px] text-white/35 hover:text-white transition-colors duration-150 font-(family-name:--font-inter)"
              >
                {item.label}
              </a>
            ))}
          </div>
        </div>
      </div>
    </footer>
  );
}
