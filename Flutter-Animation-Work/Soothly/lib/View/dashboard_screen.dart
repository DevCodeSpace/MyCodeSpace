// ONBOARDING SCREEN (Dashboard Screen)
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:soothly/Controller/dashboard_controller.dart';

// DashboardScreen uses GetX's GetView to connect with DashboardController
class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),

      // App Bar with title, notification icon and user avatar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Notification icon with badge
          GestureDetector(
            onTap: controller.onNotificationTap,
            child: Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: Colors.black54,
                  ),
                  onPressed: controller.onNotificationTap,
                ),
                // Reactive badge for unread notifications
                Obx(
                  () =>
                      controller.notificationCount.value > 0
                          ? Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${controller.notificationCount.value}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                          : SizedBox(),
                ),
              ],
            ),
          ),

          // Profile avatar with snackbar message
          GestureDetector(
            onTap:
                () => Get.snackbar(
                  'Profile',
                  'Profile feature coming soon!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Color(0xFF667eea),
                  colorText: Colors.white,
                  borderRadius: 12,
                  margin: EdgeInsets.all(16),
                ),
            child: Obx(
              () => CircleAvatar(
                backgroundColor: Color(0xFF667eea),
                child: Text(
                  controller.userName.value[0].toUpperCase(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
        ],
      ),

      // Pull-to-refresh and main scroll content
      body: RefreshIndicator(
        onRefresh: () => controller.refreshData(),
        color: Color(0xFF667eea),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome banner with slide and fade animation
              AnimatedBuilder(
                animation: controller.cardSlideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      50 * (1 - controller.cardSlideAnimation.value),
                    ),
                    child: Opacity(
                      opacity: math.max(
                        0.0,
                        math.min(1.0, controller.cardSlideAnimation.value),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF667eea).withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Greeting and welcome messages
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(
                                    () => Text(
                                      controller.greeting.value,
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Obx(
                                    () => Text(
                                      controller.welcomeMessage.value,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.wb_sunny_outlined,
                              color: Colors.white,
                              size: 40,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 30),

              // Overview section title
              Text(
                'Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 16),

              // Reactive list of statistics cards
              Obx(
                () => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildStatsCard(0)),
                        SizedBox(width: 16),
                        Expanded(child: _buildStatsCard(1)),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildStatsCard(2)),
                        SizedBox(width: 16),
                        Expanded(child: _buildStatsCard(3)),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Analytics section title
              Text(
                'Analytics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 16),

              // Animated chart container
              AnimatedBuilder(
                animation: controller.chartAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: math.max(
                      0.0,
                      math.min(1.0, controller.chartAnimation.value),
                    ),
                    child: Container(
                      height: 200,
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header of chart card
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sales Chart',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.more_horiz, color: Colors.grey),
                            ],
                          ),
                          SizedBox(height: 20),
                          // Animated chart bars
                          Expanded(child: _buildAnimatedChart()),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),

      // Floating Action Button with animated rotation
      floatingActionButton: AnimatedBuilder(
        animation: controller.fabRotation,
        builder: (context, child) {
          return Transform.rotate(
            angle: controller.fabRotation.value * 2 * math.pi,
            child: Obx(
              () => FloatingActionButton(
                onPressed: controller.toggleFabMenu,
                backgroundColor: Color(0xFF667eea),
                child: Icon(
                  controller.isMenuOpen.value ? Icons.close : Icons.add,
                ),
              ),
            ),
          );
        },
      ),

      // Bottom navigation bar with reactive tab selection
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: controller.onBottomNavTap,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Color(0xFF667eea),
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Wallet'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  // Builds a single statistics card with animation
  Widget _buildStatsCard(int index) {
    final card = controller.statsCards[index];
    return AnimatedBuilder(
      animation: controller.cardSlideAnimation,
      builder: (context, child) {
        final delay = index * 0.1;
        final rawAnimationValue =
            (controller.cardSlideAnimation.value - delay) / (1.0 - delay);
        final animationValue = Curves.easeOutBack.transform(
          math.max(0.0, math.min(1.0, rawAnimationValue)),
        );

        return Transform.translate(
          offset: Offset(0, 30 * (1 - animationValue)),
          child: Opacity(
            opacity: math.max(0.0, math.min(1.0, animationValue)),
            child: GestureDetector(
              onTap: () => controller.onStatsCardTap(index),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon row with badge and menu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: card.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(card.icon, color: card.color, size: 20),
                        ),
                        Icon(Icons.more_vert, color: Colors.grey, size: 16),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Card value
                    Text(
                      card.value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    // Card title
                    Text(
                      card.title,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Builds animated chart using bar animation and reactive data
  Widget _buildAnimatedChart() {
    return AnimatedBuilder(
      animation: controller.chartAnimation,
      builder: (context, child) {
        return Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(controller.chartData.length, (index) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 1000 + (index * 100)),
                height:
                    controller.chartData[index] *
                    controller.chartAnimation.value,
                width: 20,
                decoration: BoxDecoration(
                  color:
                      controller.chartColors[index %
                          controller.chartColors.length],
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
