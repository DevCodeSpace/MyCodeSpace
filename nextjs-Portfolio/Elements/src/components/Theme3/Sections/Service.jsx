import { theme3Services } from '@/data/serviceData'
import React from 'react'

const Service = ({ handleMouseMove, mousePos }) => {
    return (
        <section className="min-h-screen bg-black relative overflow-hidden py-16 sm:py-24 px-10 sm:px-6" onMouseMove={handleMouseMove}>
            <div
                className="absolute inset-0 opacity-30 transition-all duration-300"
                style={{
                    background: `radial-gradient(600px circle at ${mousePos.x}px ${mousePos.y}px, rgba(99, 102, 241, 0.15), transparent 40%)`
                }}
            />

            <div className="max-w-7xl mx-auto relative z-10">
                <div className="text-center mb-16 sm:mb-20 space-y-4">
                    <h2 className="text-4xl sm:text-5xl md:text-6xl lg:text-7xl xl:text-7xl font-bold">
                        <span className="bg-linear-to-r from-white to-gray-400 bg-clip-text text-transparent block mb-2">
                            Our Services
                        </span>
                        <span className="bg-linear-to-r from-indigo-500 via-purple-500 to-pink-500 bg-clip-text text-transparent">
                            That Transform
                        </span>
                    </h2>
                </div>

                <div className="grid sm:grid-cols-2 gap-6 sm:gap-8">
                    {theme3Services.map((service, idx) => (
                        <div
                            key={idx}
                            className="group relative"
                            style={{
                                animation: `float ${3 + idx * 0.5}s ease-in-out infinite`,
                                animationDelay: `${idx * 0.2}s`
                            }}
                        >
                            <div className={`absolute -inset-1 bg-linear-to-r ${service.gradient} rounded-3xl blur-2xl opacity-0 group-hover:opacity-75 transition-all duration-700`} />

                            <div className="relative h-64 sm:h-72 bg-linear-to-br from-zinc-900 to-black border border-zinc-800 rounded-3xl p-6 sm:p-8 transform group-hover:scale-105 transition-all duration-500 group-hover:border-zinc-700 overflow-hidden">
                                <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-700">
                                    <div className="absolute inset-0 bg-linear-to-r from-transparent via-white/10 to-transparent -translate-x-full group-hover:translate-x-full transition-transform duration-1000" />
                                </div>

                                <div className="relative space-y-4 sm:space-y-6 h-full flex flex-col">
                                    <div className={`inline-flex p-3 sm:p-4 bg-linear-to-r ${service.gradient} rounded-2xl text-white w-fit text-2xl sm:text-3xl transform group-hover:rotate-12 group-hover:scale-110 transition-all duration-500`}>
                                        {service.icon}
                                    </div>

                                    <div className="space-y-2 sm:space-y-3 flex-1">
                                        <h3 className="text-2xl sm:text-3xl font-bold text-white">
                                            {service.title}
                                        </h3>
                                        <p className="text-zinc-400 text-base sm:text-lg leading-relaxed">
                                            {service.desc}
                                        </p>
                                    </div>

                                    <div className="flex items-center gap-2 text-zinc-500 group-hover:text-white transition-colors duration-300">
                                        <span className="text-sm font-medium">Learn More</span>
                                        <div className="transform group-hover:translate-x-2 transition-transform duration-300">
                                            →
                                        </div>
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