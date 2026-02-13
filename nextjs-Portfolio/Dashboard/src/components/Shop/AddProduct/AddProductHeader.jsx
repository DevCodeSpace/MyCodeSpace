import { Button } from "@/components/ui/button";
import { ChevronLeft } from "lucide-react";
import Link from "next/link";
import React from "react";

const AddProductHeader = () => {
  return (
    <>
      {" "}
      <div className="flex items-center gap-4">
        <Link
          href="/admin/products"
          className="p-2 border border-slate-200 bg-white rounded-lg hover:bg-slate-50 transition-colors text-slate-500 hover:text-slate-700"
        >
          <ChevronLeft size={20} />
        </Link>
        <h1 className="text-xl font-bold text-slate-900">Add Products</h1>
      </div>
      <div className="flex items-center gap-3">
        <Button className="px-4 py-2 text-sm font-medium text-slate-700 bg-white border border-slate-200 rounded-lg hover:bg-slate-50 transition-colors shadow-xs">
          Discard
        </Button>
        <Button className="px-4 py-2 text-sm font-medium text-violet-600 bg-violet-50 border border-violet-100 rounded-lg hover:bg-violet-100 transition-colors shadow-xs">
          Save Draft
        </Button>
        <Button className="px-4 py-2 text-sm font-medium text-white bg-violet-600 rounded-lg hover:bg-violet-700 transition-colors shadow-xs shadow-violet-500/20 ">
          Publish
        </Button>
      </div>
    </>
  );
};

export default AddProductHeader;
