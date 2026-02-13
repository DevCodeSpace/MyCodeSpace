/** @type {import('tailwindcss').Config} */
module.exports = {
    darkMode: "class", // Required for dark mode toggle
    content: [
        "./src/app/**/*.{js,jsx}",
        "./src/components/**/*.{js,jsx}",
        "./src/pages/**/*.{js,jsx}",
    ],
    theme: {
        container: {
            center: true,
            padding: "2rem",
            screens: {
                "2xl": "1400px",
            },
        },
        extend: {
            colors: {
                border: "hsl(var(--border))",
                input: "hsl(var(--input))",
                ring: "hsl(var(--ring))",
                background: "hsl(var(--background))",
                foreground: "hsl(var(--foreground))",

                primary: {
                    DEFAULT: "hsl(var(--primary))",
                    foreground: "hsl(var(--primary-foreground))",
                },
                secondary: {
                    DEFAULT: "hsl(var(--secondary))",
                    foreground: "hsl(var(--secondary-foreground))",
                },
                destructive: {
                    DEFAULT: "hsl(var(--destructive))",
                    foreground: "hsl(var(--destructive-foreground))",
                },
                muted: {
                    DEFAULT: "hsl(var(--muted))",
                    foreground: "hsl(var(--muted-foreground))",
                },
                accent: {
                    DEFAULT: "hsl(var(--accent))",
                    foreground: "hsl(var(--accent-foreground))",
                },
                popover: {
                    DEFAULT: "hsl(var(--popover))",
                    foreground: "hsl(var(--popover-foreground))",
                },
                card: {
                    DEFAULT: "hsl(var(--card))",
                    foreground: "hsl(var(--card-foreground))",
                },
            },
            borderRadius: {
                lg: "var(--radius)",
                md: "calc(var(--radius) - 2px)",
                sm: "calc(var(--radius) - 4px)",
            },
            keyframes: {
                "accordion-down": {
                    from: { height: 0 },
                    to: { height: "var(--radix-accordion-content-height)" },
                },
                "accordion-up": {
                    from: { height: "var(--radix-accordion-content-height)" },
                    to: { height: 0 },
                },
                megaGlow: {
                    "0%, 100%": { opacity: "0.4", transform: "scale(1) rotate(0deg)" },
                    "50%": { opacity: "0.6", transform: "scale(1.1) rotate(180deg)" },
                },
                spinIn: {
                    "0%": { transform: "rotate(90deg) scale(0)", opacity: "0" },
                    "100%": { transform: "rotate(0deg) scale(1)", opacity: "1" },
                },
                bounceSubtle: {
                    "0%, 100%": { transform: "translateY(0) scale(1)" },
                    "50%": { transform: "translateY(-2px) scale(1.05)" },
                },
                slideInRight: {
                    "0%": { opacity: "0", transform: "translateX(20px)" },
                    "100%": { opacity: "1", transform: "translateX(0)" },
                },
                borderRotate: {
                    "0%": { transform: "rotate(0deg)" },
                    "100%": { transform: "rotate(360deg)" },
                },
                gradientWave: {
                    "0%,100%": { backgroundPosition: "0% 50%" },
                    "50%": { backgroundPosition: "100% 50%" },
                },
                pulseSmooth: {
                    "0%,100%": { opacity: "0.5" },
                    "50%": { opacity: "0.8" },
                },
                shimmerSlide: {
                    "100%": { transform: "translateX(200%)" },
                },
                starTwinkle: {
                    "0%,100%": { opacity: "0.3", transform: "scale(0.8)" },
                    "50%": { opacity: "1", transform: "scale(1.2)" },
                },
                bounceIcon: {
                    "0%,100%": { transform: "translateY(0) rotate(0deg)" },
                    "50%": { transform: "translateY(-4px) rotate(8deg)" },
                },
                checkPop: {
                    "0%": { opacity: "0", transform: "scale(0.3)" },
                    "50%": { transform: "scale(1.2)" },
                    "100%": { opacity: "1", transform: "scale(1)" },
                },
                particleFloat: {
                    "0%,100%": { transform: "translate(0,0) scale(1)" },
                    "25%": { transform: "translate(8px,-8px) scale(1.1)" },
                    "50%": { transform: "translate(-4px,-12px) scale(0.9)" },
                    "75%": { transform: "translate(-8px,-6px) scale(1.05)" },
                },
                particleFloatDelayed: {
                    "0%,100%": { transform: "translate(0,0) scale(1)" },
                    "25%": { transform: "translate(-8px,8px) scale(1.1)" },
                    "50%": { transform: "translate(4px,12px) scale(0.9)" },
                    "75%": { transform: "translate(8px,6px) scale(1.05)" },
                },
            },
            animation: {
                "accordion-down": "accordion-down 0.2s ease-out",
                "accordion-up": "accordion-up 0.2s ease-out",
                "mega-glow": "megaGlow 6s ease-in-out infinite",
                "spin-in": "spinIn 0.3s ease-out",
                "bounce-subtle": "bounceSubtle 2s ease-in-out infinite",
                "slide-in-right": "slideInRight 0.4s ease-out",
                "border-rotate": "borderRotate 10s linear infinite",
                "gradient-wave": "gradientWave 4s ease infinite",
                "pulse-smooth": "pulseSmooth 3s ease-in-out infinite",
                "shimmer-slide": "shimmerSlide 2s ease-in-out infinite",
                "star-twinkle": "starTwinkle 2s ease-in-out infinite",
                "bounce-icon": "bounceIcon 3s ease-in-out infinite",
                "check-pop": "checkPop 0.5s ease-out",
                "particle-float": "particleFloat 5s ease-in-out infinite",
                "particle-float-delayed":
                    "particleFloatDelayed 5s ease-in-out infinite 2.5s",

            },
        },
    },
};
