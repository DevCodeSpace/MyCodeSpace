"use client";
import React from 'react'
import Navbar from './Sections/Navbar';
import useTheme1 from './useTheme1';
import Theme1Hero from './Sections/Theme1Hero';
import Theme1Service from './Sections/Theme1Service';
import Theme1Faq from './Sections/Theme1Faq';
import Theme1Contactus from './Sections/Theme1Contactus';

const Theme1 = () => {
    const { formData, toggleFaq, focusedField, setFocusedField, openIndex, handleChange, handleSubmit } = useTheme1();

    return (
        <>
            <Navbar />

            <Theme1Hero /> {/* HEro Section */}

            <Theme1Service />  {/* Services Section */}

            <Theme1Faq openIndex={openIndex} toggleFaq={toggleFaq} />    {/* FAQ Section */}
            {/* Contact Us Section */}
            <Theme1Contactus
                formData={formData}
                focusedField={focusedField}
                setFocusedField={setFocusedField}
                handleChange={handleChange}
                handleSubmit={handleSubmit}
            />
        </>
    )
}

export default Theme1
