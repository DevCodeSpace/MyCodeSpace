import { section3FaqCategories, section3faqData } from '@/data/faqData';
import React from 'react'

const Faq = ({ toggleFaq, selectedCategory, setSelectedCategory, openIndex, setOpenIndex }) => {
    return (
        <section className="min-h-screen bg-linear-to-br from-emerald-50 via-teal-50 to-cyan-50 py-14 px-10 lg:px-4">
            <div className="max-w-7xl mx-auto">
                <div className="text-center mb-16">
                    <h2 className="text-5xl font-bold text-gray-900 mb-4">
                        Frequently Asked Questions
                    </h2>
                    <p className="text-lg text-gray-600">
                        Browse by category to find answers quickly
                    </p>
                </div>

                <div className="flex flex-col lg:flex-row gap-8">
                    {/* Sidebar */}
                    <div className="lg:w-64 shrink-0">
                        <div className="bg-white rounded-2xl shadow-lg p-4 sticky top-20">
                            <h3 className="text-sm font-semibold text-gray-500 uppercase tracking-wider mb-4 px-2">
                                Categories
                            </h3>
                            <div className="space-y-2">
                                {section3FaqCategories.map(cat => (
                                    <button
                                        key={cat.id}
                                        onClick={() => {
                                            setSelectedCategory(cat.id);
                                            setOpenIndex(null);
                                        }}
                                        className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-300 ${selectedCategory === cat.id
                                            ? 'bg-linear-to-r from-emerald-500 to-teal-500 text-white shadow-md'
                                            : 'text-gray-700 hover:bg-gray-100'
                                            }`}
                                    >
                                        <span className="text-2xl">{cat.icon}</span>
                                        <span className="font-semibold">{cat.name}</span>
                                    </button>
                                ))}
                            </div>
                        </div>
                    </div>

                    {/* FAQ Content */}
                    <div className="flex-1">
                        <div className="space-y-4">
                            {section3faqData[selectedCategory].map((faq, index) => (
                                <div
                                    key={index}
                                    className="bg-white rounded-2xl shadow-md overflow-hidden hover:shadow-xl transition-all duration-300"
                                >
                                    <button
                                        onClick={() => toggleFaq(index)}
                                        className="w-full px-6 py-5 text-left flex items-center justify-between gap-4"
                                    >
                                        <span className="text-lg font-semibold text-gray-900">
                                            {faq.question}
                                        </span>
                                        <div className={`w-8 h-8 rounded-full flex items-center justify-center shrink-0 transition-all duration-300 ${openIndex === index ? 'bg-emerald-500 rotate-180' : 'bg-gray-200'
                                            }`}>
                                            <svg
                                                className={`w-5 h-5 ${openIndex === index ? 'text-white' : 'text-gray-600'}`}
                                                fill="none"
                                                stroke="currentColor"
                                                viewBox="0 0 24 24"
                                            >
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                                            </svg>
                                        </div>
                                    </button>
                                    <div
                                        className={`overflow-hidden transition-all duration-300 ${openIndex === index ? 'max-h-96 opacity-100' : 'max-h-0 opacity-0'
                                            }`}
                                    >
                                        <div className="px-6 pb-5 text-gray-600 leading-relaxed border-t border-gray-100 pt-4">
                                            {faq.answer}
                                        </div>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </div>
                </div>
            </div>
        </section>
    )
}

export default Faq