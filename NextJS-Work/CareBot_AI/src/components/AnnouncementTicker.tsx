"use client";

export default function AnnouncementBanner({
  onDismiss,
}: {
  onDismiss: () => void;
}) {
  return (
    <div className="fixed top-0 left-0 right-0 z-60 h-10.5 flex items-center justify-center px-6 bg-linear-to-r from-[#0D1B4B] via-primary to-[#0D1B4B] shadow-[0_2px_12px_rgba(0,61,245,0.35)]">
      {/* Subtle shimmer line */}
      <div className="absolute inset-x-0 top-0 h-px bg-linear-to-r from-transparent via-white/30 to-transparent" />

      {/* Content */}
      <div className="flex items-center gap-2 sm:gap-3 min-w-0">
        <span className="inline-flex items-center gap-1.5 bg-white/15 border border-white/20 text-white text-[11px] font-bold px-3 py-1 rounded-md uppercase tracking-widest shrink-0">
          🎉 New
        </span>
        <p className="text-[12px] sm:text-[13px] font-medium text-white/90 truncate">
          <span className="hidden sm:inline">
            Book specialists in under 60 seconds{" "}
          </span>
          CareBot AI is now live
          <a
            href="#contact"
            className="ml-1.5 sm:ml-2 text-white font-bold hover:text-emerald-300 transition-colors duration-150 whitespace-nowrap"
          >
            Get Early Access →
          </a>
        </p>
      </div>

      {/* Dismiss */}
      <button
        onClick={onDismiss}
        aria-label="Dismiss"
        className="absolute right-4 w-6 h-6 flex items-center justify-center rounded-full text-white/40 hover:text-white hover:bg-white/10 transition-all duration-150"
      >
        <svg width="12" height="12" viewBox="0 0 16 16" fill="none">
          <path
            d="M4 4l8 8M12 4l-8 8"
            stroke="currentColor"
            strokeWidth="2.2"
            strokeLinecap="round"
          />
        </svg>
      </button>
    </div>
  );
}
