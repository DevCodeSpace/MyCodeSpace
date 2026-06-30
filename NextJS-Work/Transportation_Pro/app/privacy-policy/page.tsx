import { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Privacy Policy",
  description: "Privacy Policy for TransportPro software and services.",
};

export default function PrivacyPolicyPage() {
  return (
    <div className="bg-white min-h-screen">
      {/* Header Section */}
      <section className="bg-[#F0F8FF] pt-28 pb-16 lg:pt-36 lg:pb-24 border-b border-[#0C1B33]/5">
        <div className="max-w-360 mx-auto px-4 sm:px-6 lg:px-10">
          <h1 className="text-[38px] sm:text-[46px] lg:text-[52px] font-bold text-[#0C1B33] leading-[1.05] tracking-tight mb-4">
            Privacy Policy
          </h1>
          <p className="text-[17.5px] text-[#0C1B33]/55 leading-[1.75] max-w-2xl">
            Last updated:{" "}
            {new Date().toLocaleDateString("en-US", {
              month: "long",
              day: "numeric",
              year: "numeric",
            })}
          </p>
        </div>
      </section>

      {/* Content Section */}
      <section className="py-16 lg:py-24">
        <div className="max-w-360 mx-auto px-4 sm:px-6 lg:px-10">
          <div className="max-w-4xl prose prose-lg prose-blue">
            <div className="space-y-10 text-[#0C1B33]/80">
              <div>
                <h2 className="text-[28px] font-bold text-[#0C1B33] mb-4 tracking-tight">
                  1. Introduction
                </h2>
                <p className="text-[17.5px] leading-[1.75] mb-4">
                  Welcome to TransportPro. We respect your privacy and are
                  committed to protecting your personal data. This privacy
                  policy will inform you as to how we look after your personal
                  data when you visit our website or use our transport
                  management software and tell you about your privacy rights and
                  how the law protects you.
                </p>
              </div>

              <div>
                <h2 className="text-[28px] font-bold text-[#0C1B33] mb-4 tracking-tight">
                  2. The Data We Collect About You
                </h2>
                <p className="text-[17.5px] leading-[1.75] mb-4">
                  Personal data, or personal information, means any information
                  about an individual from which that person can be identified.
                  We may collect, use, store and transfer different kinds of
                  personal data about you which we have grouped together as
                  follows:
                </p>
                <ul className="list-disc pl-6 space-y-2 text-[17.5px] leading-[1.75]">
                  <li>
                    <strong>Identity Data:</strong> includes first name, last
                    name, username or similar identifier.
                  </li>
                  <li>
                    <strong>Contact Data:</strong> includes billing address,
                    delivery address, email address and telephone numbers.
                  </li>
                  <li>
                    <strong>Technical Data:</strong> includes internet protocol
                    (IP) address, your login data, browser type and version,
                    time zone setting and location, browser plug-in types and
                    versions, operating system and platform, and other
                    technology on the devices you use to access this website.
                  </li>
                  <li>
                    <strong>Usage Data:</strong> includes information about how
                    you use our website, products and services.
                  </li>
                </ul>
              </div>

              <div>
                <h2 className="text-[28px] font-bold text-[#0C1B33] mb-4 tracking-tight">
                  3. How We Use Your Personal Data
                </h2>
                <p className="text-[17.5px] leading-[1.75] mb-4">
                  We will only use your personal data when the law allows us to.
                  Most commonly, we will use your personal data in the following
                  circumstances:
                </p>
                <ul className="list-disc pl-6 space-y-2 text-[17.5px] leading-[1.75]">
                  <li>
                    Where we need to perform the contract we are about to enter
                    into or have entered into with you.
                  </li>
                  <li>
                    Where it is necessary for our legitimate interests (or those
                    of a third party) and your interests and fundamental rights
                    do not override those interests.
                  </li>
                  <li>Where we need to comply with a legal obligation.</li>
                </ul>
              </div>

              <div>
                <h2 className="text-[28px] font-bold text-[#0C1B33] mb-4 tracking-tight">
                  4. Data Security
                </h2>
                <p className="text-[17.5px] leading-[1.75] mb-4">
                  We have put in place appropriate security measures to prevent
                  your personal data from being accidentally lost, used or
                  accessed in an unauthorised way, altered or disclosed. In
                  addition, we limit access to your personal data to those
                  employees, agents, contractors and other third parties who
                  have a business need to know.
                </p>
              </div>

              <div>
                <h2 className="text-[28px] font-bold text-[#0C1B33] mb-4 tracking-tight">
                  5. Contact Us
                </h2>
                <p className="text-[17.5px] leading-[1.75] mb-4">
                  If you have any questions about this privacy policy or our
                  privacy practices, please contact us at:
                </p>
                <p className="text-[17.5px] leading-[1.75]">
                  Email:{" "}
                  <a
                    href="mailto:moiz.codexlancers@gmail.com"
                    className="text-blue-600 hover:text-blue-800 transition-colors"
                  >
                    moiz.codexlancers@gmail.com
                  </a>
                </p>
                <div className="mt-8">
                  <Link
                    href="/support"
                    className="inline-flex items-center justify-center gap-2.5 px-7 py-3.5 text-[14px] font-semibold text-white bg-[#0C1B33] rounded-xl hover:bg-[#0C1B33]/90 transition-all shadow-sm"
                  >
                    Visit Support Center
                  </Link>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
