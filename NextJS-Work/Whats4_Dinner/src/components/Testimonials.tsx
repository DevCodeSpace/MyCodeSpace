const testimonials = [
  {
    name: "Marco R.",
    role: "Restaurant Owner, Sydney",
    avatar: "MR",
    avatarBg: "#FFF0F1",
    avatarColor: "#E63946",
    rating: 5,
    quote:
      "Empty Tuesday nights used to kill my revenue. With What's 4 Dinner flash deals I filled those slow shifts within hours. The QR redemption system is seamless — staff love it.",
    tag: "Flash Deals",
    tagBg: "#FFF0F1",
    tagColor: "#E63946",
  },
  {
    name: "Emma K.",
    role: "Restaurant Admin, Berlin",
    avatar: "EK",
    avatarBg: "#F0FAF0",
    avatarColor: "#7CB47A",
    rating: 5,
    quote:
      "Managing two branches used to mean spreadsheets everywhere. The multi-branch dashboard keeps everything in one place and staff QR permissions are a game changer.",
    tag: "Multi-Branch",
    tagBg: "#F0FAF0",
    tagColor: "#7CB47A",
  },
  {
    name: "Jake M.",
    role: "Customer, Melbourne",
    avatar: "JM",
    avatarBg: "#FFF9EC",
    avatarColor: "#F5A623",
    rating: 5,
    quote:
      "Found a 30% off deal at my favourite Thai place five minutes away. Claimed it, got a QR code, showed it at the door. No hassle at all. Will never use paper coupons again.",
    tag: "Deal Discovery",
    tagBg: "#FFF9EC",
    tagColor: "#F5A623",
  },
  {
    name: "David S.",
    role: "Restaurant Owner, Sydney",
    avatar: "DS",
    avatarBg: "#F5F5F5",
    avatarColor: "#4A5568",
    rating: 5,
    quote:
      "The analytics dashboard showed me that Wednesday flash deals had 3× the redemption rate of weekend ones. That insight alone changed how I plan promotions every week.",
    tag: "Analytics",
    tagBg: "#F5F5F5",
    tagColor: "#4A5568",
  },
  {
    name: "Lisa H.",
    role: "Customer, Hamburg",
    avatar: "LH",
    avatarBg: "#F0FAF0",
    avatarColor: "#7CB47A",
    rating: 5,
    quote:
      "I love the GPS deal discovery — it finds great offers near me instantly. The app is simple, the QR scan was instant at the restaurant. Completely changed how I eat out.",
    tag: "Nearby Deals",
    tagBg: "#F0FAF0",
    tagColor: "#7CB47A",
  },
  {
    name: "Sophie T.",
    role: "Customer, Berlin",
    avatar: "ST",
    avatarBg: "#FFF0F1",
    avatarColor: "#E63946",
    rating: 5,
    quote:
      "Discovered three restaurants I'd never heard of through the app. Claimed deals at all three in one week. What's 4 Dinner has completely changed how I discover great food.",
    tag: "Restaurant Discovery",
    tagBg: "#FFF0F1",
    tagColor: "#E63946",
  },
];

function StarRating({ count }: { count: number }) {
  return (
    <div className="flex items-center gap-0.5">
      {Array.from({ length: count }).map((_, i) => (
        <svg key={i} width="14" height="14" viewBox="0 0 24 24" fill="#FBBF24" aria-hidden="true">
          <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" />
        </svg>
      ))}
    </div>
  );
}

