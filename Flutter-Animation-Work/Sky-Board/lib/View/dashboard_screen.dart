// Dashboard Screen View
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sky_board/Controller/dashboard_controller.dart';
import 'package:sky_board/View/neumorphic_container.dart';

// Main Dashboard Screen using GetX for state management
class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE0E5EC),
      body: SafeArea(
        // AnimatedBuilder listens to multiple animation controllers to rebuild UI
        child: AnimatedBuilder(
          animation: Listenable.merge([
            controller.headerController,
            controller.weatherController,
            controller.statsController,
            controller.quickActionsController,
            controller.recentController,
            controller.pulseController,
          ]),
          builder: (context, child) {
            return RefreshIndicator(
              onRefresh: controller.refreshDashboard,
              color: Color(0xFF667eea),
              backgroundColor: Color(0xFFE0E5EC),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),            // Top greeting and icons
                    SizedBox(height: 25),
                    _buildWeatherCard(),      // Weather widget
                    SizedBox(height: 25),
                    _buildStatsGrid(),        // Stats/metrics section
                    SizedBox(height: 25),
                    _buildQuickActions(),     // Quick action buttons
                    SizedBox(height: 25),
                    _buildRecentActivity(),   // Recent activity list
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Header section with greeting, user name, notification & profile buttons
  Widget _buildHeader() {
    return Transform.translate(
      offset: Offset(0, controller.headerSlideAnimation.value),
      child: Opacity(
        opacity: controller.headerFadeAnimation.value,
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Greeting and user name
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.userData.value.greeting,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF9BAACF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    controller.userData.value.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C7293),
                    ),
                  ),
                ],
              ),
              // Notification and profile icons
              Row(
                children: [
                  // Notification button with pulse animation
                  GestureDetector(
                    onTap: controller.openNotifications,
                    child: NeumorphicContainer(
                      width: 50,
                      height: 50,
                      borderRadius: 25,
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(
                              Icons.notifications_outlined,
                              color: Color(0xFF6C7293),
                              size: 24,
                            ),
                          ),
                          if (controller.userData.value.notificationCount > 0)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: AnimatedBuilder(
                                animation: controller.pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: controller.pulseAnimation.value,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFFF6B6B),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  // Profile icon button
                  GestureDetector(
                    onTap: controller.openProfile,
                    child: NeumorphicContainer(
                      width: 50,
                      height: 50,
                      borderRadius: 25,
                      child: Container(
                        margin: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Weather card with temperature, condition and location
  Widget _buildWeatherCard() {
    return Transform.scale(
      scale: controller.weatherScaleAnimation.value,
      child: GestureDetector(
        onTap: controller.refreshWeather,
        child: Obx(
          () => NeumorphicContainer(
            height: 180,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(25),
                child: Row(
                  children: [
                    // Weather text info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.weatherData.value.location,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            controller.weatherData.value.temperature,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            controller.weatherData.value.condition,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Rotating weather icon
                    Transform.rotate(
                      angle:
                          controller.weatherRotateAnimation.value *
                          2 *
                          math.pi *
                          0.1,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          controller.weatherData.value.icon,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Grid displaying various statistics
  Widget _buildStatsGrid() {
    return Transform.translate(
      offset: Offset(controller.statsSlideAnimation.value, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6C7293),
            ),
          ),
          SizedBox(height: 15),
          Obx(
            () => Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildStatCard(0)),
                    SizedBox(width: 15),
                    Expanded(child: _buildStatCard(1)),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(child: _buildStatCard(2)),
                    SizedBox(width: 15),
                    Expanded(child: _buildStatCard(3)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Builds individual statistic card by index
  Widget _buildStatCard(int index) {
    final stat = controller.statsCards[index];
    return GestureDetector(
      onTap: () => controller.onStatCardTap(index),
      child: NeumorphicContainer(
        height: 135,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon and percentage change
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: stat.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(stat.icon, color: stat.color, size: 20),
                  ),
                  Text(
                    stat.change,
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Spacer(),
              // Title and value
              Text(
                stat.title,
                style: TextStyle(color: Color(0xFF9BAACF), fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                stat.value,
                style: TextStyle(
                  color: Color(0xFF6C7293),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Quick Actions Section
  Widget _buildQuickActions() {
    return Transform.scale(
      scale: controller.quickActionsAnimation.value,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6C7293),
            ),
          ),
          SizedBox(height: 15),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                controller.quickActions.length,
                (index) => _buildActionButton(index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds individual quick action button
  Widget _buildActionButton(int index) {
    final action = controller.quickActions[index];
    return GestureDetector(
      onTap: () => controller.onQuickActionTap(index),
      child: Column(
        children: [
          NeumorphicContainer(
            width: 60,
            height: 60,
            borderRadius: 30,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [action.color, action.color.withValues(alpha: 0.8)],
                ),
              ),
              child: Icon(action.icon, color: Colors.white, size: 28),
            ),
          ),
          SizedBox(height: 8),
          Text(
            action.label,
            style: TextStyle(
              color: Color(0xFF6C7293),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Recent Activity Section
  Widget _buildRecentActivity() {
    return Opacity(
      opacity: controller.recentFadeAnimation.value,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6C7293),
            ),
          ),
          SizedBox(height: 15),
          Obx(
            () => Column(
              children: List.generate(
                controller.recentActivities.length,
                (index) => _buildActivityItem(index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds individual recent activity item
  Widget _buildActivityItem(int index) {
    final activity = controller.recentActivities[index];
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: Transform.translate(
        offset: Offset(
          0,
          (1 - controller.recentFadeAnimation.value) * 50 * (index + 1),
        ),
        child: GestureDetector(
          onTap: () => controller.onActivityItemTap(index),
          child: NeumorphicContainer(
            height: 85,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: activity.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(activity.icon, color: activity.color, size: 20),
                  ),
                  SizedBox(width: 15),
                  // Title and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          activity.title,
                          style: TextStyle(
                            color: Color(0xFF6C7293),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          activity.subtitle,
                          style: TextStyle(
                            color: Color(0xFF9BAACF),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF9BAACF),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
