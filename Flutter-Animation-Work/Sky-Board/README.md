# 📊 SkyBoard - Flutter Dashboard App

Beautiful Flutter dashboard app with stunning neumorphic UI and smooth animations. Experience elegant data visualization with advanced animation techniques and modern design patterns.

### App Animation Showcase 🎯

<img src="assets/readme_video/dashboard-animation.gif" alt="VPN App Demo" height="600" />


## ✨ Features

🎨 **Neumorphic Design** - Beautiful soft UI with realistic shadows and depth </br>
📊 **Interactive Dashboard** - Dynamic stats cards with real-time data display </br>
🌤️ **Weather Widget** - Animated weather card with location & temperature </br>
⚡ **Quick Actions** - Floating action buttons with gradient backgrounds </br>
🔔 **Smart Notifications** - Pulsing indicators with interactive bottom sheets </br>

## 📱 App Structure

### 🎨 Dashboard Screen
🎯 Animated header with personalized greetings </br>
🎯 Weather card with rotating icon animations </br>
🎯 Stats grid with sliding entrance effects </br>
🎯 Quick action buttons with scale animations </br>
🎯 Recent activity list with staggered fade-in </br>

### 🔧 Controller Architecture
🎯 Multiple animation controllers for complex sequences </br>
🎯 Reactive state management with GetX observables </br>
🎯 Comprehensive data models for all components </br>
🎯 Pull-to-refresh functionality with smooth animations </br>

## 🎨 Animation Magic

### Core Techniques
🔥 **AnimationController** - Six controllers for orchestrated sequences </br>
🔥 **Tween & Curves** - Elastic, bounce and ease-out motion effects </br>
🔥 **Transform** - Scale, translate & rotation animations </br>

### Advanced Features
⚡ **Staggered Animations** - Sequential entrance with precise timing </br>
⚡ **Pulse Effects** - Continuous notification badge animations </br>
⚡ **Pull-to-Refresh** - Interactive data refresh with feedback </br>

## 🛠️ Project Structure

```
lib/
├── main.dart                      # Entry point with GetX setup
├── Controller/
│   └── dashboard_controller.dart  # Dashboard logic & animations
├── Model/
│   └── common_models.dart         # Data structures & models
├── View/
│   ├── dashboard_screen.dart      # Neumorphic dashboard UI
│   └── neumorphic_container.dart  # Reusable neumorphic widget
└── Routes/
    ├── app_pages.dart             # Route definitions
    ├── app_routes.dart            # Route constants
    └── binding.dart               # Dependency injection
```

## 🎯 Key Highlights

💡 **Performance Optimized** - Efficient rebuilds with AnimatedBuilder </br>
💡 **Memory Safe** - Proper controller disposal in onClose </br>
💡 **Responsive Design** - Adaptive layouts for all devices </br>
💡 **Modern Architecture** - GetX pattern with clean separation </br>



---

*Built with ❤️ DevCodeSpace using Flutter • Showcasing innovation in mobile development*