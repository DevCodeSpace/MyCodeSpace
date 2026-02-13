import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Plus } from "lucide-react";
import React from "react";

const ProductCategoriesSection = () => {
  return (
    <>
      {" "}
      <h2 className="text-lg font-semibold text-slate-900 mb-6">Categories</h2>
      <div className="space-y-4">
        <div className="flex gap-2">
          <div className="flex-1">
            <Select>
              <SelectTrigger className="w-full bg-slate-50 border-slate-200 text-slate-900">
                <SelectValue placeholder="Select a category" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="electronics">Electronics</SelectItem>
                <SelectItem value="clothing">Clothing</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <button className="p-2 border border-slate-200 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-50 transition-colors">
            <Plus size={18} />
          </button>
        </div>

        <div className="flex gap-2">
          <div className="flex-1">
            <Select>
              <SelectTrigger className="w-full bg-slate-50 border-slate-200 text-slate-900">
                <SelectValue placeholder="Select a sub category" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="phones">Phones</SelectItem>
                <SelectItem value="laptops">Laptops</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <button className="p-2 border border-slate-200 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-50 transition-colors">
            <Plus size={18} />
          </button>
        </div>
      </div>
    </>
  );
};

export default ProductCategoriesSection;
