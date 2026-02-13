"use client";
import React from 'react'
import Navbar from './Sections/Navbar';
import useTheme2 from './useTheme2';
import Hero from './Sections/Hero';
import Service from './Sections/Service';
import Faq from './Sections/Faq';
import Contactus from './Sections/Contactus';

const Theme2 = () => {
    const {
        formData,
        setFormData,
        activeTab,
        setActiveTab,
        selectedCategory,
        setSelectedCategory,
        openIndex,
        setOpenIndex,
        toggleFaq
    } = useTheme2();

    return (
        <>
            <Navbar />
            {/* Hero Section */}
            <Hero />
            {/* Service Section */}
            <Service />
            {/* FAQ Section */}
            <Faq
                toggleFaq={toggleFaq}
                openIndex={openIndex}
                setOpenIndex={setOpenIndex}
                selectedCategory={selectedCategory}
                setSelectedCategory={setSelectedCategory}
            />
            {/* Contact Section */}
            <Contactus formData={formData}
                setFormData={setFormData}
                activeTab={activeTab}
                setActiveTab={setActiveTab}
            />

        </>
    )
}

export default Theme2