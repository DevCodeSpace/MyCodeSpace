import { theme4Faq } from '@/data/faqData'
import React from 'react'

const Faq = ({ hoveredCard, setHoveredCard }) => {
    return (
        <section className="relative min-h-screen bg-linear-to-br from-slate-900 via-indigo-900 to-slate-900 overflow-hidden py-20 px-5 ">
            {/* Animated Background Grid */}
            <div className="absolute inset-0 opacity-5" style={{ backgroundImage: 'linear-gradient(#fff 1px, transparent 1px), linear-gradient(90deg, #fff 1px, transparent 1px)', backgroundSize: '50px 50px' }}></div>

            {/* Dynamic Gradient Orbs */}
            <div className="absolute inset-0">
                <div className="absolute top-1/4 left-1/3 w-96 h-96 bg-indigo-600 rounded-full filter blur-3xl opacity-30 animate-pulse"></div>
                <div className="absolute bottom-1/3 right-1/3 w-96 h-96 bg-purple-600 rounded-full filter blur-3xl opacity-30 animate-pulse" style={{ animationDelay: '1s' }}></div>
            </div>

            <div className="relative max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
                {/* Header */}
                <div className="text-center mb-16">
                    <div className="inline-flex items-center gap-3 px-6 py-3 bg-white/10 backdrop-blur-xl rounded-full border border-white/20 shadow-xl mb-6">
                        <span className="text-sm font-bold text-white uppercase tracking-wider">Got Questions?</span>
                    </div>
                    <h2 className="text-6xl lg:text-6xl font-bold text-white mb-4">
                        Frequently Asked <span className="text-transparent bg-clip-text bg-linear-to-r from-indigo-400 via-purple-400 to-pink-400">Questions</span>
                    </h2>
                    <p className="text-xl text-gray-300 max-w-2xl mx-auto">
                        Find answers to common questions about our services and platform
                    </p>
                </div>

                {/* FAQ Items */}
                <div className="space-y-4">
                    {theme4Faq.map((faq, idx) => (
                        <div
                            key={idx}
                            className="group bg-white/10 backdrop-blur-2xl border border-white/20 rounded-2xl overflow-hidden hover:bg-white/15 transition-all duration-500 hover:scale-[1.02] hover:border-indigo-400/50"
                        >
                            <button
                                onClick={() => setHoveredCard(hoveredCard === idx + 100 ? null : idx + 100)}
                                className="w-full px-6 lg:px-8 py-6 flex items-start justify-between gap-4 text-left"
                            >
                                <div className="flex items-start gap-4 flex-1">
                                    <div className="mt-1 p-2 bg-linear-to-br from-indigo-500 to-purple-500 rounded-lg group-hover:scale-110 transition-transform duration-300">
                                        <svg className="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                        </svg>
                                    </div>
                                    <div className="flex-1">
                                        <h3 className="text-xl font-bold text-white group-hover:text-indigo-300 transition-colors">
                                            {faq.q}
                                        </h3>
                                    </div>
                                </div>
                                <div className={`mt-1 p-2 bg-white/10 rounded-lg transform transition-all duration-300 ${hoveredCard === idx + 100 ? 'rotate-180 bg-linear-to-br from-indigo-500 to-purple-500' : ''}`}>
                                    <svg className="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                                    </svg>
                                </div>
                            </button>

                            <div className={`overflow-hidden transition-all duration-500 ${hoveredCard === idx + 100 ? 'max-h-96 opacity-100' : 'max-h-0 opacity-0'}`}>
                                <div className="px-6 lg:px-8 pb-6 pl-20">
                                    <p className="text-gray-300 text-lg leading-relaxed">
                                        {faq.a}
                                    </p>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>

                {/* CTA */}
                <div className="mt-12 text-center">
                    <p className="text-gray-300 text-lg mb-6">Still have questions?</p>
                    <button className="group relative px-10 py-5 bg-linear-to-r from-indigo-600 to-purple-600 text-white font-bold rounded-2xl overflow-hidden shadow-2xl hover:shadow-indigo-500/50 transition-all duration-300 hover:scale-110">
                        <span className="relative z-10 flex items-center gap-2">
                            Contact Our Team
                            <svg className="w-5 h-5 group-hover:translate-x-2 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7l5 5m0 0l-5 5m5-5H6" />
                            </svg>
                        </span>
                    </button>
                </div>
            </div>
        </section>
    )
}

export default Faq