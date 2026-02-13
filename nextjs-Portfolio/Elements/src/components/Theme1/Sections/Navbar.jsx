"use client";
import { usePathname } from "next/navigation";
import React, { useEffect, useState } from "react";

const Navbar = () => {
    const pathname = usePathname();
    const [scrolled, setScrolled] = useState(false);
    const [menuOpen, setMenuOpen] = useState(false);

    useEffect(() => {
        const handleScroll = () => {
            setScrolled(window.scrollY > 20);
        };
        window.addEventListener("scroll", handleScroll);
        return () => window.removeEventListener("scroll", handleScroll);
    }, []);

    const navLinks = [
        { name: 'Theme 1', href: '/' },
        { name: 'Theme 2', href: '/theme-second' },
        { name: 'Theme 3', href: '/theme-third' },
        { name: 'Theme 4', href: '/theme-fourth' },
        { name: 'Theme 5', href: '/theme-fifth' },
    ];

    return (
        <>
            {/* Navbar */}
            <header className={`fixed top-0 left-0 w-full z-50 transition-all duration-500 ${scrolled ? "bg-white/80 backdrop-blur-xl shadow-lg" : "bg-transparent"}`}>
                <div className="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
                    {/* Logo */}
                    <div className="flex items-center gap-2 group cursor-pointer">
                        <div className="w-10 h-10 rounded-xl bg-linear-to-br from-indigo-600 via-purple-600 to-pink-600 flex items-center justify-center text-white font-bold shadow-lg group-hover:scale-110 transition-transform">
                            T1
                        </div>
                        <span className="text-xl font-bold text-gray-900">
                            Build<span className="text-indigo-600">Digital</span>
                        </span>
                    </div>

                    {/* Desktop Menu */}
                    <nav className="hidden lg:flex items-center gap-10">
                        {navLinks.map((link, i) => {
                            const isActive = pathname === link.href;
                            return (
                                <a
                                    key={i}
                                    href={link.href}
                                    className={`relative font-medium transition-colors group
                                        ${isActive ? "text-indigo-600" : "text-gray-700 hover:text-indigo-600"}
                                      `}
                                >
                                    {link.name}
                                    <span className={`absolute left-0 -bottom-2 h-0.5 bg-linear-to-r from-indigo-600 to-purple-600 transition-all duration-300 ${isActive ? "w-full" : "w-0 group-hover:w-full"}`}
                                    ></span>
                                </a>
                            )
                        })}
                    </nav>

                    {/* CTA */}
                    <div className="hidden lg:block">
                        <button className="relative px-6 py-3 font-semibold text-white rounded-xl bg-linear-to-r from-indigo-600 to-purple-600 shadow-lg overflow-hidden group">
                            <span className="relative z-10">Get Started</span>
                            <span className="absolute inset-0 bg-linear-to-r from-purple-600 to-pink-600 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></span>
                        </button>
                    </div>

                    {/* Mobile Menu Button */}
                    <button
                        className="lg:hidden w-10 h-10 flex items-center justify-center rounded-lg bg-white/80 shadow"
                        onClick={() => setMenuOpen(true)}
                    >
                        <svg
                            className="w-6 h-6 text-gray-800"
                            fill="none"
                            stroke="currentColor"
                            viewBox="0 0 24 24"
                        >
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
                        </svg>
                    </button>
                </div>
            </header>

            {/* Mobile Menu */}
            <div className={`fixed inset-0 z-50 transition-all duration-500 ${menuOpen ? "visible opacity-100" : "invisible opacity-0"}`}>
                {/* Backdrop */}
                <div
                    className="absolute inset-0 bg-black/40 backdrop-blur-sm"
                    onClick={() => setMenuOpen(false)}
                />

                {/* Drawer */}
                <div
                    className={`absolute top-0 right-0 h-full w-72 bg-white shadow-2xl p-6 transform transition-transform duration-500 ${menuOpen ? "translate-x-0" : "translate-x-full"}`}
                >
                    <div className="flex items-center justify-between mb-10">
                        <span className="text-xl font-bold text-gray-900">Menu</span>
                        <button onClick={() => setMenuOpen(false)}>
                            ✕
                        </button>
                    </div>

                    <nav className="flex flex-col gap-6">
                        {navLinks.map((link, i) => {
                            const isActive = pathname === link.href;
                            return (
                                <a
                                    key={i}
                                    href={link.href}
                                    className={`text-lg font-medium transition
                                    ${isActive ? "text-indigo-600" : "text-gray-700 hover:text-indigo-600"}
                                  `}
                                    onClick={() => setMenuOpen(false)}
                                >
                                    {link.name}
                                </a>
                            )
                        })}
                    </nav>

                    <button className="mt-10 w-full py-3 rounded-xl bg-linear-to-r from-indigo-600 to-purple-600 text-white font-semibold shadow-lg">
                        Get Started
                    </button>
                </div>
            </div>
        </>
    );
};

export default Navbar;
