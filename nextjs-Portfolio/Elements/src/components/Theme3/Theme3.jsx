"use client"
import React from 'react'
import Navbar from './Sections/Navbar';
import useTheme3 from './useTheme3';
import Hero from './Sections/Hero';
import Service from './Sections/Service';
import Faq from './Sections/Faq';
import Contactus from './Sections/Contactus';

const Theme3 = () => {
    const { mousePos, activeFaq, setActiveFaq, formData, setFormData, handleMouseMove, handleSubmit } = useTheme3();

    return (
        <>
            <Navbar />
            <div className="bg-black">
                {/* Hero Section */}
                <Hero
                    mousePos={mousePos}
                    handleMouseMove={handleMouseMove}
                />

                {/* Service Section */}
                <Service
                    mousePos={mousePos}
                    handleMouseMove={handleMouseMove}
                />

                {/* FAQ Section */}
                <Faq
                    activeFaq={activeFaq}
                    setActiveFaq={setActiveFaq}
                />

                {/* Contact Section */}
                <Contactus
                    formData={formData}
                    setFormData={setFormData}
                    handleSubmit={handleSubmit}
                />


                <style jsx>{`
                @keyframes float {
                    0%, 100% { transform: translateY(0px); }
                    50% { transform: translateY(-20px); }
                }
                .animate-float {
                    animation: float 3s ease-in-out infinite;
                }
            `}</style>
            </div>
        </>
    )
}

export default Theme3