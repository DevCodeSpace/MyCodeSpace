"use client";

import { useState, useEffect } from "react";
import { usePathname } from "next/navigation";
import Image from "next/image";

const navLinks = [
  { label: "Home",           href: "",               sectionId: ""              },
  { label: "Features",       href: "#features",        sectionId: "features"      },
  { label: "For Restaurants",href: "#for-restaurants", sectionId: "for-restaurants"},
  { label: "How It Works",   href: "#how-it-works",    sectionId: "how-it-works"  },
  { label: "Mobile App",     href: "#mobile-app",      sectionId: "mobile-app"    },
  { label: "FAQ",            href: "#faq",             sectionId: "faq"           },
  { label: "Contact",        href: "#contact",         sectionId: "contact"       },
];

export default function Navbar() {
  const pathname = usePathname();
  const isHome = pathname === "/";
  const [scrolled, setScrolled] = useState(false);
  const [menuOpen, setMenuOpen] = useState(false);
  const [activeLink, setActiveLink] = useState("Home");

  function resolveHref(href: string) {
    if (!isHome && href.startsWith("#")) return `/${href}`;
    return href;
  }

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 20);
    window.addEventListener("scroll", onScroll);
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  useEffect(() => {
    const sectionIds = navLinks.filter((l) => l.sectionId).map((l) => l.sectionId);
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
        { rootMargin: "-40% 0px -55% 0px", threshold: 0 }
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
      <header
        className={`fixed top-0 left-0 right-0 z-50 bg-white transition-shadow duration-300 ${
          scrolled ? "shadow-[0_2px_16px_rgba(0,0,0,0.08)]" : "border-b border-[#EBEBEB]"
        }`}
      >
        <nav className="max-w-screen-2xl mx-auto px-4 sm:px-6 h-16 sm:h-18 flex items-center justify-between gap-4 sm:gap-8">

          {/* ── Logo ── */}
          <a href={resolveHref("#")} className="flex items-center gap-3 shrink-0 group">
            <Image
              src="/logo.svg"
              alt="What's 4 Dinner"
              width={52}
              height={52}
            />
            <span className="text-[15px] sm:text-[18px] tracking-[-0.3px] font-(family-name:--font-poppins) leading-none">
              <span className="font-normal text-slate-gray">What&apos;s 4 </span>
              <span className="font-extrabold text-primary-text group-hover:text-primary transition-colors duration-200">Dinner</span>
            </span>
          </a>

          {/* ── Desktop nav  floating pill ── */}
          <div className="hidden xl:flex flex-1 justify-center">
            <ul className="flex items-center gap-0.5 bg-[#F5F5F5] border border-[#E8E8E8] rounded-full px-1.5 py-1.5">
              {navLinks.map((link) => {
                const isActive = activeLink === link.label;
                return (
                  <li key={link.label}>
                    <a
                      href={resolveHref(link.href)}
                      onClick={() => setActiveLink(link.label)}
                      className={`relative text-[13.5px] px-4 py-1.5 rounded-full block whitespace-nowrap transition-all duration-200
                        ${
                          isActive
                            ? "bg-white text-primary-text font-semibold shadow-[0_1px_4px_rgba(0,0,0,0.10)]"
                            : "text-slate-gray font-medium hover:text-primary-text"
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
          <div className="hidden xl:flex items-center gap-2 shrink-0">
            <a
              href={resolveHref("#contact")}
              className="text-[14px] font-semibold text-slate-gray hover:text-primary-text transition-colors duration-150 px-4 py-2.5 rounded-lg hover:bg-soft-gray font-(family-name:--font-inter)"
            >
              Sign In
            </a>
            <a
              href={resolveHref("#contact")}
              className="inline-flex items-center gap-2 text-[14px] font-bold px-5 py-2.5 rounded-lg bg-primary-text text-white hover:bg-primary active:scale-[0.97] transition-all duration-150 font-(family-name:--font-poppins)"
            >
              Get Started
              <svg width="13" height="13" viewBox="0 0 16 16" fill="none" aria-hidden="true">
                <path d="M3 8h10M9 4l4 4-4 4" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
              </svg>
            </a>
          </div>

          {/* ── Mobile + Tablet hamburger ── */}
          <button
            className="xl:hidden w-10 h-10 flex items-center justify-center rounded-lg text-slate-gray hover:bg-soft-gray transition-colors"
            onClick={() => setMenuOpen(!menuOpen)}
            aria-label="Toggle menu"
            aria-expanded={menuOpen}
          >
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              {menuOpen ? (
                <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
              ) : (
                <path strokeLinecap="round" strokeLinejoin="round" d="M4 6h16M4 12h16M4 18h16" />
              )}
            </svg>
          </button>
        </nav>
      </header>

      {/* ── Mobile drawer  solid dark panel ── */}
      <div
        className={`xl:hidden fixed inset-0 z-40 transition-all duration-300 ease-in-out ${
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
          className={`absolute top-0 right-0 h-full w-72 bg-primary-text flex flex-col transition-transform duration-300 ease-in-out ${
            menuOpen ? "translate-x-0" : "translate-x-full"
          }`}
        >
          {/* Drawer header */}
          <div className="flex items-center justify-between px-6 py-5 border-b border-white/10">
            <div className="flex items-center gap-2.5">
              <Image
                src="/logo.svg"
                alt="What's 4 Dinner"
                width={30}
                height={30}
                className="brightness-0 invert"
              />
              <span className="text-[15px] tracking-[-0.2px] font-(family-name:--font-poppins) leading-none">
                <span className="font-normal text-white/50">What&apos;s 4 </span>
                <span className="font-extrabold text-white">Dinner</span>
              </span>
            </div>
            <button
              onClick={() => setMenuOpen(false)}
              className="w-8 h-8 flex items-center justify-center rounded-lg text-white/50 hover:text-white hover:bg-white/10 transition-colors"
              aria-label="Close menu"
            >
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
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
                    href={resolveHref(link.href)}
                    onClick={() => { setActiveLink(link.label); setMenuOpen(false); }}
                    className={`flex items-center gap-3 text-[15px] font-medium px-4 py-3 rounded-lg transition-colors duration-150 ${
                      isActive
                        ? "bg-primary text-white font-semibold"
                        : "text-white/70 hover:text-white hover:bg-white/8"
                    }`}
                  >
                    {isActive && (
                      <span className="w-1.5 h-1.5 rounded-full bg-white shrink-0" />
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
              href={resolveHref("#contact")}
              onClick={() => setMenuOpen(false)}
              className="flex items-center justify-center text-[14px] font-semibold px-5 py-3 rounded-lg border border-white/20 text-white/80 hover:text-white hover:border-white/40 transition-colors duration-150"
            >
              Sign In
            </a>
            <a
              href={resolveHref("#contact")}
              onClick={() => setMenuOpen(false)}
              className="flex items-center justify-center gap-2 text-[14px] font-bold px-5 py-3 rounded-lg bg-primary text-white hover:bg-primary-dark transition-colors duration-150"
            >
              Get Started
              <svg width="13" height="13" viewBox="0 0 16 16" fill="none" aria-hidden="true">
                <path d="M3 8h10M9 4l4 4-4 4" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
              </svg>
            </a>
          </div>
        </div>
      </div>
    </>
  );
}
