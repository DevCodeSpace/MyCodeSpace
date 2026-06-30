const testimonials = [
  {
    name: "Priya Sharma",
    role: "Working Mother, Mumbai",
    avatar: "PS",
    avatarBg: "#EEF2FF",
    avatarColor: "#003DF5",
    rating: 5,
    quote:
      "I booked a paediatrician for my son in literally 45 seconds. No hold music, no forms just typed his symptoms and CareBot found the right doctor with an open slot. Absolutely brilliant.",
    tag: "Paediatrics",
    tagBg: "#EEF2FF",
    tagColor: "#003DF5",
  },
  {
    name: "Rahul Mehta",
    role: "Software Engineer, Bengaluru",
    avatar: "RM",
    avatarBg: "#E0F7FF",
    avatarColor: "#0096DE",
    rating: 5,
    quote:
      "I've tried three different hospital apps. All of them made me create accounts, verify OTPs, and still gave me wrong availability. CareBot AI just worked real-time slots, instant confirmation.",
    tag: "Orthopaedics",
    tagBg: "#E0F7FF",
    tagColor: "#0096DE",
  },
  {
    name: "Ananya Iyer",
    role: "College Student, Chennai",
    avatar: "AI",
    avatarBg: "#F0FDF4",
    avatarColor: "#16A34A",
    rating: 5,
    quote:
      "The chat felt like talking to a knowledgeable friend. It asked the right questions, matched me to a dermatologist near my campus, and I had a booking summary ready to show my parents in under a minute.",
    tag: "Dermatology",
    tagBg: "#F0FDF4",
    tagColor: "#16A34A",
  },
  {
    name: "Suresh Nair",
    role: "Retired Teacher, Kochi",
    avatar: "SN",
    avatarBg: "#FAF5FF",
    avatarColor: "#9333EA",
    rating: 5,
    quote:
      "I'm not great with technology but this was so simple. I described my chest discomfort, it recommended a cardiologist, showed me fees upfront, and gave me directions to the clinic. My son was impressed.",
    tag: "Cardiology",
    tagBg: "#FAF5FF",
    tagColor: "#9333EA",
  },
  {
    name: "Deepika Rao",
    role: "Freelance Designer, Hyderabad",
    avatar: "DR",
    avatarBg: "#FFF7ED",
    avatarColor: "#EA580C",
    rating: 5,
    quote:
      "The PDF summary feature is underrated. I downloaded my appointment details and shared it with my family immediately. Everything was there octor, hospital, time, fees. Zero back-and-forth.",
    tag: "General Medicine",
    tagBg: "#FFF7ED",
    tagColor: "#EA580C",
  },
  {
    name: "Vikram Joshi",
    role: "Business Owner, Pune",
    avatar: "VJ",
    avatarBg: "#FFF1F2",
    avatarColor: "#E11D48",
    rating: 5,
    quote:
      "My time is valuable. CareBot AI respects that. I went from 'my back hurts' to a confirmed appointment with an orthopaedic surgeon all while having my morning coffee. This is what healthcare should feel like.",
    tag: "Orthopaedics",
    tagBg: "#FFF1F2",
    tagColor: "#E11D48",
  },
];

function StarRating({ count }: { count: number }) {
  return (
    <div className="flex items-center gap-0.5">
      {Array.from({ length: count }).map((_, i) => (
        <svg
          key={i}
          width="14"
          height="14"
          viewBox="0 0 24 24"
          fill="#FBBF24"
          aria-hidden="true"
        >
          <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" />
        </svg>
      ))}
    </div>
  );
}

