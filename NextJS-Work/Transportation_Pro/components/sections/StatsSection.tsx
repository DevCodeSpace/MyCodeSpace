import { Star } from "lucide-react";

const testimonials = [
  {
    quote:
      "Before TransportPro, we were managing everything on paper and Excel. Now our loading, billing, and reports are done in minutes. The Taka & Bale tracking alone saved us hours every day.",
    name: "Rajesh Patel",
    role: "Owner",
    company: "Patel Transport Co.",
    location: "Surat, Gujarat",
    initials: "RP",
    rating: 5,
  },
  {
    quote:
      "The freight auto-calculation is a game changer. We handle 50+ shipments daily and the system has not made a single billing error. Financial reports are clean, GST-ready, and ready in one click.",
    name: "Suresh Mehta",
    role: "Operations Manager",
    company: "Mehta Logistics Pvt. Ltd.",
    location: "Ahmedabad, Gujarat",
    initials: "SM",
    rating: 5,
  },
  {
    quote:
      "We tried two other platforms before this. Neither understood transport the way TransportPro does. The delivery workflow and print engine alone are worth it for any serious logistics business.",
    name: "Ankit Shah",
    role: "Director",
    company: "Shah Freight Services",
    location: "Vadodara, Gujarat",
    initials: "AS",
    rating: 5,
  },
  {
    quote:
      "The real-time stock dashboard gives us visibility we never had before. We know exactly what's in transit, what's delivered, and what's pending  all from one screen.",
    name: "Dinesh Kumar",
    role: "Fleet Manager",
    company: "Kumar & Sons Transport",
    location: "Rajkot, Gujarat",
    initials: "DK",
    rating: 5,
  },
  {
    quote:
      "Setting up was incredibly fast. We were fully operational within a day. The admin control panel makes it easy to manage our team, parties, and access levels without any technical help.",
    name: "Priya Sharma",
    role: "Admin Head",
    company: "Sharma Carriers",
    location: "Mumbai, Maharashtra",
    initials: "PS",
    rating: 5,
  },
  {
    quote:
      "Multi-payment support  Cash, Cheque, RTGS, and Credit  all tracked perfectly. Our accounts team loves the commission and bill detail reports. No more month-end chaos.",
    name: "Vikram Joshi",
    role: "CEO",
    company: "Joshi Express Logistics",
    location: "Pune, Maharashtra",
    initials: "VJ",
    rating: 5,
  },
];

const trustBadges = [
  "500+ Shipments Managed Daily",
  "GST-Ready Platform",
  "Textile Logistics Specialists",
  "Zero Billing Errors",
];

