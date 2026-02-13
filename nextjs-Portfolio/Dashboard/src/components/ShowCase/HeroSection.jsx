import React from "react";
import { BlurFade } from "../ui/BlurFade";

const HeroSection = () => {
  return (
    <div>
      {" "}
      <BlurFade delay={0.1} inView>
        <div className="text-center mb-10">
          <h2 className="text-4xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-violet-600 to-indigo-600 mb-2">
            Command Center
          </h2>
          <p className="text-slate-500">
            Real-time system overview and controls
          </p>
        </div>
      </BlurFade>
    </div>
  );
};

export default HeroSection;
