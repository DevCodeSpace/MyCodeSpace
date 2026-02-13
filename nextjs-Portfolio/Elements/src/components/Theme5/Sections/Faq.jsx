import { theme5faqs } from '@/data/faqData'
import React from 'react'

const Faq = ({ openFaq, setOpenFaq }) => {
    return (
        <section className="relative min-h-screen bg-white py-20 px-10 overflow-hidden">
            {/* Background Pattern */}
            <div className="absolute inset-0">
                <div className="absolute top-0 left-1/4 w-px h-full bg-gray-100"></div>
                <div className="absolute top-0 left-2/4 w-px h-full bg-gray-100"></div>
                <div className="absolute top-0 left-3/4 w-px h-full bg-gray-100"></div>
            </div>

            {/* Gradient Orbs */}
            <div className="absolute top-40 left-20 w-64 h-64 bg-linear-to-br from-emerald-200 to-teal-200 rounded-full filter blur-3xl opacity-20 animate-float"></div>
            <div className="absolute bottom-40 right-20 w-64 h-64 bg-linear-to-br from-rose-200 to-orange-200 rounded-full filter blur-3xl opacity-20 animate-float" style={{ animationDelay: '3s' }}></div>

            <div className="max-w-4xl mx-auto relative z-10">
                {/* Section Header */}
                <div className="text-center mb-10 animate-fade-in-up">
                    <div className="inline-flex items-center gap-2 px-6 py-3 border-2 border-gray-900 rounded-full mb-6">
                        <span className="w-2 h-2 bg-linear-to-r from-emerald-500 to-teal-500 rounded-full animate-pulse"></span>
                        <span className="text-sm font-bold text-gray-900 uppercase tracking-wider">FAQ</span>
                    </div>

                    <h2 className="text-5xl lg:text-5xl font-bold text-gray-900 mb-6">
                        Got Questions?
                        <span className="block mt-2 text-transparent bg-clip-text bg-linear-to-r from-emerald-600 via-teal-600 to-blue-600">
                            We've Got Answers
                        </span>
                    </h2>

                    <p className="max-w-2xl mx-auto text-xl text-gray-600 leading-relaxed">
                        Everything you need to know about working with us
                    </p>
                </div>

                {/* FAQ Accordion */}
                <div className="space-y-4">
                    {theme5faqs.map((faq, idx) => (
                        <div
                            key={idx}
                            className="group bg-white border-2 border-gray-200 rounded-3xl overflow-hidden hover:border-gray-900 transition-all duration-300 animate-fade-in-up"
                            style={{ animationDelay: `${idx * 0.1}s` }}
                        >
                            <button
                                onClick={() => setOpenFaq(openFaq === idx ? null : idx)}
                                className="w-full px-8 py-6 flex items-center justify-between text-left hover:bg-gray-50 transition-colors duration-300"
                            >
                                <span className="text-xl font-bold text-gray-900 pr-8">
                                    {faq.question}
                                </span>

                                <div className={`shrink-0 w-10 h-10 rounded-full bg-linear-to-br from-emerald-400 to-teal-500 flex items-center justify-center text-white transition-transform duration-500 ${openFaq === idx ? 'rotate-180' : ''}`}>
                                    <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                                    </svg>
                                </div>
                            </button>

                            <div
                                className={`overflow-hidden transition-all duration-500 ${openFaq === idx ? 'max-h-96 opacity-100' : 'max-h-0 opacity-0'}`}
                            >
                                <div className="px-8 pb-6 text-gray-600 leading-relaxed border-t-2 border-gray-100 pt-6">
                                    {faq.answer}
                                </div>
                            </div>
                        </div>
                    ))}
                </div>

                {/* Bottom CTA */}
                <div className="mt-16 text-center bg-linear-to-br from-gray-50 to-gray-100 rounded-3xl p-12 animate-fade-in-up" style={{ animationDelay: '0.8s' }}>
                    <h3 className="text-3xl font-bold text-gray-900 mb-4">
                        Still have questions?
                    </h3>
                    <p className="text-gray-600 mb-8 text-lg">
                        We're here to help! Reach out to our team and we'll get back to you within 24 hours.
                    </p>
                    <button className="group px-10 py-5 bg-gray-900 text-white font-bold rounded-full hover:shadow-2xl hover:scale-110 transition-all duration-300">
                        <span className="flex items-center gap-3">
                            Contact Us
                            <svg className="w-5 h-5 group-hover:translate-x-2 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                            </svg>
                        </span>
                    </button>
                </div>
            </div>
        </section>
    )
}

export default Faq