export default function StatsSection() {
  return (
    <section
      id="testimonials"
      className="bg-white py-20 lg:py-28"
      aria-labelledby="testimonials-heading"
    >
      <div className="max-w-360 mx-auto px-4 sm:px-6 lg:px-10">
        {/* Header */}
        <div className="flex flex-col lg:flex-row lg:items-end lg:justify-between gap-6 mb-14">
          <div className="max-w-xl">
            <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-[#F0F8FF] border border-[#0C1B33]/10 mb-5">
              <span
                className="w-1.5 h-1.5 rounded-full bg-[#0C1B33]"
                aria-hidden="true"
              />
              <span className="text-[13px] font-semibold text-[#0C1B33]/60 tracking-widest uppercase">
                Client Stories
              </span>
            </div>
            <h2
              id="testimonials-heading"
              className="text-[42px] sm:text-[48px] font-bold text-[#0C1B33] leading-[1.1] tracking-tight"
            >
              Trusted by Transport
              <br />
              Businesses Across India
            </h2>
          </div>

          {/* Aggregate rating */}
          <div
            className="flex items-center gap-5 shrink-0"
            aria-label="Overall rating: 4.9 out of 5 from 200+ clients"
          >
            <div className="text-center">
              <p
                className="text-[48px] font-bold text-[#0C1B33] leading-none"
                aria-hidden="true"
              >
                4.9
              </p>
              <div
                className="flex gap-0.5 justify-center mt-1.5"
                aria-hidden="true"
              >
                {[...Array(5)].map((_, i) => (
                  <Star
                    key={i}
                    className="w-4 h-4 fill-amber-400 text-amber-400"
                  />
                ))}
              </div>
              <p className="text-[12px] text-[#0C1B33]/40 font-medium mt-1">
                Average Rating
              </p>
            </div>
            <div className="w-px h-16 bg-[#0C1B33]/8" aria-hidden="true" />
            <div className="text-center">
              <p
                className="text-[48px] font-bold text-[#0C1B33] leading-none"
                aria-hidden="true"
              >
                200+
              </p>
              <p className="text-[12px] text-[#0C1B33]/40 font-medium mt-2.5">
                Happy Clients
              </p>
            </div>
          </div>
        </div>

        {/* Testimonial cards  semantic figure/blockquote/cite */}
        <ul className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5 list-none p-0 m-0">
          {testimonials.map(
            ({ quote, name, role, company, location, initials, rating }) => (
              <li key={name}>
                <figure className="group flex flex-col justify-between gap-5 p-6 rounded-2xl bg-[#F0F8FF] border border-[#0C1B33]/6 hover:border-[#0C1B33]/18 hover:shadow-lg hover:shadow-[#0C1B33]/5 hover:-translate-y-0.5 transition-all duration-200 h-full">
                  {/* Top */}
                  <div className="flex flex-col gap-4">
                    <div className="flex items-center justify-between">
                      <div
                        className="w-9 h-9 rounded-xl bg-[#0C1B33]/6 flex items-center justify-center"
                        aria-hidden="true"
                      >
                        <svg
                          className="w-4 h-4 text-[#0C1B33]/40"
                          viewBox="0 0 24 24"
                          fill="currentColor"
                        >
                          <path d="M14.017 21v-7.391c0-5.704 3.731-9.57 8.983-10.609l.995 2.151c-2.432.917-3.995 3.638-3.995 5.849h4v10h-9.983zm-14.017 0v-7.391c0-5.704 3.748-9.57 9-10.609l.996 2.151c-2.433.917-3.996 3.638-3.996 5.849h3.983v10h-9.983z" />
                        </svg>
                      </div>
                      <div
                        className="flex gap-0.5"
                        aria-label={`${rating} out of 5 stars`}
                      >
                        {[...Array(rating)].map((_, i) => (
                          <Star
                            key={i}
                            className="w-3.5 h-3.5 fill-amber-400 text-amber-400"
                            aria-hidden="true"
                          />
                        ))}
                      </div>
                    </div>

                    <blockquote>
                      <p className="text-[15px] text-[#0C1B33]/65 leading-relaxed">
                        &ldquo;{quote}&rdquo;
                      </p>
                    </blockquote>
                  </div>

                  {/* Author */}
                  <figcaption className="flex items-center gap-3 pt-4 border-t border-[#0C1B33]/6">
                    <div
                      className="w-10 h-10 rounded-full bg-[#0C1B33] flex items-center justify-center shrink-0"
                      aria-hidden="true"
                    >
                      <span className="text-[12px] font-bold text-white">
                        {initials}
                      </span>
                    </div>
                    <div className="min-w-0">
                      <cite className="not-italic text-[14.5px] font-semibold text-[#0C1B33] truncate block">
                        {name}
                      </cite>
                      <p className="text-[13.5px] text-[#0C1B33]/45 truncate">
                        {role} · {company}
                      </p>
                      <p className="text-[12.5px] text-[#0C1B33]/30 font-medium mt-0.5">
                        {location}
                      </p>
                    </div>
                  </figcaption>
                </figure>
              </li>
            ),
          )}
        </ul>

        {/* Trust badges */}
        <div
          className="mt-12 flex flex-wrap items-center justify-center gap-x-10 gap-y-3"
          role="list"
          aria-label="Platform trust signals"
        >
          {trustBadges.map((item) => (
            <div key={item} className="flex items-center gap-2" role="listitem">
              <span
                className="w-1.5 h-1.5 rounded-full bg-[#0C1B33]/30"
                aria-hidden="true"
              />
              <span className="text-[13px] font-medium text-[#0C1B33]/45">
                {item}
              </span>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
