import { contactMethods } from '@/data/contactData'
import React from 'react'

const Contactus = ({ hoveredCard, setHoveredCard, formData, setFormData }) => {
    return (
        <section className="min-h-screen bg-linear-to-br from-slate-900 via-pink-900 to-slate-900 py-20 px-10 relative overflow-hidden">
            {/* Animated Background Grid */}
            <div className="absolute inset-0 opacity-5" style={{ backgroundImage: 'linear-gradient(#fff 1px, transparent 1px), linear-gradient(90deg, #fff 1px, transparent 1px)', backgroundSize: '50px 50px' }}></div>

            {/* Animated Background */}
            <div className="absolute inset-0 overflow-hidden">
                <div className="absolute w-96 h-96 bg-pink-500 rounded-full blur-3xl opacity-30 animate-pulse top-0 left-0"></div>
                <div className="absolute w-96 h-96 bg-rose-500 rounded-full blur-3xl opacity-30 animate-pulse top-0 right-0" style={{ animationDelay: '1s' }}></div>
                <div className="absolute w-96 h-96 bg-purple-500 rounded-full blur-3xl opacity-30 animate-pulse bottom-0 left-1/2" style={{ animationDelay: '2s' }}></div>
            </div>

            <div className="max-w-7xl mx-auto relative z-10">
                {/* Header */}
                <div className="text-center mb-16">
                    <div className="inline-flex items-center gap-3 px-6 py-3 bg-white/10 backdrop-blur-xl rounded-full border border-white/20 shadow-xl mb-6">
                        <span className="text-sm font-bold text-white uppercase tracking-wider">Let's Connect</span>
                    </div>
                    <h1 className="text-6xl lg:text-6xl font-bold text-white mb-4">
                        Get in <span className="text-transparent bg-clip-text bg-linear-to-r from-pink-400 via-rose-400 to-purple-400">Touch</span>
                    </h1>
                    <p className="text-xl text-gray-300">Choose your preferred way to reach us</p>
                </div>

                {/* Contact Method Cards */}
                <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6 mb-16">
                    {contactMethods.map((method, idx) => (
                        <div
                            key={idx}
                            onMouseEnter={() => setHoveredCard(idx + 200)}
                            onMouseLeave={() => setHoveredCard(null)}
                            className="group relative bg-white/5 backdrop-blur-xl rounded-2xl p-6 border border-white/10 hover:border-white/30 transition-all duration-500 cursor-pointer hover:scale-105"
                        >
                            <div className={`absolute inset-0 bg-linear-to-br ${method.color} opacity-0 group-hover:opacity-10 rounded-2xl transition-opacity duration-500`}></div>
                            <div className="relative">
                                <div className={`w-16 h-16 bg-linear-to-br ${method.color} rounded-xl flex items-center justify-center text-3xl mb-4 transform group-hover:scale-110 group-hover:rotate-6 transition-all duration-500 shadow-lg`}>
                                    {method.icon}
                                </div>
                                <h3 className="text-xl font-bold text-white mb-2">{method.title}</h3>
                                <p className="text-gray-400">{method.desc}</p>
                            </div>
                            {hoveredCard === idx + 200 && (
                                <div className="absolute inset-0 rounded-2xl animate-pulse opacity-20">
                                    <div className={`absolute inset-0 bg-linear-to-br ${method.color} rounded-2xl`}></div>
                                </div>
                            )}
                        </div>
                    ))}
                </div>

                {/* Contact Form */}
                <div className="max-w-3xl mx-auto">
                    <div className="bg-white/10 backdrop-blur-2xl rounded-3xl p-8 lg:p-12 border border-white/20 shadow-2xl">
                        <h2 className="text-3xl font-bold text-white mb-8 text-center">Send Us a Message</h2>

                        <div className="grid md:grid-cols-2 gap-6 mb-6">
                            <div className="space-y-2">
                                <label className="text-sm font-semibold text-gray-300">Your Name</label>
                                <input
                                    type="text"
                                    value={formData.name}
                                    placeholder="Jude Philip"
                                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                    className="w-full px-4 py-4 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-500 focus:border-pink-500 mt-2"
                                />
                            </div>
                            {/* Email */}
                            <div className="space-y-2">
                                <label className="text-sm font-semibold text-gray-300">Email Address</label>
                                <input
                                    type="email"
                                    value={formData.email}
                                    onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                                    placeholder="you@company.com"
                                    className="w-full mt-2 px-4 py-4 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-500 focus:outline-none focus:border-pink-500 focus:ring-2 focus:ring-pink-500/30 transition-all duration-300 hover:border-white/30"
                                />
                            </div>

                            {/* Subject */}
                            <div className="space-y-2">
                                <label className="text-sm font-semibold text-gray-300">Subject</label>
                                <input
                                    type="text"
                                    value={formData.subject}
                                    onChange={(e) => setFormData({ ...formData, subject: e.target.value })}
                                    placeholder="Project Inquiry"
                                    className="w-full px-4 mt-2 py-4 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-500 focus:outline-none focus:border-pink-500 focus:ring-2 focus:ring-pink-500/30 transition-all duration-300 hover:border-white/30"
                                />
                            </div>
                        </div>

                        {/* Message */}
                        <div className="space-y-2 mb-8">
                            <label className="text-sm font-semibold text-gray-300">Message</label>
                            <textarea
                                rows={5}
                                value={formData.message}
                                onChange={(e) => setFormData({ ...formData, message: e.target.value })}
                                placeholder="Tell us about your project..."
                                className="w-full px-4 mt-2 py-4 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-500 focus:outline-none focus:border-pink-500 focus:ring-2 focus:ring-pink-500/30 transition-all duration-300 resize-none hover:border-white/30"
                            />
                        </div>

                        {/* Submit Button */}
                        <div className="text-center">
                            <button className="group relative px-12 py-5 bg-linear-to-r from-pink-600 via-rose-500 to-purple-600 text-white font-bold rounded-2xl overflow-hidden shadow-2xl hover:shadow-pink-500/50 transition-all duration-300 hover:scale-110">
                                <span className="relative z-10 flex items-center justify-center gap-3">
                                    Send Message
                                    <svg
                                        className="w-5 h-5 group-hover:translate-x-2 transition-transform duration-300"
                                        fill="none"
                                        stroke="currentColor"
                                        viewBox="0 0 24 24"
                                    >
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7l5 5m0 0l-5 5m5-5H6" />
                                    </svg>
                                </span>
                                <div className="absolute inset-0 bg-linear-to-r from-purple-600 to-pink-600 translate-x-full group-hover:translate-x-0 transition-transform duration-500" />
                            </button>

                            <p className="mt-4 text-sm text-gray-400">
                                We usually respond within 24 hours
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    )
}

export default Contactus