import { offices } from '@/data/contactData'
import React from 'react'

const Contactus = ({ formData,
    setFormData,
    activeTab,
    setActiveTab }) => {
    return (
        <section className="min-h-screen bg-linear-to-br from-emerald-50 via-teal-50 to-cyan-50 py-20 px-10 lg:px-4">
            <div className="max-w-7xl mx-auto">
                {/* Header */}
                <div className="text-center mb-16 animate-slide-down">
                    <div className="inline-block px-6 py-2 bg-linear-to-r from-emerald-600 to-teal-600 text-white rounded-full text-sm font-semibold mb-4 animate-pulse-slow">
                        We're Here to Help
                    </div>
                    <h1 className="text-5xl font-bold text-gray-900 mb-4">
                        Contact <span className="text-transparent bg-clip-text bg-linear-to-r from-emerald-600 to-teal-600">Our Team</span>
                    </h1>
                    <p className="text-xl text-gray-600">Choose how you'd like to connect with us</p>
                </div>

                <div className="grid lg:grid-cols-3 gap-8">
                    {/* Left - Office Locations */}
                    <div className="lg:col-span-1 space-y-4 animate-slide-right">
                        <h2 className="text-2xl font-bold text-gray-900 mb-6">Our Offices</h2>
                        {offices.map((office, idx) => (
                            <div
                                key={idx}
                                className="group bg-white rounded-2xl p-6 shadow-lg hover:shadow-2xl transition-all duration-500 cursor-pointer hover:-translate-y-2 animate-fade-in"
                                style={{ animationDelay: `${idx * 0.1}s` }}
                            >
                                <div className="flex items-start gap-4">
                                    <div className="w-12 h-12 bg-linear-to-br from-emerald-500 to-teal-500 rounded-xl flex items-center justify-center shrink-0 group-hover:scale-110 group-hover:rotate-12 transition-all duration-500">
                                        <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                                        </svg>
                                    </div>
                                    <div className="flex-1">
                                        <h3 className="text-xl font-bold text-gray-900 mb-2 group-hover:text-emerald-600 transition-colors">
                                            {office.city}
                                        </h3>
                                        <p className="text-sm text-gray-600 mb-2">{office.address}</p>
                                        <p className="text-xs text-emerald-600 font-semibold">{office.time}</p>
                                    </div>
                                </div>
                            </div>
                        ))}

                        {/* Quick Stats */}
                        <div className="bg-linear-to-br from-emerald-600 to-teal-600 rounded-2xl p-6 text-white animate-fade-in" style={{ animationDelay: '0.4s' }}>
                            <h3 className="text-lg font-bold mb-4">Quick Stats</h3>
                            <div className="space-y-3">
                                <div className="flex justify-between items-center">
                                    <span className="text-emerald-100">Response Time</span>
                                    <span className="font-bold">{'< 2 hours'}</span>
                                </div>
                                <div className="flex justify-between items-center">
                                    <span className="text-emerald-100">Support Available</span>
                                    <span className="font-bold">24/7</span>
                                </div>
                                <div className="flex justify-between items-center">
                                    <span className="text-emerald-100">Satisfaction Rate</span>
                                    <span className="font-bold">98%</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    {/* Right - Contact Form */}
                    <div className="lg:col-span-2 animate-slide-left">
                        <div className="bg-white rounded-3xl shadow-2xl overflow-hidden">
                            {/* Tabs */}
                            <div className="flex border-b border-gray-200 bg-gray-50">
                                {['general', 'sales', 'support'].map((tab) => (
                                    <button
                                        key={tab}
                                        onClick={() => setActiveTab(tab)}
                                        className={`flex-1 py-4 px-6 font-semibold capitalize transition-all duration-300 relative ${activeTab === tab ? 'text-emerald-600' : 'text-gray-600 hover:text-gray-900'
                                            }`}
                                    >
                                        {tab}
                                        {activeTab === tab && (
                                            <div className="absolute bottom-0 left-0 right-0 h-1 bg-linear-to-r from-emerald-600 to-teal-600 animate-expand"></div>
                                        )}
                                    </button>
                                ))}
                            </div>

                            {/* Form Content */}
                            <div className="p-8 lg:p-12">
                                <div className="mb-8">
                                    <h2 className="text-3xl font-bold text-gray-900 mb-2">
                                        {activeTab === 'general' && 'General Inquiry'}
                                        {activeTab === 'sales' && 'Sales Questions'}
                                        {activeTab === 'support' && 'Technical Support'}
                                    </h2>
                                    <p className="text-gray-600">
                                        {activeTab === 'general' && 'Have a question? We\'re here to help!'}
                                        {activeTab === 'sales' && 'Interested in our products? Let\'s talk!'}
                                        {activeTab === 'support' && 'Need technical assistance? We\'ve got you covered!'}
                                    </p>
                                </div>

                                <div className="space-y-6">
                                    <div className="grid md:grid-cols-2 gap-6">
                                        <div className="space-y-2 animate-fade-in-up" style={{ animationDelay: '0.1s' }}>
                                            <label className="text-sm font-semibold text-gray-700">Full Name *</label>
                                            <input
                                                type="text"
                                                value={formData.name}
                                                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                                className="w-full px-4 py-3 bg-gray-50 border-2 border-transparent rounded-xl focus:border-emerald-500 focus:bg-white transition-all duration-300 hover:border-gray-300"
                                                placeholder="John Doe"
                                            />
                                        </div>
                                        <div className="space-y-2 animate-fade-in-up" style={{ animationDelay: '0.2s' }}>
                                            <label className="text-sm font-semibold text-gray-700">Email Address *</label>
                                            <input
                                                type="email"
                                                value={formData.email}
                                                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                                                className="w-full px-4 py-3 bg-gray-50 border-2 border-transparent rounded-xl focus:border-emerald-500 focus:bg-white transition-all duration-300 hover:border-gray-300"
                                                placeholder="john@example.com"
                                            />
                                        </div>
                                    </div>

                                    <div className="space-y-2 animate-fade-in-up" style={{ animationDelay: '0.3s' }}>
                                        <label className="text-sm font-semibold text-gray-700">Company</label>
                                        <input
                                            type="text"
                                            value={formData.company}
                                            onChange={(e) => setFormData({ ...formData, company: e.target.value })}
                                            className="w-full px-4 py-3 bg-gray-50 border-2 border-transparent rounded-xl focus:border-emerald-500 focus:bg-white transition-all duration-300 hover:border-gray-300"
                                            placeholder="Your Company Name"
                                        />
                                    </div>

                                    <div className="space-y-2 animate-fade-in-up" style={{ animationDelay: '0.4s' }}>
                                        <label className="text-sm font-semibold text-gray-700">Message *</label>
                                        <textarea
                                            value={formData.message}
                                            onChange={(e) => setFormData({ ...formData, message: e.target.value })}
                                            rows={6}
                                            className="w-full px-4 py-3 bg-gray-50 border-2 border-transparent rounded-xl focus:border-emerald-500 focus:bg-white transition-all duration-300 resize-none hover:border-gray-300"
                                            placeholder="Tell us more about your inquiry..."
                                        ></textarea>
                                    </div>

                                    <button className="group w-full py-4 bg-linear-to-r from-emerald-600 to-teal-600 text-white font-bold rounded-xl hover:shadow-2xl transition-all duration-300 hover:scale-105 animate-fade-in-up" style={{ animationDelay: '0.5s' }}>
                                        <span className="flex items-center justify-center gap-2">
                                            Submit {activeTab.charAt(0).toUpperCase() + activeTab.slice(1)} Inquiry
                                            <svg className="w-5 h-5 group-hover:translate-x-2 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M14 5l7 7m0 0l-7 7m7-7H3" />
                                            </svg>
                                        </span>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <style jsx>{`
                    @keyframes slideDown {
                        from { opacity: 0; transform: translateY(-30px); }
                        to { opacity: 1; transform: translateY(0); }
                    }
                    @keyframes slideRight {
                        from { opacity: 0; transform: translateX(-30px); }
                        to { opacity: 1; transform: translateX(0); }
                    }
                    @keyframes slideLeft {
                        from { opacity: 0; transform: translateX(30px); }
                        to { opacity: 1; transform: translateX(0); }
                    }
                    @keyframes fadeIn {
                        from { opacity: 0; }
                        to { opacity: 1; }
                    }
                    @keyframes fadeInUp {
                        from { opacity: 0; transform: translateY(20px); }
                        to { opacity: 1; transform: translateY(0); }
                    }
                    @keyframes expand {
                        from { transform: scaleX(0); }
                        to { transform: scaleX(1); }
                    }
                    @keyframes pulseSlow {
                        0%, 100% { opacity: 1; }
                        50% { opacity: 0.8; }
                    }
                    .animate-slide-down { animation: slideDown 0.8s ease-out; }
                    .animate-slide-right { animation: slideRight 0.8s ease-out; }
                    .animate-slide-left { animation: slideLeft 0.8s ease-out; }
                    .animate-fade-in { animation: fadeIn 0.6s ease-out; }
                    .animate-fade-in-up { animation: fadeInUp 0.6s ease-out; }
                    .animate-expand { animation: expand 0.3s ease-out; }
                    .animate-pulse-slow { animation: pulseSlow 3s ease-in-out infinite; }
                `}</style>
        </section>
    )
}

export default Contactus