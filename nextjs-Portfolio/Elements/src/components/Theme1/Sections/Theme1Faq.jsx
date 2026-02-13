import { section5faqs } from '@/data/faqData'
import React from 'react'

const Theme1Faq = ({ openIndex, toggleFaq }) => {
    return (
        <section className="min-h-screen bg-linear-to-br from-indigo-50 via-purple-50 to-pink-50 py-20 px-4">
            <div className="max-w-4xl mx-auto">
                <div className="text-center mb-20">
                    <h2 className="text-5xl font-bold text-gray-900 mb-6">
                        Frequently Asked Questions
                    </h2>
                    <div className="w-24 h-1 bg-linear-to-r from-indigo-600 to-purple-600 mx-auto rounded-full"></div>
                </div>

                <div className="relative">
                    {/* Timeline Line */}
                    <div className="absolute left-8 top-0 bottom-0 w-0.5 bg-linear-to-b from-indigo-200 via-purple-200 to-pink-200"></div>

                    <div className="space-y-8">
                        {section5faqs.map((faq, index) => (
                            <div key={index} className="relative pl-20">
                                {/* Timeline Dot */}
                                <div className={`absolute left-0 w-16 h-16 rounded-full flex items-center justify-center font-bold text-lg transition-all duration-300 ${openIndex === index
                                    ? 'bg-linear-to-br from-indigo-600 to-purple-600 text-white shadow-lg scale-110'
                                    : 'bg-gray-100 text-gray-400 hover:bg-gray-200'
                                    }`}>
                                    {faq.number}
                                </div>

                                {/* FAQ Card */}
                                <div className={`transition-all duration-500 ${openIndex === index ? 'transform translate-x-2' : ''
                                    }`}>
                                    <button
                                        onClick={() => toggleFaq(index)}
                                        className="w-full text-left group"
                                    >
                                        <div className={`rounded-2xl p-6 transition-all duration-300 ${openIndex === index
                                            ? 'bg-linear-to-br from-indigo-50 to-purple-50 shadow-xl'
                                            : 'bg-gray-50 hover:bg-gray-100 shadow-sm hover:shadow-md'
                                            }`}>
                                            <div className="flex items-start justify-between gap-4">
                                                <h3 className={`text-xl font-bold transition-colors duration-300 ${openIndex === index ? 'text-indigo-900' : 'text-gray-900 group-hover:text-indigo-600'
                                                    }`}>
                                                    {faq.question}
                                                </h3>
                                                <div className={`shrink-0 w-10 h-10 rounded-full flex items-center justify-center transition-all duration-300 ${openIndex === index
                                                    ? 'bg-indigo-600 rotate-180'
                                                    : 'bg-white shadow-sm group-hover:shadow'
                                                    }`}>
                                                    <svg
                                                        className={`w-5 h-5 transition-colors duration-300 ${openIndex === index ? 'text-white' : 'text-gray-400 group-hover:text-indigo-600'
                                                            }`}
                                                        fill="none"
                                                        stroke="currentColor"
                                                        viewBox="0 0 24 24"
                                                    >
                                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                                                    </svg>
                                                </div>
                                            </div>

                                            <div
                                                className={`overflow-hidden transition-all duration-500 ${openIndex === index ? 'max-h-96 mt-4 opacity-100' : 'max-h-0 opacity-0'
                                                    }`}
                                            >
                                                <div className="pt-4 border-t border-indigo-100">
                                                    <p className="text-gray-700 leading-relaxed">
                                                        {faq.answer}
                                                    </p>
                                                </div>
                                            </div>
                                        </div>
                                    </button>
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        </section>
    )
}

export default Theme1Faq