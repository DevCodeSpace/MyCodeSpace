import { serviceSection4 } from '@/data/serviceData'
import React from 'react'

const Service = ({ setActiveTab, activeTab }) => {
    return (
        <section className="relative min-h-screen bg-linear-to-br from-slate-900 via-blue-900 to-slate-900 overflow-hidden py-20">
            {/* Animated Background Grid */}
            <div className="absolute inset-0 opacity-5" style={{ backgroundImage: 'linear-gradient(#fff 1px, transparent 1px), linear-gradient(90deg, #fff 1px, transparent 1px)', backgroundSize: '50px 50px' }}></div>

            {/* Dynamic Gradient Orbs */}
            <div className="absolute inset-0">
                <div className="absolute top-0 right-1/4 w-96 h-96 bg-blue-600 rounded-full filter blur-3xl opacity-30 animate-pulse"></div>
                <div className="absolute bottom-1/4 left-1/4 w-96 h-96 bg-cyan-600 rounded-full filter blur-3xl opacity-30 animate-pulse" style={{ animationDelay: '1s' }}></div>
            </div>

            <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                {/* Header */}
                <div className="text-center mb-16">
                    <div className="inline-flex items-center gap-3 px-6 py-3 bg-white/10 backdrop-blur-xl rounded-full border border-white/20 shadow-xl mb-6">
                        <span className="text-sm font-bold text-white uppercase tracking-wider">What We Offer</span>
                    </div>
                    <h2 className="text-xl lg:text-6xl font-bold text-white mb-4">
                        Our <span className="text-transparent bg-clip-text bg-linear-to-r from-blue-400 via-cyan-400 to-purple-400">Services</span>
                    </h2>
                    <p className="text-xl text-gray-300 max-w-2xl mx-auto">
                        Comprehensive solutions tailored to transform your digital presence
                    </p>
                </div>

                {/* Tabs */}
                <div className="flex flex-wrap justify-center gap-4 mb-12">
                    {serviceSection4.map((service, idx) => (
                        <button
                            key={idx}
                            onClick={() => setActiveTab(idx)}
                            className={`group relative px-8 py-4 rounded-2xl font-bold text-lg transition-all duration-500 ${activeTab === idx
                                ? 'bg-linear-to-r from-blue-600 to-purple-600 text-white shadow-2xl shadow-blue-500/50 scale-105'
                                : 'bg-white/10 text-white hover:bg-white/20 backdrop-blur-xl border border-white/20'
                                }`}
                        >
                            <div className="flex items-center gap-3">
                                {React.cloneElement(service.icon, {
                                    className: `w-6 h-6 transition-transform duration-500 ${activeTab === idx ? 'scale-110' : ''}`
                                })}
                                {service.title}
                            </div>
                            {activeTab === idx && (
                                <div className="absolute -bottom-3 left-1/2 -translate-x-1/2 w-3 h-3 bg-linear-to-r from-blue-400 to-purple-400 rounded-full animate-pulse" />
                            )}
                        </button>
                    ))}
                </div>

                {/* Content */}
                <div className="relative min-h-125 px-4 md:px-2">
                    {serviceSection4.map((service, idx) => (
                        <div
                            key={idx}
                            className={`transition-all duration-700 ${activeTab === idx
                                ? 'opacity-100 translate-y-0 relative'
                                : 'opacity-0 absolute inset-0 translate-y-8 pointer-events-none'
                                }`}
                        >
                            <div className="bg-white/10 backdrop-blur-2xl border border-white/20 rounded-3xl p-8 lg:p-12 shadow-2xl">
                                <div className="space-y-8">
                                    <div className="flex items-center gap-6">
                                        <div className="relative group">
                                            <div className="absolute inset-0 bg-linear-to-r from-blue-600 to-purple-600 rounded-2xl blur-xl opacity-50 group-hover:opacity-75 transition-opacity"></div>
                                            <div className="relative p-5 bg-linear-to-br from-blue-500 to-purple-500 rounded-2xl text-white transform hover:scale-110 transition-transform duration-300">
                                                {React.cloneElement(service.icon, { className: "w-12 h-12" })}
                                            </div>
                                        </div>
                                        <h3 className="text-4xl lg:text-4xl font-bold text-white">
                                            {service.title}
                                        </h3>
                                    </div>

                                    <p className="text-xl lg:text-2xl text-gray-200 leading-relaxed">
                                        {service.desc}
                                    </p>

                                    <div className="grid md:grid-cols-2 gap-4 pt-4">
                                        {service.features.map((feature, featureIdx) => (
                                            <div
                                                key={featureIdx}
                                                className="group flex items-center gap-4 p-5 bg-white/5 rounded-xl border border-white/10 hover:bg-white/10 hover:border-blue-400/50 transition-all duration-300 hover:scale-105"
                                            >
                                                <div className="w-3 h-3 bg-linear-to-r from-blue-400 to-purple-400 rounded-full group-hover:scale-125 transition-transform" />
                                                <span className="text-white font-medium text-lg">{feature}</span>
                                            </div>
                                        ))}
                                    </div>

                                    <div className="pt-6">
                                        <button className="group relative px-8 py-4 bg-linear-to-r from-blue-600 to-purple-600 text-white font-bold rounded-xl overflow-hidden shadow-xl hover:shadow-blue-500/50 transition-all duration-300 hover:scale-105">
                                            <span className="relative z-10 flex items-center gap-2">
                                                Learn More
                                                <svg className="w-5 h-5 group-hover:translate-x-2 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7l5 5m0 0l-5 5m5-5H6" />
                                                </svg>
                                            </span>
                                        </button>
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

export default Service