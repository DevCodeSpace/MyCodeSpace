"use client";

import { motion } from "framer-motion";
import { ChevronLeft, UploadCloud, Plus } from "lucide-react";
import Link from "next/link";
import { useState } from "react";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";
import ProductDetailSection from "./ProductDetailSection";
import ProductImagesSection from "./ProductImagesSection";
import ProductVariantsSection from "./ProductVariantsSection";
import ProductPricingSection from "./ProductPricingSection";
import ProductStatusSection from "./ProductStatusSection";
import ProductCategoriesSection from "./ProductCategoriesSection";
import AddProductHeader from "./AddProductHeader";

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

export default function AddProductView() {
  const [inStock, setInStock] = useState(true);

  return (
    <motion.div
      initial="hidden"
      animate="visible"
      variants={containerVariants}
      className="bg-slate-50 min-h-screen text-slate-900 p-6 -m-8"
    >
      {/* Header */}
      <motion.div
        variants={itemVariants}
        className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mb-8"
      >
        <AddProductHeader />
      </motion.div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Left Column (Main Details) */}
        <div className="lg:col-span-2 space-y-8">
          {/* Product Details Section */}
          <motion.section
            variants={itemVariants}
            className="bg-white rounded-2xl p-6 border border-slate-200 shadow-sm"
          >
            <ProductDetailSection />
          </motion.section>

          {/* Product Images Section */}
          <motion.section
            variants={itemVariants}
            className="bg-white rounded-2xl p-6 border border-slate-200 shadow-sm"
          >
            <ProductImagesSection />
          </motion.section>

          {/* Variants Section */}
          <motion.section
            variants={itemVariants}
            className="bg-white rounded-2xl p-6 border border-slate-200 shadow-sm"
          >
            <ProductVariantsSection />
          </motion.section>
        </div>

        {/* Right Column (Side Details) */}
        <div className="space-y-8">
          {/* Pricing Section */}
          <motion.section
            variants={itemVariants}
            className="bg-white rounded-2xl p-6 border border-slate-200 shadow-sm"
          >
            <ProductPricingSection inStock={inStock} setInStock={setInStock} />
          </motion.section>

          {/* Status Section */}
          <motion.section
            variants={itemVariants}
            className="bg-white rounded-2xl p-6 border border-slate-200 shadow-sm"
          >
            <ProductStatusSection />
          </motion.section>

          {/* Categories Section */}
          <motion.section
            variants={itemVariants}
            className="bg-white rounded-2xl p-6 border border-slate-200 shadow-sm"
          >
            <ProductCategoriesSection />
          </motion.section>
        </div>
      </div>
    </motion.div>
  );
}
