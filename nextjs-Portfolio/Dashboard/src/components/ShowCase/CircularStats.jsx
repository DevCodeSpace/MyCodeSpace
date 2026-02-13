import React from "react";
import { BlurFade } from "../ui/BlurFade";
import { CircularProgress } from "../ui/CircularProgress";

const CircularStats = () => {
  return (
    <div>
      {" "}
      <BlurFade
        delay={0.3}
        inView
        className="bg-white p-8 rounded-2xl border border-slate-100 shadow-sm flex flex-col items-center justify-center text-center"
      >
        <h3 className="text-lg font-semibold text-slate-700 mb-8">
          System Health
        </h3>
        <div className="relative">
          <CircularProgress
            value={85}
            size={200}
            strokeWidth={15}
            color="#8b5cf6"
            text="Optimal"
          />
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 mt-16 text-sm text-slate-400">
            CPU Load
          </div>
        </div>
      </BlurFade>
    </div>
  );
};

export default CircularStats;
