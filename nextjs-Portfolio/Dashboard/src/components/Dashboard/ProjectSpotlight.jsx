import { useRef, useState } from "react";
import { motion } from "framer-motion";
import SpotlightCard from "../ui/SpotlightCard";
import { BlurFade } from "../ui/BlurFade";
import { ArrowUpRight, Folder, GitBranch, Star } from "lucide-react";

const PROJECTS = [
  {
    id: 1,
    title: "E-Commerce Platform",
    description: "A modern shopping experience with AI recommendations",
    tags: ["React", "Node.js", "AI"],
    stars: 124,
    forks: 35,
    status: "active",
  },
  {
    id: 2,
    title: "Finance Dashboard",
    description: "Real-time crypto and stock market tracking",
    tags: ["Vue", "D3.js", "WebSocket"],
    stars: 89,
    forks: 12,
    status: "beta",
  },
  {
    id: 3,
    title: "Social Media App",
    description: "Connect with friends and share moments instantly",
    tags: ["Next.js", "GraphQL", "Prisma"],
    stars: 256,
    forks: 48,
    status: "active",
  },
  {
    id: 4,
    title: "Task Manager",
    description: "Collaborative project management tool for teams",
    tags: ["Svelte", "Firebase", "Tailwind"],
    stars: 67,
    forks: 8,
    status: "development",
  },
];

const ProjectSpotlight = () => {
  return (
    <section className="space-y-6">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-gray-900 to-gray-600 dark:from-white dark:to-gray-400">
          Recent Projects
        </h2>
        <button className="text-sm text-muted-foreground hover:text-foreground transition-colors flex items-center gap-1">
          View All <ArrowUpRight className="w-4 h-4" />
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {PROJECTS.map((project, idx) => (
          <BlurFade key={project.id} delay={0.1 * idx} inView>
            <SpotlightCard className="h-full bg-white/50 dark:bg-zinc-900/50 border-neutral-200 dark:border-neutral-800">
              <div className="flex flex-col h-full space-y-4 relative z-10">
                <div className="flex justify-between items-start">
                  <div className="p-2 bg-violet-100 dark:bg-violet-900/30 rounded-lg">
                    <Folder className="w-6 h-6 text-violet-600 dark:text-violet-400" />
                  </div>
                  <div className="flex gap-3 text-xs text-muted-foreground">
                    <span className="flex items-center gap-1">
                      <Star className="w-3.5 h-3.5" />
                      {project.stars}
                    </span>
                    <span className="flex items-center gap-1">
                      <GitBranch className="w-3.5 h-3.5" />
                      {project.forks}
                    </span>
                  </div>
                </div>

                <div>
                  <h3 className="text-lg font-semibold text-foreground mb-1">
                    {project.title}
                  </h3>
                  <p className="text-sm text-muted-foreground line-clamp-2">
                    {project.description}
                  </p>
                </div>

                <div className="mt-auto pt-4 flex gap-2 flex-wrap">
                  {project.tags.map((tag) => (
                    <span
                      key={tag}
                      className="px-2 py-1 text-xs rounded-full bg-secondary text-secondary-foreground"
                    >
                      {tag}
                    </span>
                  ))}
                </div>
              </div>
            </SpotlightCard>
          </BlurFade>
        ))}
      </div>
    </section>
  );
};

export default ProjectSpotlight;
