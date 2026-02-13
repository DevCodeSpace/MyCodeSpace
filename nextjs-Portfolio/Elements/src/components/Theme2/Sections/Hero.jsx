import { heroMetrics } from '@/data/heroData'
import React from 'react'

const Hero = () => {
    return (
        <section className="relative min-h-screen bg-linear-to-br from-emerald-50 via-teal-50 to-cyan-50 overflow-hidden">
            {/* Decorative Shapes */}
            <div className="absolute top-0 right-0 w-1/2 h-full bg-linear-to-bl from-emerald-100 to-transparent opacity-50"></div>
            <div className="absolute bottom-0 left-0 w-96 h-96 bg-teal-200 rounded-full filter blur-3xl opacity-30 animate-pulse-gentle"></div>

            <div className="relative max-w-7xl mx-auto px-6 lg:px-8 pt-32 pb-20">
                <div className="grid lg:grid-cols-12 gap-12 items-center">
                    {/* Left Content - 7 columns */}
                    <div className="lg:col-span-7 space-y-8">
                        {/* Small Tag */}
                        <div className="inline-flex items-center gap-3 animate-slide-in-left">
                            <div className="w-12 h-12 bg-linear-to-br from-emerald-500 to-teal-500 rounded-2xl flex items-center justify-center text-white font-bold text-xl shadow-lg">
                                ✦
                            </div>
                            <span className="text-sm font-bold text-gray-700 uppercase tracking-wider">Award-Winning Agency</span>
                        </div>

                        <div className="space-y-6 animate-fade-in-up" style={{ animationDelay: '0.2s' }}>
                            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-bold text-gray-900 leading-tight">
                                We Create
                                <span className="block text-transparent bg-clip-text bg-linear-to-r from-emerald-600 via-teal-600 to-cyan-600">
                                    Exceptional
                                </span>
                                <span className="block">Digital Products</span>
                            </h1>

                            <p className="text-lg sm:text-xl text-gray-600 leading-relaxed max-w-xl">
                                From concept to launch, we craft beautiful and functional digital experiences that help your business stand out.
                            </p>
                        </div>

                        {/* Action Buttons */}
                        <div className="flex flex-wrap gap-4 animate-fade-in-up" style={{ animationDelay: '0.4s' }}>
                            <button className="group px-6 sm:px-8 py-3 sm:py-4 bg-linear-to-r from-emerald-600 to-teal-600 text-white font-semibold rounded-2xl shadow-xl hover:shadow-2xl transition-all duration-300 hover:scale-105">
                                <span className="flex items-center gap-2">
                                    View Our Work
                                    <svg className="w-5 h-5 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 8l4 4m0 0l-4 4m4-4H3" />
                                    </svg>
                                </span>
                            </button>
                            <button className="px-6 sm:px-8 py-3 sm:py-4 bg-white text-gray-900 font-semibold rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300 hover:scale-105 border-2 border-emerald-200">
                                Contact Us
                            </button>
                        </div>

                        {/* Metrics */}
                        <div className="flex flex-wrap gap-12 pt-8 animate-fade-in-up" style={{ animationDelay: '0.6s' }}>
                            {heroMetrics.map((metric, idx) => (
                                <div key={idx} className="group">
                                    <div className="flex items-center gap-2 mb-2">
                                        <span className="text-2xl group-hover:scale-125 transition-transform duration-300">{metric.icon}</span>
                                        <span className="text-2xl sm:text-3xl font-bold text-gray-900">{metric.value}</span>
                                    </div>
                                    <div className="text-sm text-gray-600">{metric.label}</div>
                                </div>
                            ))}
                        </div>
                    </div>

                    {/* Right Visual - 5 columns */}
                    <div className="hidden lg:block lg:col-span-5 relative animate-slide-in-right">
                        <div className="relative">
                            {/* Main Image Placeholder */}
                            <div className="relative w-full aspect-square bg-linear-to-br from-emerald-400 to-teal-500 rounded-[3rem] shadow-2xl transform rotate-3 hover:rotate-0 transition-transform duration-500">
                                <div className="absolute inset-0 bg-white/10 rounded-[3rem] backdrop-blur-sm"></div>
                            </div>

                            {/* Floating Elements */}
                            <div className="absolute -top-8 -left-8 w-24 h-24 sm:w-32 sm:h-32 bg-white rounded-3xl shadow-xl p-3 sm:p-4 animate-float" style={{ animationDelay: '0.2s' }}>
                                <div className="w-8 h-8 sm:w-12 sm:h-12 bg-linear-to-br from-emerald-500 to-teal-500 rounded-2xl mb-2"></div>
                                <div className="h-2 bg-gray-200 rounded-full mb-1"></div>
                                <div className="h-2 bg-gray-200 rounded-full w-3/4"></div>
                            </div>

                            <div className="absolute -bottom-8 -right-8 w-32 h-32 sm:w-40 sm:h-40 bg-white rounded-3xl shadow-xl p-4 sm:p-6 animate-float" style={{ animationDelay: '0.5s' }}>
                                <div className="flex items-center gap-2 mb-2 sm:mb-3">
                                    <div className="w-6 h-6 sm:w-8 sm:h-8 bg-linear-to-br from-cyan-500 to-blue-500 rounded-full"></div>
                                    <div className="flex-1">
                                        <div className="h-2 bg-gray-200 rounded-full mb-1"></div>
                                        <div className="h-1.5 bg-gray-200 rounded-full w-2/3"></div>
                                    </div>
                                </div>
                                <div className="space-y-1.5">
                                    <div className="h-1.5 bg-gray-200 rounded-full"></div>
                                    <div className="h-1.5 bg-gray-200 rounded-full w-5/6"></div>
                                </div>
                            </div>

                            {/* Stats Badge */}
                            <div className="absolute top-1/2 -left-8 sm:-left-12 bg-white rounded-2xl shadow-xl p-3 sm:p-4 animate-float" style={{ animationDelay: '0.8s' }}>
                                <div className="text-center">
                                    <div className="text-xl sm:text-2xl font-bold text-emerald-600">98%</div>
                                    <div className="text-xs text-gray-600">Success</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    )
}

export default Hero