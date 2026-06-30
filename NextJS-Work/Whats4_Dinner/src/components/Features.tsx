const features = [
  {
    icon: (
      <img
        src="/flash.svg"
        width={22}
        height={22}
        alt=""
        aria-hidden="true"
        style={{
          filter:
            "brightness(0) saturate(100%) invert(27%) sepia(99%) saturate(1500%) hue-rotate(338deg) brightness(104%) contrast(91%)",
        }}
      />
    ),
    bg: "#FFF0F1",
    accent: "#E63946",
    title: "Flash & Weekly Deals",
    desc: "Create time-limited flash deals or recurring weekly offers. Set caps, schedules and manage everything from a single dashboard.",
    tags: ["CRUD Operations", "Flexible Scheduling", "Dialog Flows"],
  },
  {
    icon: (
      <img
        src="/role.svg"
        width={22}
        height={22}
        alt=""
        aria-hidden="true"
        style={{
          filter:
            "brightness(0) saturate(100%) invert(71%) sepia(18%) saturate(563%) hue-rotate(69deg) brightness(89%) contrast(87%)",
        }}
      />
    ),
    bg: "#F0FAF0",
    accent: "#7CB47A",
    title: "Role-Based Dashboards",
    desc: "Separate, purpose-built views for Super Admin and Restaurant Admin. Access gated by role so every user sees exactly what they need.",
    tags: ["Super Admin", "Restaurant Admin", "Role-Gated Routing"],
  },
  {
    icon: (
      <img
        src="/qrcode.svg"
        width={22}
        height={22}
        alt=""
        aria-hidden="true"
        style={{
          filter:
            "brightness(0) saturate(100%) invert(69%) sepia(74%) saturate(1318%) hue-rotate(357deg) brightness(101%) contrast(92%)",
        }}
      />
    ),
    bg: "#FFF9EC",
    accent: "#F5A623",
    title: "QR Code Redemption",
    desc: "Every claimed deal generates a unique QR code. Staff scan in-venue for verified, trackable redemptions with full scan history.",
    tags: ["Unique QR per Deal", "In-Venue Scanning", "Secure Tracking"],
  },
  {
    icon: (
      <img
        src="/analytics.svg"
        width={22}
        height={22}
        alt=""
        aria-hidden="true"
        style={{
          filter:
            "brightness(0) saturate(100%) invert(33%) sepia(11%) saturate(1046%) hue-rotate(176deg) brightness(93%) contrast(87%)",
        }}
      />
    ),
    bg: "#F5F5F5",
    accent: "#4A5568",
    title: "Analytics & KPI Charts",
    desc: "Track key performance indicators, monthly registrations, weekly approvals and deal engagement trends with visual charts.",
    tags: ["KPI Stats", "Trend Charts", "Custom Date Range"],
  },
  {
    icon: (
      <img
        src="/staff.svg"
        width={22}
        height={22}
        alt=""
        aria-hidden="true"
        style={{
          filter:
            "brightness(0) saturate(100%) invert(13%) sepia(91%) saturate(3691%) hue-rotate(347deg) brightness(86%) contrast(95%)",
        }}
      />
    ),
    bg: "#FFF0F1",
    accent: "#A1131D",
    title: "Staff Management",
    desc: "Add, edit and remove team members with international phone support. Assign specific roles and permissions to each staff member.",
    tags: ["Add / Edit / Delete", "Role Assignment", "International Support"],
  },
  {
    icon: (
      <img
        src="/notification.svg"
        width={22}
        height={22}
        alt=""
        aria-hidden="true"
        style={{
          filter:
            "brightness(0) saturate(100%) invert(71%) sepia(18%) saturate(563%) hue-rotate(69deg) brightness(89%) contrast(87%)",
        }}
      />
    ),
    bg: "#F0FAF0",
    accent: "#7CB47A",
    title: "Notifications Panel",
    desc: "Tabbed view for All, Unread, Claim and Redeem alerts. Paginated for large lists with real-time updates so nothing is missed.",
    tags: ["Tabbed View", "Real-Time Alerts", "Pagination"],
  },
  {
    icon: (
      <img
        src="/excel.svg"
        width={22}
        height={22}
        alt=""
        aria-hidden="true"
        style={{
          filter:
            "brightness(0) saturate(100%) invert(69%) sepia(74%) saturate(1318%) hue-rotate(357deg) brightness(101%) contrast(92%)",
        }}
      />
    ),
    bg: "#FFF9EC",
    accent: "#F5A623",
    title: "Excel Data Export",
    desc: "Download dashboard metrics, deal data and redemption records as Excel files for offline reporting and easy sharing.",
    tags: ["Export Dashboards", "Deal Data", "Redemption Records"],
  },
  {
    icon: (
      <img
        src="/restaurant.svg"
        width={22}
        height={22}
        alt=""
        aria-hidden="true"
        style={{
          filter:
            "brightness(0) saturate(100%) invert(33%) sepia(11%) saturate(1046%) hue-rotate(176deg) brightness(93%) contrast(87%)",
        }}
      />
    ),
    bg: "#F5F5F5",
    accent: "#4A5568",
    title: "Restaurant Approval",
    desc: "Super Admins approve or reject restaurant requests with reason tracking. Activate or deactivate restaurants with full status control.",
    tags: ["Approve / Reject", "Reason Tracking", "Status Control"],
  },
];

