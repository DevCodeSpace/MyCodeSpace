"use client";

import { motion } from "framer-motion";
import {
  LayoutTemplate,
  PieChart,
  ShoppingBag,
  PlusCircle,
} from "lucide-react";
import Link from "next/link";
import { usePathname } from "next/navigation";

const NAV_ITEMS = [
  { id: "dashboard", label: "Dashboard", icon: LayoutTemplate, href: "/admin" },
  {
    id: "showcase",
    label: "Showcase",
    icon: PieChart,
    href: "/admin/showcase",
  },
  {
    id: "products",
    label: "Products",
    icon: ShoppingBag,
    href: "/admin/products",
  },
  {
    id: "add-product",
    label: "Add Product",
    icon: PlusCircle,
    href: "/admin/add-product",
  },
];

export const SidebarContent = () => {
  const pathname = usePathname();

  return (
    <div className="relative h-full bg-white/80 backdrop-blur-xl border-r border-slate-200">
      {/* Soft gradient wash (NOT blobs) */}
      <div className="absolute inset-0 pointer-events-none">
        <div className="absolute top-0 left-0 h-64 w-full bg-gradient-to-b from-violet-50/60 to-transparent" />
        <div className="absolute bottom-0 left-0 h-64 w-full bg-gradient-to-t from-slate-50 to-transparent" />
      </div>

      {/* Content */}
      <div className="relative z-10 flex h-full flex-col px-3 py-6">
        {/* Identity */}
        <div className="flex items-center gap-3 px-3">
          <div className="h-9 w-9 rounded-lg bg-violet-600 text-white text-sm font-semibold flex items-center justify-center shadow-sm">
            A
          </div>
          <div className="block">
            <p className="text-sm font-semibold text-slate-900">Admin</p>
            <p className="text-xs text-slate-500">Workspace</p>
          </div>
        </div>

        {/* Section label */}
        <p className="mt-10 mb-2 block px-4 text-[11px] font-medium uppercase tracking-wide text-slate-400">
          Overview
        </p>

        {/* Navigation */}
        <nav className="flex flex-col gap-1">
          {NAV_ITEMS.map((item) => {
            const Icon = item.icon;
            const isActive = pathname === item.href;

            return (
              <Link
                key={item.id}
                href={item.href}
                className={`relative flex items-center gap-3 px-4 py-2.5 rounded-xl text-sm transition ${
                  isActive
                    ? "text-violet-700"
                    : "text-slate-600 hover:text-slate-900"
                }`}
              >
                <motion.div
                  className="absolute inset-0 rounded-xl bg-violet-50 border border-violet-100"
                  initial={false}
                  animate={{
                    opacity: isActive ? 1 : 0,
                    scale: isActive ? 1 : 0.96,
                  }}
                  transition={{
                    duration: 0.18,
                    ease: "easeOut",
                  }}
                />

                <Icon size={18} className="relative z-10" />
                <span className="relative z-10 block font-medium">
                  {item.label}
                </span>
              </Link>
            );
          })}
        </nav>

        {/* Spacer content that feels intentional */}
        <div className="mt-10 px-4 block">
          <div className="rounded-xl border border-slate-200 bg-white p-3">
            <p className="text-xs font-medium text-slate-700">System Status</p>
            <div className="mt-2 flex items-center gap-2">
              <span className="h-2 w-2 rounded-full bg-emerald-500" />
              <span className="text-xs text-slate-500">
                All services operational
              </span>
            </div>
          </div>
        </div>

        {/* Footer */}
        {/* Bottom Stack */}
        <div className="mt-auto px-4 space-y-4 block">
          {/* Divider */}
          <div className="h-px w-full bg-slate-200" />

          {/* System status (denser) */}
          <div className="flex items-center justify-between text-xs">
            <span className="text-slate-500">System</span>
            <span className="flex items-center gap-2 text-emerald-600 font-medium">
              <span className="h-2 w-2 rounded-full bg-emerald-500" />
              Operational
            </span>
          </div>

          {/* Workspace card */}
          <div className="rounded-xl border border-slate-200 bg-white p-3">
            <p className="text-xs font-semibold text-slate-800">
              Admin Workspace
            </p>
            <p className="mt-1 text-[11px] text-slate-500 leading-relaxed">
              Production environment
              <br />
              Europe · Frankfurt
            </p>

            <div className="mt-3 flex items-center justify-between text-[11px] text-slate-500">
              <span>Plan</span>
              <span className="font-medium text-slate-700">Pro</span>
            </div>
          </div>

          {/* Meta info */}
          <div className="flex items-center justify-between text-[11px] text-slate-400">
            <span>v2.4.0</span>
            <span>⌘K</span>
          </div>
        </div>
      </div>
    </div>
  );
};

export const Sidebar = () => {
  return (
    <aside className="fixed left-0 top-0 h-screen w-64 z-20 hidden lg:block">
      <SidebarContent />
    </aside>
  );
};
