import React from "react";
import { motion } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { BlurFade } from "../ui/BlurFade";
import { ACTIVITY_DATA } from "@/const/data";

const ActivityFeedSection = () => {
  return (
    <div>
      {" "}
      <motion.div
        initial={{ opacity: 0, x: 20 }}
        animate={{ opacity: 1, x: 0 }}
        transition={{ delay: 0.3, duration: 0.5 }}
      >
        <Card className="h-full border-slate-100 bg-white/50 backdrop-blur-sm">
          <CardHeader>
            <CardTitle>Recent Activity</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-6">
              {ACTIVITY_DATA.map((item, index) => (
                <BlurFade key={item.id} delay={0.1 + index * 0.1} inView={true}>
                  <div className="flex gap-4 group">
                    <div className="relative">
                      <div className="w-10 h-10 rounded-full bg-slate-100 flex items-center justify-center text-slate-600 text-xs font-bold border-2 border-white shadow-sm z-10 relative group-hover:bg-violet-100 group-hover:text-violet-600 transition-colors">
                        {item.avatar}
                      </div>
                      {index !== ACTIVITY_DATA.length - 1 && (
                        <div className="absolute top-10 left-1/2 -ml-px w-px h-full bg-slate-100 -z-0" />
                      )}
                    </div>
                    <div className="flex-1 pb-2">
                      <p className="text-sm text-slate-900">
                        <span className="font-semibold">{item.user}</span>{" "}
                        <span className="text-slate-500">{item.action}</span>{" "}
                        <span className="font-medium text-slate-900">
                          {item.target}
                        </span>
                      </p>
                      <p className="text-xs text-slate-400 mt-1">{item.time}</p>
                    </div>
                  </div>
                </BlurFade>
              ))}
            </div>
            <Button
              variant="ghost"
              className="w-full mt-6 text-violet-600 hover:text-violet-700 hover:bg-violet-50"
            >
              View All Activity
            </Button>
          </CardContent>
        </Card>
      </motion.div>
    </div>
  );
};

export default ActivityFeedSection;