export default function Testimonials() {
  return (
    <section id="testimonials" className="bg-white py-16 lg:py-24 overflow-hidden">
      <div className="max-w-screen-2xl mx-auto px-4 sm:px-6">
        {/* Section header */}
        <div className="text-center mb-10 lg:mb-16">
          <span className="inline-flex items-center gap-2 bg-[#EEF2FF] text-[#003DF5] text-[11px] font-bold px-4 py-2 rounded-full tracking-widest uppercase mb-5">
            {/* <svg
              width="12"
              height="12"
              viewBox="0 0 24 24"
              fill="none"
              aria-hidden="true"
            >
              <path
                d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"
                fill="#003DF5"
              />
            </svg> */}
            Patient Stories
          </span>
          <h2 className="text-[26px] sm:text-[34px] lg:text-[48px] font-extrabold text-[#0D1B4B] tracking-[-0.5px] sm:tracking-[-1px] leading-[1.1]">
            Loved by <span className="text-[#003DF5]">10,000+ Patients</span>
            <br className="hidden sm:block" /> Across India
          </h2>
          <p className="mt-4 text-[16px] text-[#6B7280] max-w-135 mx-auto leading-relaxed">
            Real stories from patients who ditched the waiting room queue and
            booked smarter with CareBot AI.
          </p>

          {/* Aggregate rating */}
          <div className="mt-6 inline-flex flex-wrap justify-center items-center gap-2 sm:gap-3 bg-[#FFFBEB] border border-[#FDE68A] rounded-full px-4 sm:px-5 py-2.5">
            <StarRating count={5} />
            <span className="text-[14px] font-bold text-[#92400E]">
              4.9 / 5
            </span>
            <span className="text-[13px] text-[#B45309]">
              from 2,400+ reviews
            </span>
          </div>
        </div>

        {/* Testimonial grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {testimonials.map(
            ({
              name,
              role,
              avatar,
              avatarBg,
              avatarColor,
              rating,
              quote,
              tag,
              tagBg,
              tagColor,
            }) => (
              <div
                key={name}
                className="group relative flex flex-col gap-5 rounded-2xl border border-[#E8EDF5] bg-white p-7 shadow-[0_2px_12px_rgba(0,0,0,0.05)] hover:shadow-[0_8px_32px_rgba(0,0,0,0.10)] hover:-translate-y-1 transition-all duration-200"
              >
                {/* Quote mark */}
                <svg
                  width="32"
                  height="32"
                  viewBox="0 0 32 32"
                  fill="none"
                  aria-hidden="true"
                  className="shrink-0 opacity-20"
                >
                  <path
                    d="M9.333 20c0-3.682 2.985-6.667 6.667-6.667V10c-5.523 0-10 4.477-10 10v2h3.333V20zm13.334 0c0-3.682 2.986-6.667 6.666-6.667V10c-5.522 0-10 4.477-10 10v2h3.334V20z"
                    fill="#003DF5"
                  />
                </svg>

                {/* Quote text */}
                <p className="text-[14px] text-[#374151] leading-relaxed flex-1">
                  "{quote}"
                </p>

                {/* Divider */}
                <div className="h-px bg-[#F3F4F6]" />

                {/* Footer: avatar + name + rating */}
                <div className="flex items-center justify-between gap-3">
                  <div className="flex items-center gap-3">
                    {/* Avatar initials */}
                    <div
                      className="w-10 h-10 rounded-full flex items-center justify-center text-[13px] font-black shrink-0"
                      style={{ backgroundColor: avatarBg, color: avatarColor }}
                    >
                      {avatar}
                    </div>
                    <div>
                      <p className="text-[14px] font-bold text-[#0D1B4B] leading-tight">
                        {name}
                      </p>
                      <p className="text-[12px] text-[#9CA3AF] leading-tight">
                        {role}
                      </p>
                    </div>
                  </div>
                  <StarRating count={rating} />
                </div>

                {/* Specialty tag */}
                <span
                  className="self-start text-[11px] font-bold px-3 py-1 rounded-full tracking-wide"
                  style={{ backgroundColor: tagBg, color: tagColor }}
                >
                  {tag}
                </span>

                {/* Bottom accent on hover */}
                {/* <div
                  className="absolute bottom-0 left-6 right-6 h-0.5 rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-200"
                  style={{ backgroundColor: tagColor }}
                /> */}
              </div>
            ),
          )}
        </div>

        {/* Bottom CTA */}
        <div className="mt-10 lg:mt-16 text-center">
          <p className="text-[15px] text-[#6B7280] mb-5">
            Join thousands of patients already booking smarter.
          </p>
          <a
            href="#contact"
            className="inline-flex items-center gap-2 bg-[#003DF5] hover:bg-[#0030CC] text-white text-[15px] font-bold px-8 py-4 rounded-full transition-colors duration-200 shadow-[0_4px_20px_rgba(0,61,245,0.28)]"
          >
            Get Started Free
            <svg
              width="16"
              height="16"
              viewBox="0 0 24 24"
              fill="none"
              aria-hidden="true"
            >
              <path
                d="M5 12h14M13 6l6 6-6 6"
                stroke="currentColor"
                strokeWidth="2.2"
                strokeLinecap="round"
                strokeLinejoin="round"
              />
            </svg>
          </a>
        </div>
      </div>
    </section>
  );
}
