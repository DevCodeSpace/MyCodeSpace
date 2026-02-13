import { theme2services } from '@/data/serviceData'
import React from 'react'

const Service = () => {
    return (
        <section className="relative py-20 lg:py-20 bg-white overflow-hidden">
            {/* Decorative Background Elements */}
            <div className="absolute top-0 left-0 w-96 h-96 bg-emerald-100 rounded-full filter blur-3xl opacity-20"></div>
            <div className="absolute bottom-0 right-0 w-96 h-96 bg-teal-100 rounded-full filter blur-3xl opacity-20"></div>

            <div className="relative max-w-7xl mx-auto px-10 sm:px-14 lg:px-8">
                {/* Section Header */}
                <div className="text-center mb-16 lg:mb-20">
                    <div className="inline-flex items-center gap-2 mb-6 animate-fade-in-up">
                        <div className="w-10 h-10 bg-linear-to-br from-emerald-500 to-teal-500 rounded-xl flex items-center justify-center text-white font-bold shadow-lg">
                            ✦
                        </div>
                        <span className="text-sm font-bold text-gray-700 uppercase tracking-wider">Our Services</span>
                    </div>

                    <h2 className="text-4xl md:text-5xl lg:text-6xl font-bold text-gray-900 mb-6 animate-fade-in-up" style={{ animationDelay: '0.1s' }}>
                        What We
                        <span className="block text-transparent bg-clip-text bg-linear-to-r from-emerald-600 via-teal-600 to-cyan-600">
                            Can Do For You
                        </span>
                    </h2>

                    <p className="text-lg md:text-xl text-gray-600 max-w-3xl mx-auto animate-fade-in-up" style={{ animationDelay: '0.2s' }}>
                        We offer a comprehensive range of digital services to help your business grow and succeed in the modern digital landscape.
                    </p>
                </div>

                {/* Services Grid */}
                <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6 lg:gap-8">
                    {theme2services.map((service, idx) => (
                        <div
                            key={idx}
                            className="group relative bg-white rounded-3xl p-8 shadow-lg hover:shadow-2xl transition-all duration-500 border-2 border-gray-100 hover:border-transparent animate-fade-in-up"
                            style={{ animationDelay: `${0.1 * idx}s` }}
                        >
                            {/* Gradient Border Effect on Hover */}
                            <div className={`absolute inset-0 bg-linear-to-br ${service.gradient} rounded-3xl opacity-0 group-hover:opacity-100 transition-opacity duration-500 -z-10`}></div>
                            <div className="absolute inset-0.5 bg-white rounded-3xl -z-10"></div>

                            {/* Icon */}
                            <div className={`w-16 h-16 bg-linear-to-br ${service.gradient} rounded-2xl flex items-center justify-center text-3xl mb-6 shadow-lg group-hover:scale-110 group-hover:rotate-3 transition-all duration-500`}>
                                {service.icon}
                            </div>

                            {/* Content */}
                            <h3 className="text-2xl font-bold text-gray-900 mb-4 group-hover:text-emerald-600 transition-colors duration-300">
                                {service.title}
                            </h3>

                            <p className="text-gray-600 mb-6 leading-relaxed">
                                {service.description}
                            </p>

                            {/* Features */}
                            <div className="flex flex-wrap gap-2 mb-6">
                                {service.features.map((feature, featureIdx) => (
                                    <span
                                        key={featureIdx}
                                        className="px-3 py-1 bg-gray-100 text-gray-700 text-sm rounded-full group-hover:bg-emerald-50 group-hover:text-emerald-700 transition-colors duration-300"
                                    >
                                        {feature}
                                    </span>
                                ))}
                            </div>

                            {/* Learn More Link */}
                            <button className="flex items-center gap-2 text-emerald-600 font-semibold group-hover:gap-4 transition-all duration-300">
                                Learn More
                                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 8l4 4m0 0l-4 4m4-4H3" />
                                </svg>
                            </button>

                            {/* Decorative Element */}
                            <div className={`absolute -top-2 -right-2 w-20 h-20 bg-linear-to-br ${service.gradient} rounded-full opacity-0 group-hover:opacity-10 blur-2xl transition-opacity duration-500`}></div>
                        </div>
                    ))}
                </div>

                {/* CTA Section */}
                <div className="mt-16 lg:mt-24 text-center animate-fade-in-up" style={{ animationDelay: '0.8s' }}>
                    <div className="relative inline-block">
                        <div className="absolute inset-0 bg-linear-to-r from-emerald-500 to-cyan-500 rounded-3xl blur-xl opacity-30"></div>
                        <div className="relative bg-linear-to-r from-emerald-600 to-teal-600 rounded-3xl p-8 lg:p-12 shadow-2xl">
                            <h3 className="text-2xl lg:text-3xl font-bold text-white mb-4">
                                Ready to Start Your Project?
                            </h3>
                            <p className="text-emerald-50 mb-6 lg:mb-8 max-w-2xl mx-auto">
                                Let's discuss how we can help bring your vision to life with our expert services.
                            </p>
                            <div className="flex flex-col sm:flex-row gap-4 justify-center">
                                <button className="group px-8 py-4 bg-white text-emerald-600 font-semibold rounded-2xl shadow-xl hover:shadow-2xl transition-all duration-300 hover:scale-105">
                                    <span className="flex items-center justify-center gap-2">
                                        Get Started
                                        <svg className="w-5 h-5 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 8l4 4m0 0l-4 4m4-4H3" />
                                        </svg>
                                    </span>
                                </button>
                                <button className="px-8 py-4 bg-transparent text-white font-semibold rounded-2xl border-2 border-white hover:bg-white hover:text-emerald-600 transition-all duration-300 hover:scale-105">
                                    View Pricing
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <style jsx>{`
               @keyframes fade-in-up {
                 from {
                   opacity: 0;
                   transform: translateY(20px);
                 }
                 to {
                   opacity: 1;
                   transform: translateY(0);
                 }
               }
       
               .animate-fade-in-up {
                 animation: fade-in-up 0.8s ease-out forwards;
                 opacity: 0;
               }
             `}</style>
        </section>
    )
}

export default Service