// app/admin/page.tsx
import { Suspense } from "react";
import AdminClient from "./AdminClient";

export default function AdminPage() {
  return (
    <Suspense fallback={<AdminFallback />}>
      <AdminClient />
    </Suspense>
  );
}

// Simple fallback while the client component loads
function AdminFallback() {
  return (
    <div className="min-h-screen flex items-center justify-center text-slate-500">
      Loading admin dashboard…
    </div>
  );
}
