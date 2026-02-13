"use client";

import { motion } from "framer-motion";
export const CircularProgress = ({
  value,
  min = 0,
  max = 100,
  size = 120,
  strokeWidth = 10,
  color = "#8b5cf6",
  trackColor = "#e2e8f0",
  text = "",
  className,
}) => {
  const radius = (size - strokeWidth) / 2;
  const circumference = radius * 2 * Math.PI;
  const normalizedValue = Math.min(Math.max(value, min), max);
  const percentage = ((normalizedValue - min) / (max - min)) * 100;
  const offset = circumference - (percentage / 100) * circumference;

  return (
    <div
      className={`relative flex items-center justify-center ${className}`}
      style={{ width: size, height: size }}
    >
      <svg width={size} height={size} className="transform -rotate-90">
        <circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          stroke={trackColor}
          strokeWidth={strokeWidth}
          fill="none"
        />
        <motion.circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          stroke={color}
          strokeWidth={strokeWidth}
          strokeDasharray={circumference}
          strokeLinecap="round"
          fill="none"
          initial={{ strokeDashoffset: circumference }}
          animate={{ strokeDashoffset: offset }}
          transition={{ duration: 1, ease: "easeOut" }}
        />
      </svg>
      <div className="absolute flex flex-col items-center justify-center text-slate-800">
        <span className="text-xl font-bold">{Math.round(percentage)}%</span>
        {text && (
          <span className="text-xs text-slate-500 font-medium">{text}</span>
        )}
      </div>
    </div>
  );
};
