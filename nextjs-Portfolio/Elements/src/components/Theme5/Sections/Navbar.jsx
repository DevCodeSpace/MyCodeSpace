import { usePathname } from 'next/navigation';
import React, { useState, useEffect } from 'react';

const Navbar = () => {
    const pathname = usePathname();
    const [isScrolled, setIsScrolled] = useState(false);
    const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

    useEffect(() => {
        const handleScroll = () => {
            setIsScrolled(window.scrollY > 50);
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
        <nav
            className={`fixed top-0 left-0 right-0 z-50 transition-all duration-500 ${isScrolled
                ? 'bg-white/95 backdrop-blur-lg shadow-xl py-3'
                : 'bg-white py-5'
                }`}
        >
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div className="flex items-center justify-between">
                    {/* Logo */}
                    <div className="flex items-center gap-3 group cursor-pointer">
                        <div className="w-12 h-12 bg-linear-to-br from-orange-500 via-pink-500 to-purple-600 rounded-2xl flex items-center justify-center transform group-hover:rotate-12 transition-all duration-500 shadow-lg group-hover:shadow-xl group-hover:shadow-pink-300">
                            <svg
                                className="w-7 h-7 text-white"
                                fill="none"
                                stroke="currentColor"
                                viewBox="0 0 24 24"
                            >
                                <path
                                    strokeLinecap="round"
                                    strokeLinejoin="round"
                                    strokeWidth={2}
                                    d="M13 10V3L4 14h7v7l9-11h-7z"
                                />
                            </svg>
                        </div>
                        <span className="text-2xl font-bold text-gray-900 group-hover:text-transparent group-hover:bg-clip-text group-hover:bg-linear-to-r group-hover:from-orange-500 group-hover:to-pink-500 transition-all duration-300">
                            DesignCo
                        </span>
                    </div>

                    {/* Desktop Navigation */}
                    <div className="hidden lg:flex items-center gap-8">
                        {navLinks.map((link, idx) => {
                            const isActive = pathname === link.href;

                            return (
                                <a
                                    key={idx}
                                    href={link.href}
                                    className={`group relative font-semibold transition-all duration-300 ${isActive
                                        ? "text-transparent bg-clip-text bg-linear-to-r from-orange-500 to-pink-500"
                                        : "text-gray-700 hover:text-transparent hover:bg-clip-text hover:bg-linear-to-r hover:from-orange-500 hover:to-pink-500"}`}
                                >
                                    {link.name}

                                    {/* Underline (hover + active SAME behavior) */}
                                    <span
                                        className={`absolute -bottom-1 left-0 h-0.5 bg-linear-to-r from-orange-500 to-pink-500 transition-all duration-300 ${isActive ? "w-full" : "w-0 group-hover:w-full"}`}
                                    />
                                </a>
                            );
                        })}
                    </div>


                    {/* CTA Button */}
                    <div className="hidden lg:flex items-center gap-4">
                        <button className="group relative px-8 py-3 bg-linear-to-r from-orange-500 via-pink-500 to-purple-600 text-white font-bold rounded-full overflow-hidden hover:shadow-2xl hover:shadow-pink-400/50 hover:scale-110 transition-all duration-300">
                            <span className="relative z-10 flex items-center gap-2">
                                Get Started
                                <svg
                                    className="w-4 h-4 group-hover:translate-x-1 transition-transform duration-300"
                                    fill="none"
                                    stroke="currentColor"
                                    viewBox="0 0 24 24"
                                >
                                    <path
                                        strokeLinecap="round"
                                        strokeLinejoin="round"
                                        strokeWidth={2}
                                        d="M13 7l5 5m0 0l-5 5m5-5H6"
                                    />
                                </svg>
                            </span>
                            <div className="absolute inset-0 bg-linear-to-r from-purple-600 via-pink-500 to-orange-500 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                        </button>
                    </div>

                    {/* Mobile Menu Button */}
                    <button
                        onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
                        className="lg:hidden w-12 h-12 bg-linear-to-br from-orange-500 to-pink-500 rounded-xl flex items-center justify-center hover:scale-110 transition-all duration-300 shadow-lg"
                    >
                        <div className="w-6 h-5 flex flex-col justify-between">
                            <span
                                className={`w-full h-0.5 bg-white rounded-full transform transition-all duration-300 ${isMobileMenuOpen ? 'rotate-45 translate-y-2' : ''
                                    }`}
                            ></span>
                            <span
                                className={`w-full h-0.5 bg-white rounded-full transition-all duration-300 ${isMobileMenuOpen ? 'opacity-0' : ''
                                    }`}
                            ></span>
                            <span
                                className={`w-full h-0.5 bg-white rounded-full transform transition-all duration-300 ${isMobileMenuOpen ? '-rotate-45 -translate-y-2' : ''
                                    }`}
                            ></span>
                        </div>
                    </button>
                </div>

                {/* Mobile Menu */}
                <div
                    className={`lg:hidden overflow-hidden transition-all duration-500 ${isMobileMenuOpen ? 'max-h-1/4 opacity-100 mt-6' : 'max-h-0 opacity-0'
                        }`}
                >
                    <div className="bg-linear-to-br from-gray-50 to-gray-100 rounded-3xl p-6 space-y-3 border-2 border-gray-200 shadow-xl">
                        {navLinks.map((link, idx) => {
                            const isActive = pathname === link.href;

                            return (
                                <a
                                    key={idx}
                                    href={link.href}
                                    onClick={() => setIsMobileMenuOpen(false)}
                                    className={`block font-semibold py-3 px-4 rounded-2xl transition-all duration-300 transform ${isActive
                                        ? "text-white bg-linear-to-r from-orange-500 to-pink-500 shadow-lg"
                                        : "text-gray-700 hover:bg-linear-to-r hover:from-orange-500 hover:to-pink-500 hover:text-white hover:translate-x-2"}`}
                                >
                                    {link.name}
                                </a>
                            );
                        })}

                        <button className="w-full mt-1 px-8 py-3 bg-linear-to-r from-orange-500 via-pink-500 to-purple-600 text-white font-bold rounded-2xl hover:shadow-2xl hover:shadow-pink-400/50 hover:scale-105 transition-all duration-300">
                            Get Started
                        </button>
                    </div>
                </div>
            </div>
        </nav>
    );
};

export default Navbar;