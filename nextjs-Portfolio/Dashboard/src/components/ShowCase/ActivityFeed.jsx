import React from "react";
import { BlurFade } from "../ui/BlurFade";

const ActivityFeed = () => {
  const activityFeed = [
    { id: 1, text: "Server backup completed", time: "2m ago", type: "success" },
    { id: 2, text: "New user registered", time: "15m ago", type: "info" },
    {
      id: 3,
      text: "High memory usage warning",
      time: "1h ago",
      type: "warning",
    },
    {
      id: 4,
      text: "Payment gateway connected",
      time: "3h ago",
      type: "success",
    },
  ];

  return (
    <div>
      {" "}
      <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm">
        <h3 className="text-lg font-semibold text-slate-700 mb-6 flex items-center gap-2">
          <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
          Real-time Logs
        </h3>
        <div className="space-y-4">
          {activityFeed.map((item, i) => (
            <BlurFade key={item.id} delay={0.4 + i * 0.1} inView>
              <div className="flex items-start gap-3 p-3 rounded-lg hover:bg-slate-50 transition-colors border border-transparent hover:border-slate-100">
                <div
                  className={`mt-1 w-2 h-2 rounded-full ${
                    item.type === "success"
                      ? "bg-emerald-500"
                      : item.type === "warning"
                        ? "bg-amber-500"
                        : "bg-blue-500"
                  }`}
                />
                <div>
                  <p className="text-sm font-medium text-slate-700">
                    {item.text}
                  </p>
                  <p className="text-xs text-slate-400">{item.time}</p>
                </div>
              </div>
            </BlurFade>
          ))}
        </div>
      </div>
    </div>
  );
};

export default ActivityFeed;
