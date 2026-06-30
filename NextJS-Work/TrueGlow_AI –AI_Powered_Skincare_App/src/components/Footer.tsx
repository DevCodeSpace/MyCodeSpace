import Image from "next/image";

const navColumns = [
  {
    heading: "Product",
    links: [
      { label: "Features", href: "#features" },
      { label: "How It Works", href: "#how-it-works" },
      { label: "Mobile App", href: "#mobile-app" },
      { label: "AI Chat", href: "#features" },
      { label: "Scan History", href: "#features" },
    ],
  },
  {
    heading: "Support",
    links: [
      { label: "FAQ", href: "#faq" },
      { label: "Contact Us", href: "#contact" },
      { label: "Help Center", href: "#contact" },
      { label: "Privacy & Data", href: "#contact" },
    ],
  },
  {
    heading: "Legal",
    links: [
      { label: "Privacy Policy", href: "#" },
      { label: "Terms of Service", href: "#" },
      { label: "Cookie Policy", href: "#" },
      { label: "Delete Account", href: "#" },
    ],
  },
];

const socials = [
  {
    label: "Twitter / X",
    href: "#",
    icon: (
      <svg
        width="15"
        height="15"
        viewBox="0 0 24 24"
        fill="currentColor"
        aria-hidden="true"
      >
        <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
      </svg>
    ),
  },
  {
    label: "Instagram",
    href: "#",
    icon: (
      <svg
        width="15"
        height="15"
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
    label: "LinkedIn",
    href: "#",
    icon: (
      <svg
        width="15"
        height="15"
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
    label: "YouTube",
    href: "#",
    icon: (
      <svg
        width="15"
        height="15"
        viewBox="0 0 24 24"
        fill="currentColor"
        aria-hidden="true"
      >
        <path d="M22.54 6.42a2.78 2.78 0 0 0-1.95-1.96C18.88 4 12 4 12 4s-6.88 0-8.59.46A2.78 2.78 0 0 0 1.46 6.42 29 29 0 0 0 1 12a29 29 0 0 0 .46 5.58 2.78 2.78 0 0 0 1.95 1.95C5.12 20 12 20 12 20s6.88 0 8.59-.47a2.78 2.78 0 0 0 1.95-1.95A29 29 0 0 0 23 12a29 29 0 0 0-.46-5.58z" />
        <polygon
          points="9.75 15.02 15.5 12 9.75 8.98 9.75 15.02"
          fill="#0F172A"
        />
      </svg>
    ),
  },
];



export default function Footer() {
  const year = new Date().getFullYear();

  return (
    <footer className="bg-[#0F172A] text-white overflow-hidden">
      {/* ── Top CTA band ── */}
      <div className="border-b border-white/8">
        <div className="max-w-screen-2xl mx-auto px-6 py-10 md:py-14 flex flex-col md:flex-row items-center justify-between gap-6">
          <div>
            <h3 className="text-[22px] lg:text-[28px] font-extrabold leading-snug font-(family-name:--font-noto)">
              Ready to know your skin?
            </h3>
            <p className="mt-1 text-[14px] text-white/50 font-(family-name:--font-noto)">
              Join 50,000+ users already glowing with TrueGlow AI.
            </p>
          </div>
          <div className="flex flex-wrap items-center gap-3">
            <a
              href="#contact"
              className="inline-flex items-center gap-2 bg-[#F4C95D] hover:bg-[#e8b84b] text-[#0F172A] text-[14px] font-bold px-6 py-3.5 rounded-xl transition-colors duration-150 font-(family-name:--font-noto)"
            >
              Get Started Free
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
              className="inline-flex items-center gap-2 border border-white/15 hover:border-white/30 text-white text-[14px] font-bold px-6 py-3.5 rounded-xl transition-colors duration-150 font-(family-name:--font-noto)"
            >
              Explore Features
            </a>
          </div>
        </div>
      </div>

      {/* ── Main body ── */}
      <div className="max-w-screen-2xl mx-auto px-6 py-10 md:py-16">
        <div className="grid grid-cols-1 lg:grid-cols-[280px_1fr] gap-12">
          {/* Brand column */}
          <div className="flex flex-col gap-6">
            {/* Logo + wordmark */}
            <a href="#" className="flex items-center gap-3 shrink-0">
              <Image
                src="/logo.jpeg"
                alt="TrueGlow AI"
                width={38}
                height={38}
                className="rounded-lg"
              />
              <span className="text-[17px] tracking-[-0.3px] font-(family-name:--font-noto) leading-none">
                <span className="font-extrabold text-white">True</span>
                <span className="font-extrabold text-[#F4C95D]">Glow</span>
                <span className="font-semibold text-[#98B8F8]"> ai</span>
              </span>
            </a>

            <p className="text-[13.5px] text-white/45 leading-relaxed max-w-64 font-(family-name:--font-noto)">
              AI-powered skin analysis and personalized skincare available on
              iOS and Android.
            </p>



            {/* Socials */}
            <div className="flex items-center gap-2">
              {socials.map(({ label, href, icon }) => (
                <a
                  key={label}
                  href={href}
                  aria-label={label}
                  className="w-8 h-8 rounded-lg bg-white/6 hover:bg-[#F4C95D] border border-white/10 flex items-center justify-center text-white/45 hover:text-[#0F172A] transition-all duration-150"
                >
                  {icon}
                </a>
              ))}
            </div>
          </div>

          {/* Nav columns */}
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-8">
            {navColumns.map(({ heading, links }) => (
              <div key={heading}>
                <h4 className="text-[10.5px] font-extrabold uppercase tracking-[0.18em] text-white/25 mb-4 font-(family-name:--font-noto)">
                  {heading}
                </h4>
                <ul className="flex flex-col gap-2.5">
                  {links.map(({ label, href }) => (
                    <li key={label}>
                      <a
                        href={href}
                        className="text-[13.5px] text-white/50 hover:text-white transition-colors duration-150 font-(family-name:--font-noto)"
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

      {/* ── Bottom bar ── */}
      <div className="border-t border-white/8">
        <div className="max-w-screen-2xl mx-auto px-6 py-5 flex flex-col sm:flex-row items-center justify-between gap-3">
          <p className="text-[12.5px] text-white/30 font-(family-name:--font-noto)">
            © {year} TrueGlow AI. All rights reserved.
          </p>
          {/* <div className="flex items-center gap-1.5 text-[12.5px] text-white/30 font-(family-name:--font-noto)">
            <span>Made with</span>
            <span className="text-[#F4C95D]">♥</span>
            <span>for healthy skin</span>
          </div> */}
          <div className="flex items-center gap-4">
            {["Privacy", "Terms", "Cookies"].map((item) => (
              <a
                key={item}
                href="#"
                className="text-[12.5px] text-white/30 hover:text-white transition-colors duration-150 font-(family-name:--font-noto)"
              >
                {item}
              </a>
            ))}
          </div>
        </div>
      </div>
    </footer>
  );
}
