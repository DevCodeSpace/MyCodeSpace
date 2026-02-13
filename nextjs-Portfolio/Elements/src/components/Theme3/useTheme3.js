import React, { useState } from 'react'

const useTheme3 = () => {
    const [mousePos, setMousePos] = useState({ x: 0, y: 0 });
    const [activeFaq, setActiveFaq] = useState(null);
    const [formData, setFormData] = useState({ name: '', email: '', message: '' });

    const handleMouseMove = (e) => {
        const rect = e.currentTarget.getBoundingClientRect();
        setMousePos({
            x: e.clientX - rect.left,
            y: e.clientY - rect.top,
        });
    };

    const handleSubmit = () => {
        setFormData({ name: '', email: '', message: '' });
    };

    return {
        mousePos,
        activeFaq,
        setActiveFaq,
        formData,
        setFormData,
        handleMouseMove,
        handleSubmit
    }
}

export default useTheme3