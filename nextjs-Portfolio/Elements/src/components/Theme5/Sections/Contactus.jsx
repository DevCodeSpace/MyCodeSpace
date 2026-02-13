import React from 'react'

const Contactus = ({ step, formData, setFormData, nextStep, prevStep }) => {
    return (
        <section className="min-h-screen bg-white py-12 md:py-10 lg:py-20 px-10 md:px-8 lg:px-4 flex items-center justify-center overflow-hidden">
            <div className="max-w-2xl w-full">
                {/* Header with Animation */}
                <div className="text-center mb-8 md:mb-12 lg:mb-16 animate-fade-scale">
                    <div className="w-16 h-16 md:w-20 md:h-20 bg-linear-to-br from-rose-500 to-orange-500 rounded-3xl mx-auto mb-4 md:mb-6 flex items-center justify-center animate-rotate-slow">
                        <svg className="w-8 h-8 md:w-10 md:h-10 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                        </svg>
                    </div>
                    <h1 className="text-3xl md:text-4xl lg:text-5xl font-bold text-gray-900 mb-3 md:mb-4">
                        We'd Love to Hear From You
                    </h1>
                    <p className="text-base md:text-lg text-gray-600">
                        Fill out the form below and we'll get back to you within 24 hours
                    </p>
                </div>

                {/* Progress Bar */}
                <div className="mb-8 md:mb-12 animate-slide-in">
                    <div className="flex items-center justify-between mb-2">
                        {[1, 2, 3].map((num) => (
                            <div
                                key={num}
                                className={`flex items-center ${num < 3 ? 'flex-1' : ''}`}
                            >
                                <div className={`w-8 h-8 md:w-10 md:h-10 rounded-full flex items-center justify-center text-sm md:text-base font-bold transition-all duration-500 ${step >= num
                                    ? 'bg-gradient-to-br from-rose-500 to-orange-500 text-white scale-110'
                                    : 'bg-gray-200 text-gray-500'
                                    }`}>
                                    {num}
                                </div>
                                {num < 3 && (
                                    <div className="flex-1 h-1 mx-2">
                                        <div className={`h-full rounded transition-all duration-500 ${step > num ? 'bg-gradient-to-r from-rose-500 to-orange-500' : 'bg-gray-200'
                                            }`}></div>
                                    </div>
                                )}
                            </div>
                        ))}
                    </div>
                    <div className="flex justify-between text-xs text-gray-500 mt-2">
                        <span>Personal Info</span>
                        <span>Contact Details</span>
                        <span>Message</span>
                    </div>
                </div>

                {/* Form Steps */}
                <div className="bg-gradient-to-br from-gray-50 to-gray-100 rounded-2xl md:rounded-3xl p-6 md:p-8 lg:p-12 shadow-2xl">
                    {/* Step 1 */}
                    {step === 1 && (
                        <div className="space-y-5 md:space-y-6 animate-fade-slide-up">
                            <h2 className="text-xl md:text-2xl font-bold text-gray-900 mb-4 md:mb-6">Tell us about yourself</h2>
                            <div className="space-y-2">
                                <label className="text-sm font-semibold text-gray-700">Full Name</label>
                                <input
                                    type="text"
                                    value={formData.name}
                                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                    className="w-full px-4 md:px-6 py-3 md:py-4 bg-white border-2 border-gray-200 rounded-xl md:rounded-2xl focus:border-rose-500 focus:ring-4 focus:ring-rose-100 transition-all duration-300"
                                    placeholder="John Doe"
                                />
                            </div>
                            <div className="space-y-2">
                                <label className="text-sm font-semibold text-gray-700">Email Address</label>
                                <input
                                    type="email"
                                    value={formData.email}
                                    onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                                    className="w-full px-4 md:px-6 py-3 md:py-4 bg-white border-2 border-gray-200 rounded-xl md:rounded-2xl focus:border-rose-500 focus:ring-4 focus:ring-rose-100 transition-all duration-300"
                                    placeholder="john@example.com"
                                />
                            </div>
                        </div>
                    )}

                    {/* Step 2 */}
                    {step === 2 && (
                        <div className="space-y-5 md:space-y-6 animate-fade-slide-up">
                            <h2 className="text-xl md:text-2xl font-bold text-gray-900 mb-4 md:mb-6">How can we reach you?</h2>
                            <div className="space-y-2">
                                <label className="text-sm font-semibold text-gray-700">Phone Number</label>
                                <input
                                    type="tel"
                                    value={formData.phone}
                                    onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                                    className="w-full px-4 md:px-6 py-3 md:py-4 bg-white border-2 border-gray-200 rounded-xl md:rounded-2xl focus:border-rose-500 focus:ring-4 focus:ring-rose-100 transition-all duration-300"
                                    placeholder="+1 (555) 123-4567"
                                />
                            </div>
                            <div className="bg-rose-50 border border-rose-200 rounded-xl md:rounded-2xl p-4">
                                <p className="text-sm text-rose-700">
                                    💡 <strong>Tip:</strong> Including your phone number helps us respond faster!
                                </p>
                            </div>
                        </div>
                    )}

                    {/* Step 3 */}
                    {step === 3 && (
                        <div className="space-y-5 md:space-y-6 animate-fade-slide-up">
                            <h2 className="text-xl md:text-2xl font-bold text-gray-900 mb-4 md:mb-6">What's on your mind?</h2>
                            <div className="space-y-2">
                                <label className="text-sm font-semibold text-gray-700">Your Message</label>
                                <textarea
                                    value={formData.message}
                                    onChange={(e) => setFormData({ ...formData, message: e.target.value })}
                                    rows={6}
                                    className="w-full px-4 md:px-6 py-3 md:py-4 bg-white border-2 border-gray-200 rounded-xl md:rounded-2xl focus:border-rose-500 focus:ring-4 focus:ring-rose-100 transition-all duration-300 resize-none"
                                    placeholder="Tell us about your project, question, or inquiry..."
                                ></textarea>
                            </div>
                            <div className="bg-gradient-to-r from-rose-50 to-orange-50 border border-rose-200 rounded-xl md:rounded-2xl p-4">
                                <p className="text-sm text-gray-700">
                                    ✨ <strong>Almost done!</strong> Review your information and submit when ready.
                                </p>
                            </div>
                        </div>
                    )}

                    {/* Navigation Buttons */}
                    <div className="flex gap-3 md:gap-4 mt-6 md:mt-8">
                        {step > 1 && (
                            <button
                                onClick={prevStep}
                                className="flex-1 py-3 md:py-4 bg-white border-2 border-gray-300 text-gray-700 font-bold rounded-xl md:rounded-2xl hover:bg-gray-50 hover:scale-105 transition-all duration-300 text-sm md:text-base"
                            >
                                ← Previous
                            </button>
                        )}
                        {step < 3 ? (
                            <button
                                onClick={nextStep}
                                className="flex-1 py-3 md:py-4 bg-gradient-to-r from-rose-500 to-orange-500 text-white font-bold rounded-xl md:rounded-2xl hover:shadow-2xl hover:scale-105 transition-all duration-300 text-sm md:text-base"
                            >
                                Next Step →
                            </button>
                        ) : (
                            <button
                                type="button"
                                className="flex-1 py-3 md:py-4 bg-gradient-to-r from-rose-500 to-orange-500 text-white font-bold rounded-xl md:rounded-2xl hover:shadow-2xl hover:scale-105 transition-all duration-300 group text-sm md:text-base"
                            >
                                <span className="flex items-center justify-center gap-2">
                                    Submit Message
                                    <svg className="w-4 h-4 md:w-5 md:h-5 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                                    </svg>
                                </span>
                            </button>
                        )}
                    </div>
                </div>

                {/* Footer Info */}
                <div className="mt-8 md:mt-12 text-center animate-fade-in-delayed">
                    <p className="text-gray-600 mb-4 text-sm md:text-base">Or reach us directly at:</p>
                    <div className="flex flex-col sm:flex-row flex-wrap justify-center gap-4 md:gap-6">
                        <a href="mailto:hello@company.com" className="flex items-center justify-center gap-2 text-rose-600 hover:text-rose-700 font-semibold text-sm md:text-base">
                            <svg className="w-4 h-4 md:w-5 md:h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                            </svg>
                            hello@company.com
                        </a>
                        <a href="tel:+15551234567" className="flex items-center justify-center gap-2 text-rose-600 hover:text-rose-700 font-semibold text-sm md:text-base">
                            <svg className="w-4 h-4 md:w-5 md:h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                            </svg>
                            +1 (555) 123-4567
                        </a>
                    </div>
                </div>
            </div>

            <style jsx>{`
                @keyframes fadeScale {
                    from { opacity: 0; transform: scale(0.95); }
                    to { opacity: 1; transform: scale(1); }
                }
                @keyframes slideIn {
                    from { opacity: 0; transform: translateY(-20px); }
                    to { opacity: 1; transform: translateY(0); }
                }
                @keyframes fadeSlideUp {
                    from { opacity: 0; transform: translateY(20px); }
                    to { opacity: 1; transform: translateY(0); }
                }
                @keyframes rotateSlow {
                    0%, 100% { transform: rotate(0deg); }
                    50% { transform: rotate(5deg); }
                }
                .animate-fade-scale { animation: fadeScale 0.6s ease-out; }
                .animate-slide-in { animation: slideIn 0.8s ease-out 0.2s both; }
                .animate-fade-slide-up { animation: fadeSlideUp 0.5s ease-out; }
                .animate-rotate-slow { animation: rotateSlow 3s ease-in-out infinite; }
                .animate-fade-in-delayed { animation: fadeScale 0.8s ease-out 0.4s both; }
            `}</style>
        </section>
    )
}

export default Contactus