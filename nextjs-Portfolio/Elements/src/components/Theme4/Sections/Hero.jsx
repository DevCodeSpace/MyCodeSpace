import { heroBottomStatsBar, theme4features } from '@/data/heroData'
import React from 'react'

const Hero = ({ hoveredCard, setHoveredCard }) => {
    return (
        <section className="relative min-h-screen bg-linear-to-br from-slate-900 via-purple-900 to-slate-900 overflow-hidden">
            {/* Animated Background Grid */}
            <div className="absolute inset-0 bg-grid-white opacity-5"></div>

            {/* Dynamic Gradient Orbs */}
            <div className="absolute inset-0">
                <div className="absolute top-0 left-1/4 w-96 h-96 bg-purple-600 rounded-full filter blur-3xl opacity-30 animate-blob"></div>
                <div className="absolute top-1/3 right-1/4 w-96 h-96 bg-pink-600 rounded-full filter blur-3xl opacity-30 animate-blob animation-delay-2000"></div>
                <div className="absolute bottom-0 left-1/2 w-96 h-96 bg-blue-600 rounded-full filter blur-3xl opacity-30 animate-blob animation-delay-4000"></div>
            </div>

            <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-32 pb-20">
                <div className="text-center space-y-12">
                    {/* Animated Badge */}
                    <div className="inline-flex items-center gap-3 px-6 py-3 bg-white/10 backdrop-blur-xl rounded-full border border-white/20 shadow-xl animate-bounce-in">
                        <div className="relative">
                            <div className="w-3 h-3 bg-emerald-400 rounded-full animate-ping absolute"></div>
                            <div className="w-3 h-3 bg-emerald-500 rounded-full relative"></div>
                        </div>
                        <span className="text-sm font-bold text-white uppercase tracking-wider">Next-Gen Platform</span>
                    </div>

                    {/* Main Heading with Split Animation */}
                    <div className="space-y-6">
                        <h1 className="text-5xl lg:text-7xl font-bold text-white leading-tight">
                            <span className="block animate-slide-in-left">Innovation</span>
                            <span className="block text-transparent bg-clip-text bg-linear-to-r from-pink-400 via-purple-400 to-blue-400 animate-gradient-slide animate-slide-in-right" style={{ animationDelay: '0.2s' }}>
                                Meets Design
                            </span>
                        </h1>

                        <p className="max-w-3xl mx-auto text-xl text-gray-300 leading-relaxed animate-fade-in-up" style={{ animationDelay: '0.4s' }}>
                            Transform your vision into reality with our comprehensive digital solutions. We combine creativity with technology.
                        </p>
                    </div>

                    {/* Interactive Feature Cards */}
                    <div className="flex flex-wrap justify-center gap-6 pt-8 animate-stagger-in" style={{ animationDelay: '0.6s' }}>
                        {theme4features?.map((feature, idx) => (
                            <div
                                key={idx}
                                onMouseEnter={() => setHoveredCard(idx)}
                                onMouseLeave={() => setHoveredCard(null)}
                                className="group relative w-48 h-48 cursor-pointer animate-fade-scale-in"
                                style={{ animationDelay: `${0.8 + idx * 0.1}s` }}
                            >
                                {/* Glow Effect */}
                                {hoveredCard === idx && (
                                    <div className={`absolute inset-0 bg-linear-to-br ${feature.color} rounded-3xl blur-2xl opacity-60 animate-pulse-glow`}></div>
                                )}

                                {/* Card */}
                                <div className={`relative w-full h-full bg-white/10 backdrop-blur-xl rounded-3xl border border-white/20 p-8 transition-all duration-500 ${hoveredCard === idx ? 'scale-110 bg-white/20' : 'hover:scale-105'
                                    }`}>
                                    <div className="flex flex-col items-center justify-center h-full space-y-4">
                                        <div className={`text-6xl transform transition-all duration-500 ${hoveredCard === idx ? 'scale-125 rotate-12' : ''
                                            }`}>
                                            {feature.icon}
                                        </div>
                                        <h3 className="text-xl font-bold text-white">{feature.title}</h3>
                                    </div>
                                </div>
                            </div>
                        ))}
                    </div>

                    {/* CTA Buttons */}
                    <div className="flex flex-wrap justify-center gap-4 pt-8 animate-fade-in-up" style={{ animationDelay: '1s' }}>
                        <button className="group relative px-10 py-5 bg-linear-to-r from-pink-600 to-purple-600 text-white font-bold rounded-2xl overflow-hidden shadow-2xl hover:shadow-pink-500/50 transition-all duration-300 hover:scale-110">
                            <span className="relative z-10 flex items-center gap-2">
                                Start Building
                                <svg className="w-5 h-5 group-hover:translate-x-2 group-hover:scale-125 transition-all duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7l5 5m0 0l-5 5m5-5H6" />
                                </svg>
                            </span>
                            <div className="absolute inset-0 bg-linear-to-r from-purple-600 to-blue-600 translate-x-full group-hover:translate-x-0 transition-transform duration-500"></div>
                        </button>

                        <button className="group px-10 py-5 bg-white/10 backdrop-blur-xl text-white font-bold rounded-2xl border-2 border-white/20 hover:bg-white/20 hover:border-white/40 transition-all duration-300 hover:scale-110">
                            <span className="flex items-center gap-2">
                                <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                                    <path d="M8 5v14l11-7z" />
                                </svg>
                                Watch Demo
                            </span>
                        </button>
                    </div>

                    {/* Bottom Stats Bar */}
                    <div className="pt-16 animate-fade-in" style={{ animationDelay: '1.2s' }}>
                        <div className="max-w-4xl mx-auto grid grid-cols-2 md:grid-cols-4 gap-8 p-8 bg-white/5 backdrop-blur-xl rounded-3xl border border-white/10">
                            {heroBottomStatsBar.map((stat, idx) => (
                                <div key={idx} className="text-center group cursor-pointer">
                                    <div className="text-3xl mb-2 group-hover:scale-125 transition-transform duration-300">{stat.icon}</div>
                                    <div className="text-3xl font-bold text-white mb-1">{stat.value}</div>
                                    <div className="text-sm text-gray-400">{stat.label}</div>
                                </div>
                            ))}
                        </div>
                    </div>
                </div>
            </div>
        </section>
    )
}

export default Hero