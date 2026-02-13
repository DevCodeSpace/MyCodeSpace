"use client";

import { useState, useMemo } from "react";
import {
  ArrowUpRight,
  ArrowDownRight,
  LayoutTemplate,
  PieChart,
} from "lucide-react";
import { useRouter, useSearchParams } from "next/navigation";

export const useAdmin = () => {
  // Interaction State
  const [hoveredCard, setHoveredCard] = useState(null);

  const searchParams = useSearchParams();
  const router = useRouter();

  // URL-based active tab (default to 'dashboard')
  const activeTab = searchParams.get("tab") || "dashboard";

  // Handler to update URL
  const handleTabChange = (tabId) => {
    // Preserve existing query params if needed, for now just setting tab
    router.push(`/admin?tab=${tabId}`);
  };

  /**
   * Greeting Logic based on time of day.
   * Memoized to prevent recalculation on every render.
   */
  const greeting = useMemo(() => {
    const hour = new Date().getHours();
    if (hour < 12) return "Good morning";
    if (hour < 18) return "Good afternoon";
    return "Good evening";
  }, []);

  /**
   * Helper to determine trend icon based on direction.
   */
  const getTrendIcon = (direction) => {
    return direction === "up" ? ArrowUpRight : ArrowDownRight;
  };

  /**
   * Format currency helper.
   */
  const formatCurrency = (value) => {
    return new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: "USD",
    }).format(value);
  };

  // Exposed Data and Handlers
  return {
    state: {
      activeTab,
      hoveredCard,
      greeting,
    },
    actions: {
      setHoveredCard,
      handleTabChange,
      getTrendIcon,
      formatCurrency,
      handleTabChange,
    },
    icons: {
      LayoutTemplate,
      PieChart,
    },
  };
};
