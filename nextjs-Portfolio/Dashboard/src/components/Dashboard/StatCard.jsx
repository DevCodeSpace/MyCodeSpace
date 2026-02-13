import { motion } from "framer-motion";
import { CountUp } from "../ui/CountUp";
import { TiltedCard } from "../ui/TiltedCard";

export const StatCard = ({
  item,
  index,
  hoveredCard,
  setHoveredCard,
  actions,
}) => {
  const TrendIcon = actions.getTrendIcon(item.trendDir);
  // Parse value for CountUp
  const numericValue = parseFloat(item.value.replace(/[^0-9.]/g, ""));
  const prefix = item.value.startsWith("$")
    ? "$"
    : item.value.startsWith("+")
      ? "+"
      : "";
  const suffix = item.value.endsWith("%") ? "%" : "";

  return (
    <TiltedCard
      containerClassName="h-full"
      className="h-full p-6 rounded-2xl border border-slate-100 shadow-sm overflow-hidden"
      captionText={item.label} // 👈 tooltip text
      showTooltip={true} // optional
      showSpotlightBackground={
        item.trendDir === "up" ? "bg-emerald-400/30" : "bg-rose-400/30"
      }
      scaleOnHover={1.06} // optional
      rotateAmplitude={14} // optional
    >
      <div className="flex justify-between items-start mb-4">
        <div
          className={`p-3 rounded-xl bg-gradient-to-br ${item.color} text-white shadow-md`}
        >
          <item.icon size={20} />
        </div>
        <div
          className={`flex items-center gap-1 text-xs font-semibold px-2 py-1 rounded-full ${
            item.trendDir === "up"
              ? "bg-emerald-50 text-emerald-600"
              : "bg-rose-50 text-rose-600"
          }`}
        >
          <TrendIcon size={14} />
          {item.trend}
        </div>
      </div>
      <div>
        <h3 className="text-slate-500 text-sm font-medium mb-1">
          {item.label}
        </h3>
        <h2 className="text-2xl font-bold text-slate-900 flex items-center">
          <CountUp
            value={numericValue}
            prefix={prefix}
            suffix={suffix}
            className="inline-block"
          />
        </h2>
      </div>

      {/* Decorative background element */}
      <div className="absolute -right-4 -bottom-4 opacity-5 pointer-events-none">
        <item.icon size={120} className="text-slate-900" />
      </div>
    </TiltedCard>
  );
};
