import { useState } from 'react'

const useTheme2 = () => {
    const [formData, setFormData] = useState({ name: '', email: '', company: '', message: '' });
    const [activeTab, setActiveTab] = useState('general');
    const [selectedCategory, setSelectedCategory] = useState('general');
    const [openIndex, setOpenIndex] = useState(null);


    const toggleFaq = (index) => {
        setOpenIndex(openIndex === index ? null : index);
    };

    return {
        formData,
        setFormData,
        activeTab,
        setActiveTab,
        selectedCategory,
        setSelectedCategory,
        openIndex,
        setOpenIndex,
        toggleFaq
    }
}

export default useTheme2