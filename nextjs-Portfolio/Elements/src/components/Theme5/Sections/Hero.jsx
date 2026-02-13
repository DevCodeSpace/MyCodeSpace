import { heroFeaturePills, heroShowcaseGrid } from '@/data/heroData'
import React from 'react'

const Hero = () => {
    return (
        <section className="relative min-h-screen bg-white flex items-center justify-center overflow-hidden">
            {/* Minimal Background Pattern */}
            <div className="absolute inset-0">
                <div className="absolute top-0 left-1/4 w-px h-full bg-gray-100"></div>
                <div className="absolute top-0 left-2/4 w-px h-full bg-gray-100"></div>
                <div className="absolute top-0 left-3/4 w-px h-full bg-gray-100"></div>
            </div>

            {/* Subtle Gradient Orbs */}
            <div className="absolute top-20 right-20 w-64 h-64 bg-linear-to-br from-orange-200 to-pink-200 rounded-full filter blur-3xl opacity-20 animate-float-slow"></div>
            <div className="absolute bottom-20 left-20 w-64 h-64 bg-linear-to-br from-blue-200 to-purple-200 rounded-full filter blur-3xl opacity-20 animate-float-slow" style={{ animationDelay: '2s' }}></div>

            <div className="relative max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-20">
                <div className="text-center space-y-12">
                    {/* Minimal Badge */}
                    <div className="inline-flex mt-5 items-center gap-2 px-6 py-3 border-2 border-gray-900 rounded-full animate-fade-in-down">
                        <span className="w-2 h-2 bg-orange-500 rounded-full animate-pulse"></span>
                        <span className="text-sm font-bold text-gray-900 uppercase tracking-wider">Crafted with Precision</span>
                    </div>

                    {/* Main Heading */}
                    <div className="space-y-3 animate-scale-fade-in" style={{ animationDelay: '0.2s' }}>
                        <h1 className="text-5xl lg:text-7xl font-bold text-gray-900 leading-tight tracking-tight">
                            Design That
                            <span className="block mt-4 text-transparent bg-clip-text bg-linear-to-r from-orange-600 via-pink-600 to-purple-600">
                                Speaks Volumes
                            </span>
                        </h1>

                        <p className="max-w-2xl mx-auto text-xl text-gray-600 leading-relaxed">
                            We believe in the power of simplicity. Clean design, powerful results.
                        </p>
                    </div>

                    {/* CTA Section */}
                    <div className="flex flex-col sm:flex-row items-center justify-center gap-6 animate-fade-in-up" style={{ animationDelay: '0.4s' }}>
                        <button className="group relative px-10 py-5 bg-gray-900 text-white font-semibold rounded-full transition-all duration-300 hover:scale-110 hover:shadow-2xl">
                            <span className="flex items-center gap-3">
                                Get Started
                                <svg className="w-5 h-5 group-hover:translate-x-2 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7l5 5m0 0l-5 5m5-5H6" />
                                </svg>
                            </span>
                        </button>

                        <button className="group flex items-center gap-3 px-8 py-5 text-gray-900 font-semibold transition-all duration-300 hover:gap-4">
                            <div className="w-12 h-12 bg-gray-100 rounded-full flex items-center justify-center group-hover:bg-gray-900 transition-colors duration-300">
                                <svg className="w-5 h-5 text-gray-900 group-hover:text-white transition-colors" fill="currentColor" viewBox="0 0 24 24">
                                    <path d="M8 5v14l11-7z" />
                                </svg>
                            </div>
                            <span>Watch Video</span>
                        </button>
                    </div>

                    {/* Feature Pills */}
                    <div className="flex flex-wrap justify-center gap-4 pt-8 animate-fade-in-up" style={{ animationDelay: '0.6s' }}>
                        {heroFeaturePills.map((feature, idx) => (
                            <div
                                key={idx}
                                className="px-6 py-3 bg-gray-50 text-gray-700 text-sm font-semibold rounded-full border border-gray-200 hover:border-gray-900 hover:bg-gray-100 transition-all duration-300"
                            >
                                {feature}
                            </div>
                        ))}
                    </div>

                    {/* Showcase Grid */}
                    <div className="grid grid-cols-3 gap-6 pt-16 max-w-4xl mx-auto animate-stagger-fade-in" style={{ animationDelay: '0.8s' }}>
                        {heroShowcaseGrid.map((item, idx) => (
                            <div
                                key={idx}
                                className={`${item.size} bg-linear-to-br ${item.color} rounded-3xl shadow-lg hover:shadow-2xl transition-all duration-500 hover:scale-105 animate-fade-in-up`}
                                style={{ animationDelay: `${1 + idx * 0.1}s` }}
                            ></div>
                        ))}
                    </div>

                    {/* Bottom Stats */}
                    <div className="flex justify-center items-center gap-12 pt-12 animate-fade-in" style={{ animationDelay: '1.2s' }}>
                        {[
                            { number: '50K+', label: 'Users' },
                            { number: '4.9', label: 'Rating' },
                            { number: '12+', label: 'Countries' }
                        ].map((stat, idx) => (
                            <div key={idx} className="text-center group cursor-pointer">
                                <div className="text-4xl font-bold text-gray-900 mb-1 group-hover:scale-110 transition-transform duration-300">
                                    {stat.number}
                                </div>
                                <div className="text-sm text-gray-500 uppercase tracking-wider">
                                    {stat.label}
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        </section>
    )
}

export default Hero