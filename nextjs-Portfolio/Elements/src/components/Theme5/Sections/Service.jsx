import { theme5Service } from '@/data/serviceData'
import React from 'react'

const Service = () => {
    return (
        <section className="relative min-h-screen bg-gradient-to-b from-white to-gray-50 py-20 px-6 md:px-8 lg:px-4 overflow-hidden">
            {/* Background Elements */}
            <div className="absolute top-20 right-10 w-72 h-72 bg-gradient-to-br from-orange-200 to-pink-200 rounded-full filter blur-3xl opacity-20 animate-float"></div>
            <div className="absolute bottom-20 left-10 w-72 h-72 bg-gradient-to-br from-purple-200 to-blue-200 rounded-full filter blur-3xl opacity-20 animate-float" style={{ animationDelay: '2s' }}></div>

            <div className="max-w-7xl mx-auto relative z-10">
                {/* Section Header */}
                <div className="text-center mb-10 animate-fade-in-up">
                    <div className="inline-flex items-center gap-2 px-6 py-3 border-2 border-gray-900 rounded-full mb-6">
                        <span className="w-2 h-2 bg-gradient-to-r from-orange-500 to-pink-500 rounded-full animate-pulse"></span>
                        <span className="text-sm font-bold text-gray-900 uppercase tracking-wider">Our Services</span>
                    </div>

                    <h2 className="text-4xl lg:text-5xl font-bold text-gray-900 mb-6">
                        What We Do
                        <span className="block mt-2 text-transparent bg-clip-text bg-gradient-to-r from-orange-600 via-pink-600 to-purple-600">
                            Best In Class
                        </span>
                    </h2>

                    <p className="max-w-2xl mx-auto text-xl text-gray-600 leading-relaxed">
                        Transform your ideas into reality with our comprehensive suite of digital services
                    </p>
                </div>

                {/* Services Grid */}
                <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
                    {theme5Service.map((service, idx) => (
                        <div
                            key={idx}
                            className="group relative bg-white rounded-3xl p-8 shadow-lg hover:shadow-2xl transition-all duration-500 hover:-translate-y-2 animate-fade-in-up"
                            style={{ animationDelay: `${idx * 0.1}s` }}
                        >
                            {/* Icon */}
                            <div className={`w-16 h-16 bg-gradient-to-br ${service.color} rounded-2xl flex items-center justify-center text-white mb-6 group-hover:scale-110 group-hover:rotate-6 transition-all duration-500`}>
                                {service.icon}
                            </div>

                            {/* Content */}
                            <h3 className="text-2xl font-bold text-gray-900 mb-4 group-hover:text-transparent group-hover:bg-clip-text group-hover:bg-gradient-to-r group-hover:from-orange-600 group-hover:to-pink-600 transition-all duration-300">
                                {service.title}
                            </h3>

                            <p className="text-gray-600 leading-relaxed mb-6">
                                {service.description}
                            </p>

                            {/* Hover Arrow */}
                            <div className="flex items-center text-gray-900 font-semibold group-hover:gap-3 gap-2 transition-all duration-300">
                                <span>Learn More</span>
                                <svg className="w-5 h-5 group-hover:translate-x-2 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 8l4 4m0 0l-4 4m4-4H3" />
                                </svg>
                            </div>

                            {/* Decorative Corner */}
                            <div className={`absolute top-0 right-0 w-20 h-20 bg-gradient-to-br ${service.color} opacity-0 group-hover:opacity-10 rounded-bl-full transition-all duration-500`}></div>
                        </div>
                    ))}
                </div>

                {/* CTA */}
                <div className="text-center mt-16 animate-fade-in-up" style={{ animationDelay: '0.8s' }}>
                    <button className="group px-10 py-5 bg-gradient-to-r from-orange-500 via-pink-500 to-purple-500 text-white font-bold rounded-full hover:shadow-2xl hover:scale-110 transition-all duration-300">
                        <span className="flex items-center gap-3">
                            View All Services
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

export default Service