import { Clock, LifeBuoy, Mail, MapPin, Phone } from "lucide-react";
import { Metadata } from "next";
import SupportForm from "../../components/SupportForm";

export const metadata: Metadata = {
  title: "Support Center",
  description: "Get help and support for TransportPro software.",
};

export default function SupportPage() {
  return (
    <div className="bg-white min-h-screen">
      {/* Header Section */}
      <section className="bg-[#F0F8FF] pt-28 pb-16 lg:pt-36 lg:pb-24 border-b border-[#0C1B33]/5">
        <div className="max-w-360 mx-auto px-4 sm:px-6 lg:px-10">
          <div className="max-w-3xl">
            <h1 className="text-[38px] sm:text-[46px] lg:text-[52px] font-bold text-[#0C1B33] leading-[1.05] tracking-tight mb-4">
              How can we help you?
            </h1>
            <p className="text-[17.5px] text-[#0C1B33]/55 leading-[1.75]">
              Whether you have a question about features, pricing, or technical
              issues, our team is ready to answer all your questions.
            </p>
          </div>
        </div>
      </section>

      {/* Contact Options */}
      <section className="py-16 lg:py-24">
        <div className="max-w-360 mx-auto px-4 sm:px-6 lg:px-10">
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8 mb-16">
            {/* Technical Support */}
            <div className="p-8 rounded-2xl border border-[#0C1B33]/10 bg-white hover:shadow-xl hover:shadow-[#0C1B33]/5 transition-all group">
              <div className="w-12 h-12 bg-[#F0F8FF] rounded-xl flex items-center justify-center mb-6 group-hover:bg-[#0C1B33] transition-colors">
                <LifeBuoy className="w-6 h-6 text-[#0C1B33] group-hover:text-white transition-colors" />
              </div>
              <h3 className="text-[22px] font-bold text-[#0C1B33] mb-3">
                Technical Support
              </h3>
              <p className="text-[15.5px] text-[#0C1B33]/65 leading-[1.6] mb-6">
                Need help with the software? Our technical team is available to
                assist you with any platform-related queries.
              </p>
              <a
                href="mailto:moiz.codexlancers@gmail.com"
                className="inline-flex items-center gap-2 text-[15.5px] font-semibold text-[#0C1B33] hover:text-blue-600 transition-colors"
              >
                moiz.codexlancers@gmail.com
              </a>
            </div>

            {/* Sales Inquiries */}
            <div className="p-8 rounded-2xl border border-[#0C1B33]/10 bg-white hover:shadow-xl hover:shadow-[#0C1B33]/5 transition-all group">
              <div className="w-12 h-12 bg-[#F0F8FF] rounded-xl flex items-center justify-center mb-6 group-hover:bg-[#0C1B33] transition-colors">
                <Mail className="w-6 h-6 text-[#0C1B33] group-hover:text-white transition-colors" />
              </div>
              <h3 className="text-[22px] font-bold text-[#0C1B33] mb-3">
                Sales Inquiries
              </h3>
              <p className="text-[15.5px] text-[#0C1B33]/65 leading-[1.6] mb-6">
                Interested in our platform? Contact our sales team for pricing,
                custom plans, and product demonstrations.
              </p>
              <a
                href="mailto:moiz.codexlancers@gmail.com"
                className="inline-flex items-center gap-2 text-[15.5px] font-semibold text-[#0C1B33] hover:text-blue-600 transition-colors"
              >
                moiz.codexlancers@gmail.com
              </a>
            </div>

            {/* Phone Support */}
            <div className="p-8 rounded-2xl border border-[#0C1B33]/10 bg-white hover:shadow-xl hover:shadow-[#0C1B33]/5 transition-all group">
              <div className="w-12 h-12 bg-[#F0F8FF] rounded-xl flex items-center justify-center mb-6 group-hover:bg-[#0C1B33] transition-colors">
                <Phone className="w-6 h-6 text-[#0C1B33] group-hover:text-white transition-colors" />
              </div>
              <h3 className="text-[22px] font-bold text-[#0C1B33] mb-3">
                Phone Support
              </h3>
              <p className="text-[15.5px] text-[#0C1B33]/65 leading-[1.6] mb-6">
                Prefer speaking to someone directly? Call our helpline during
                business hours for immediate assistance.
              </p>
              <a
                href="tel:+919876543210"
                className="inline-flex items-center gap-2 text-[15.5px] font-semibold text-[#0C1B33] hover:text-blue-600 transition-colors"
              >
                +91 7405545576
              </a>
            </div>
          </div>

          {/* Contact Form & Office Address Section */}
          <div className="grid lg:grid-cols-[1fr_400px] gap-12 bg-[#F0F8FF] rounded-3xl p-8 lg:p-12">
            <div>
              <h2 className="text-[28px] font-bold text-[#0C1B33] mb-2">
                Send us a message
              </h2>
              <p className="text-[15.5px] text-[#0C1B33]/60 mb-8">
                We usually respond within 24 hours.
              </p>

              <SupportForm />
            </div>

            <div className="space-y-8 lg:border-l lg:border-[#0C1B33]/10 lg:pl-12">
              <div>
                <h3 className="text-[20px] font-bold text-[#0C1B33] mb-6 flex items-center gap-2">
                  <MapPin className="w-5 h-5 text-[#0C1B33]/60" />
                  Office Location
                </h3>
                <address className="not-italic text-[15.5px] text-[#0C1B33]/70 leading-[1.6]">
                  <strong>TransportPro Headquarters</strong>
                  <br />
                  5th Floor, Oppo Hills Nursery, A Landmark Building, Paliya St, Bhim Kachi Mohallo,
                  <br />
                  Nanpura, Surat, Gujarat 395001
                  <br />
                  India
                </address>
              </div>

              <div>
                <h3 className="text-[20px] font-bold text-[#0C1B33] mb-6 flex items-center gap-2">
                  <Clock className="w-5 h-5 text-[#0C1B33]/60" />
                  Business Hours
                </h3>
                <ul className="space-y-2 text-[15.5px] text-[#0C1B33]/70">
                  <li className="flex justify-between">
                    <span>Monday - Saturday:</span>
                    <span className="font-medium text-[#0C1B33]">
                      9:00 AM - 6:00 PM
                    </span>
                  </li>
                  <li className="flex justify-between">
                    <span>Sunday:</span>
                    <span className="font-medium text-[#0C1B33]">Closed</span>
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
