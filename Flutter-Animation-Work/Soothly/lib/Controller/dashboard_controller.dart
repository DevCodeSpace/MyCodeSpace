

// DASHBOARD CONTROLLER
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:soothly/Model/common_model.dart';

class DashboardController extends GetxController with GetTickerProviderStateMixin {
  late AnimationController chartController;
  late AnimationController cardController;
  late AnimationController fabController;
  late Animation<double> chartAnimation;
  late Animation<double> cardSlideAnimation;
  late Animation<double> fabRotation;

  var selectedIndex = 0.obs;
  var isMenuOpen = false.obs;
  var userName = 'User'.obs;
  var greeting = 'Good Morning!'.obs;
  var welcomeMessage = 'Welcome back'.obs;
  var notificationCount = 3.obs;

  var statsCards = <StatsCardModel>[
    StatsCardModel(
      title: 'Total Sales',
      value: '\$12,345',
      icon: Icons.trending_up,
      color: Colors.green,
    ),
    StatsCardModel(
      title: 'Orders',
      value: '1,234',
      icon: Icons.shopping_cart,
      color: Colors.blue,
    ),
    StatsCardModel(
      title: 'Revenue',
      value: '\$8,765',
      icon: Icons.account_balance_wallet,
      color: Colors.purple,
    ),
    StatsCardModel(
      title: 'Customers',
      value: '567',
      icon: Icons.people,
      color: Colors.orange,
    ),
  ].obs;

  var chartData = [60.0, 80.0, 40.0, 100.0, 70.0, 90.0, 50.0].obs;
  var chartColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.pink
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    _startAnimations();
    _updateGreeting();
  }

  void _initializeAnimations() {
    chartController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    cardController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    fabController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: chartController, curve: Curves.elasticOut),
    );

    cardSlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: cardController, curve: Curves.easeOutBack),
    );

    fabRotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: fabController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    Future.delayed(Duration(milliseconds: 300), () {
      cardController.forward();
    });

    Future.delayed(Duration(milliseconds: 800), () {
      chartController.forward();
    });
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greeting.value = 'Good Morning!';
    } else if (hour < 17) {
      greeting.value = 'Good Afternoon!';
    } else {
      greeting.value = 'Good Evening!';
    }
  }

  void onBottomNavTap(int index) {
    selectedIndex.value = index;
    
    String navName = '';
    switch (index) {
      case 0:
        navName = 'Home';
        break;
      case 1:
        navName = 'Analytics';
        break;
      case 2:
        navName = 'Wallet';
        break;
      case 3:
        navName = 'Profile';
        break;
    }
    
    Get.snackbar(
      'Navigation',
      'Navigated to $navName',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color(0xFF667eea),
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16),
      duration: Duration(seconds: 1),
    );
  }

  void toggleFabMenu() {
    if (isMenuOpen.value) {
      fabController.reverse();
    } else {
      fabController.forward();
    }
    isMenuOpen.value = !isMenuOpen.value;

    Get.snackbar(
      'Menu',
      isMenuOpen.value ? 'Menu opened' : 'Menu closed',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isMenuOpen.value ? Colors.green : Colors.red,
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16),
      duration: Duration(seconds: 1),
    );
  }

  void onNotificationTap() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications (${notificationCount.value})',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            ...List.generate(notificationCount.value, (index) {
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(Icons.notifications, color: Color(0xFF667eea)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Notification ${index + 1}: You have a new message',
                        style: TextStyle(color: Colors.black87),
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

  void onStatsCardTap(int index) {
    final card = statsCards[index];
    Get.snackbar(
      card.title,
      'Current ${card.title.toLowerCase()}: ${card.value}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: card.color,
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16),
    );
  }

   refreshData() async {
    Get.snackbar(
      'Refreshing',
      'Updating dashboard data...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16),
      duration: Duration(seconds: 1),
    );

    // Simulate data refresh
    await Future.delayed(Duration(seconds: 1));
    
    // Update some values
    notificationCount.value += 1;
    _updateGreeting();
    
    // Restart animations
    cardController.reset();
    chartController.reset();
    _startAnimations();

    Get.snackbar(
      'Success',
      'Dashboard refreshed successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16),
    );
  }

  @override
  void onClose() {
    chartController.dispose();
    cardController.dispose();
    fabController.dispose();
    super.onClose();
  }
}
