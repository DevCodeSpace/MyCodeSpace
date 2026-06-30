export default function TrustBar() {
  return (
    <div className="fixed top-0 left-0 right-0 z-60 h-9 bg-primary-text border-b border-white/5">
      <div className="max-w-screen-2xl mx-auto px-6 h-full flex items-center justify-between">

        {/* Left  live status */}
        <div className="flex items-center gap-2">
          <span className="relative flex h-1.5 w-1.5">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-avocado opacity-75" />
            <span className="relative inline-flex rounded-full h-1.5 w-1.5 bg-avocado" />
          </span>
          <span className="text-[11px] font-medium text-white/50 tracking-wide uppercase">
            Now live · Web &amp; Mobile
          </span>
        </div>

        {/* Right  3 clean stats */}
        <div className="hidden md:flex items-center gap-0">

          <div className="flex items-center gap-2 px-5 border-r border-white/10">
            <span className="text-[12px] font-bold text-white">120+</span>
            <span className="text-[11px] text-white/40 font-medium">Restaurants</span>
          </div>

          <div className="flex items-center gap-2 px-5 border-r border-white/10">
            <span className="text-[12px] font-bold text-white">4.8</span>
            <span className="text-[11px] text-white/40 font-medium">App Rating</span>
          </div>

          <div className="flex items-center gap-2 px-5 border-r border-white/10">
            <span className="text-[12px] font-bold text-white">3</span>
            <span className="text-[11px] text-white/40 font-medium">User Roles</span>
          </div>

          <div className="flex items-center gap-2.5 pl-5">
            <span className="text-[13px]" title="Australia">🇦🇺</span>
            <span className="text-[13px]" title="Germany">🇩🇪</span>
          </div>

        </div>

      </div>
    </div>
  );
}
