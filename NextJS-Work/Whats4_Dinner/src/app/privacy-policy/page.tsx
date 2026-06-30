import { Metadata } from "next";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";

export const metadata: Metadata = {
  title: "Privacy Policy – What's 4 Dinner",
  description: "Read the Privacy Policy for What's 4 Dinner.",
};

export default function PrivacyPolicyPage() {
  return (
    <>
    <Navbar />
    <main className="min-h-screen bg-white pt-16 sm:pt-[72px]">
      <div className="max-w-2xl mx-auto px-6 py-12 sm:py-16">

        <h1 className="text-3xl sm:text-4xl font-bold text-[#1A1A1A] text-center font-(family-name:--font-poppins)">
          Privacy Policy
        </h1>
        <div className="flex justify-center mt-3">
          <span className="text-sm font-medium px-4 py-1.5 rounded-full border font-(family-name:--font-inter)"
            style={{ background: "#fff0f0", color: "#e05252", borderColor: "#f5c6c6" }}>
            Last Updated: January 21, 2026
          </span>
        </div>

        <p className="mt-8 text-[15px] text-gray-700 leading-relaxed font-(family-name:--font-inter)">
          Welcome to What&apos;s 4 Dinner (&quot;W4D,&quot; &quot;we,&quot; &quot;us,&quot; or &quot;our&quot;). These Terms and
          Conditions (&quot;Terms&quot;) govern your access to and use of the What&apos;s 4 Dinner mobile
          application, website, and services (collectively, the &quot;Platform&quot;).
        </p>
        <p className="mt-4 text-[15px] text-gray-700 leading-relaxed font-(family-name:--font-inter)">
          By accessing or using the Platform, you agree to be bound by these Terms. If you do
          not agree, do not use the Platform.
        </p>

        <div className="mt-8 space-y-8 font-(family-name:--font-inter) text-[15px] text-gray-700 leading-relaxed">

          <Section title="1. Platform Role">
            <p>What&apos;s 4 Dinner is a technology platform that connects diners with independent restaurants offering time-limited promotions and deals.</p>
            <p className="mt-3 font-semibold text-[#1A1A1A]">W4D does not:</p>
            <BulletList items={["Prepare, sell, or deliver food", "Set menu prices", "Process in-restaurant payments", "Employ restaurant staff", "Guarantee availability of any deal"]} />
            <p className="mt-3">All transactions for food and beverage occur directly between the diner and the restaurant. Restaurants are independent third parties and are solely responsible for food quality, safety, service, pricing, and compliance with laws.</p>
          </Section>

          <Section title="2. User Accounts">
            <p>You must create an account to use certain features.</p>
            <p className="mt-3 font-semibold text-[#1A1A1A]">You agree to:</p>
            <BulletList items={["Provide accurate information", "Maintain the security of your login", "Be responsible for all activity under your account"]} />
            <p className="mt-3">W4D may suspend or terminate accounts for misuse, fraud, or violation of these Terms.</p>
          </Section>

          <Section title="3. Deal Usage & Redemption">
            <p className="font-semibold text-[#1A1A1A]">Deals displayed on the Platform:</p>
            <BulletList items={["Are created and managed by restaurants", "Are subject to time limits, availability, and redemption rules", "May be changed or removed at any time"]} />
            <p className="mt-3 font-semibold text-[#1A1A1A]">QR codes are:</p>
            <BulletList items={["Dynamically generated", "Single-use", "Non-transferable", "Invalid if screenshotted, duplicated, or reused"]} />
            <p className="mt-3">Restaurants may refuse redemption for expired, duplicated, or abused deals.</p>
          </Section>

          <Section title="4. Restaurant Responsibilities">
            <p className="font-semibold text-[#1A1A1A]">Restaurants agree to:</p>
            <BulletList items={["Honor all active deals as displayed", "Accurately describe terms and limitations", "Comply with all local, state, and federal laws", "Maintain proper food safety and licensing"]} />
            <p className="mt-3 font-semibold text-[#1A1A1A]">W4D is not responsible for:</p>
            <BulletList items={["Lost revenue", "Staffing issues", "Inventory shortages", "Customer disputes", "Health code compliance"]} />
          </Section>

          <Section title="5. Payments">
            <p>W4D does not process payments between diners and restaurants unless explicitly stated in the future. All food purchases are completed directly at the restaurant using their accepted payment methods.</p>
          </Section>

          <Section title="6. Prohibited Conduct">
            <p className="font-semibold text-[#1A1A1A]">Users may not:</p>
            <BulletList items={["Abuse promotions", "Share or sell QR codes", "Circumvent redemption limits", "Use the Platform for unlawful purposes", "Interfere with app security or functionality"]} />
          </Section>

          <Section title="7. Intellectual Property">
            <p>All app content, trademarks, logos, and software belong to What&apos;s 4 Dinner or its licensors and may not be copied or used without permission.</p>
          </Section>

          <Section title="8. Disclaimer of Warranties">
            <p>The Platform is provided &quot;as is&quot; and &quot;as available.&quot;</p>
            <p className="mt-3 font-semibold text-[#1A1A1A]">W4D makes no warranties regarding:</p>
            <BulletList items={["Deal availability", "Restaurant performance", "Service quality", "Platform uptime"]} />
          </Section>

          <Section title="9. Limitation of Liability">
            <p>To the maximum extent permitted by law, W4D shall not be liable for:</p>
            <BulletList items={["Personal injury", "Foodborne illness", "Lost profits", "Missed reservations", "Service interruptions", "Indirect or consequential damages"]} />
            <p className="mt-3">Your sole remedy is to stop using the Platform.</p>
          </Section>

          <Section title="10. Indemnification">
            <p>You agree to indemnify and hold harmless What&apos;s 4 Dinner from claims arising from:</p>
            <BulletList items={["Your misuse of the Platform", "Your violation of these Terms", "Restaurant operations and customer interactions"]} />
          </Section>

          <Section title="11. Termination">
            <p>W4D may suspend or terminate access at any time for any reason, including violations of these Terms.</p>
          </Section>

          <Section title="12. Governing Law">
            <p>These Terms are governed by the laws of the State of Maryland, without regard to conflict-of-law principles.</p>
          </Section>

          <Section title="13. Changes to Terms">
            <p>We may update these Terms from time to time. Continued use of the Platform after changes constitutes acceptance.</p>
          </Section>

          <Section title="14. Contact">
            <p>Questions about these Terms may be sent to:</p>
            <ContactCard />
          </Section>

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

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div>
      <h2 className="text-[17px] font-bold text-[#1A1A1A] mb-3 font-(family-name:--font-poppins)">{title}</h2>
      {children}
    </div>
  );
}

function BulletList({ items }: { items: string[] }) {
  return (
    <ul className="mt-2 space-y-1.5 pl-5">
      {items.map((item) => (
        <li key={item} className="flex items-start gap-2">
          <span className="mt-[6px] w-[6px] h-[6px] rounded-full flex-shrink-0" style={{ background: "var(--color-primary, #e05252)" }} />
          <span>{item}</span>
        </li>
      ))}
    </ul>
  );
}

function ContactCard() {
  return (
    <div className="mt-3 border border-gray-200 rounded-xl p-4 flex flex-col gap-3">
      <div className="flex items-center gap-3">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ color: "#e05252", flexShrink: 0 }}>
          <rect width="20" height="16" x="2" y="4" rx="2" /><path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7" />
        </svg>
        <a href="mailto:support@whats4dinnerapp.com" className="text-[15px] text-gray-700 hover:underline">support@whats4dinnerapp.com</a>
      </div>
      <div className="flex items-center gap-3">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ color: "#e05252", flexShrink: 0 }}>
          <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" /><polyline points="9 22 9 12 15 12 15 22" />
        </svg>
        <span className="text-[15px] text-gray-700">What&apos;s 4 Dinner, LLC</span>
      </div>
    </div>
  );
}
