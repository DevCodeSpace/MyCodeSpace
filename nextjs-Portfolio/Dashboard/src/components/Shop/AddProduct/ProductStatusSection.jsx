import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import React from "react";

const ProductStatusSection = () => {
  return (
    <>
      {" "}
      <h2 className="text-lg font-semibold text-slate-900 mb-6">Status</h2>
      <Select defaultValue="draft">
        <SelectTrigger className="w-full bg-slate-50 border-slate-200 text-slate-900">
          <div className="flex items-center gap-2">
            <div className="w-2 h-2 rounded-full bg-amber-500" />
            <SelectValue placeholder="Select status" />
          </div>
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="draft">Draft</SelectItem>
          <SelectItem value="active">Active</SelectItem>
          <SelectItem value="archived">Archived</SelectItem>
        </SelectContent>
      </Select>
      <p className="text-xs text-slate-500 mt-3">Set the product status.</p>
    </>
  );
};

export default ProductStatusSection;
