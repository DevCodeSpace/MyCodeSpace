import { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Terms of Use",
  description: "Terms of Use for TransportPro software and services.",
};

export default function TermsOfUsePage() {
  return (
    <div className="bg-white min-h-screen">
      {/* Header Section */}
      <section className="bg-[#F0F8FF] pt-28 pb-16 lg:pt-36 lg:pb-24 border-b border-[#0C1B33]/5">
        <div className="max-w-360 mx-auto px-4 sm:px-6 lg:px-10">
          <h1 className="text-[38px] sm:text-[46px] lg:text-[52px] font-bold text-[#0C1B33] leading-[1.05] tracking-tight mb-4">
            Terms of Use
          </h1>
          <p className="text-[17.5px] text-[#0C1B33]/55 leading-[1.75] max-w-2xl">
            Last updated: {new Date().toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })}
          </p>
        </div>
      </section>

      {/* Content Section */}
      <section className="py-16 lg:py-24">
        <div className="max-w-360 mx-auto px-4 sm:px-6 lg:px-10">
          <div className="max-w-4xl prose prose-lg prose-blue">
            <div className="space-y-10 text-[#0C1B33]/80">
              
              <div>
                <h2 className="text-[28px] font-bold text-[#0C1B33] mb-4 tracking-tight">1. Agreement to Terms</h2>
                <p className="text-[17.5px] leading-[1.75] mb-4">
                  By accessing or using TransportPro ("the Service"), you agree to be bound by these Terms of Use. If you disagree with any part of the terms, you may not access the Service. These Terms apply to all visitors, users, and others who access or use the Service.
                </p>
              </div>

              <div>
                <h2 className="text-[28px] font-bold text-[#0C1B33] mb-4 tracking-tight">2. Intellectual Property</h2>
                <p className="text-[17.5px] leading-[1.75] mb-4">
                  The Service and its original content, features, and functionality are and will remain the exclusive property of TransportPro and its licensors. The Service is protected by copyright, trademark, and other laws of both the local and foreign countries. Our trademarks and trade dress may not be used in connection with any product or service without the prior written consent of TransportPro.
                </p>
              </div>

              <div>
                <h2 className="text-[28px] font-bold text-[#0C1B33] mb-4 tracking-tight">3. User Accounts</h2>
                <p className="text-[17.5px] leading-[1.75] mb-4">
                  When you create an account with us, you must provide information that is accurate, complete, and current at all times. Failure to do so constitutes a breach of the Terms, which may result in immediate termination of your account on our Service.
                </p>
                <p className="text-[17.5px] leading-[1.75] mb-4">
                  You are responsible for safeguarding the password that you use to access the Service and for any activities or actions under your password, whether your password is with our Service or a third-party service.
                </p>
              </div>

              <div>
                <h2 className="text-[28px] font-bold text-[#0C1B33] mb-4 tracking-tight">4. Limitation of Liability</h2>
                <p className="text-[17.5px] leading-[1.75] mb-4">
                  In no event shall TransportPro, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from your access to or use of or inability to access or use the Service.
                </p>
              </div>

              <div>
                <h2 className="text-[28px] font-bold text-[#0C1B33] mb-4 tracking-tight">5. Governing Law</h2>
                <p className="text-[17.5px] leading-[1.75] mb-4">
                  These Terms shall be governed and construed in accordance with the laws of India, without regard to its conflict of law provisions. Our failure to enforce any right or provision of these Terms will not be considered a waiver of those rights.
                </p>
              </div>

              <div>
                <h2 className="text-[28px] font-bold text-[#0C1B33] mb-4 tracking-tight">6. Changes to Terms</h2>
                <p className="text-[17.5px] leading-[1.75] mb-4">
                  We reserve the right, at our sole discretion, to modify or replace these Terms at any time. What constitutes a material change will be determined at our sole discretion. By continuing to access or use our Service after those revisions become effective, you agree to be bound by the revised terms.
                </p>
              </div>

            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
