import { Metadata } from "next";
import ContactSection from "../components/sections/ContactSection";
import FeaturesSection from "../components/sections/FeaturesSection";
import HeroSection from "../components/sections/HeroSection";
import HowItWorksSection from "../components/sections/HowItWorksSection";
import ProblemSection from "../components/sections/ProblemSection";
import StatsSection from "../components/sections/StatsSection";
import WhySection from "../components/sections/WhySection";
import { siteConfig } from "../lib/siteConfig";

export const metadata: Metadata = {
  title: "Transport Management Software | GST Billing & Freight",
  description:
    "Streamline your logistics business with TransportPro  end-to-end shipment loading, delivery tracking, GST-ready invoicing, auto freight calculation, 8+ reports, and live analytics. Built for Indian transport companies.",
  alternates: {
    canonical: siteConfig.url,
  },
  openGraph: {
    title: "TransportPro  Complete Transport & Logistics Management Software",
    description:
      "11 powerful modules for Indian logistics businesses  shipment loading, GST invoicing, freight billing, delivery tracking, and real-time analytics in one platform.",
    url: siteConfig.url,
  },
};

const softwareJsonLd = {
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  name: siteConfig.name,
  applicationCategory: "BusinessApplication",
  operatingSystem: "Web",
  url: siteConfig.url,
  description: siteConfig.description,
  offers: {
    "@type": "Offer",
    price: "0",
    priceCurrency: "INR",
    description: "Free demo available",
  },
  featureList: [
    "Shipment Loading Management",
    "Delivery Tracking & Workflow",
    "GST-Ready Invoicing",
    "Auto Freight Calculation",
    "Financial Integrity Reports",
    "Real-time Stock Dashboard",
    "Taka & Bale Management",
    "Operational Analytics",
    "Multi-party Billing",
    "Print Engine for Transport Receipts",
    "Master Administrative Control",
  ],
  screenshot: `${siteConfig.url}/images/og-image.jpg`,
  aggregateRating: {
    "@type": "AggregateRating",
    ratingValue: "4.8",
    ratingCount: "120",
  },
};

const faqJsonLd = {
  "@context": "https://schema.org",
  "@type": "FAQPage",
  mainEntity: [
    {
      "@type": "Question",
      name: "What is TransportPro?",
      acceptedAnswer: {
        "@type": "Answer",
        text: "TransportPro is an all-in-one transport management software built for Indian logistics businesses. It covers shipment loading, delivery tracking, GST invoicing, freight calculation, financial reports, and real-time analytics in a single platform.",
      },
    },
    {
      "@type": "Question",
      name: "Is TransportPro GST compliant?",
      acceptedAnswer: {
        "@type": "Answer",
        text: "Yes, TransportPro is 100% GST compliant. It automatically generates GST-ready invoices, handles multi-party billing, and produces financial reports aligned with Indian tax requirements.",
      },
    },
    {
      "@type": "Question",
      name: "Can I get a free demo of TransportPro?",
      acceptedAnswer: {
        "@type": "Answer",
        text: "Yes, TransportPro offers a free demo with no commitment or credit card required. Fill out the contact form and our team will walk you through the full platform tailored to your business.",
      },
    },
    {
      "@type": "Question",
      name: "Does TransportPro support textile transport (Taka & Bale)?",
      acceptedAnswer: {
        "@type": "Answer",
        text: "Yes, TransportPro has a specialized Taka & Bale management module for textile shipment tracking  logging Taka counts and Bale numbers per invoice, designed specifically for textile-industry transport operations.",
      },
    },
  ],
};

export default function Home() {
  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(softwareJsonLd) }}
      />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(faqJsonLd) }}
      />
      <HeroSection />
      <FeaturesSection />
      <HowItWorksSection />
      <WhySection />
      <StatsSection />
      <ProblemSection />
      <ContactSection />
    </>
  );
}
