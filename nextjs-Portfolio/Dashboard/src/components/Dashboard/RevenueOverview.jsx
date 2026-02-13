import React from "react";
import { motion } from "framer-motion";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import {
  ResponsiveContainer,
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
} from "recharts";
import CustomTooltip from "../ui/CustomTooltip";
import { REVENUE_DATA } from "@/const/data";

const RevenueOverview = () => {
  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ delay: 0.2, duration: 0.5 }}
      className="xl:col-span-2"
    >
      <Card className="h-full border-slate-100 bg-white/50 backdrop-blur-sm">
        <CardHeader className="flex flex-row items-center justify-between pb-8">
          <div className="space-y-1">
            <CardTitle>Revenue Overview</CardTitle>
            <CardDescription>Monthly revenue performance</CardDescription>
          </div>
          <Button variant="outline" size="sm" className="h-8">
            Download Report
          </Button>
        </CardHeader>
        <CardContent>
          <div className="h-[300px] w-full">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart
                data={REVENUE_DATA}
                margin={{ top: 10, right: 10, left: 0, bottom: 0 }}
              >
                <defs>
                  <linearGradient id="colorTotal" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#8b5cf6" stopOpacity={0.1} />
                    <stop offset="95%" stopColor="#8b5cf6" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid
                  strokeDasharray="3 3"
                  vertical={false}
                  stroke="#E2E8F0"
                />
                <XAxis
                  dataKey="name"
                  axisLine={false}
                  tickLine={false}
                  tick={{ fill: "#64748B", fontSize: 12 }}
                  dy={10}
                />
                <YAxis
                  axisLine={false}
                  tickLine={false}
                  tick={{ fill: "#64748B", fontSize: 12 }}
                  tickFormatter={(value) => `$${value}`}
                />
                <Tooltip
                  content={<CustomTooltip />}
                  cursor={{
                    stroke: "#8b5cf6",
                    strokeWidth: 1,
                    strokeDasharray: "4 4",
                  }}
                  isAnimationActive={true}
                  animationDuration={200}
                />
                <Area
                  type="monotone"
                  dataKey="total"
                  stroke="#8b5cf6"
                  strokeWidth={3}
                  fillOpacity={1}
                  fill="url(#colorTotal)"
                  animationDuration={1500}
                />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </CardContent>
      </Card>
    </motion.div>
  );
};

export default RevenueOverview;
