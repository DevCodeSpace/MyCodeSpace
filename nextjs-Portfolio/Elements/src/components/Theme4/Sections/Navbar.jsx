"use client";
import { usePathname } from 'next/navigation';
import React, { useState, useEffect } from 'react';

const Navbar = () => {
    const pathname = usePathname();
    const [isScrolled, setIsScrolled] = useState(false);
    const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

    useEffect(() => {
        const handleScroll = () => {
            setIsScrolled(window.scrollY > 20);
        };
        window.addEventListener('scroll', handleScroll);
        return () => window.removeEventListener('scroll', handleScroll);
    }, []);

    const navLinks = [
        { name: 'Theme 1', href: '/' },
        { name: 'Theme 2', href: '/theme-second' },
        { name: 'Theme 3', href: '/theme-third' },
        { name: 'Theme 4', href: '/theme-fourth' },
        { name: 'Theme 5', href: '/theme-fifth' },
    ];

    return (
        <nav className={`fixed top-0 left-0 right-0 z-50 transition-all duration-500 ${isScrolled
            ? 'bg-slate-900/80 backdrop-blur-2xl shadow-2xl shadow-purple-500/10'
            : 'bg-transparent'
            }`}>
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div className="flex items-center justify-between h-16 sm:h-20">
                    {/* Logo */}
                    <div className="flex-shrink-0 group cursor-pointer">
                        <div className="flex items-center gap-2 sm:gap-3">
                            <div className="relative">
                                <div className="absolute inset-0 bg-gradient-to-r from-pink-500 to-purple-500 rounded-lg sm:rounded-xl blur-lg opacity-50 group-hover:opacity-75 transition-opacity"></div>
                                <div className="relative w-10 h-10 sm:w-12 sm:h-12 bg-gradient-to-br from-pink-600 via-purple-600 to-blue-600 rounded-lg sm:rounded-xl flex items-center justify-center transform group-hover:scale-110 group-hover:rotate-6 transition-all duration-300">
                                    <svg className="w-5 h-5 sm:w-7 sm:h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
                                    </svg>
                                </div>
                            </div>
                            <div className="hidden sm:block">
                                <h1 className="text-xl sm:text-2xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-pink-400 via-purple-400 to-blue-400">
                                    InnovateLab
                                </h1>
                            </div>
                        </div>
                    </div>

                    {/* Desktop Navigation - Hidden on mobile/tablet, visible on large screens */}
                    <div className="hidden lg:flex items-center gap-1 xl:gap-2">
                        {navLinks.map((link, idx) => {
                            const isActive = pathname === link.href;

                            return (
                                <a
                                    key={idx}
                                    href={link.href}
                                    onClick={() => setPathname(link.href)}
                                    className={`group relative px-3 xl:px-5 py-2 font-medium transition-all duration-300 text-sm xl:text-base
                                        ${isActive ? "text-white" : "text-gray-300 hover:text-white"}
                                    `}
                                >
                                    <span className="relative z-10">{link.name}</span>

                                    {/* Background highlight */}
                                    <div
                                        className={`absolute inset-0 rounded-lg transition-opacity duration-300
                                            ${isActive ? "opacity-100" : "opacity-0 group-hover:opacity-100"}
                                        `}
                                    />

                                    {/* Underline */}
                                    <div
                                        className={`absolute bottom-0 left-1/2 -translate-x-1/2 h-0.5
                                            bg-gradient-to-r from-pink-500 to-purple-500
                                            transition-all duration-300
                                            ${isActive ? "w-full" : "w-0 group-hover:w-full"}
                                        `}
                                    />
                                </a>
                            );
                        })}
                    </div>

                    {/* CTA Button - Desktop */}
                    <div className="hidden lg:block">
                        <button className="group relative px-4 xl:px-6 py-2 xl:py-3 bg-gradient-to-r from-pink-600 to-purple-600 text-white font-bold rounded-xl overflow-hidden shadow-lg hover:shadow-pink-500/50 transition-all duration-300 hover:scale-105 text-sm xl:text-base">
                            <span className="relative z-10 flex items-center gap-2">
                                Get Started
                                <svg className="w-4 h-4 group-hover:translate-x-1 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7l5 5m0 0l-5 5m5-5H6" />
                                </svg>
                            </span>
                            <div className="absolute inset-0 bg-gradient-to-r from-purple-600 to-blue-600 translate-x-full group-hover:translate-x-0 transition-transform duration-500"></div>
                        </button>
                    </div>

                    {/* Mobile Menu Button */}
                    <button
                        onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
                        className="lg:hidden relative w-10 h-10 bg-white/10 backdrop-blur-xl rounded-lg border border-white/20 flex items-center justify-center hover:bg-white/20 transition-all duration-300"
                    >
                        <div className="w-5 h-4 flex flex-col justify-between">
                            <span className={`w-full h-0.5 bg-white rounded-full transform transition-all duration-300 ${isMobileMenuOpen ? 'rotate-45 translate-y-1.5' : ''
                                }`}></span>
                            <span className={`w-full h-0.5 bg-white rounded-full transition-all duration-300 ${isMobileMenuOpen ? 'opacity-0' : ''
                                }`}></span>
                            <span className={`w-full h-0.5 bg-white rounded-full transform transition-all duration-300 ${isMobileMenuOpen ? '-rotate-45 -translate-y-1.5' : ''
                                }`}></span>
                        </div>
                    </button>
                </div>
            </div>

            {/* Mobile Menu */}
            <div className={`lg:hidden overflow-hidden transition-all duration-500 ${isMobileMenuOpen ? 'max-h-screen opacity-100' : 'max-h-0 opacity-0'
                }`}>
                <div className="px-4 sm:px-6 pt-2 pb-6 bg-slate-900/95 backdrop-blur-2xl border-t border-white/10">
                    <div className="space-y-2">
                        {navLinks.map((link, idx) => {
                            const isActive = pathname === link.href;

                            return (
                                <a
                                    key={idx}
                                    href={link.href}
                                    onClick={() => {
                                        setPathname(link.href);
                                        setIsMobileMenuOpen(false);
                                    }}
                                    className={`block px-4 py-3 font-medium rounded-lg transition-all duration-300 transform
                                        ${isActive
                                            ? "text-white bg-gradient-to-r from-pink-500/20 to-purple-500/20 border border-pink-500/30"
                                            : "text-gray-300 bg-white/5 hover:bg-white/10 hover:text-white hover:translate-x-2"
                                        }
                                    `}
                                >
                                    <div className="flex items-center justify-between">
                                        <span>{link.name}</span>
                                        <svg
                                            className={`w-4 h-4 transition-opacity duration-300
                                                ${isActive ? "opacity-100" : "opacity-0"}
                                            `}
                                            fill="none"
                                            stroke="currentColor"
                                            viewBox="0 0 24 24"
                                        >
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                                        </svg>
                                    </div>
                                </a>
                            );
                        })}
                    </div>

                    {/* Mobile CTA */}
                    <div className="mt-6">
                        <button className="w-full group relative px-6 py-4 bg-gradient-to-r from-pink-600 to-purple-600 text-white font-bold rounded-xl overflow-hidden shadow-lg">
                            <span className="relative z-10 flex items-center justify-center gap-2">
                                Get Started
                                <svg className="w-4 h-4 group-hover:translate-x-1 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7l5 5m0 0l-5 5m5-5H6" />
                                </svg>
                            </span>
                            <div className="absolute inset-0 bg-gradient-to-r from-purple-600 to-blue-600 translate-x-full group-hover:translate-x-0 transition-transform duration-500"></div>
                        </button>
                    </div>

                    {/* Social Links - Mobile */}
                    <div className="flex justify-center gap-4 mt-6 pt-6 border-t border-white/10">
                        {[1, 2, 3].map((idx) => (
                            <a
                                key={idx}
                                href="#"
                                className="w-10 h-10 bg-white/5 rounded-lg flex items-center justify-center hover:bg-gradient-to-br hover:from-pink-500 hover:to-purple-500 transition-all duration-300 hover:scale-110"
                            >
                                <svg className="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 24 24">
                                    <circle cx="12" cy="12" r="3" />
                                </svg>
                            </a>
                        ))}
                    </div>
                </div>
            </div>

            {/* Animated Border Bottom */}
            {isScrolled && (
                <div className="absolute bottom-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-purple-500 to-transparent opacity-50"></div>
            )}
        </nav>
    );
};

export default Navbar;