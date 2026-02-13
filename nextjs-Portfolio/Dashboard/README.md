# 📊 Dashboard Elements

<p align="center">
  <img src="assets/dashboard.png" width="90%" alt="Dashboard Elements Preview" />
</p>

<p align="center">
  <b>A modern, component-driven admin dashboard built with Next.js</b><br/>
  Focused on scalability, real-world workflows, and clean UI architecture.
</p>

<p align="center">
  🔗 <b>Live Demo:</b> <a href="https://dashboard-elements.vercel.app/admin">https://dashboard-elements.vercel.app/admin</a>
</p>

---

## 🚀 Project Overview

**Dashboard Elements** is a frontend-first admin panel designed to showcase how modern dashboards should be structured, composed, and scaled.

Instead of focusing only on visuals, this project emphasizes:

- ✨ Real admin workflows (dashboard, products, forms)
- 🧱 Reusable, isolated UI components
- 🎞 Smooth, purposeful animations
- 📊 Data visualization with charts
- ⚙️ Clean architecture suitable for production dashboards

### This project can be used as:

- 🚀 Admin dashboard starter
- 🎨 UI reference for SaaS products
- 🧩 Component showcase for dashboards

---

## 🧩 Tech Stack

### ⚙️ Framework

- 🟢 **Next.js 16**
- ⚛️ **React 19**

### 🎨 Styling & UI

- 🎯 Tailwind CSS
- 🧩 class-variance-authority
- 🧠 clsx
- 🎨 tailwind-merge
- ✨ tailwindcss-animate

### 🧱 Headless UI (Radix)

- @radix-ui/react-dialog
- @radix-ui/react-dropdown-menu
- @radix-ui/react-select
- @radix-ui/react-slot
- @radix-ui/react-switch

### 🎞 Animation

- 🎬 framer-motion
- 🌀 motion

### 📊 Charts & Visualization

- 📈 recharts

### 🛠 Utilities

- 🎨 lucide-react

---

## 🧭 Application Structure

```txt
src/
├─ app/
│  └─ admin/
│
├─ components/
│  ├─ Dashboard/
│  ├─ Products/
│  ├─ Shop/
│  ├─ ShowCase/
│  ├─ react-bits/
│  └─ ui/
│
├─ const/
└─ lib/
```

### 🧱 Architecture Highlights

- 🧱 **Component-driven architecture**
- ♻️ **High reusability** across pages
- 🛠 **Easy to extend** with new modules

### 🖥 Dashboard Pages & Features

#### 📊 Admin Dashboard

<p style="display:flex; justify-content:center; gap:10px;">
  <img src="assets/admin-1.png" width="48%" />
  <img src="assets/admin-2.png" width="48%" />
</p>

- ✨ **Stats cards** & analytics overview
- 📈 **Chart-based** data visualization
- 🎞 **Animated** UI interactions

#### 📦 Products Management

<p align="center">
  <img src="assets/productlist.png" width="30%" />
  <img src="assets/add-product1.png" width="30%" />
  <img src="assets/add-product2.png" width="30%" />
</p>

- 🧾 **Products listing** layout
- ➕ **Add product** form
- 🧩 **Modular product components**

#### 🧪 Showcase & UI Elements

<p align="center">
  <img src="assets/showcase.png" width="90%" />
</p>

- 🎨 **UI component showcase**
- 🧱 **Radix-based** interactive elements
- 🎞 **Motion-enhanced** micro-interactions

### 📱 Responsive Design

- 📱 **Mobile-friendly** layouts
- 📟 **Tablet-optimized** components
- 🖥 **Desktop-first** admin experience

The dashboard adapts cleanly across screen sizes without breaking layout consistency.

### 📁 Assets Management

All README images are stored in a root-level `assets/` folder:

```txt
assets/
├─ dashboard.png
├─ admin-1.png
├─ admin-2.png
├─ admin-3.png
├─ productlist.png
├─ add-product1.png
└─ add-product2.png
```

### ⚙️ Local Setup

```bash
npm install
npm run dev
```

### 🚀 Deployment

- ☁️ **Deployed on Vercel**
- ⚡ **Optimized production builds**
- 🚄 **Fast routing and rendering**
