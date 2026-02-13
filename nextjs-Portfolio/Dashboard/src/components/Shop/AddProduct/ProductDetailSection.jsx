import React from "react";

const ProductDetailSection = () => {
  return (
    <>
      {" "}
      <h2 className="text-lg font-semibold text-slate-900 mb-6">
        Product Details
      </h2>
      <div className="space-y-6">
        <div>
          <label className="block text-xs font-semibold text-slate-500 mb-2 uppercase tracking-wide">
            Name
          </label>
          <input
            type="text"
            className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-sm text-slate-900 focus:outline-none focus:border-violet-500 focus:ring-1 focus:ring-violet-500 transition-all placeholder:text-slate-400"
            placeholder="Product Name"
          />
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label className="block text-xs font-semibold text-slate-500 mb-2 uppercase tracking-wide">
              SKU
            </label>
            <input
              type="text"
              className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-sm text-slate-900 focus:outline-none focus:border-violet-500 focus:ring-1 focus:ring-violet-500 transition-all placeholder:text-slate-400"
              placeholder="SKU"
            />
          </div>
          <div>
            <label className="block text-xs font-semibold text-slate-500 mb-2 uppercase tracking-wide">
              Barcode
            </label>
            <input
              type="text"
              className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-sm text-slate-900 focus:outline-none focus:border-violet-500 focus:ring-1 focus:ring-violet-500 transition-all placeholder:text-slate-400"
              placeholder="Barcode"
            />
          </div>
        </div>

        <div>
          <label className="block text-xs font-semibold text-slate-500 mb-2 uppercase tracking-wide">
            Description (Optional)
          </label>
          <textarea
            rows={4}
            className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-sm text-slate-900 focus:outline-none focus:border-violet-500 focus:ring-1 focus:ring-violet-500 transition-all resize-none placeholder:text-slate-400"
            placeholder="Set a description to the product for better visibility."
          />
        </div>
      </div>
    </>
  );
};

export default ProductDetailSection;
