import { motion } from "framer-motion";
import { StatCard } from "./StatCard";
import RevenueOverview from "./RevenueOverview";
import ActivityFeedSection from "./ActivityFeedSection";
import { ACTIVITY_DATA, REVENUE_DATA, STATS_DATA } from "@/const/data";
import ProjectSpotlight from "./ProjectSpotlight";

export const DashboardView = ({ actions, hoveredCard, setHoveredCard }) => {
  return (
    <div>
      <motion.div
        key="dashboard"
        initial={{ opacity: 0, x: -20 }}
        animate={{ opacity: 1, x: 0 }}
        exit={{ opacity: 0, x: 20 }}
        transition={{ duration: 0.3 }}
        className="space-y-8 max-w-7xl mx-auto"
      >
        {/* Stats Grid */}
        <section className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-6">
          {STATS_DATA.map((item, index) => (
            <div key={item.id} className="h-full">
              <StatCard
                item={item}
                index={index}
                hoveredCard={hoveredCard}
                setHoveredCard={setHoveredCard}
                actions={actions}
              />
            </div>
          ))}
        </section>

        <div className="grid grid-cols-1 xl:grid-cols-3 gap-8">
          {/* Main Chart Section */}
          <RevenueOverview data={REVENUE_DATA} />

          {/* Activity Feed Section */}
          <ActivityFeedSection />
        </div>
        <ProjectSpotlight />
      </motion.div>
    </div>
  );
};
