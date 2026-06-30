"use client";
import { ArrowRight, Menu, X } from "lucide-react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useState } from "react";

const navLinks = [
  { label: "Home", href: "/", section: "" },
  { label: "Features", href: "/#features", section: "features" },
  { label: "How It Works", href: "/#how-it-works", section: "how-it-works" },
  { label: "Why Us", href: "/#why", section: "why" },
  { label: "Testimonials", href: "/#testimonials", section: "testimonials" },
  { label: "FAQ", href: "/#faq", section: "faq" },
  { label: "Contact", href: "/#contact", section: "contact" },
];

const sectionIds = navLinks.map((l) => l.section).filter(Boolean);

const marqueeItems = [
  "Efficient Shipment Loading",
  "Financial Integrity Reports",
  "Real-time Stock Dashboard",
  "GST-Ready Invoicing",
  "Taka & Bale Management",
  "Auto Freight Calculation",
  "8+ Logistics Reports",
  "Multi-party Management",
  "Standalone Print Engine",
  "Complete Admin Control",
];

export default function Navbar() {
  const [open, setOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);
  const [activeSection, setActiveSection] = useState("");
  const pathname = usePathname();

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 10);
    window.addEventListener("scroll", onScroll);
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  useEffect(() => {
    const observers: IntersectionObserver[] = [];

    sectionIds.forEach((id) => {
      const el = document.getElementById(id);
      if (!el) return;

      const observer = new IntersectionObserver(
        ([entry]) => {
          if (entry.isIntersecting) setActiveSection(id);
        },
        { rootMargin: "-40% 0px -55% 0px", threshold: 0 },
      );

      observer.observe(el);
      observers.push(observer);
    });

    const onScroll = () => {
      if (window.scrollY < 80) setActiveSection("");
    };
    window.addEventListener("scroll", onScroll, { passive: true });

    return () => {
      observers.forEach((o) => o.disconnect());
      window.removeEventListener("scroll", onScroll);
    };
  }, []);

  const isActive = (section: string) => activeSection === section;

  return (
    <div className="fixed top-0 w-full z-50">
      {/* Announcement bar */}
      <div
        className="bg-[#0C1B33] py-2 relative overflow-hidden"
        aria-hidden="true"
      >
        <div
          className="absolute left-0 top-0 bottom-0 w-16 z-10 pointer-events-none"
          style={{
            background: "linear-gradient(to right, #0C1B33, transparent)",
          }}
        />
        <div
          className="absolute right-0 top-0 bottom-0 w-16 z-10 pointer-events-none"
          style={{
            background: "linear-gradient(to left, #0C1B33, transparent)",
          }}
        />
        <div className="flex overflow-hidden">
          <div className="flex animate-marquee items-center whitespace-nowrap">
            {[0, 1].map((ri) => (
              <div key={ri} className="flex items-center shrink-0">
                {marqueeItems.map((item, idx) => (
                  <span key={idx} className="inline-flex items-center shrink-0">
                    <span className="inline-flex items-center gap-2.5 px-6">
                      <span
                        className="w-1 h-1 rounded-full bg-[#F0F8FF]/40 shrink-0"
                        aria-hidden="true"
                      />
                      <span className="text-[12px] font-medium text-white/55 tracking-widest uppercase">
                        {item}
                      </span>
                    </span>
                    <span className="text-white/10 text-xs" aria-hidden="true">
                      ✦
                    </span>
                  </span>
                ))}
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Main navbar */}
      <header
        className={`bg-white transition-all duration-300 ${
          scrolled
            ? "shadow-[0_2px_20px_rgba(12,27,51,0.08)] border-b border-[#0C1B33]/6"
            : "border-b border-[#0C1B33]/8"
        }`}
      >
        <div className="max-w-360 mx-auto px-4 sm:px-6 lg:px-10">
          <div className="flex items-center justify-between h-18">
            {/* Logo */}
            <Link
              href="/"
              aria-label="TransportPro  Transport Management Software"
              className="flex items-center gap-3 group shrink-0"
            >
              <div className="w-9 h-9 rounded-xl bg-[#0C1B33] flex items-center justify-center shadow-sm group-hover:shadow-md group-hover:scale-105 transition-all duration-200">
                <svg
                  viewBox="0 0 24 24"
                  className="w-5 h-5 fill-white"
                  xmlns="http://www.w3.org/2000/svg"
                  aria-hidden="true"
                >
                  <path d="M20 8h-3V4H3c-1.1 0-2 .9-2 2v11h2c0 1.66 1.34 3 3 3s3-1.34 3-3h6c0 1.66 1.34 3 3 3s3-1.34 3-3h2v-5l-3-4zM6 18.5c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5zm13.5-9l1.96 2.5H17V9.5h2.5zm-1.5 9c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5z" />
                </svg>
              </div>
              <div className="flex flex-col leading-none">
                <span className="text-[18px] font-bold text-[#0C1B33] tracking-tight">
                  TransportPro
                </span>
                <span className="text-[10px] font-medium text-[#0C1B33]/35 tracking-widest uppercase mt-0.5">
                  Logistics Platform
                </span>
              </div>
            </Link>

            {/* Desktop nav */}
            <nav
              aria-label="Main navigation"
              className="hidden lg:flex items-center gap-0.5"
            >
              {navLinks.map((link) => {
                const active = isActive(link.section);
                const handleClick =
                  link.section === ""
                    ? (e: React.MouseEvent) => {
                        if (pathname === "/") {
                          e.preventDefault();
                          window.scrollTo({ top: 0, behavior: "smooth" });
                        }
                      }
                    : undefined;
                return (
                  <Link
                    key={link.label}
                    href={link.href}
                    onClick={handleClick}
                    aria-current={active ? "true" : undefined}
                    className={`relative px-4 py-2 text-[15.5px] font-medium rounded-lg transition-colors duration-150 group ${
                      active
                        ? "text-[#0C1B33]"
                        : "text-[#0C1B33]/50 hover:text-[#0C1B33]"
                    }`}
                  >
                    {link.label}
                    <span
                      aria-hidden="true"
                      className={`absolute bottom-1 left-4 right-4 h-0.5 bg-[#0C1B33] rounded-full transition-transform duration-200 origin-left ${
                        active
                          ? "scale-x-100"
                          : "scale-x-0 group-hover:scale-x-100"
                      }`}
                    />
                  </Link>
                );
              })}
            </nav>

            {/* CTA */}
            <div className="hidden lg:flex items-center gap-5">
              <Link
                href="/#contact"
                className="group inline-flex items-center gap-2 px-5 py-2.5 text-[15px] font-semibold text-white bg-[#0C1B33] rounded-lg hover:bg-[#0C1B33]/90 transition-all hover:-translate-y-0.5 hover:shadow-lg hover:shadow-[#0C1B33]/20"
              >
                Request Demo
                <ArrowRight
                  className="w-3.5 h-3.5 group-hover:translate-x-0.5 transition-transform"
                  aria-hidden="true"
                />
              </Link>
            </div>

            {/* Mobile toggle */}
            <button
              className="lg:hidden p-2 rounded-lg text-[#0C1B33]/50 hover:text-[#0C1B33] hover:bg-[#0C1B33]/5 transition-all"
              onClick={() => setOpen(!open)}
              aria-label={
                open ? "Close navigation menu" : "Open navigation menu"
              }
              aria-expanded={open}
              aria-controls="mobile-nav"
            >
              {open ? (
                <X className="w-5 h-5" aria-hidden="true" />
              ) : (
                <Menu className="w-5 h-5" aria-hidden="true" />
              )}
            </button>
          </div>
        </div>

        {/* Mobile menu */}
        {open && (
          <nav
            id="mobile-nav"
            aria-label="Mobile navigation"
            className="lg:hidden border-t border-[#0C1B33]/8 bg-white px-4 pb-4 pt-2 space-y-0.5"
          >
            {navLinks.map((link) => {
              const active = isActive(link.section);
              const handleClick =
                link.section === ""
                  ? (e: React.MouseEvent) => {
                      if (pathname === "/") {
                        e.preventDefault();
                        window.scrollTo({ top: 0, behavior: "smooth" });
                      }
                      setOpen(false);
                    }
                  : () => setOpen(false);
              return (
                <Link
                  key={link.label}
                  href={link.href}
                  onClick={handleClick}
                  aria-current={active ? "true" : undefined}
                  className={`block px-4 py-3 text-[15.5px] font-medium rounded-lg transition-all ${
                    active
                      ? "bg-[#0C1B33]/6 text-[#0C1B33] font-semibold"
                      : "text-[#0C1B33]/60 hover:bg-[#F0F8FF] hover:text-[#0C1B33]"
                  }`}
                >
                  {link.label}
                </Link>
              );
            })}
            <div className="pt-2">
              <Link
                href="/#contact"
                className="flex items-center justify-center gap-2 px-4 py-3 text-[15.5px] font-semibold text-white rounded-lg bg-[#0C1B33] hover:bg-[#0C1B33]/90 transition-colors"
                onClick={() => setOpen(false)}
              >
                Request Demo
                <ArrowRight className="w-4 h-4" aria-hidden="true" />
              </Link>
            </div>
          </nav>
        )}
      </header>
    </div>
  );
}
