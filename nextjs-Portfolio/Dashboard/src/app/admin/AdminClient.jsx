"use client";

import { useAdmin } from "./useAdmin";
import { motion } from "framer-motion";
import { DashboardView } from "@/components/Dashboard/DashboardView";

export default function AdminClient() {
  const { state, actions } = useAdmin();

  return (
    <div className="flex flex-col h-full">
      <header className="flex justify-between items-end mb-10">
        <div>
          <motion.h1
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-3xl font-bold text-slate-900"
          >
            {state.greeting}, Admin.
          </motion.h1>
          <motion.p
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.1 }}
            className="text-slate-500 mt-2"
          >
            Here's what's happening with your projects today.
          </motion.p>
        </div>

        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          className="hidden md:flex items-center gap-3 bg-white px-4 py-2 rounded-xl shadow-sm border border-slate-100"
        >
          <div className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
          <span className="text-sm font-medium text-slate-600">
            System Operational
          </span>
        </motion.div>
      </header>

      <DashboardView
        actions={actions}
        hoveredCard={state.hoveredCard}
        setHoveredCard={actions.setHoveredCard}
      />
    </div>
  );
}
