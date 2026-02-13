import React from "react";
import { Bell, Globe, Zap } from "lucide-react";
import { CountUp } from "../ui/CountUp";
import SpotlightCard from "../ui/SpotlightCard";

const MetricsCard = () => {
  return (
    <div>
      {" "}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 h-max">
        <SpotlightCard className="p-6">
          <div className="flex items-center gap-4 mb-4">
            <div className="p-3 bg-violet-100 rounded-lg text-violet-600">
              <Zap size={24} />
            </div>
            <h3 className="font-semibold text-slate-700">Total Revenue</h3>
          </div>
          <div className="text-3xl font-bold text-slate-900">
            $<CountUp value={54230} />
          </div>
          <div className="text-sm text-emerald-500 mt-2 font-medium">
            +12.5% from last month
          </div>
        </SpotlightCard>

        <SpotlightCard className="p-6">
          <div className="flex items-center gap-4 mb-4">
            <div className="p-3 bg-blue-100 rounded-lg text-blue-600">
              <Globe size={24} />
            </div>
            <h3 className="font-semibold text-slate-700">Global Reach</h3>
          </div>
          <div className="text-3xl font-bold text-slate-900">
            <CountUp value={12450} />
          </div>
          <div className="text-sm text-emerald-500 mt-2 font-medium">
            +8.2% new visits
          </div>
        </SpotlightCard>

        <SpotlightCard className="p-6">
          <div className="flex items-center gap-4 mb-4">
            <div className="p-3 bg-rose-100 rounded-lg text-rose-600">
              <Bell size={24} />
            </div>
            <h3 className="font-semibold text-slate-700">Active Alerts</h3>
          </div>
          <div className="text-3xl font-bold text-slate-900">
            <CountUp value={3} />
          </div>
          <div className="text-sm text-slate-400 mt-2">
            System running smoothly
          </div>
        </SpotlightCard>
      </div>
    </div>
  );
};

export default MetricsCard;
