import { UploadCloud } from "lucide-react";
import React from "react";

const ProductImagesSection = () => {
  return (
    <>
      {" "}
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-lg font-semibold text-slate-900">Product Images</h2>
        <button className="text-violet-600 text-sm font-medium hover:text-violet-700 transition-colors">
          Add media from URL
        </button>
      </div>
      <div className="border-2 border-dashed border-slate-200 rounded-xl bg-slate-50/50 p-10 text-center transition-all hover:border-violet-500/30 hover:bg-slate-50">
        <div className="w-12 h-12 rounded-full bg-slate-100 flex items-center justify-center mx-auto mb-4 text-slate-400">
          <UploadCloud size={24} />
        </div>
        <p className="text-slate-900 font-medium mb-1">Drop your images here</p>
        <p className="text-slate-500 text-xs mb-6">PNG or JPG (max. 5MB)</p>
        <button className="px-4 py-2 bg-white text-slate-700 text-xs font-medium rounded-lg border border-slate-200 hover:bg-slate-50 transition-all shadow-sm">
          Select Images
        </button>
      </div>
    </>
  );
};

export default ProductImagesSection;
