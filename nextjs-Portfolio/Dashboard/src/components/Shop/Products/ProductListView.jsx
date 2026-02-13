"use client";

import { motion } from "framer-motion";
import { Plus, Search, Filter } from "lucide-react";
import Link from "next/link";
import { PRODUCTS_DATA } from "@/const/data";
import ProductsTable from "./ProductsTable";

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
    },
  },
};

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0 },
};

export default function ProductListView() {
  return (
    <motion.div
      initial="hidden"
      animate="visible"
      variants={containerVariants}
      className="space-y-6"
    >
      <motion.div
        variants={itemVariants}
        className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4"
      >
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Products</h1>
          <p className="text-slate-500 text-sm mt-1">
            Manage your product inventory
          </p>
        </div>
        <Link
          href="/admin/add-product"
          className="flex items-center gap-2 bg-slate-900 text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-slate-800 transition-colors"
        >
          <Plus size={16} />
          Add Product
        </Link>
      </motion.div>

      {/* Filters & Search */}
      <motion.div
        variants={itemVariants}
        className="flex gap-4 p-4 bg-white rounded-xl border border-slate-200 shadow-sm"
      >
        <div className="relative flex-1 max-w-md">
          <Search
            size={18}
            className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400"
          />
          <input
            type="text"
            placeholder="Search products..."
            className="w-full pl-10 pr-4 py-2 text-sm border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-violet-500/20 focus:border-violet-500"
          />
        </div>
        <button className="flex items-center gap-2 px-4 py-2 text-sm font-medium text-slate-600 border border-slate-200 rounded-lg hover:bg-slate-50 transition-colors">
          <Filter size={16} />
          Filters
        </button>
      </motion.div>

      {/* Product Table */}
      <motion.div
        variants={itemVariants}
        className="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden"
      >
        <ProductsTable PRODUCTS_DATA={PRODUCTS_DATA} />
      </motion.div>
    </motion.div>
  );
}
