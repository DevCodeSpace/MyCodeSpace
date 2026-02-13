import { theme1Service } from '@/data/serviceData'
import React from 'react'

const Theme1Service = () => {
    return (
        <section className="relative py-28 bg-linear-to-br from-indigo-50 via-purple-50 to-pink-50 overflow-hidden">
            {/* Soft background blobs */}
            <div className="absolute inset-0">
                <div className="absolute -top-20 right-20 w-80 h-80 bg-indigo-300/30 rounded-full blur-3xl animate-blob"></div>
                <div className="absolute bottom-0 left-10 w-96 h-96 bg-pink-300/30 rounded-full blur-3xl animate-blob animation-delay-2000"></div>
            </div>

            <div
                className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8"
            >
                {/* Section Header */}
                <div className="text-center max-w-3xl mx-auto mb-20 animate-fade-in-up">
                    <span className="inline-block mb-4 px-4 py-2 text-sm font-semibold bg-white/80 backdrop-blur rounded-full shadow">
                        Our Services
                    </span>
                    <h2 className="text-4xl lg:text-5xl font-bold text-gray-900">
                        What We
                        <span className="text-transparent bg-clip-text bg-linear-to-r from-indigo-600 via-purple-600 to-pink-600">
                            &nbsp;Build Best
                        </span>
                    </h2>
                    <p className="mt-6 text-lg text-gray-600">
                        Design-driven, performance-focused digital solutions that actually move the needle.
                    </p>
                </div>

                {/* Services Grid */}
                <div className="grid gap-8 sm:grid-cols-2 lg:grid-cols-3">
                    {theme1Service.map((service, idx) => (
                        <div
                            key={idx}
                            className="group relative bg-white/80 backdrop-blur-xl rounded-3xl p-8 shadow-xl border border-white/40
                            transition-all duration-500 hover:-translate-y-2 hover:shadow-2xl animate-fade-in-up"
                            style={{ animationDelay: `${idx * 0.1}s` }}
                        >
                            {/* Icon */}
                            <div
                                className={`w-14 h-14 mb-6 rounded-2xl bg-linear-to-br ${service.gradient}
                                shadow-lg group-hover:scale-110 transition-transform duration-300`}
                            />

                            <h3 className="text-xl font-bold text-gray-900 mb-3">
                                {service.title}
                            </h3>

                            <p className="text-gray-600 leading-relaxed">
                                {service.desc}
                            </p>

                            {/* Hover glow */}
                            <div className="absolute inset-0 rounded-3xl opacity-0 group-hover:opacity-100 transition duration-500
                                bg-linear-to-br from-indigo-500/10 via-purple-500/10 to-pink-500/10" />
                        </div>
                    ))}
                </div>
            </div>
        </section>
    )
}

export default Theme1Service