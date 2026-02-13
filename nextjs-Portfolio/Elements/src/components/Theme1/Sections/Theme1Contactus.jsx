import { contactSection1, contactSocialLinks } from '@/data/contactData'
import React from 'react'

const Theme1Contactus = ({ formData, focusedField, setFocusedField, handleChange, handleSubmit }) => {
    return (
        <section className="min-h-screen bg-linear-to-br from-indigo-50 via-purple-50 to-pink-50 py-20 px-20 lg:px-4 overflow-hidden">
            <div className="max-w-7xl mx-auto">
                <div className="grid lg:grid-cols-2 gap-12 items-center">
                    {/* Left Side - Contact Info */}
                    <div className="space-y-8 animate-fade-in-left">
                        <div className="space-y-4">
                            <div className="inline-block px-4 py-2 bg-linear-to-r from-indigo-600 to-purple-600 text-white rounded-full text-sm font-semibold animate-bounce-slow">
                                Get In Touch
                            </div>
                            <h1 className="text-5xl font-bold text-gray-900 leading-tight">
                                Let's Start a
                                <span className="block text-transparent bg-clip-text bg-linear-to-r from-indigo-600 to-purple-600 animate-gradient">
                                    Conversation
                                </span>
                            </h1>
                            <p className="text-xl text-gray-600">
                                We'd love to hear from you. Send us a message and we'll respond as soon as possible.
                            </p>
                        </div>

                        {/* Contact Cards */}
                        <div className="space-y-4">
                            {contactSection1?.map((item, idx) => (
                                <div
                                    key={idx}
                                    className="group bg-white p-6 rounded-2xl shadow-lg hover:shadow-2xl transition-all duration-300 hover:scale-105 cursor-pointer animate-slide-up"
                                    style={{ animationDelay: item.delay }}
                                >
                                    <div className="flex items-center gap-4">
                                        <div className="w-14 h-14 bg-linear-to-br from-indigo-100 to-purple-100 rounded-xl flex items-center justify-center text-2xl group-hover:scale-110 transition-transform duration-300">
                                            {item.icon}
                                        </div>
                                        <div>
                                            <h3 className="font-semibold text-gray-900">{item.title}</h3>
                                            <p className="text-gray-600">{item.value}</p>
                                        </div>
                                    </div>
                                </div>
                            ))}
                        </div>

                        {/* Social Links */}
                        <div className="flex gap-4 animate-fade-in" style={{ animationDelay: '0.4s' }}>
                            {contactSocialLinks?.map((social, idx) => (
                                <button
                                    key={idx}
                                    className="w-12 h-12 bg-white rounded-full shadow-md hover:shadow-xl flex items-center justify-center hover:scale-110 transition-all duration-300 hover:bg-linear-to-br hover:from-indigo-600 hover:to-purple-600 hover:text-white"
                                >
                                    <span className="text-sm font-semibold">{social[0]}</span>
                                </button>
                            ))}
                        </div>
                    </div>

                    {/* Right Side - Contact Form */}
                    <div className="animate-fade-in-right">
                        <div className="bg-white rounded-3xl shadow-2xl p-6 md:p-8 lg:p-12 relative overflow-hidden">
                            {/* Decorative elements */}
                            <div className="absolute -top-10 -right-10 w-40 h-40 bg-linear-to-br from-indigo-400 to-purple-400 rounded-full blur-3xl opacity-20 animate-pulse"></div>
                            <div className="absolute -bottom-10 -left-10 w-40 h-40 bg-linear-to-br from-pink-400 to-purple-400 rounded-full blur-3xl opacity-20 animate-pulse" style={{ animationDelay: '1s' }}></div>

                            <div className="relative space-y-6">
                                <div className="space-y-2">
                                    <label className="text-sm font-semibold text-gray-700">Full Name</label>
                                    <input
                                        type="text"
                                        name="name"
                                        value={formData.name}
                                        onChange={handleChange}
                                        onFocus={() => setFocusedField('name')}
                                        onBlur={() => setFocusedField('')}
                                        className={`w-full px-4 py-4 bg-gray-50 border-2 rounded-xl focus:outline-none transition-all duration-300 ${focusedField === 'name' ? 'border-indigo-600 bg-white scale-105' : 'border-transparent'
                                            }`}
                                        placeholder="John Doe"
                                    />
                                </div>

                                <div className="space-y-2">
                                    <label className="text-sm font-semibold text-gray-700">Email Address</label>
                                    <input
                                        type="email"
                                        name="email"
                                        value={formData.email}
                                        onChange={handleChange}
                                        onFocus={() => setFocusedField('email')}
                                        onBlur={() => setFocusedField('')}
                                        className={`w-full px-4 py-4 bg-gray-50 border-2 rounded-xl focus:outline-none transition-all duration-300 ${focusedField === 'email' ? 'border-indigo-600 bg-white scale-105' : 'border-transparent'
                                            }`}
                                        placeholder="john@example.com"
                                    />
                                </div>

                                <div className="space-y-2">
                                    <label className="text-sm font-semibold text-gray-700">Phone Number</label>
                                    <input
                                        type="tel"
                                        name="phone"
                                        value={formData.phone}
                                        onChange={handleChange}
                                        onFocus={() => setFocusedField('phone')}
                                        onBlur={() => setFocusedField('')}
                                        className={`w-full px-4 py-4 bg-gray-50 border-2 rounded-xl focus:outline-none transition-all duration-300 ${focusedField === 'phone' ? 'border-indigo-600 bg-white scale-105' : 'border-transparent'
                                            }`}
                                        placeholder="+1 (555) 123-4567"
                                    />
                                </div>

                                <div className="space-y-2">
                                    <label className="text-sm font-semibold text-gray-700">Message</label>
                                    <textarea
                                        name="message"
                                        value={formData.message}
                                        onChange={handleChange}
                                        onFocus={() => setFocusedField('message')}
                                        onBlur={() => setFocusedField('')}
                                        rows={5}
                                        className={`w-full px-4 py-4 bg-gray-50 border-2 rounded-xl focus:outline-none transition-all duration-300 resize-none ${focusedField === 'message' ? 'border-indigo-600 bg-white scale-105' : 'border-transparent'
                                            }`}
                                        placeholder="Tell us about your project..."
                                    ></textarea>
                                </div>

                                <button
                                    onClick={handleSubmit}
                                    className="group relative w-full py-4 bg-linear-to-r from-indigo-600 to-purple-600 text-white font-bold rounded-xl overflow-hidden hover:scale-105 transition-transform duration-300"
                                >
                                    <span className="relative z-10 flex items-center justify-center gap-2">
                                        Send Message
                                        <svg className="w-5 h-5 group-hover:translate-x-2 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7l5 5m0 0l-5 5m5-5H6" />
                                        </svg>
                                    </span>
                                    <div className="absolute inset-0 bg-linear-to-r from-purple-600 to-pink-600 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    )
}

export default Theme1Contactus