import { theme1Stats } from '@/data/heroData'
import React from 'react'

const Theme1Hero = () => {
    return (
        <section className="relative min-h-screen bg-linear-to-br from-indigo-50 via-purple-50 to-pink-50 overflow-hidden">
            {/* Animated Background Elements */}
            <div className="absolute inset-0">
                <div className="absolute top-20 left-10 w-72 h-72 bg-purple-300 rounded-full mix-blend-multiply filter blur-xl opacity-30 animate-blob"></div>
                <div className="absolute top-40 right-10 w-72 h-72 bg-pink-300 rounded-full mix-blend-multiply filter blur-xl opacity-30 animate-blob animation-delay-2000"></div>
                <div className="absolute -bottom-8 left-20 w-72 h-72 bg-indigo-300 rounded-full mix-blend-multiply filter blur-xl opacity-30 animate-blob animation-delay-4000"></div>
            </div>

            <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-32 pb-20">
                <div className="grid lg:grid-cols-2 gap-12 items-center">
                    {/* Left Content */}
                    <div className="space-y-8 animate-slide-in-left">
                        <div className="inline-flex items-center gap-2 px-4 py-2 bg-white/80 backdrop-blur-sm rounded-full shadow-lg animate-fade-in">
                            <span className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></span>
                            <span className="text-sm font-semibold text-gray-700">Welcome to Innovation</span>
                        </div>

                        <h1 className="text-5xl lg:text-6xl font-bold text-gray-900 leading-tight animate-fade-in-up" style={{ animationDelay: '0.2s' }}>
                            Build Amazing
                            <span className="block text-transparent bg-clip-text bg-linear-to-r from-indigo-600 via-purple-600 to-pink-600 animate-gradient-text">
                                Digital Experiences
                            </span>
                        </h1>

                        <p className="text-xl text-gray-600 leading-relaxed animate-fade-in-up" style={{ animationDelay: '0.4s' }}>
                            Transform your ideas into reality with our cutting-edge solutions. We help businesses grow and succeed in the digital world.
                        </p>

                        <div className="flex flex-wrap gap-4 animate-fade-in-up" style={{ animationDelay: '0.6s' }}>
                            <button className="group px-8 py-4 bg-linear-to-r from-indigo-600 to-purple-600 text-white font-semibold rounded-xl shadow-lg hover:shadow-2xl transition-all duration-300 hover:scale-105">
                                <span className="flex items-center gap-2">
                                    Get Started
                                    <svg className="w-5 h-5 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7l5 5m0 0l-5 5m5-5H6" />
                                    </svg>
                                </span>
                            </button>
                            <button className="px-8 py-4 bg-white text-gray-900 font-semibold rounded-xl shadow-lg hover:shadow-2xl transition-all duration-300 hover:scale-105 border-2 border-gray-200 hover:border-indigo-300">
                                Watch Demo
                            </button>
                        </div>

                        {/* Stats */}
                        <div className="flex flex-wrap gap-8 pt-8 animate-fade-in-up" style={{ animationDelay: '0.8s' }}>
                            {theme1Stats.map((stat, idx) => (
                                <div key={idx} className="text-center">
                                    <div className="text-3xl font-bold text-gray-900">{stat.value}</div>
                                    <div className="text-sm text-gray-600">{stat.label}</div>
                                </div>
                            ))}
                        </div>
                    </div>

                    {/* Right Visual */}
                    <div className="relative animate-slide-in-right">
                        <div className="relative w-full aspect-square">
                            {/* Floating Cards */}
                            <div className="absolute top-0 right-0 w-48 h-48 bg-white rounded-3xl shadow-2xl p-6 animate-float" style={{ animationDelay: '0.2s' }}>
                                <div className="w-12 h-12 bg-linear-to-br from-indigo-500 to-purple-500 rounded-xl mb-4"></div>
                                <div className="h-3 bg-gray-200 rounded-full mb-2"></div>
                                <div className="h-3 bg-gray-200 rounded-full w-3/4"></div>
                            </div>

                            <div className="absolute bottom-20 left-0 w-56 h-56 bg-white rounded-3xl shadow-2xl p-6 animate-float" style={{ animationDelay: '0.5s' }}>
                                <div className="flex items-center gap-3 mb-4">
                                    <div className="w-10 h-10 bg-linear-to-br from-pink-500 to-orange-500 rounded-full"></div>
                                    <div className="flex-1">
                                        <div className="h-2 bg-gray-200 rounded-full mb-2"></div>
                                        <div className="h-2 bg-gray-200 rounded-full w-2/3"></div>
                                    </div>
                                </div>
                                <div className="space-y-2">
                                    <div className="h-2 bg-gray-200 rounded-full"></div>
                                    <div className="h-2 bg-gray-200 rounded-full"></div>
                                    <div className="h-2 bg-gray-200 rounded-full w-5/6"></div>
                                </div>
                            </div>

                            <div className="absolute top-1/2 right-10 w-40 h-40 bg-linear-to-br from-purple-600 to-pink-600 rounded-3xl shadow-2xl animate-float" style={{ animationDelay: '0.8s' }}></div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    )
}

export default Theme1Hero