export default function Testimonials() {
  return (
    <section id="testimonials" className="bg-white py-16 sm:py-20 lg:py-24 overflow-hidden">
      <div className="max-w-screen-2xl mx-auto px-4 sm:px-6">

        {/* Section header */}
        <div className="max-w-2xl mb-10 sm:mb-12 lg:mb-16">
          <span className="inline-flex items-center gap-2 bg-[#FFF0F1] text-primary border border-[#FFD6D9] text-[11px] font-bold px-3.5 py-1.5 rounded-full tracking-widest uppercase mb-5 font-(family-name:--font-inter)">
            Customer Stories
          </span>
          <h2 className="text-[26px] sm:text-[36px] lg:text-[48px] font-extrabold text-primary-text tracking-[-1px] leading-[1.1] font-(family-name:--font-poppins)">
            Loved by restaurants{" "}
            <span className="text-primary">&amp; diners alike</span>
          </h2>
          <p className="mt-4 text-[15px] sm:text-[16px] text-slate-gray leading-relaxed font-(family-name:--font-inter)">
            Real stories from restaurant owners and customers who use What&apos;s 4 Dinner every day.
          </p>

          {/* Aggregate rating */}
          <div className="mt-6 inline-flex items-center gap-3 bg-[#FFFBEB] border border-[#FDE68A] rounded-full px-5 py-2.5">
            <StarRating count={5} />
            <span className="text-[14px] font-bold text-[#92400E] font-(family-name:--font-poppins)">4.8 / 5</span>
            <span className="text-[13px] text-[#B45309] font-(family-name:--font-inter)">from 2,400+ reviews</span>
          </div>
        </div>

        {/* Testimonial grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5 sm:gap-6">
          {testimonials.map(({ name, role, avatar, avatarBg, avatarColor, rating, quote, tag, tagBg, tagColor }) => (
            <div
              key={name}
              className="group relative flex flex-col gap-5 rounded-2xl border border-[#EFEFEF] bg-white p-6 shadow-[0_2px_12px_rgba(0,0,0,0.04)] hover:shadow-[0_8px_32px_rgba(0,0,0,0.08)] hover:-translate-y-1 transition-all duration-200"
            >
              {/* Quote mark */}
              <svg width="28" height="28" viewBox="0 0 32 32" fill="none" aria-hidden="true" className="shrink-0 opacity-15">
                <path d="M9.333 20c0-3.682 2.985-6.667 6.667-6.667V10c-5.523 0-10 4.477-10 10v2h3.333V20zm13.334 0c0-3.682 2.986-6.667 6.666-6.667V10c-5.522 0-10 4.477-10 10v2h3.334V20z" fill="#E63946" />
              </svg>

              {/* Quote text */}
              <p className="text-[13.5px] text-slate-gray leading-relaxed flex-1 font-(family-name:--font-inter)">
                &ldquo;{quote}&rdquo;
              </p>

              {/* Divider */}
              <div className="h-px bg-[#F3F4F6]" />

              {/* Footer: avatar + name + rating */}
              <div className="flex items-center justify-between gap-3">
                <div className="flex items-center gap-3">
                  <div
                    className="w-9 h-9 rounded-full flex items-center justify-center text-[12px] font-black shrink-0"
                    style={{ backgroundColor: avatarBg, color: avatarColor }}
                  >
                    {avatar}
                  </div>
                  <div>
                    <p className="text-[13.5px] font-bold text-primary-text leading-tight font-(family-name:--font-poppins)">{name}</p>
                    <p className="text-[11.5px] text-slate-gray leading-tight font-(family-name:--font-inter)">{role}</p>
                  </div>
                </div>
                <StarRating count={rating} />
              </div>

              {/* Tag */}
              <span
                className="self-start text-[11px] font-bold px-2.5 py-1 rounded-full tracking-wide font-(family-name:--font-inter)"
                style={{ backgroundColor: tagBg, color: tagColor }}
              >
                {tag}
              </span>

              {/* Bottom accent on hover */}
              <div
                className="absolute bottom-0 left-6 right-6 h-0.5 rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-200"
                style={{ backgroundColor: tagColor }}
              />
            </div>
          ))}
        </div>

        {/* Bottom CTA */}
        <div className="mt-10 sm:mt-14 lg:mt-16 flex flex-col sm:flex-row items-center justify-center gap-4">
          <a
            href="#contact"
            className="inline-flex items-center gap-2 bg-primary hover:bg-primary-dark text-white text-[15px] font-bold px-8 py-4 rounded-full transition-colors duration-150 shadow-[0_4px_20px_rgba(230,57,70,0.28)] font-(family-name:--font-poppins)"
          >
            Get Started Free
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" aria-hidden="true">
              <path d="M5 12h14M13 6l6 6-6 6" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round" />
            </svg>
          </a>
          <a
            href="#features"
            className="inline-flex items-center gap-2 bg-white border border-[#E8E8E8] hover:border-[#D0D0D0] text-primary-text text-[15px] font-bold px-8 py-4 rounded-full transition-colors duration-150 font-(family-name:--font-poppins)"
          >
            Explore Features
          </a>
        </div>

      </div>
    </section>
  );
}
