"use client";

import Image from "next/image";
import { useEffect, useState } from "react";

const navLinks = [
  { label: "Home", href: "#", sectionId: "" },
  { label: "Features", href: "#features", sectionId: "features" },
  { label: "How It Works", href: "#how-it-works", sectionId: "how-it-works" },
  { label: "Mobile App", href: "#mobile-app", sectionId: "mobile-app" },
  { label: "FAQ", href: "#faq", sectionId: "faq" },
  { label: "Contact", href: "#contact", sectionId: "contact" },
];

export default function Navbar() {
  const [menuOpen, setMenuOpen] = useState(false);
  const [activeLink, setActiveLink] = useState("Home");

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
    <>
      <header className="fixed top-0 left-0 right-0 z-50 bg-[#0F172A] border-b border-white/6">
        <nav className="max-w-screen-2xl mx-auto px-6 h-18 flex items-center justify-between gap-8">
          {/* ── Logo ── */}
          <a href="#" className="flex items-center gap-3 shrink-0 group">
            <Image src="/logo.jpeg" alt="TrueGlow AI" width={44} height={44} className="rounded-xl" />
            <span className="text-[18px] tracking-[-0.3px] font-(family-name:--font-noto) leading-none">
              <span className="font-extrabold text-white">True</span>
              <span className="font-extrabold text-[#F4C95D]">Glow</span>
              <span className="font-semibold text-[#98B8F8]"> ai</span>
            </span>
          </a>

          {/* ── Desktop nav  segmented control ── */}
          <div className="hidden md:flex flex-1 justify-center">
            <ul className="flex items-center bg-[#1E293B] rounded-lg p-1 gap-0.5">
              {navLinks.map((link) => {
                const isActive = activeLink === link.label;
                return (
                  <li key={link.label}>
                    <a
                      href={link.href}
                      className={`relative flex items-center px-4 py-2 rounded-md text-[13px] font-semibold whitespace-nowrap transition-all duration-200
                        ${
                          isActive
                            ? "bg-[#F4C95D] text-[#0F172A]"
                            : "text-white/45 hover:text-white/80 hover:bg-white/5"
                        }`}
                    >
                      {link.label}
                    </a>
                  </li>
                );
              })}
            </ul>
          </div>

          {/* ── Desktop CTAs ── */}
          <div className="hidden md:flex items-center gap-2 shrink-0">
            <a
              href="#contact"
              className="text-[14px] font-semibold text-white/60 hover:text-white transition-colors duration-150 px-4 py-2.5 rounded-lg hover:bg-white/8 font-(family-name:--font-noto)"
            >
              Sign In
            </a>
            <a
              href="#contact"
              className="inline-flex items-center gap-2 text-[14px] font-bold px-5 py-2.5 rounded-lg bg-[#F4C95D] text-[#0F172A] hover:bg-[#e8b84b] active:scale-[0.97] transition-all duration-150 font-(family-name:--font-noto)"
            >
              Get Started
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
          </div>

          {/* ── Mobile hamburger ── */}
          <button
            className="md:hidden w-10 h-10 flex items-center justify-center rounded-lg text-white/60 hover:text-white hover:bg-white/8 transition-colors"
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
      </header>

      {/* ── Mobile drawer ── */}
      <div
        className={`md:hidden fixed inset-0 z-40 transition-all duration-300 ease-in-out ${
          menuOpen ? "pointer-events-auto" : "pointer-events-none"
        }`}
      >
        {/* Backdrop */}
        <div
          className={`absolute inset-0 bg-black/40 transition-opacity duration-300 ${
            menuOpen ? "opacity-100" : "opacity-0"
          }`}
          onClick={() => setMenuOpen(false)}
        />

        {/* Drawer panel */}
        <div
          className={`absolute top-0 right-0 h-full w-72 bg-[#0F172A] flex flex-col transition-transform duration-300 ease-in-out ${
            menuOpen ? "translate-x-0" : "translate-x-full"
          }`}
        >
          {/* Drawer header */}
          <div className="flex items-center justify-between px-6 py-5 border-b border-white/10">
            <div className="flex items-center gap-2.5">
              <Image
                src="/logo.jpeg"
                alt="TrueGlow AI"
                width={30}
                height={30}
                className="rounded-lg"
              />
              <span className="text-[15px] tracking-[-0.2px] font-(family-name:--font-noto) leading-none">
                <span className="font-extrabold text-white">True</span>
                <span className="font-extrabold text-[#F4C95D]">Glow</span>
                <span className="font-semibold text-[#98B8F8]"> ai</span>
              </span>
            </div>
            <button
              onClick={() => setMenuOpen(false)}
              className="w-8 h-8 flex items-center justify-center rounded-lg text-white/50 hover:text-white hover:bg-white/10 transition-colors"
              aria-label="Close menu"
            >
              <svg
                width="16"
                height="16"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M6 18L18 6M6 6l12 12"
                />
              </svg>
            </button>
          </div>

          {/* Nav links */}
          <ul className="flex flex-col px-4 py-5 gap-1 flex-1 overflow-y-auto">
            {navLinks.map((link) => {
              const isActive = activeLink === link.label;
              return (
                <li key={link.label}>
                  <a
                    href={link.href}
                    onClick={() => setMenuOpen(false)}
                    className={`flex items-center gap-3 text-[15px] font-medium px-4 py-3 rounded-lg transition-colors duration-150 ${
                      isActive
                        ? "bg-[#F4C95D] text-[#0F172A] font-semibold"
                        : "text-white/70 hover:text-white hover:bg-white/8"
                    }`}
                  >
                    {isActive && (
                      <span className="w-1.5 h-1.5 rounded-full bg-[#0F172A] shrink-0" />
                    )}
                    {link.label}
                  </a>
                </li>
              );
            })}
          </ul>

          {/* Drawer footer CTAs */}
          <div className="px-4 py-5 border-t border-white/10 flex flex-col gap-2.5">
            <a
              href="#contact"
              onClick={() => setMenuOpen(false)}
              className="flex items-center justify-center text-[14px] font-semibold px-5 py-3 rounded-lg border border-white/20 text-white/80 hover:text-white hover:border-white/40 transition-colors duration-150"
            >
              Sign In
            </a>
            <a
              href="#contact"
              onClick={() => setMenuOpen(false)}
              className="flex items-center justify-center gap-2 text-[14px] font-bold px-5 py-3 rounded-lg bg-[#F4C95D] text-[#0F172A] hover:bg-[#e8b84b] transition-colors duration-150"
            >
              Get Started
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
          </div>
        </div>
      </div>
    </>
  );
}
