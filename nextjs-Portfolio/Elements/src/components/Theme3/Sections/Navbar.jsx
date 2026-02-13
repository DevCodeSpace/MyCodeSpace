"use client"
import { usePathname } from 'next/navigation';
import React, { useState, useEffect } from 'react';

const Navbar = () => {
    const pathname = usePathname();
    const [isOpen, setIsOpen] = useState(false);
    const [scrolled, setScrolled] = useState(false);

    useEffect(() => {
        const handleScroll = () => {
            setScrolled(window.scrollY > 20);
        };
        window.addEventListener('scroll', handleScroll);
        return () => window.removeEventListener('scroll', handleScroll);
    }, []);

    // Close mobile menu on route change
    useEffect(() => {
        setIsOpen(false);
    }, [pathname]);

    const navLinks = [
        { name: 'Theme 1', href: '/' },
        { name: 'Theme 2', href: '/theme-second' },
        { name: 'Theme 3', href: '/theme-third' },
        { name: 'Theme 4', href: '/theme-fourth' },
        { name: 'Theme 5', href: '/theme-fifth' },
    ];

    return (
        <>
            <nav
                className={`fixed top-0 left-0 right-0 z-50 transition-all duration-500 ${scrolled
                    ? 'bg-black/80 backdrop-blur-xl border-b border-zinc-700/50'
                    : 'bg-transparent'
                    }`}
            >
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="flex items-center justify-between h-16 sm:h-20">
                        {/* Logo */}
                        <a href="/" className="flex-shrink-0 group cursor-pointer">
                            <div className="relative">
                                <div className="absolute -inset-2 bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500 rounded-xl blur-lg opacity-0 group-hover:opacity-75 transition-all duration-500"></div>
                                <div className="relative flex items-center gap-2">
                                    <div className="w-8 h-8 sm:w-10 sm:h-10 bg-gradient-to-r from-indigo-500 to-purple-500 rounded-xl flex items-center justify-center text-white font-bold text-lg sm:text-xl">
                                        D
                                    </div>
                                    <span className="text-white font-black text-xl sm:text-2xl tracking-tight">
                                        Digital<span className="bg-gradient-to-r from-indigo-500 to-purple-500 bg-clip-text text-transparent">Dreams</span>
                                    </span>
                                </div>
                            </div>
                        </a>

                        {/* Desktop Navigation */}
                        <div className="hidden lg:flex items-center space-x-1 lg:space-x-2">
                            {navLinks.map((link, idx) => {
                                const isActive = pathname === link.href;
                                return (
                                    <a
                                        key={idx}
                                        href={link.href}
                                        className={`relative px-3 lg:px-5 py-2 font-medium text-sm lg:text-base transition-colors duration-300 group ${isActive ? "text-white" : "text-zinc-300 hover:text-white"}`}
                                    >
                                        <span className="relative z-10">{link.name}</span>
                                        <div className={`absolute bottom-0 left-1/2 -translate-x-1/2 h-0.5 bg-gradient-to-r from-indigo-500 to-purple-500 transition-all duration-300 ${isActive ? "w-3/4" : "w-0 group-hover:w-3/4"}`} />
                                    </a>
                                )
                            })}
                        </div>

                        {/* CTA Button - Desktop */}
                        <div className="hidden lg:flex items-center gap-3">
                            <button className="group relative px-4 lg:px-6 py-2 lg:py-3 bg-gradient-to-r from-indigo-500 to-purple-500 text-white font-semibold rounded-xl overflow-hidden text-sm lg:text-base">
                                <div className="absolute inset-0 bg-gradient-to-r from-purple-500 to-pink-500 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                                <span className="relative flex items-center gap-2">
                                    Get Started
                                    <svg className="w-4 h-4 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 8l4 4m0 0l-4 4m4-4H3" />
                                    </svg>
                                </span>
                            </button>
                        </div>

                        {/* Mobile Menu Button */}
                        <button
                            onClick={() => setIsOpen(!isOpen)}
                            className="lg:hidden relative w-10 h-10 bg-gradient-to-r from-indigo-500/10 to-purple-500/10 border border-zinc-700 rounded-xl flex items-center justify-center text-white hover:border-indigo-500 transition-colors duration-300"
                            aria-label="Toggle menu"
                        >
                            <div className="w-5 h-4 flex flex-col justify-between">
                                <span className={`block h-0.5 bg-white rounded-full transition-all duration-300 ${isOpen ? 'rotate-45 translate-y-1.5' : ''}`}></span>
                                <span className={`block h-0.5 bg-white rounded-full transition-all duration-300 ${isOpen ? 'opacity-0' : ''}`}></span>
                                <span className={`block h-0.5 bg-white rounded-full transition-all duration-300 ${isOpen ? '-rotate-45 -translate-y-1.5' : ''}`}></span>
                            </div>
                        </button>
                    </div>
                </div>

                {/* Mobile Menu */}
                <div
                    className={`lg:hidden transition-all duration-300 ease-in-out ${isOpen ? 'max-h-96 opacity-100' : 'max-h-0 opacity-0'}`}
                >
                    <div className="px-4 pt-2 pb-6 space-y-2 bg-black/95 backdrop-blur-xl border-t border-zinc-800/50">
                        {navLinks.map((link, idx) => {
                            const isActive = pathname === link.href;
                            return (
                                <a
                                    key={idx}
                                    href={link.href}
                                    className={`block px-4 py-3 font-medium rounded-xl transition-all duration-300 ${isActive
                                        ? "text-white bg-gradient-to-r from-indigo-500/20 to-purple-500/20 border border-indigo-500/30"
                                        : "text-zinc-300 hover:text-white hover:bg-gradient-to-r hover:from-indigo-500/10 hover:to-purple-500/10"
                                        }`}
                                    style={{
                                        animation: isOpen ? `slideIn 0.3s ease-out ${idx * 0.1}s both` : "none"
                                    }}
                                >
                                    {link.name}
                                </a>
                            );
                        })}

                        {/* Mobile CTA */}
                        <button
                            className="w-full mt-4 px-4 py-3 bg-gradient-to-r from-indigo-500 to-purple-500 text-white font-semibold rounded-xl hover:from-purple-500 hover:to-pink-500 transition-all duration-300 flex items-center justify-center gap-2"
                            style={{
                                animation: isOpen ? `slideIn 0.3s ease-out ${navLinks.length * 0.1}s both` : 'none'
                            }}
                        >
                            Get Started
                            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 8l4 4m0 0l-4 4m4-4H3" />
                            </svg>
                        </button>
                    </div>
                </div>
            </nav>

            {/* Global styles for animation */}
            <style jsx global>{`
                @keyframes slideIn {
                    from {
                        opacity: 0;
                        transform: translateX(-20px);
                    }
                    to {
                        opacity: 1;
                        transform: translateX(0);
                    }
                }
            `}</style>
        </>
    );
};

export default Navbar;