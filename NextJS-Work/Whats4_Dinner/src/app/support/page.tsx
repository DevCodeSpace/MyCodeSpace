import { Metadata } from "next";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";

export const metadata: Metadata = {
  title: "Support – What's 4 Dinner",
  description: "Get help with What's 4 Dinner. Contact our support team.",
};

export default function SupportPage() {
  return (
    <>
    <Navbar />
    <main className="min-h-screen bg-white pt-16 sm:pt-[72px]">
      <div className="max-w-2xl mx-auto px-6 py-12 sm:py-16">

        <h1 className="text-3xl sm:text-4xl font-bold text-[#1A1A1A] text-center font-(family-name:--font-poppins)">
          Support
        </h1>
        <div className="flex justify-center mt-3">
          <span className="text-sm font-medium px-4 py-1.5 rounded-full border font-(family-name:--font-inter)"
            style={{ background: "#fff0f0", color: "#e05252", borderColor: "#f5c6c6" }}>
            We respond within 24 hours
          </span>
        </div>

        <p className="mt-8 text-[15px] text-gray-700 leading-relaxed font-(family-name:--font-inter)">
          If you need help with What&apos;s 4 Dinner, our support team is here to assist you.
          Reach out to us and we&apos;ll get back to you as soon as possible.
        </p>

        <div className="mt-8 space-y-8 font-(family-name:--font-inter) text-[15px] text-gray-700 leading-relaxed">

          <div>
            <h2 className="text-[17px] font-bold text-[#1A1A1A] mb-3 font-(family-name:--font-poppins)">
              Contact Us
            </h2>
            <p>For any questions, issues, or feedback, contact us directly:</p>
            <div className="mt-3 border border-gray-200 rounded-xl p-4 flex flex-col gap-3">
              <div className="flex items-center gap-3">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ color: "#e05252", flexShrink: 0 }}>
                  <rect width="20" height="16" x="2" y="4" rx="2" /><path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7" />
                </svg>
                <a href="mailto:support@whats4dinnerapp.com" className="text-[15px] text-gray-700 hover:underline">
                  support@whats4dinnerapp.com
                </a>
              </div>
              <div className="flex items-center gap-3">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ color: "#e05252", flexShrink: 0 }}>
                  <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" /><polyline points="9 22 9 12 15 12 15 22" />
                </svg>
                <span className="text-[15px] text-gray-700">What&apos;s 4 Dinner, LLC</span>
              </div>
            </div>
          </div>

          <div>
            <h2 className="text-[17px] font-bold text-[#1A1A1A] mb-3 font-(family-name:--font-poppins)">
              Common Topics
            </h2>
            <ul className="space-y-1.5 pl-5">
              {[
                "Account setup and login issues",
                "Deal redemption problems",
                "Restaurant listing inquiries",
                "QR code not working",
                "App technical issues",
                "Billing and payment questions",
              ].map((item) => (
                <li key={item} className="flex items-start gap-2">
                  <span className="mt-[6px] w-[6px] h-[6px] rounded-full flex-shrink-0" style={{ background: "#e05252" }} />
                  <span>{item}</span>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h2 className="text-[17px] font-bold text-[#1A1A1A] mb-3 font-(family-name:--font-poppins)">
              Response Time
            </h2>
            <p>We respond to all support requests within <span className="font-semibold text-[#1A1A1A]">24 hours</span> on business days.</p>
          </div>

        </div>

        <div className="mt-12 pt-8 border-t border-gray-200 text-center">
          <p className="text-xs text-gray-400 font-(family-name:--font-inter)">
            © {new Date().getFullYear()} What&apos;s 4 Dinner, LLC. All rights reserved.
          </p>
        </div>

      </div>
    </main>
    <Footer />
    </>
  );
}