export default function Features() {
  return (
    <section id="features" className="bg-white py-16 sm:py-20 lg:py-24">
      <div className="max-w-screen-2xl mx-auto px-4 sm:px-6">
        {/* Section header */}
        <div className="max-w-2xl mb-10 sm:mb-12 lg:mb-16">
          <span className="inline-flex items-center gap-2 bg-[#FFF0F1] text-primary border border-[#FFD6D9] text-[11px] font-bold px-3.5 py-1.5 rounded-full tracking-widest uppercase mb-5 font-(family-name:--font-inter)">
            {/* <svg width="10" height="10" viewBox="0 0 24 24" fill="none" aria-hidden="true">
              <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" fill="#E63946" />
            </svg> */}
            Platform Features
          </span>
          <h2 className="text-[26px] sm:text-[36px] lg:text-[48px] font-extrabold text-primary-text tracking-[-1px] leading-[1.1] font-(family-name:--font-poppins)">
            Everything you need to run{" "}
            <span className="text-primary">restaurant deals</span>
          </h2>
          <p className="mt-4 text-[15px] sm:text-[16px] text-slate-gray leading-relaxed font-(family-name:--font-inter)">
            From deal creation to redemption tracking What&apos;s 4 Dinner gives
            Super Admins and Restaurant Admins a complete toolkit, with no
            complexity.
          </p>
        </div>

        {/* Feature grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
          {features.map(({ icon, bg, accent, title, desc, tags }) => (
            <div
              key={title}
              className="group flex flex-col gap-5 rounded-2xl border border-[#EFEFEF] bg-white p-6 hover:shadow-[0_8px_32px_rgba(0,0,0,0.08)] hover:-translate-y-1 transition-all duration-200"
            >
              {/* Icon */}
              <div
                className="w-11 h-11 rounded-xl flex items-center justify-center shrink-0"
                style={{ backgroundColor: bg }}
              >
                {icon}
              </div>

              {/* Title + desc */}
              <div className="flex flex-col gap-2">
                <h3 className="text-[15.5px] font-bold text-primary-text leading-snug font-(family-name:--font-poppins)">
                  {title}
                </h3>
                <p className="text-[13px] text-slate-gray leading-relaxed font-(family-name:--font-inter)">
                  {desc}
                </p>
              </div>

              {/* Tags */}
              <div className="flex flex-wrap gap-1.5 mt-auto">
                {tags.map((tag) => (
                  <span
                    key={tag}
                    className="text-[11px] font-semibold px-2.5 py-1 rounded-full border border-[#EFEFEF] text-slate-gray font-(family-name:--font-inter)"
                  >
                    {tag}
                  </span>
                ))}
              </div>

              {/* Accent bottom bar on hover */}
              {/* <div
                className="h-0.5 rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-200 -mx-6 -mb-6 mt-1"
                style={{ backgroundColor: accent }}
              /> */}
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
