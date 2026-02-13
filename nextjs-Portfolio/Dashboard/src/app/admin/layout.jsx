"use client";

import { Sidebar, SidebarContent } from "@/components/Dashboard/Sidebar";
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet";
import { Menu } from "lucide-react";

export default function AdminLayout({ children }) {
  return (
    <div className="flex min-h-screen bg-slate-50 font-sans text-slate-900">
      {/* Desktop Sidebar (hidden on mobile) */}
      <Sidebar />

      {/* Mobile Header (visible on mobile) */}
      <div className="lg:hidden fixed top-0 left-0 right-0 h-16 bg-white/80 backdrop-blur-md border-b border-slate-200 z-30 px-4 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Sheet>
            <SheetTrigger asChild>
              <button className="p-2 -ml-2 text-slate-600 hover:bg-slate-100 rounded-lg transition-colors">
                <Menu size={20} />
              </button>
            </SheetTrigger>
            <SheetContent side="left" className="p-0 w-72">
              <SidebarContent />
            </SheetContent>
          </Sheet>
          <div className="flex items-center gap-2">
            <div className="h-7 w-7 rounded-lg bg-violet-600 text-white text-xs font-semibold flex items-center justify-center shadow-sm">
              A
            </div>
            <span className="font-semibold text-slate-900">Admin</span>
          </div>
        </div>
      </div>

      <main className="flex-1 ml-0 lg:ml-64 p-4 lg:p-8 pt-20 lg:pt-8 transition-all duration-300">
        {children}
      </main>
    </div>
  );
}
