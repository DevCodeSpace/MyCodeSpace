"use client";
import React, { useState } from 'react';
import Navbar from './Sections/Navbar';
import Hero from './Sections/Hero';
import Service from './Sections/Service';
import Faq from './Sections/Faq';
import Contactus from './Sections/Contactus';

const Theme4 = () => {
    const [hoveredCard, setHoveredCard] = useState(null);
    const [activeTab, setActiveTab] = useState(0);
    const [formData, setFormData] = useState({ name: '', email: '', subject: '', message: '' });

    return (
        <>
            <Navbar />
            {/* Hero Section */}
            <Hero hoveredCard={hoveredCard} setHoveredCard={setHoveredCard} />

            {/* Service Section */}
            <Service activeTab={activeTab} setActiveTab={setActiveTab} />

            {/* FAQ Section */}
            <Faq hoveredCard={hoveredCard} setHoveredCard={setHoveredCard} />

            {/* Contact Section */}

            <Contactus hoveredCard={hoveredCard} setHoveredCard={setHoveredCard} formData={formData} setFormData={setFormData} />
        </>
    )
}

export default Theme4