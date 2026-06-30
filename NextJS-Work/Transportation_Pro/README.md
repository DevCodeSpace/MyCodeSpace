<div align="center">

# 🚛 TransportPro

### India's All-in-One Transport & Logistics Management Platform

[![Next.js](https://img.shields.io/badge/Next.js-16.2.4-black?style=for-the-badge&logo=next.js)](https://nextjs.org/)
[![React](https://img.shields.io/badge/React-19-61DAFB?style=for-the-badge&logo=react)](https://react.dev/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5-3178C6?style=for-the-badge&logo=typescript)](https://www.typescriptlang.org/)
[![Tailwind CSS](https://img.shields.io/badge/TailwindCSS-4-06B6D4?style=for-the-badge&logo=tailwindcss)](https://tailwindcss.com/)
[![Vercel](https://img.shields.io/badge/Deployed%20on-Vercel-000000?style=for-the-badge&logo=vercel)](https://transportationnextjs.vercel.app)

**[Live Demo](https://transportationnextjs.vercel.app)** · **[Request Demo](https://transportationnextjs.vercel.app/#contact)** · **[Features](https://transportationnextjs.vercel.app/#features)**

</div>

---

## 📸 Preview

<div align="center">

![TransportPro Hero](./public/images/hero_illustration.webp)

> *Purpose-built transport management software for Indian logistics businesses — 11 powerful modules, 8+ report types, 100% GST compliant.*

</div>

---

## 📋 Table of Contents

- [About](#-about)
- [Live Demo](#-live-demo)
- [Tech Stack](#-tech-stack)
- [Features & Modules](#-features--modules)
- [Page Sections](#-page-sections)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Environment Variables](#-environment-variables)
- [API Routes](#-api-routes)
- [SEO & Performance](#-seo--performance)
- [Contact & Support](#-contact--support)

---

## 🔍 About

**TransportPro** is a high-performance marketing landing page built with **Next.js 16** and **React 19**, promoting a transport management software platform designed specifically for Indian logistics businesses.

The platform covers the full operations lifecycle:

- End-to-end **shipment loading** and **delivery tracking**
- **GST-ready invoicing** and freight billing
- **Auto freight calculation** with multi-party billing
- **8+ logistics reports** — commission, freight, invoice, pending delivery
- **Real-time stock dashboard** and operational analytics
- Specialized **Taka & Bale management** for textile transport
- Standalone **print engine** for transport receipts

> Built for transport companies across India — Surat, Ahmedabad, Vadodara, Rajkot, Mumbai, Pune.

---

## 🌐 Live Demo

| Environment | URL |
|---|---|
| Production | [https://transportationnextjs.vercel.app](https://transportationnextjs.vercel.app) |
| Request Demo | [https://transportationnextjs.vercel.app/#contact](https://transportationnextjs.vercel.app/#contact) |

---

## 🛠 Tech Stack

| Technology | Version | Purpose |
|---|---|---|
| [Next.js](https://nextjs.org/) | 16.2.4 | React framework with App Router |
| [React](https://react.dev/) | 19.2.4 | UI library |
| [TypeScript](https://www.typescriptlang.org/) | 5 | Type safety |
| [Tailwind CSS](https://tailwindcss.com/) | 4 | Utility-first styling |
| [Framer Motion](https://www.framer.com/motion/) | 12 | Animations |
| [Lucide React](https://lucide.dev/) | 1.14 | Icon library |
| [Nodemailer](https://nodemailer.com/) | 8 | Contact form email delivery |
| [IBM Plex Sans](https://fonts.google.com/specimen/IBM+Plex+Sans) | — | Typography |

---

## ✨ Features & Modules

### 11 Core Platform Modules

| # | Module | Description |
|---|---|---|
| 1 | **Shipment Loading** | High-speed loading interface — truck numbers, destination routes, party assignments |
| 2 | **Delivery Workflow** | Log consignee details, GST info, and receipting end-to-end |
| 3 | **Analytics Dashboard** | Real-time business summary — active parties, delivery performance, inventory status |
| 4 | **Financial Reports** | Commission, freight, and bill reports with revenue and outstanding visibility |
| 5 | **Admin Control Panel** | User accounts, party masters, data accuracy, and access control |
| 6 | **Print Engine** | High-fidelity transport receipts and report printing with localized layout |
| 7 | **Taka & Bale Management** | Textile shipment tracking — Taka counts and Bale numbers per invoice |
| 8 | **Freight Calculation** | Auto-calculates base freight; generates party-wise invoices instantly |
| 9 | **Unified Delivery Interface** | Receipt numbers, tempo details, Cash / Cheque / RTGS / Credit payment support |
| 10 | **Logistics Reports (8+)** | Pending Delivery, Invoice, Freight, Commission, Stock, Taka Summation reports |
| 11 | **Real-time Stock Dashboard** | Live warehouse insights — total parties, stock levels, transit trends |

### Key Highlights

- ✅ **100% GST Compliant** — Every invoice and report is tax-ready by default
- ⚡ **Zero billing errors** — Auto freight calculation eliminates manual mistakes
- 🏭 **Textile logistics specialist** — Only platform with native Taka & Bale tracking
- 📊 **500+ shipments managed daily** across 200+ clients
- 🔒 **Role-based access control** — Secure, admin-configurable permissions
- 🚀 **Day-one ready** — Teams are operational from the very first day

---

## 📄 Page Sections

The landing page is composed of the following sections:

| Section | Description |
|---|---|
| **Navbar** | Sticky nav with scroll-aware active state detection and mobile menu |
| **Hero** | Main headline, feature bullets, stats strip (11+ modules, 8+ reports, 100% GST, 24/7) |
| **Features** | 11-module grid with icon cards and a custom workflow CTA |
| **How It Works** | 4-step workflow — Setup → Load & Dispatch → Track & Collect → Report & Grow |
| **Why TransportPro** | 6 differentiators + feature comparison table vs. generic software |
| **Testimonials** | 6 client stories with 4.9/5 aggregate rating from 200+ happy clients |
| **FAQ** | 10 questions accordion with sticky sidebar CTA |
| **Contact** | Demo request form with server-side validation and email delivery |
| **Footer** | Platform links, module nav, contact info, legal pages |

### Additional Pages

| Page | Route |
|---|---|
| Privacy Policy | `/privacy-policy` |
| Terms of Use | `/terms-of-use` |
| Support | `/support` |

---

## 📁 Project Structure

```
TransportPro/
├── app/
│   ├── api/
│   │   ├── contact/route.ts      # Demo request form API + email
│   │   └── support/route.ts      # Support form API
│   ├── privacy-policy/page.tsx
│   ├── terms-of-use/page.tsx
│   ├── support/page.tsx
│   ├── globals.css
│   ├── layout.tsx                # Root layout, metadata, GA, JSON-LD
│   ├── manifest.ts
│   ├── not-found.tsx
│   ├── page.tsx                  # Home page
│   ├── robots.ts
│   └── sitemap.ts
├── components/
│   ├── sections/
│   │   ├── HeroSection.tsx
│   │   ├── FeaturesSection.tsx
│   │   ├── HowItWorksSection.tsx
│   │   ├── WhySection.tsx
│   │   ├── StatsSection.tsx      # Testimonials
│   │   ├── ProblemSection.tsx    # FAQ accordion
│   │   └── ContactSection.tsx
│   ├── Navbar.tsx
│   ├── Footer.tsx
│   └── SupportForm.tsx
├── lib/
│   ├── mailer.ts                 # Nodemailer transporter config
│   └── siteConfig.ts             # Centralised site metadata
├── public/
│   └── images/
│       └── hero_illustration.webp
└── package.json
```

---

## 🚀 Getting Started

### Prerequisites

- **Node.js** 18+ (LTS recommended)
- **npm** or **yarn**

### Installation

```bash
# Clone the repository
git clone https://github.com/DevCodeSpace/Transportation_Pro.git

# Navigate into the project
cd Transportation_Pro

# Install dependencies
npm install
```

### Development

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

### Production Build

```bash
npm run build
npm start
```

### Lint

```bash
npm run lint
```

---

## 🔑 Environment Variables

Create a `.env.local` file in the root directory:

```env
# Site URL (used for canonical URLs, Open Graph, and JSON-LD)
NEXT_PUBLIC_SITE_URL=https://your-domain.com

# Google Analytics Measurement ID (optional)
NEXT_PUBLIC_GA_ID=G-XXXXXXXXXX

# Nodemailer — SMTP credentials for contact form email delivery
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USER=your-email@gmail.com
MAIL_PASS=your-app-password
MAIL_FROM=TransportPro <your-email@gmail.com>
MAIL_TO=recipient@example.com
```

> **Note:** For Gmail, generate an [App Password](https://support.google.com/accounts/answer/185833) instead of using your account password.

---

## 📡 API Routes

### `POST /api/contact`

Handles the demo request form submission.

**Request body:**
```json
{
  "name": "Rajesh Patel",
  "company": "Patel Transport Co.",
  "phone": "+91 7405545576",
  "email": "rajesh@example.com",
  "industry": "Logistics",
  "message": "I'd like a demo of the freight module."
}
```

**Validation rules:**
- `name` — required, 2–100 characters
- `phone` — required, valid Indian mobile number (`+91/91/0` prefix + 10 digits starting 6–9)
- `email` — required, valid email format
- `company` — optional, max 100 characters
- `message` — optional, max 1000 characters

**Responses:**
| Status | Description |
|---|---|
| `200` | Email sent successfully |
| `400` | Validation errors (returns field-level error map) |
| `500` | Email delivery failure |

---

## 🔍 SEO & Performance

This project is built with SEO and Core Web Vitals in mind:

- **Schema.org JSON-LD** — `Organization`, `WebSite`, `SoftwareApplication`, `FAQPage`
- **Open Graph & Twitter Cards** — full social sharing metadata
- **Canonical URLs** — configured via `siteConfig.ts`
- **`robots.txt`** — generated via `app/robots.ts`
- **`sitemap.xml`** — generated via `app/sitemap.ts`
- **PWA Manifest** — `app/manifest.ts`
- **Font optimisation** — IBM Plex Sans via `next/font/google` with `display: swap`
- **Google Analytics** — loaded with `afterInteractive` strategy (zero render-blocking)
- **Image priority** — hero illustration uses `priority` on Next.js `<Image />`
- **Email anti-scraping** — contact email constructed client-side to prevent bot harvesting
- **Responsive design** — fully mobile-first with Tailwind CSS

---

## 📞 Contact & Support

| Channel | Details |
|---|---|
| 📍 Location | Surat, Gujarat, India |
| 🌐 Website | [transportationnextjs.vercel.app](https://transportationnextjs.vercel.app) |
| ⏱ Response Time | Within 2 business hours |

---

## 📜 License

This project is proprietary software. All rights reserved.

© 2025 TransportPro. Built for Transport & Logistics Businesses.

---

<div align="center">

**[⬆ Back to top](#-transportpro)**

Made with ❤️ for Indian logistics businesses

</div>
