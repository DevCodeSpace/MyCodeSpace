import { Bell, CreditCard, Globe, Zap } from "lucide-react";
import { BlurFade } from "../ui/BlurFade";
import { TiltedCard } from "../ui/TiltedCard";
import Magnet from "../ui/Magnet";
const FeatureCard = () => {
  return (
    <div>
      {" "}
      <BlurFade delay={0.2} inView className="h-full">
        <TiltedCard
          containerClassName="h-full"
          className="h-full p-8 bg-gradient-to-br from-slate-900 to-slate-800 text-white rounded-2xl flex flex-col justify-between min-h-[300px]"
        >
          <div>
            <div className="flex justify-between items-start mb-6">
              <CreditCard size={32} className="text-violet-400" />
              <span className="px-3 py-1 bg-white/10 rounded-full text-xs font-medium backdrop-blur-sm border border-white/10">
                Pro Plan
              </span>
            </div>
            <h3 className="text-2xl font-bold mb-2">Premium Access</h3>
            <p className="text-slate-400 text-sm">
              Unleash the full power of your dashboard with advanced analytics
              and priority support.
            </p>
          </div>
          {/* <button className="w-full py-3 bg-violet-500 hover:bg-violet-600 text-white rounded-xl font-medium transition-colors mt-6">
            Upgrade Now
          </button> */}
          <Magnet
            className="w-full py-3 bg-violet-500 hover:bg-violet-600 text-white rounded-xl font-medium transition-colors mt-6 text-center"
            padding={50}
            disabled={false}
            magnetStrength={10}
          >
            <p>Upgrade Now</p>
          </Magnet>
        </TiltedCard>
      </BlurFade>
    </div>
  );
};

export default FeatureCard;
