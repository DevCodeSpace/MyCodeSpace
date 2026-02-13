import { Activity, DollarSign, TrendingUp, Users } from "lucide-react";

export const STATS_DATA = [
  {
    id: "total-revenue",
    label: "Total Revenue",
    value: "$45,231.89",
    trend: "+20.1% from last month",
    trendDir: "up",
    icon: DollarSign,
    color: "from-emerald-500 to-emerald-700", // Gradient definition for potential usage
  },
  {
    id: "active-users",
    label: "Active Users",
    value: "+2350",
    trend: "+180.1% from last month",
    trendDir: "up",
    icon: Users,
    color: "from-blue-500 to-blue-700",
  },
  {
    id: "bounce-rate",
    label: "Bounce Rate",
    value: "12.23%",
    trend: "-19% from last month",
    trendDir: "down", // 'down' in bounce rate is usually good, but we handle visual logic in UI
    icon: Activity,
    color: "from-rose-500 to-rose-700",
  },
  {
    id: "active-now",
    label: "Active Now",
    value: "+573",
    trend: "+201 since last hour",
    trendDir: "up",
    icon: TrendingUp,
    color: "from-violet-500 to-violet-700",
  },
];

export const REVENUE_DATA = [
  { name: "Jan", total: Math.floor(Math.random() * 5000) + 1000 },
  { name: "Feb", total: Math.floor(Math.random() * 5000) + 1000 },
  { name: "Mar", total: Math.floor(Math.random() * 5000) + 1000 },
  { name: "Apr", total: Math.floor(Math.random() * 5000) + 1000 },
  { name: "May", total: Math.floor(Math.random() * 5000) + 1000 },
  { name: "Jun", total: Math.floor(Math.random() * 5000) + 1000 },
  { name: "Jul", total: Math.floor(Math.random() * 5000) + 1000 },
  { name: "Aug", total: Math.floor(Math.random() * 5000) + 1000 },
  { name: "Sep", total: Math.floor(Math.random() * 5000) + 1000 },
  { name: "Oct", total: Math.floor(Math.random() * 5000) + 1000 },
  { name: "Nov", total: Math.floor(Math.random() * 5000) + 1000 },
  { name: "Dec", total: Math.floor(Math.random() * 5000) + 1000 },
];

export const ACTIVITY_DATA = [
  {
    id: 1,
    user: "Jackson Lee",
    action: "created a new project",
    target: "Dashboard UI",
    time: "2 minutes ago",
    avatar: "JL",
  },
  {
    id: 2,
    user: "Isabella Nguyen",
    action: "commented on",
    target: "Monthly Report",
    time: "15 minutes ago",
    avatar: "IN",
  },
  {
    id: 3,
    user: "William Kim",
    action: "deployed",
    target: "Production Build v2.4",
    time: "1 hour ago",
    avatar: "WK",
  },
  {
    id: 4,
    user: "Sofia Davis",
    action: "updated settings",
    target: "Account Security",
    time: "3 hours ago",
    avatar: "SD",
  },
];

export const PRODUCTS_DATA = [
  {
    id: 1,
    name: "Wireless Noise-Canceling Headphones",
    category: "Electronics",
    price: 299.99,
    stock: 45,
    status: "In Stock",
    image:
      "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=200&q=80",
  },
  {
    id: 2,
    name: "Ergonomic Office Chair",
    category: "Furniture",
    price: 189.5,
    stock: 12,
    status: "Low Stock",
    image:
      "https://images.unsplash.com/photo-1580480055273-228ff5388ef8?w=200&q=80",
  },
  {
    id: 3,
    name: "Smart Fitness Watch",
    category: "Wearables",
    price: 149.0,
    stock: 0,
    status: "Out of Stock",
    image:
      "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=200&q=80",
  },
  {
    id: 4,
    name: "Professional Camera Lens",
    category: "Photography",
    price: 899.99,
    stock: 8,
    status: "In Stock",
    image:
      "https://images.unsplash.com/photo-1617005082133-548c4dd27f35?w=200&q=80",
  },
  {
    id: 5,
    name: "Mechanical Keyboard",
    category: "Electronics",
    price: 129.99,
    stock: 25,
    status: "In Stock",
    image:
      "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=200&q=80",
  },
];
