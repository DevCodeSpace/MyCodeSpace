"use client";

const messages = [
  {
    from: "user",
    text: "I've been having chest pain and shortness of breath for 2 days.",
  },
  {
    from: "bot",
    text: "I understand  those symptoms need prompt attention. I'm identifying the right specialist for you...",
  },
  {
    from: "bot",
    text: "Found 3 available Cardiologists near you. Dr. Arjun Mehta is available today at 3:00 PM. Consultation fee: ₹800.",
    highlight: true,
  },
  { from: "user", text: "Book the 3:00 PM slot with Dr. Mehta please." },
  {
    from: "bot",
    text: "✅ Appointment confirmed! Dr. Arjun Mehta · Apollo Hospital · Today 3:00 PM. Download your summary below.",
    success: true,
  },
];

export default function ChatMockup() {
  return (
    <div className="float-animation w-full max-w-[360px] relative">
      {/* Card frame */}
      <div className="relative rounded-2xl border border-[#E3E3E3] bg-white shadow-[0_8px_40px_rgba(0,0,0,0.10)] overflow-hidden">
        {/* Chat header */}
        <div className="flex items-center justify-between px-4 py-3.5 bg-white border-b border-[#E3E3E3]">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-full bg-[#003DF5] flex items-center justify-center flex-shrink-0">
              <svg
                width="14"
                height="14"
                viewBox="0 0 24 24"
                fill="white"
                aria-hidden="true"
              >
                <path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2z" />
              </svg>
            </div>
            <div>
              <p className="text-[#000000] text-[13px] font-bold leading-none">
                CareBot AI
              </p>
              <p className="text-[11px] text-[#667085] flex items-center gap-1 mt-0.5">
                <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 inline-block" />
                Online
              </p>
            </div>
          </div>
          <div className="flex items-center gap-3 text-[#667085]">
            <svg
              width="15"
              height="15"
              viewBox="0 0 24 24"
              fill="currentColor"
              aria-hidden="true"
            >
              <path d="M6.62 10.79c1.44 2.83 3.76 5.14 6.59 6.59l2.2-2.2c.27-.27.67-.36 1.02-.24 1.12.37 2.33.57 3.57.57.55 0 1 .45 1 1V20c0 .55-.45 1-1 1-9.39 0-17-7.61-17-17 0-.55.45-1 1-1h3.5c.55 0 1 .45 1 1 0 1.25.2 2.45.57 3.57.11.35.03.74-.25 1.02l-2.2 2.2z" />
            </svg>
            <svg
              width="15"
              height="15"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              aria-hidden="true"
            >
              <circle cx="12" cy="12" r="1" />
              <circle cx="19" cy="12" r="1" />
              <circle cx="5" cy="12" r="1" />
            </svg>
          </div>
        </div>

        {/* Messages */}
        <div className="px-4 py-4 flex flex-col gap-3 bg-[#F6F6F7] min-h-[340px]">
          {messages.map((msg, i) => (
            <div
              key={i}
              className={`flex items-end gap-2 ${msg.from === "user" ? "justify-end" : "justify-start"}`}
            >
              {msg.from === "bot" && (
                <div className="w-6 h-6 rounded-full bg-[#003DF5] flex-shrink-0 flex items-center justify-center mb-0.5">
                  <svg
                    width="10"
                    height="10"
                    viewBox="0 0 24 24"
                    fill="white"
                    aria-hidden="true"
                  >
                    <path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2z" />
                  </svg>
                </div>
              )}

              <div
                className={`max-w-[78%] px-3.5 py-2.5 rounded-2xl text-[12.5px] leading-relaxed ${
                  msg.from === "user"
                    ? "bg-[#003DF5] text-white rounded-br-sm"
                    : msg.success
                      ? "bg-emerald-50 border border-emerald-200 text-emerald-800 rounded-bl-sm"
                      : msg.highlight
                        ? "bg-[#EEF2FF] border border-[#003DF5]/20 text-[#000000] rounded-bl-sm"
                        : "bg-white border border-[#E3E3E3] text-[#000000] rounded-bl-sm shadow-sm"
                }`}
              >
                {msg.text}
              </div>
            </div>
          ))}

          {/* Typing indicator */}
          <div className="flex items-end gap-2 justify-start">
            <div className="w-6 h-6 rounded-full bg-[#003DF5] flex-shrink-0 flex items-center justify-center mb-0.5">
              <svg
                width="10"
                height="10"
                viewBox="0 0 24 24"
                fill="white"
                aria-hidden="true"
              >
                <path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2z" />
              </svg>
            </div>
            <div className="bg-white border border-[#E3E3E3] px-4 py-3 rounded-2xl rounded-bl-sm flex items-center gap-1.5 shadow-sm">
              {[0, 0.2, 0.4].map((delay, i) => (
                <span
                  key={i}
                  className="w-1.5 h-1.5 rounded-full bg-[#667085] inline-block typing-dot"
                  style={{ animationDelay: `${delay}s` }}
                />
              ))}
            </div>
          </div>
        </div>

        {/* Input */}
        <div className="px-4 py-3.5 bg-white border-t border-[#E3E3E3]">
          <div className="flex items-center gap-2 bg-[#F6F6F7] rounded-xl border border-[#E3E3E3] px-3.5 py-2.5">
            <p className="flex-1 text-[#667085] text-[12px]">
              Describe your symptoms...
            </p>
            <button
              aria-label="Send message"
              className="w-7 h-7 rounded-lg bg-[#003DF5] flex items-center justify-center flex-shrink-0 hover:bg-[#0031cc] transition-colors"
            >
              <svg
                width="12"
                height="12"
                viewBox="0 0 24 24"
                fill="none"
                aria-hidden="true"
              >
                <path
                  d="M22 2L11 13"
                  stroke="white"
                  strokeWidth="2"
                  strokeLinecap="round"
                />
                <path
                  d="M22 2L15 22l-4-9-9-4 20-7z"
                  stroke="white"
                  strokeWidth="2"
                  strokeLinejoin="round"
                />
              </svg>
            </button>
          </div>
        </div>
      </div>

      {/* Floating confirmation badge */}
      <div className="absolute -bottom-4 -right-4 bg-white border border-[#E3E3E3] rounded-2xl px-4 py-3 shadow-[0_8px_24px_rgba(0,0,0,0.10)] flex items-center gap-3">
        <div className="w-8 h-8 rounded-xl bg-emerald-100 flex items-center justify-center flex-shrink-0">
          <svg
            width="16"
            height="16"
            viewBox="0 0 24 24"
            fill="none"
            aria-hidden="true"
          >
            <path
              d="M5 13l4 4L19 7"
              stroke="#16a34a"
              strokeWidth="2.5"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </svg>
        </div>
        <div>
          <p className="text-emerald-600 text-[10px] font-bold uppercase tracking-wide">
            Confirmed!
          </p>
          <p className="text-[#000000] text-[12px] font-semibold">
            Dr. Mehta · 3 PM
          </p>
        </div>
      </div>
    </div>
  );
}
