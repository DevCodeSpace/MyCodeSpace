import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Edit, Eye, MoreHorizontal, Trash } from "lucide-react";
import React from "react";
import { motion } from "framer-motion";

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0 },
};

const ProductsTable = ({ PRODUCTS_DATA }) => {
  return (
    <>
      {" "}
      <div className="overflow-x-auto">
        <table className="w-full text-left text-sm">
          <thead className="bg-slate-50 text-slate-500 font-medium border-b border-slate-200">
            <tr>
              <th className="px-6 py-4">Product</th>
              <th className="px-6 py-4">Category</th>
              <th className="px-6 py-4">Price</th>
              <th className="px-6 py-4">Status</th>
              <th className="px-6 py-4">Stock</th>
              <th className="px-6 py-4 text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {PRODUCTS_DATA.map((product) => (
              <motion.tr
                key={product.id}
                variants={itemVariants}
                className="hover:bg-slate-50/50 transition-colors"
              >
                <td className="px-6 py-4">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-lg bg-slate-100 overflow-hidden flex-shrink-0">
                      <img
                        src={product.image}
                        alt={product.name}
                        className="w-full h-full object-cover"
                      />
                    </div>
                    <span className="font-medium text-slate-900">
                      {product.name}
                    </span>
                  </div>
                </td>
                <td className="px-6 py-4 text-slate-600">{product.category}</td>
                <td className="px-6 py-4 font-medium text-slate-900">
                  ${product.price}
                </td>
                <td className="px-6 py-4">
                  <span
                    className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                      product.status === "In Stock"
                        ? "bg-emerald-100 text-emerald-800"
                        : product.status === "Low Stock"
                          ? "bg-amber-100 text-amber-800"
                          : "bg-red-100 text-red-800"
                    }`}
                  >
                    {product.status}
                  </span>
                </td>
                <td className="px-6 py-4 text-slate-600">{product.stock}</td>
                <td className="px-6 py-4 text-right">
                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <button className="p-2 text-slate-400 hover:text-slate-600 rounded-lg hover:bg-slate-100 transition-colors outline-none">
                        <MoreHorizontal size={18} />
                      </button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end">
                      <DropdownMenuLabel>Actions</DropdownMenuLabel>
                      <DropdownMenuItem className="cursor-pointer gap-2">
                        <Edit size={16} />
                        Edit
                      </DropdownMenuItem>
                      <DropdownMenuItem className="cursor-pointer gap-2">
                        <Eye size={16} />
                        View
                      </DropdownMenuItem>
                      <DropdownMenuSeparator />
                      <DropdownMenuItem className="text-red-600 cursor-pointer gap-2 focus:text-red-600 focus:bg-red-50">
                        <Trash size={16} />
                        Delete
                      </DropdownMenuItem>
                    </DropdownMenuContent>
                  </DropdownMenu>
                </td>
              </motion.tr>
            ))}
          </tbody>
        </table>
      </div>
      <div className="px-6 py-4 border-t border-slate-200 bg-slate-50/50 flex items-center justify-between text-xs text-slate-500">
        <span>Showing 5 of 24 products</span>
        <div className="flex gap-2">
          <button className="px-3 py-1 border border-slate-200 rounded bg-white hover:bg-slate-50 disabled:opacity-50">
            Previous
          </button>
          <button className="px-3 py-1 border border-slate-200 rounded bg-white hover:bg-slate-50">
            Next
          </button>
        </div>
      </div>
    </>
  );
};

export default ProductsTable;
