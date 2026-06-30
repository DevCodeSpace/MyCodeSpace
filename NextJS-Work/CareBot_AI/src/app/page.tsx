import LayoutShell from "@/components/LayoutShell";
import Features from "@/components/Features";
import HowItWorks from "@/components/HowItWorks";
import WhyUs from "@/components/WhyUs";
import Testimonials from "@/components/Testimonials";
import FAQ from "@/components/FAQ";
import Contact from "@/components/Contact";
import Footer from "@/components/Footer";

export default function Home() {
  return (
    <main className="flex flex-col min-h-screen">
      <LayoutShell />
      <Features />
      <HowItWorks />
      <WhyUs />
      <Testimonials />
      <FAQ />
      <Contact />
      <Footer />
    </main>
  );
}
