"use client";
import React, { useState } from 'react'
import Navbar from './Sections/Navbar';
import Hero from './Sections/Hero';
import Service from './Sections/Service';
import Faq from './Sections/Faq';
import Contactus from './Sections/Contactus';

const Theme5 = () => {
    const [formData, setFormData] = useState({ name: '', email: '', phone: '', message: '' });
    const [step, setStep] = useState(1);

    const nextStep = () => setStep(step + 1);
    const prevStep = () => setStep(step - 1);
    const [openFaq, setOpenFaq] = useState(null);

    return (
        <>
            <Navbar />
            {/* hero Section */}
            <Hero />

            {/* Service Section */}
            <Service />

            {/* FAQ Section */}
            <Faq openFaq={openFaq} setOpenFaq={setOpenFaq} />

            {/* Contact Us Section */}
            <Contactus
                step={step}
                formData={formData}
                setFormData={setFormData}
                nextStep={nextStep}
                prevStep={prevStep}
            />
        </>
    )
}

export default Theme5