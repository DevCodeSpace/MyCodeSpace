import MetricsCard from "../ShowCase/MetricsCard";
import FeatureCard from "../ShowCase/FeatureCard";
import CircularStats from "../ShowCase/CircularStats";
import ActivityFeed from "../ShowCase/ActivityFeed";
import HeroSection from "../ShowCase/HeroSection";
import ShowcaseGallery from "./ShowcaseGallery";

export const ShowcaseView = () => {
  return (
    <div className="space-y-8 relative pb-24">
      {/* Hero Section */}
      <HeroSection />

      {/* Top Metrics Row */}
      <MetricsCard />

      {/* Main Content Areas */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Feature Card */}
        <FeatureCard />

        {/* Circular Stats */}
        <CircularStats />

        {/* Activity Feed */}
        <ActivityFeed />
      </div>

      {/* Gallery Section */}
      <ShowcaseGallery />
    </div>
  );
};
