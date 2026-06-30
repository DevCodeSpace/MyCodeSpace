"use client";

import { useEffect, useState } from "react";

const navLinks = [
  { label: "Home", href: "#", sectionId: "" },
  { label: "Features", href: "#features", sectionId: "features" },
  { label: "How It Works", href: "#how-it-works", sectionId: "how-it-works" },
  { label: "Why Us", href: "#why-us", sectionId: "why-us" },
  { label: "Testimonials", href: "#testimonials", sectionId: "testimonials" },
  { label: "FAQ", href: "#faq", sectionId: "faq" },
  { label: "Contact", href: "#contact", sectionId: "contact" },
];

export default function Navbar({ tickerVisible = true }: { tickerVisible?: boolean }) {
  const [scrolled, setScrolled] = useState(false);
  const [menuOpen, setMenuOpen] = useState(false);
  const [activeLink, setActiveLink] = useState("Home");

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 20);
    window.addEventListener("scroll", onScroll);
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  // Scroll-spy: update active link based on which section is in view
  useEffect(() => {
    const sectionIds = navLinks
      .filter((l) => l.sectionId)
      .map((l) => l.sectionId);

    const observers: IntersectionObserver[] = [];

    sectionIds.forEach((id) => {
      const el = document.getElementById(id);
      if (!el) return;
      const obs = new IntersectionObserver(
        ([entry]) => {
          if (entry.isIntersecting) {
            const link = navLinks.find((l) => l.sectionId === id);
            if (link) setActiveLink(link.label);
          }
        },
        { rootMargin: "-40% 0px -55% 0px", threshold: 0 },
      );
      obs.observe(el);
      observers.push(obs);
    });

    // If scrolled near top, reset to Home
    const onScroll = () => {
      if (window.scrollY < 100) setActiveLink("Home");
    };
    window.addEventListener("scroll", onScroll);

    return () => {
      observers.forEach((obs) => obs.disconnect());
      window.removeEventListener("scroll", onScroll);
    };
  }, []);

  return (
    <header
      className={`fixed left-0 right-0 z-50 transition-all duration-300 ${tickerVisible ? "top-10.5" : "top-0"} ${
        scrolled
          ? "bg-white shadow-[0_1px_0_0_#E8E8EC,0_4px_24px_rgba(0,0,0,0.06)]"
          : "bg-white border-b border-[#EBEBEF]"
      }`}
    >
      <nav className="max-w-screen-2xl mx-auto px-6 h-19 flex items-center justify-between gap-10">
        {/* Logo */}
        <a href="#" className="flex items-center gap-2.5 shrink-0">
          <img
            src="/carebot_logo.svg"
            alt="CareBot AI"
            className="h-11 w-auto"
          />
          <span className="text-[22px] font-extrabold tracking-[-0.5px]">
            CareBot<span className="text-primary">AI</span>
          </span>
        </a>

        {/* Desktop nav  center */}
        <ul className="hidden md:flex items-center gap-1 flex-1 justify-center">
          {navLinks.map((link) => {
            const isActive = activeLink === link.label;
            return (
              <li key={link.label}>
                <a
                  href={link.href}
                  className={`relative text-[15px] font-semibold px-4 py-2 block whitespace-nowrap transition-colors duration-200 group
                    ${isActive ? "text-primary" : "text-[#52526B] hover:text-primary"}`}
                >
                  {link.label}
                  <span
                    className={`absolute bottom-0 left-1/2 -translate-x-1/2 h-[2.5px] rounded-full bg-primary transition-all duration-300
                      ${isActive ? "w-5 opacity-100" : "w-0 opacity-0 group-hover:w-5 group-hover:opacity-40"}`}
                  />
                </a>
              </li>
            );
          })}
        </ul>

        {/* CTA right */}
        <div className="hidden md:flex items-center gap-3 shrink-0">
          <a
            href="#contact"
            className="text-[15px] font-semibold text-[#52526B] hover:text-[#0D0D14] transition-colors duration-150 px-4 py-2 rounded-lg hover:bg-[#F4F4F8]"
          >
            Sign In
          </a>
          <a
            href="#contact"
            className="inline-flex items-center gap-2 text-[14.5px] font-bold px-6 py-2.5 rounded-[11px] bg-primary text-white hover:bg-[#0031CC] active:scale-[0.97] transition-all duration-150 shadow-[0_2px_10px_rgba(0,61,245,0.30)] hover:shadow-[0_4px_18px_rgba(0,61,245,0.42)]"
          >
            Request Demo
            <svg
              width="14"
              height="14"
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
        </div>

        {/* Mobile hamburger */}
        <button
          className="md:hidden p-2.5 rounded-xl text-[#555] hover:text-black hover:bg-[#F0F0F3] transition-colors"
          onClick={() => setMenuOpen(!menuOpen)}
          aria-label="Toggle menu"
          aria-expanded={menuOpen}
        >
          <svg
            width="20"
            height="20"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
          >
            {menuOpen ? (
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M6 18L18 6M6 6l12 12"
              />
            ) : (
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M4 6h16M4 12h16M4 18h16"
              />
            )}
          </svg>
        </button>
      </nav>

      {/* Mobile menu */}
      <div
        className={`md:hidden overflow-hidden transition-all duration-300 ease-in-out ${
          menuOpen ? "max-h-96 opacity-100" : "max-h-0 opacity-0"
        } bg-white border-t border-[#EBEBEF]`}
      >
        <ul className="flex flex-col px-5 py-4 gap-1">
          {navLinks.map((link) => (
            <li key={link.label}>
              <a
                href={link.href}
                className="flex items-center text-[#333] text-[15px] font-medium px-4 py-3 rounded-xl hover:bg-[#F4F4F8] hover:text-primary transition-colors"
                onClick={() => setMenuOpen(false)}
              >
                {link.label}
              </a>
            </li>
          ))}
          <li className="pt-3 mt-1 border-t border-[#EBEBEF]">
            <a
              href="#contact"
              className="flex items-center justify-center gap-2 text-[15px] font-semibold px-5 py-3 rounded-xl bg-primary text-white hover:bg-[#0031CC] transition-colors shadow-[0_2px_10px_rgba(0,61,245,0.30)]"
              onClick={() => setMenuOpen(false)}
            >
              Request Demo
              <svg
                width="13"
                height="13"
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
          </li>
        </ul>
      </div>
    </header>
  );
}
