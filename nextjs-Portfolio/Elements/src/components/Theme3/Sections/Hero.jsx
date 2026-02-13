import { theme3HeroStats } from '@/data/heroData'
import React from 'react'

const Hero = ({ mousePos, handleMouseMove }) => {
    return (
        <section
            className="min-h-screen bg-black relative overflow-hidden flex items-center px-10 md:px-10 lg:px-6 pt-20"
            onMouseMove={handleMouseMove}
        >
            {/* Animated Background */}
            <div
                className="absolute inset-0 opacity-40 transition-all duration-300"
                style={{
                    background: `radial-gradient(800px circle at ${mousePos.x}px ${mousePos.y}px, rgba(99, 102, 241, 0.2), transparent 50%)`
                }}
            />

            {/* Grid Pattern */}
            <div className="absolute inset-0 opacity-10">
                <div className="absolute inset-0" style={{
                    backgroundImage: `linear-gradient(rgba(99, 102, 241, 0.3) 1px, transparent 1px), linear-gradient(90deg, rgba(99, 102, 241, 0.3) 1px, transparent 1px)`,
                    backgroundSize: '50px 50px'
                }} />
            </div>

            {/* Gradient Orbs */}
            <div className="absolute top-20 left-20 w-96 h-96 bg-indigo-500 rounded-full filter blur-3xl opacity-20 animate-pulse"></div>
            <div className="absolute bottom-20 right-20 w-96 h-96 bg-purple-500 rounded-full filter blur-3xl opacity-20 animate-pulse" style={{ animationDelay: '1s' }}></div>

            <div className="max-w-7xl mx-auto relative z-10 w-full">
                <div className="grid lg:grid-cols-2 gap-12 items-center">
                    {/* Left Content */}
                    <div className="space-y-8">
                        {/* Badge */}
                        <div className="inline-flex items-center gap-3 bg-linear-to-r from-indigo-500/20 to-purple-500/20 border border-indigo-500/30 rounded-full px-6 py-3 backdrop-blur-sm">
                            <div className="w-2 h-2 bg-indigo-500 rounded-full animate-pulse"></div>
                            <span className="text-indigo-300 text-sm font-semibold tracking-wide">DIGITAL INNOVATION</span>
                        </div>

                        {/* Main Heading */}
                        <div className="space-y-6">
                            <h1 className="text-5xl sm:text-6xl md:text-7xl lg:text-8xl font-bold leading-none">
                                <span className="bg-linear-to-r from-white to-gray-400 bg-clip-text text-transparent block">
                                    We Build
                                </span>
                                <span className="bg-linear-to-r from-indigo-500 via-purple-500 to-pink-500 bg-clip-text text-transparent block">
                                    Digital Dreams
                                </span>
                            </h1>

                            <p className="text-lg md:text-xl lg:text-2xl text-zinc-400 leading-relaxed max-w-xl">
                                Transform your vision into reality with cutting-edge digital solutions that drive growth and innovation.
                            </p>
                        </div>

                        {/* CTA Buttons */}
                        <div className="flex flex-wrap gap-4">
                            <button className="group relative px-6 sm:px-8 py-3 sm:py-4 bg-linear-to-r from-indigo-500 to-purple-500 text-white font-semibold rounded-2xl overflow-hidden">
                                <div className="absolute inset-0 bg-linear-to-r from-purple-500 to-pink-500 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                                <span className="relative flex items-center gap-2 text-sm sm:text-base">
                                    Start Your Project
                                    <svg className="w-4 h-4 sm:w-5 sm:h-5 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 8l4 4m0 0l-4 4m4-4H3" />
                                    </svg>
                                </span>
                            </button>
                            <button className="px-6 sm:px-8 py-3 sm:py-4 bg-white/5 backdrop-blur-sm text-white font-semibold rounded-2xl border border-zinc-700 hover:border-indigo-500 hover:bg-white/10 transition-all duration-300 text-sm sm:text-base">
                                View Our Work
                            </button>
                        </div>

                        {/* Stats */}
                        <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 sm:gap-6 pt-8">
                            {theme3HeroStats.map((stat, idx) => (
                                <div key={idx} className="space-y-2">
                                    <div className={`text-2xl sm:text-3xl md:text-4xl font-bold bg-linear-to-r ${stat.gradient} bg-clip-text text-transparent`}>
                                        {stat.value}
                                    </div>
                                    <div className="text-xs sm:text-sm text-zinc-500 font-medium">
                                        {stat.label}
                                    </div>
                                </div>
                            ))}
                        </div>
                    </div>

                    {/* Right Visual */}
                    <div className="relative h-96 lg:h-150 flex items-center justify-center">
                        {/* Central Card */}
                        <div className="relative w-full max-w-md">
                            {/* Main Card */}
                            <div className="relative bg-linear-to-br from-zinc-900 to-black border border-zinc-800 rounded-3xl p-6 sm:p-8 shadow-2xl transform hover:scale-105 transition-transform duration-500">
                                <div className="absolute inset-0 bg-linear-to-r from-indigo-500/10 to-purple-500/10 rounded-3xl"></div>
                                <div className="relative space-y-6">
                                    <div className="w-12 h-12 sm:w-16 sm:h-16 bg-linear-to-r from-indigo-500 to-purple-500 rounded-2xl flex items-center justify-center text-2xl sm:text-3xl">
                                        ⚡
                                    </div>
                                    <div className="space-y-3">
                                        <div className="h-3 sm:h-4 bg-zinc-800 rounded-full w-3/4"></div>
                                        <div className="h-3 sm:h-4 bg-zinc-800 rounded-full w-1/2"></div>
                                    </div>
                                    <div className="grid grid-cols-3 gap-2 sm:gap-3">
                                        <div className="h-16 sm:h-20 bg-linear-to-br from-indigo-500/20 to-purple-500/20 rounded-xl"></div>
                                        <div className="h-16 sm:h-20 bg-linear-to-br from-purple-500/20 to-pink-500/20 rounded-xl"></div>
                                        <div className="h-16 sm:h-20 bg-linear-to-br from-pink-500/20 to-rose-500/20 rounded-xl"></div>
                                    </div>
                                </div>
                            </div>

                            {/* Floating Elements */}
                            <div className="absolute -top-6 sm:-top-8 -left-6 sm:-left-8 w-24 h-24 sm:w-32 sm:h-32 bg-linear-to-br from-indigo-500 to-purple-500 rounded-3xl p-3 sm:p-4 shadow-2xl animate-float">
                                <div className="w-full h-full bg-white/10 rounded-2xl backdrop-blur-sm"></div>
                            </div>

                            <div className="absolute -bottom-6 sm:-bottom-8 -right-6 sm:-right-8 w-32 h-32 sm:w-40 sm:h-40 bg-linear-to-br from-purple-500 to-pink-500 rounded-3xl p-4 sm:p-6 shadow-2xl animate-float" style={{ animationDelay: '1s' }}>
                                <div className="space-y-2">
                                    <div className="w-8 h-8 sm:w-12 sm:h-12 bg-white/20 rounded-xl"></div>
                                    <div className="h-1.5 sm:h-2 bg-white/20 rounded-full"></div>
                                    <div className="h-1.5 sm:h-2 bg-white/20 rounded-full w-3/4"></div>
                                </div>
                            </div>

                            <div className="absolute top-1/2 -right-8 sm:-right-12 bg-linear-to-br from-cyan-500 to-indigo-500 rounded-2xl p-3 sm:p-4 shadow-2xl animate-float" style={{ animationDelay: '0.5s' }}>
                                <div className="text-xl sm:text-2xl font-bold text-white">98%</div>
                                <div className="text-xs text-white/80">Success</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    )
}

export default Hero