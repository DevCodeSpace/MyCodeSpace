import React from 'react'

const Contactus = ({ handleSubmit, formData, setFormData }) => {
    return (
        <section className="min-h-screen bg-black relative overflow-hidden py-16 sm:py-24 px-10 sm:px-16 flex items-center">
            <div className="absolute inset-0 opacity-20">
                <div className="absolute inset-0" style={{
                    backgroundImage: `linear-gradient(rgba(99, 102, 241, 0.2) 1px, transparent 1px), linear-gradient(90deg, rgba(99, 102, 241, 0.2) 1px, transparent 1px)`,
                    backgroundSize: '50px 50px'
                }} />
            </div>

            <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-purple-500 rounded-full filter blur-3xl opacity-10"></div>
            <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-pink-500 rounded-full filter blur-3xl opacity-10"></div>

            <div className="max-w-6xl mx-auto relative z-10 w-full">
                <div className="grid lg:grid-cols-2 gap-8 lg:gap-12 items-center">
                    {/* Left Info */}
                    <div className="space-y-8">
                        <div className="space-y-6">
                            <h2 className="text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-bold">
                                <span className="bg-linear-to-r from-white to-gray-400 bg-clip-text text-transparent block">
                                    Let's Create
                                </span>
                                <span className="bg-linear-to-r from-indigo-500 via-purple-500 to-pink-500 bg-clip-text text-transparent">
                                    Something Amazing
                                </span>
                            </h2>
                            <p className="text-lg sm:text-xl text-zinc-400 leading-relaxed">
                                Ready to start your next project? Get in touch and let's discuss how we can bring your vision to life.
                            </p>
                        </div>

                        <div className="space-y-6">
                            <div className="flex items-start gap-4">
                                <div className="w-12 h-12 bg-linear-to-r from-indigo-500 to-purple-500 rounded-xl flex items-center justify-center text-white text-xl shrink-0">
                                    📧
                                </div>
                                <div>
                                    <div className="text-white font-semibold mb-1">Email</div>
                                    <div className="text-zinc-400">hello@agency.com</div>
                                </div>
                            </div>

                            <div className="flex items-start gap-4">
                                <div className="w-12 h-12 bg-linear-to-r from-purple-500 to-pink-500 rounded-xl flex items-center justify-center text-white text-xl shrink-0">
                                    📱
                                </div>
                                <div>
                                    <div className="text-white font-semibold mb-1">Phone</div>
                                    <div className="text-zinc-400">+1 (555) 123-4567</div>
                                </div>
                            </div>

                            <div className="flex items-start gap-4">
                                <div className="w-12 h-12 bg-linear-to-r from-pink-500 to-rose-500 rounded-xl flex items-center justify-center text-white text-xl shrink-0">
                                    📍
                                </div>
                                <div>
                                    <div className="text-white font-semibold mb-1">Location</div>
                                    <div className="text-zinc-400">San Francisco, CA</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    {/* Right Form */}
                    <div className="relative">
                        <div className="absolute -inset-1 bg-linear-to-r from-indigo-500 via-purple-500 to-pink-500 rounded-3xl blur-xl opacity-30"></div>
                        <div className="relative bg-linear-to-br from-zinc-900 to-black border border-zinc-800 rounded-3xl p-6 sm:p-8 shadow-2xl">
                            <div className="space-y-6">
                                <div>
                                    <label className="block text-white font-semibold mb-2">Name</label>
                                    <input
                                        type="text"
                                        value={formData.name}
                                        onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                        className="w-full px-4 py-3 bg-white/5 border border-zinc-700 rounded-xl text-white placeholder-zinc-500 focus:outline-none focus:border-indigo-500 transition-colors"
                                        placeholder="John Doe"
                                    />
                                </div>

                                <div>
                                    <label className="block text-white font-semibold mb-2">Email</label>
                                    <input
                                        type="email"
                                        value={formData.email}
                                        onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                                        className="w-full px-4 py-3 bg-white/5 border border-zinc-700 rounded-xl text-white placeholder-zinc-500 focus:outline-none focus:border-indigo-500 transition-colors"
                                        placeholder="john@example.com"
                                    />
                                </div>

                                <div>
                                    <label className="block text-white font-semibold mb-2">Message</label>
                                    <textarea
                                        rows="4"
                                        value={formData.message}
                                        onChange={(e) => setFormData({ ...formData, message: e.target.value })}
                                        className="w-full px-4 py-3 bg-white/5 border border-zinc-700 rounded-xl text-white placeholder-zinc-500 focus:outline-none focus:border-indigo-500 transition-colors resize-none"
                                        placeholder="Tell us about your project..."
                                    ></textarea>
                                </div>

                                <button
                                    onClick={handleSubmit}
                                    className="w-full py-4 bg-linear-to-r from-indigo-500 to-purple-500 text-white font-semibold rounded-xl hover:from-purple-500 hover:to-pink-500 transition-all duration-300 flex items-center justify-center gap-2"
                                >
                                    Send Message
                                    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M14 5l7 7m0 0l-7 7m7-7H3" />
                                    </svg>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    )
}

export default Contactus