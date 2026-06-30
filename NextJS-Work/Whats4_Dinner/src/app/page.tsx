import Navbar from "@/components/Navbar";
import Hero from "@/components/Hero";
import Features from "@/components/Features";
import WhyUs from "@/components/WhyUs";
import HowItWorks from "@/components/HowItWorks";
import MobileApp from "@/components/MobileApp";
import FAQ from "@/components/FAQ";
import Contact from "@/components/Contact";
import Footer from "@/components/Footer";

export default function Home() {
  return (
    <main className="flex flex-col min-h-screen">
      <Navbar />
      <Hero />
      <Features />
      <WhyUs />
      <HowItWorks />
      <MobileApp />
      <FAQ />
      <Contact />
      <Footer />
    </main>
  );
}
