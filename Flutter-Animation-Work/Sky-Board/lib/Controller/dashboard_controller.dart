// GetX Controller for Dashboard
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Model/common_models.dart';

// Controller responsible for managing the state and animations of the dashboard
class DashboardController extends GetxController
    with GetTickerProviderStateMixin {
  // Animation Controllers for different dashboard sections
  late AnimationController headerController;
  late AnimationController weatherController;
  late AnimationController statsController;
  late AnimationController quickActionsController;
  late AnimationController recentController;
  late AnimationController pulseController;

  // Various animations tied to controllers
  late Animation<double> headerFadeAnimation;
  late Animation<double> headerSlideAnimation;
  late Animation<double> weatherScaleAnimation;
  late Animation<double> weatherRotateAnimation;
  late Animation<double> statsSlideAnimation;
  late Animation<double> quickActionsAnimation;
  late Animation<double> recentFadeAnimation;
  late Animation<double> pulseAnimation;

  // Reactive user data with initial dummy values
  var userData =
      UserData(
        name: 'John Doe',
        greeting: 'Good Morning',
        notificationCount: 3,
      ).obs;

  // Reactive weather data with sample values
  var weatherData =
      WeatherData(
        location: 'San Francisco',
        temperature: '24°C',
        condition: 'Partly Cloudy',
        icon: Icons.wb_sunny,
      ).obs;

  // List of stat cards to show dashboard metrics
  var statsCards =
      <StatCard>[
        StatCard(
          title: 'Revenue',
          value: '\$12,450',
          icon: Icons.trending_up,
          color: Color(0xFF4CAF50),
          change: '+12%',
        ),
        StatCard(
          title: 'Orders',
          value: '1,247',
          icon: Icons.shopping_cart,
          color: Color(0xFF2196F3),
          change: '+8%',
        ),
        StatCard(
          title: 'Users',
          value: '2,847',
          icon: Icons.people,
          color: Color(0xFF9C27B0),
          change: '+24%',
        ),
        StatCard(
          title: 'Conversion',
          value: '3.2%',
          icon: Icons.show_chart,
          color: Color(0xFFFF9800),
          change: '+0.8%',
        ),
      ].obs;

  // List of quick actions available on the dashboard
  var quickActions =
      <QuickAction>[
        QuickAction(icon: Icons.send, label: 'Send', color: Color(0xFF667eea)),
        QuickAction(icon: Icons.add, label: 'Add', color: Color(0xFF4CAF50)),
        QuickAction(
          icon: Icons.qr_code_scanner,
          label: 'Scan',
          color: Color(0xFFFF9800),
        ),
        QuickAction(
          icon: Icons.more_horiz,
          label: 'More',
          color: Color(0xFF9C27B0),
        ),
      ].obs;

  // List of recent user activities
  var recentActivities =
      <ActivityItem>[
        ActivityItem(
          icon: Icons.payment,
          title: 'Payment received',
          subtitle: '2 minutes ago',
          color: Color(0xFF4CAF50),
        ),
        ActivityItem(
          icon: Icons.person_add,
          title: 'New user registered',
          subtitle: '15 minutes ago',
          color: Color(0xFF2196F3),
        ),
        ActivityItem(
          icon: Icons.shopping_bag,
          title: 'New order placed',
          subtitle: '1 hour ago',
          color: Color(0xFFFF9800),
        ),
      ].obs;

  // Flag to indicate whether dashboard is refreshing
  var isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAnimationControllers(); // Initialize animation controllers
    _setupAnimations(); // Define animation sequences
    _startAnimationSequence(); // Start animation in order
  }

  // Initialize all animation controllers with respective durations
  void _initializeAnimationControllers() {
    headerController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    weatherController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    statsController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    quickActionsController = AnimationController(
      duration: Duration(milliseconds: 1800),
      vsync: this,
    );
    recentController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
  }

  // Define tween-based animations and link them with their controllers
  void _setupAnimations() {
    headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: headerController, curve: Curves.easeInOut),
    );
    headerSlideAnimation = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(parent: headerController, curve: Curves.elasticOut),
    );
    weatherScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: weatherController, curve: Curves.bounceOut),
    );
    weatherRotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: weatherController, curve: Curves.easeInOut),
    );
    statsSlideAnimation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(parent: statsController, curve: Curves.easeOutBack),
    );
    quickActionsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: quickActionsController, curve: Curves.elasticOut),
    );
    recentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: recentController, curve: Curves.easeIn));
    pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );
  }

  // Sequence the animations with delays between them
  void _startAnimationSequence() {
    headerController.forward();
    Future.delayed(Duration(milliseconds: 300), () {
      weatherController.forward();
    });
    Future.delayed(Duration(milliseconds: 600), () {
      statsController.forward();
    });
    Future.delayed(Duration(milliseconds: 900), () {
      quickActionsController.forward();
    });
    Future.delayed(Duration(milliseconds: 1200), () {
      recentController.forward();
    });

    // Repeating pulse effect animation
    pulseController.repeat(reverse: true);
  }

  // Show bottom sheet with notifications
  void openNotifications() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFFE0E5EC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C7293),
              ),
            ),
            SizedBox(height: 20),
            // Generate notification items dynamically
            ...List.generate(userData.value.notificationCount, (index) {
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(180),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF667eea)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Notification ${index + 1}',
                        style: TextStyle(color: Color(0xFF6C7293)),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Display a simple snackbar when profile is tapped
  void openProfile() {
    Get.snackbar(
      'Profile',
      'Opening profile screen...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color(0xFF667eea),
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16),
    );
  }

  // Refresh weather and show snackbar
  void refreshWeather() {
    Get.snackbar(
      'Weather',
      'Weather data refreshed!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color(0xFF4facfe),
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16),
    );
  }

  // Handle quick action button taps
  void onQuickActionTap(int index) {
    String action = quickActions[index].label;

    switch (action) {
      case 'Send':
        Get.snackbar(
          'Send',
          'Send money feature coming soon!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Color(0xFF667eea),
          colorText: Colors.white,
          borderRadius: 12,
          margin: EdgeInsets.all(16),
        );
        break;
      case 'Add':
        Get.snackbar(
          'Add',
          'Add new item feature coming soon!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Color(0xFF4CAF50),
          colorText: Colors.white,
          borderRadius: 12,
          margin: EdgeInsets.all(16),
        );
        break;
      case 'Scan':
        Get.snackbar(
          'Scan',
          'QR Scanner feature coming soon!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Color(0xFFFF9800),
          colorText: Colors.white,
          borderRadius: 12,
          margin: EdgeInsets.all(16),
        );
        break;
      case 'More':
        // Show additional actions in bottom sheet
        Get.bottomSheet(
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFFE0E5EC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.analytics, color: Color(0xFF6C7293)),
                  title: Text(
                    'Analytics',
                    style: TextStyle(color: Color(0xFF6C7293)),
                  ),
                  onTap: () => Get.back(),
                ),
                ListTile(
                  leading: Icon(Icons.settings, color: Color(0xFF6C7293)),
                  title: Text(
                    'Settings',
                    style: TextStyle(color: Color(0xFF6C7293)),
                  ),
                  onTap: () => Get.back(),
                ),
                ListTile(
                  leading: Icon(Icons.help, color: Color(0xFF6C7293)),
                  title: Text(
                    'Help',
                    style: TextStyle(color: Color(0xFF6C7293)),
                  ),
                  onTap: () => Get.back(),
                ),
              ],
            ),
          ),
        );
        break;
    }
  }

  // Handle taps on stats cards
  void onStatCardTap(int index) {
    StatCard stat = statsCards[index];
    Get.snackbar(
      stat.title,
      'Viewing ${stat.title} details: ${stat.value}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: stat.color,
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16),
    );
  }

  // Handle taps on activity items
  void onActivityItemTap(int index) {
    ActivityItem activity = recentActivities[index];
    Get.snackbar(
      'Activity',
      activity.title,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: activity.color,
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16),
    );
  }

  // Refresh dashboard data and simulate an API call
  Future<void> refreshDashboard() async {
    isRefreshing.value = true;

    // Simulated delay to mimic API response
    await Future.delayed(Duration(seconds: 2));

    // Update greeting message based on current time
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    // Update user data with new greeting and incremented notifications
    userData.value = UserData(
      name: userData.value.name,
      greeting: greeting,
      notificationCount: userData.value.notificationCount + 1,
    );

    isRefreshing.value = false;

    Get.snackbar(
      'Refreshed',
      'Dashboard data updated!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color(0xFF4CAF50),
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16),
    );
  }

  // Dispose of all animation controllers when controller is destroyed
  @override
  void onClose() {
    headerController.dispose();
    weatherController.dispose();
    statsController.dispose();
    quickActionsController.dispose();
    recentController.dispose();
    pulseController.dispose();
    super.onClose();
  }
}
