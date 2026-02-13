import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Plus } from "lucide-react";
import React from "react";

const ProductVariantsSection = () => {
  return (
    <>
      {" "}
      <h2 className="text-lg font-semibold text-slate-900 mb-6">Variants</h2>
      <div className="space-y-4">
        <div className="grid grid-cols-12 gap-4 text-xs font-semibold text-slate-500 uppercase tracking-wide mb-2">
          <div className="col-span-4">Options</div>
          <div className="col-span-4">Value</div>
          <div className="col-span-4">Price</div>
        </div>

        {[1, 2].map((i) => (
          <div key={i} className="grid grid-cols-12 gap-4">
            <div className="col-span-4">
              <Select>
                <SelectTrigger className="w-full bg-slate-50 border-slate-200 text-slate-900">
                  <SelectValue placeholder="Select a status" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="size">Size</SelectItem>
                  <SelectItem value="color">Color</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div className="col-span-4">
              <input
                type="text"
                placeholder="Enter value"
                className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2 text-sm text-slate-900 focus:outline-none focus:border-violet-500"
              />
            </div>
            <div className="col-span-4">
              <input
                type="text"
                placeholder="Enter price"
                className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2 text-sm text-slate-900 focus:outline-none focus:border-violet-500"
              />
            </div>
          </div>
        ))}

        <button className="w-full py-3 border border-dashed border-slate-200 rounded-xl text-slate-500 text-sm font-medium hover:text-violet-600 hover:border-violet-200 hover:bg-violet-50/50 transition-all flex items-center justify-center gap-2 mt-4">
          <Plus size={16} />
          Add Variant
        </button>
      </div>
    </>
  );
};

export default ProductVariantsSection;
