import { Switch } from "@/components/ui/switch";
import React from "react";

const ProductPricingSection = ({ inStock, setInStock }) => {
  return (
    <>
      {" "}
      <h2 className="text-lg font-semibold text-slate-900 mb-6">Pricing</h2>
      <div className="space-y-6">
        <div>
          <label className="block text-xs font-semibold text-slate-500 mb-2 uppercase tracking-wide">
            Base Price
          </label>
          <input
            type="text"
            className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-sm text-slate-900 focus:outline-none focus:border-violet-500 focus:ring-1 focus:ring-violet-500 transition-all placeholder:text-slate-400"
            placeholder="$0.00"
          />
        </div>

        <div>
          <label className="block text-xs font-semibold text-slate-500 mb-2 uppercase tracking-wide">
            Discounted Price
          </label>
          <input
            type="text"
            className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-sm text-slate-900 focus:outline-none focus:border-violet-500 focus:ring-1 focus:ring-violet-500 transition-all placeholder:text-slate-400"
            placeholder="$0.00"
          />
        </div>

        <div className="flex items-center gap-3">
          <Switch id="tax-mode" />
          <label
            htmlFor="tax-mode"
            className="text-sm text-slate-600 cursor-pointer"
          >
            Charge tax on this product
          </label>
        </div>

        <div className="h-px bg-slate-100 my-4" />

        <div className="flex items-center justify-between">
          <span className="text-sm font-medium text-slate-900">In stock</span>
          <Switch
            checked={inStock}
            onCheckedChange={setInStock}
            className="data-[state=checked]:bg-emerald-500"
          />
        </div>
      </div>
    </>
  );
};

export default ProductPricingSection;
