import { theme3faqs } from '@/data/faqData'
import React from 'react'

const Faq = ({ activeFaq, setActiveFaq }) => {
    return (
        <section className="min-h-screen bg-black relative overflow-hidden py-16 sm:py-24 px-10  sm:px-12">
            <div className="absolute inset-0 opacity-10">
                <div className="absolute inset-0" style={{
                    backgroundImage: `linear-gradient(rgba(168, 85, 247, 0.2) 1px, transparent 1px), linear-gradient(90deg, rgba(168, 85, 247, 0.2) 1px, transparent 1px)`,
                    backgroundSize: '50px 50px'
                }} />
            </div>

            <div className="max-w-4xl mx-auto relative z-10">
                <div className="text-center mb-16 sm:mb-20 space-y-4">
                    <h2 className="text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-bold">
                        <span className="bg-linear-to-r from-white to-gray-400 bg-clip-text text-transparent block mb-2">
                            Got Questions?
                        </span>
                        <span className="bg-linear-to-r from-indigo-500 via-purple-500 to-pink-500 bg-clip-text text-transparent">
                            We've Got Answers
                        </span>
                    </h2>
                </div>

                <div className="space-y-4">
                    {theme3faqs.map((faq, idx) => (
                        <div
                            key={idx}
                            className="group relative"
                        >
                            <div className={`absolute -inset-1 bg-linear-to-r from-indigo-500 to-purple-500 rounded-2xl blur-xl opacity-0 ${activeFaq === idx ? 'opacity-30' : ''} transition-all duration-300`}></div>

                            <div className="relative bg-linear-to-br from-zinc-900 to-black border border-zinc-800 rounded-2xl overflow-hidden">
                                <button
                                    onClick={() => setActiveFaq(activeFaq === idx ? null : idx)}
                                    className="w-full px-6 sm:px-8 py-5 sm:py-6 flex items-center justify-between text-left hover:bg-white/5 transition-colors"
                                >
                                    <span className="text-lg sm:text-xl font-bold text-white pr-4 sm:pr-8">
                                        {faq.question}
                                    </span>
                                    <div className={`shrink-0 w-8 h-8 bg-linear-to-r from-indigo-500 to-purple-500 rounded-lg flex items-center justify-center text-white transform transition-transform duration-300 ${activeFaq === idx ? 'rotate-180' : ''}`}>
                                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                                        </svg>
                                    </div>
                                </button>

                                <div className={`overflow-hidden transition-all duration-300 ${activeFaq === idx ? 'max-h-96' : 'max-h-0'}`}>
                                    <div className="px-6 sm:px-8 pb-5 sm:pb-6 text-zinc-400 leading-relaxed text-sm sm:text-base">
                                        {faq.answer}
                                    </div>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>
            </div>
        </section>
    )
}

export default Faq