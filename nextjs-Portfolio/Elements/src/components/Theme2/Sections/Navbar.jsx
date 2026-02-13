"use client";
import React, { useState } from "react";
import { Menu, Search, X } from "lucide-react";
import Link from "next/link";
import { usePathname } from "next/navigation";

const Navbar = () => {
    const pathname = usePathname();
    const [isOpen, setIsOpen] = useState(false);

    return (
        <>
            {/* Floating Navbar */}
            <nav className="fixed top-4 left-4 right-4 md:top-6 md:left-1/2 md:-translate-x-1/2 z-50 md:w-[95%] max-w-6xl">
                <div className="bg-white/90 backdrop-blur-xl rounded-2xl shadow-2xl border border-gray-200">
                    <div className="px-6">
                        <div className="flex items-center justify-between h-16">
                            {/* Logo */}
                            <div className="flex items-center gap-3">
                                <div className="w-10 h-10 bg-linear-to-br from-emerald-500 to-teal-500 rounded-xl flex items-center justify-center text-white font-bold shadow-lg">
                                    F
                                </div>
                                <span className="text-xl font-bold text-gray-900">
                                    Floating
                                </span>
                            </div>

                            {/* Desktop Menu */}
                            <div className="hidden lg:flex items-center gap-6">
                                {[
                                    { label: "Theme 1", href: "/" },
                                    { label: "Theme 2", href: "/theme-second" },
                                    { label: "Theme 3", href: "/theme-third" },
                                    { label: "Theme 4", href: "/theme-fourth" },
                                    { label: "Theme 5", href: "/theme-fifth" },
                                ].map((item, i) => {
                                    const isActive = pathname === item.href;

                                    return (
                                        <Link
                                            key={i}
                                            href={item.href}
                                            className={`relative font-semibold px-2 py-1 transition-colors group ${isActive ? "text-emerald-600" : "text-gray-700 hover:text-emerald-600"}`}
                                        >
                                            {item.label}

                                            {/* Underline */}
                                            <span className={`absolute left-0 -bottom-1 h-0.5  bg-linear-to-r from-emerald-500 to-teal-500 transition-all duration-300 ${isActive ? "w-full" : "w-0 group-hover:w-full"}`} />
                                        </Link>
                                    );
                                })}
                            </div>


                            {/* Desktop Actions */}
                            <div className="hidden lg:flex items-center gap-3">
                                <button className="p-2 rounded-xl hover:bg-gray-100 transition">
                                    <Search size={20} />
                                </button>
                                <button className="px-5 py-2 bg-linear-to-r from-emerald-500 to-teal-500 text-white rounded-xl font-semibold hover:shadow-xl hover:scale-[1.03] transition-all">
                                    Get Started
                                </button>
                            </div>

                            {/* Mobile Toggle */}
                            <button onClick={() => setIsOpen(!isOpen)} className="lg:hidden p-2 rounded-xl hover:bg-gray-100 transition">
                                {isOpen ? <X size={24} /> : <Menu size={24} />}
                            </button>
                        </div>
                    </div>
                </div>

                {/* Mobile / Tablet Menu */}
                <div className={`lg:hidden absolute left-0 right-0 mt-4 transition-all duration-500 ${isOpen
                    ? "opacity-100 translate-y-0 scale-100 pointer-events-auto"
                    : "opacity-0 -translate-y-4 scale-95 pointer-events-none"
                    }`}
                >
                    <div className="bg-white/95 backdrop-blur-2xl rounded-2xl shadow-2xl border border-gray-200 p-6 origin-top animate-menu">
                        {/* Links */}
                        <div className="flex flex-col gap-3">
                            {[
                                { label: "Theme 1", href: "/" },
                                { label: "Theme 2", href: "/theme-second" },
                                { label: "Theme 3", href: "/theme-third" },
                                { label: "Theme 4", href: "/theme-fourth" },
                                { label: "Theme 5", href: "/theme-fifth" },
                            ].map((item, i) => (
                                <Link
                                    key={i}
                                    href={item.href}
                                    onClick={() => setIsOpen(false)}
                                    style={{ animationDelay: `${i * 80}ms` }}
                                    className={`menu-item px-4 py-3 rounded-xl font-semibold transition-all duration-300
                                ${pathname === item.href
                                            ? "bg-emerald-50 text-emerald-600"
                                            : "text-gray-800 hover:bg-emerald-50 hover:text-emerald-600"}
                              `}

                                >
                                    {item.label}
                                </Link>
                            ))}
                        </div>

                        {/* Actions */}
                        <div className="mt-6 flex gap-3 animate-fade-in-up">
                            <button className="flex-1 py-3 rounded-xl border border-gray-300 font-semibold hover:bg-gray-100 active:scale-95 transition">
                                Search
                            </button>
                            <button className="flex-1 py-3 rounded-xl font-semibold text-white
                                 bg-linear-to-r from-emerald-500 to-teal-500
                                 shadow-lg hover:shadow-xl hover:scale-[1.03]
                                 active:scale-95 transition-all duration-300">
                                Get Started
                            </button>
                        </div>
                    </div>
                </div>
            </nav>
        </>
    );
};

export default Navbar;
