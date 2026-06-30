import { CheckCircle, LayoutDashboard } from "lucide-react";

const featureList = [
  {
    label: "Dispatch Management",
    detail: "Assign trips, manage routes and truck schedules",
  },
  {
    label: "GST Invoice & Billing",
    detail: "Auto-generate GST invoices in minutes",
  },
  {
    label: "Real-time Tracking",
    detail: "Live status of shipments and deliveries",
  },
  {
    label: "Driver & Fleet Management",
    detail: "Profiles, documents, and performance tracking",
  },
  {
    label: "Payment & Ledger",
    detail: "Track dues, Cash, Cheque, RTGS  zero confusion",
  },
  {
    label: "Reports & Analytics",
    detail: "Daily, monthly, and party-wise business reports",
  },
];

export default function AboutSection() {
  return (
    <section
      id="about"
      className="py-24 bg-white overflow-hidden border-b border-gray-100"
      aria-labelledby="about-heading"
    >
      <div className="max-w-360 mx-auto px-4 sm:px-6 lg:px-10">
        <div className="grid lg:grid-cols-2 gap-16 items-center">
          {/* Left  content */}
          <div>
            <div className="inline-flex items-center gap-2 rounded-full border border-[#0C1B33]/15 bg-[#0C1B33]/5 px-4 py-1.5 text-sm font-semibold text-[#0C1B33]/70 mb-6">
              <LayoutDashboard className="w-4 h-4" aria-hidden="true" />
              <span>What is TransportPro?</span>
            </div>

            <h2
              id="about-heading"
              className="text-3xl sm:text-4xl font-bold text-[#0C1B33] leading-[1.2] tracking-tight mb-6"
            >
              All-in-One{" "}
              <span className="text-[#0C1B33]/50">Transport Management</span>
              <br />
              Software for India
            </h2>

            <p className="text-[#0C1B33]/55 leading-relaxed mb-4 text-[16px]">
              TransportPro is a{" "}
              <strong className="text-[#0C1B33]/80">
                purpose-built transport management platform
              </strong>{" "}
              that digitalizes your entire logistics operation from shipment
              loading and freight billing to delivery tracking and financial
              reporting.
            </p>
            <p className="text-[#0C1B33]/55 leading-relaxed mb-8 text-[16px]">
              Manage your full fleet, all parties, and every account from a
              single dashboard. No large investment, no technical expertise
              required your team is operational from day one.
            </p>

            {/* Highlight box */}
            <div className="flex items-center gap-3 p-4 rounded-xl mb-8 border border-[#0C1B33]/10 bg-[#F0F8FF]">
              <CheckCircle
                className="w-5 h-5 text-[#0C1B33] shrink-0"
                aria-hidden="true"
              />
              <p className="text-[#0C1B33]/80 font-semibold text-[15px]">
                Built for transport businesses across Surat, Gujarat, and
                pan-India
              </p>
            </div>

            {/* Feature checklist */}
            <ul
              className="grid grid-cols-1 sm:grid-cols-2 gap-3 list-none p-0 m-0"
              aria-label="Platform capabilities"
            >
              {featureList.map((f) => (
                <li
                  key={f.label}
                  className="flex items-start gap-2.5 p-3 bg-white rounded-xl border border-[#0C1B33]/8 shadow-sm"
                >
                  <CheckCircle
                    className="w-4 h-4 text-[#0C1B33] shrink-0 mt-0.5"
                    aria-hidden="true"
                  />
                  <div>
                    <p className="text-[13px] font-bold text-[#0C1B33]">
                      {f.label}
                    </p>
                    <p className="text-[11px] text-[#0C1B33]/40 mt-0.5">
                      {f.detail}
                    </p>
                  </div>
                </li>
              ))}
            </ul>
          </div>

          {/* Right  dashboard illustration */}
          <div className="relative">
            <div
              className="rounded-2xl overflow-hidden shadow-lg border border-[#0C1B33]/10"
              style={{ aspectRatio: "4/3" }}
              role="img"
              aria-label="TransportPro dashboard showing shipment tracking, trip management, and real-time analytics"
            >
              <div className="absolute inset-0 bg-[#0C1C35]">
                <svg
                  className="absolute inset-0 w-full h-full"
                  viewBox="0 0 500 375"
                  preserveAspectRatio="xMidYMid slice"
                  aria-hidden="true"
                >
                  <rect x="0" y="0" width="500" height="375" fill="#0C1C35" />
                  <rect x="0" y="0" width="80" height="375" fill="#0C1C35" />
                  {[40, 80, 120, 160, 200, 240].map((y, i) => (
                    <g key={i}>
                      <rect
                        x="20"
                        y={y}
                        width="40"
                        height="30"
                        rx="6"
                        fill={i === 0 ? "#0C1B33" : "#ffffff10"}
                      />
                      <rect
                        x="30"
                        y={y + 8}
                        width="20"
                        height="3"
                        rx="1.5"
                        fill={i === 0 ? "white" : "#ffffff50"}
                      />
                      <rect
                        x="30"
                        y={y + 15}
                        width="14"
                        height="3"
                        rx="1.5"
                        fill={i === 0 ? "white" : "#ffffff30"}
                      />
                    </g>
                  ))}
                  <rect x="80" y="0" width="420" height="40" fill="#0f2540" />
                  <rect
                    x="95"
                    y="12"
                    width="120"
                    height="16"
                    rx="8"
                    fill="#ffffff10"
                  />
                  <rect
                    x="100"
                    y="17"
                    width="80"
                    height="6"
                    rx="3"
                    fill="#ffffff20"
                  />
                  <circle
                    cx="445"
                    cy="20"
                    r="12"
                    fill="#0C1B33"
                    opacity="0.8"
                  />
                  <circle cx="465" cy="20" r="12" fill="#ffffff10" />
                  {[
                    {
                      x: 95,
                      color: "#0C1B33",
                      label: "Trips Today",
                      val: "24",
                    },
                    {
                      x: 210,
                      color: "#0C1B33",
                      label: "Revenue",
                      val: "₹1.2L",
                    },
                    {
                      x: 325,
                      color: "#0C1B33",
                      label: "Active Fleet",
                      val: "18",
                    },
                  ].map((card) => (
                    <g key={card.label}>
                      <rect
                        x={card.x}
                        y="55"
                        width="100"
                        height="65"
                        rx="8"
                        fill="#ffffff08"
                        stroke="#ffffff10"
                        strokeWidth="1"
                      />
                      <rect
                        x={card.x + 8}
                        y="63"
                        width="30"
                        height="20"
                        rx="4"
                        fill={card.color}
                        opacity="0.3"
                      />
                      <rect
                        x={card.x + 10}
                        y="68"
                        width="20"
                        height="4"
                        rx="2"
                        fill={card.color}
                        opacity="0.8"
                      />
                      <rect
                        x={card.x + 10}
                        y="75"
                        width="14"
                        height="3"
                        rx="1.5"
                        fill={card.color}
                        opacity="0.5"
                      />
                      <text
                        x={card.x + 10}
                        y="100"
                        fill="white"
                        fontSize="16"
                        fontWeight="bold"
                        opacity="0.9"
                      >
                        {card.val}
                      </text>
                      <text x={card.x + 10} y="112" fill="#94a3b8" fontSize="7">
                        {card.label}
                      </text>
                    </g>
                  ))}
                  <rect
                    x="95"
                    y="135"
                    width="330"
                    height="200"
                    rx="8"
                    fill="#ffffff06"
                    stroke="#ffffff08"
                    strokeWidth="1"
                  />
                  <rect
                    x="95"
                    y="135"
                    width="330"
                    height="28"
                    rx="8"
                    fill="#ffffff10"
                  />
                  <text
                    x="110"
                    y="153"
                    fill="#94a3b8"
                    fontSize="8"
                    fontWeight="bold"
                  >
                    TRIP ID
                  </text>
                  <text
                    x="190"
                    y="153"
                    fill="#94a3b8"
                    fontSize="8"
                    fontWeight="bold"
                  >
                    DRIVER
                  </text>
                  <text
                    x="270"
                    y="153"
                    fill="#94a3b8"
                    fontSize="8"
                    fontWeight="bold"
                  >
                    ROUTE
                  </text>
                  <text
                    x="360"
                    y="153"
                    fill="#94a3b8"
                    fontSize="8"
                    fontWeight="bold"
                  >
                    STATUS
                  </text>
                  {[
                    {
                      id: "#T-1024",
                      driver: "Ramu B.",
                      route: "SRT→MUM",
                      status: "Active",
                      color: "#0C1B33",
                    },
                    {
                      id: "#T-1023",
                      driver: "Suresh K.",
                      route: "SRT→DEL",
                      status: "Transit",
                      color: "#334155",
                    },
                    {
                      id: "#T-1022",
                      driver: "Mohan L.",
                      route: "SRT→HYD",
                      status: "Delivered",
                      color: "#334155",
                    },
                    {
                      id: "#T-1021",
                      driver: "Arun P.",
                      route: "SRT→PUN",
                      status: "Active",
                      color: "#0C1B33",
                    },
                    {
                      id: "#T-1020",
                      driver: "Vijay R.",
                      route: "SRT→CHE",
                      status: "Transit",
                      color: "#334155",
                    },
                  ].map((row, i) => (
                    <g key={row.id}>
                      {i % 2 === 0 && (
                        <rect
                          x="95"
                          y={165 + i * 30}
                          width="330"
                          height="30"
                          fill="#ffffff03"
                        />
                      )}
                      <text
                        x="110"
                        y={183 + i * 30}
                        fill="#e2e8f0"
                        fontSize="8"
                      >
                        {row.id}
                      </text>
                      <text
                        x="190"
                        y={183 + i * 30}
                        fill="#94a3b8"
                        fontSize="8"
                      >
                        {row.driver}
                      </text>
                      <text
                        x="270"
                        y={183 + i * 30}
                        fill="#94a3b8"
                        fontSize="8"
                      >
                        {row.route}
                      </text>
                      <rect
                        x="355"
                        y={172 + i * 30}
                        width="50"
                        height="14"
                        rx="7"
                        fill={row.color}
                        opacity="0.25"
                      />
                      <text
                        x="365"
                        y={182 + i * 30}
                        fill={row.color}
                        fontSize="7"
                        fontWeight="bold"
                        opacity="0.9"
                      >
                        {row.status}
                      </text>
                    </g>
                  ))}
                  <rect
                    x="95"
                    y="345"
                    width="330"
                    height="3"
                    rx="1.5"
                    fill="#ffffff08"
                  />
                  <rect
                    x="95"
                    y="345"
                    width="200"
                    height="3"
                    rx="1.5"
                    fill="#0C1B33"
                    opacity="0.6"
                  />
                </svg>
              </div>
            </div>

            {/* Floating badge */}
            <div className="absolute -top-4 -left-4 bg-white rounded-xl shadow-lg p-3.5 border border-[#0C1B33]/8">
              <p className="text-xs text-[#0C1B33]/40 font-medium mb-1">
                Platform Uptime
              </p>
              <p className="text-xl font-bold text-[#0C1B33]">99.9%</p>
              <div className="flex items-center gap-1 mt-1">
                <div
                  className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse"
                  aria-hidden="true"
                />
                <span className="text-xs text-emerald-600 font-semibold">
                  Always On
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
