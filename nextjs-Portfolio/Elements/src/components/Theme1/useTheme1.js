import { useState } from 'react'

const useTheme1 = () => {
    const [formData, setFormData] = useState({
        name: '',
        email: '',
        phone: '',
        message: ''
    });
    const [focusedField, setFocusedField] = useState('');
    const [openIndex, setOpenIndex] = useState(null);

    const handleSubmit = (e) => {
        e.preventDefault();
    };

    const handleChange = (e) => {
        setFormData({ ...formData, [e.target.name]: e.target.value });
    };
    const toggleFaq = (index) => {
        setOpenIndex(openIndex === index ? null : index);
    };

    return {
        formData,
        setFormData,
        focusedField,
        setFocusedField,
        toggleFaq,
        handleChange,
        handleSubmit,
        openIndex,
    }
}

export default useTheme1