// GetX Controller for Profile Screen
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:profimotion/Model/user_profile_model.dart';

class ProfileController extends GetxController with GetTickerProviderStateMixin {
  // Animation Controllers for various animated elements
  late AnimationController mainController;
  late AnimationController fabController;
  late AnimationController listController;

  // Animation definitions
  late Animation<double> fadeAnimation;
  late Animation<double> slideAnimation;
  late Animation<double> scaleAnimation;
  late Animation<double> rotateAnimation;

  // Reactive variables using GetX observables
  var isPressed = false.obs;
  var isFollowing = false.obs;

  // Sample user profile data
  var userProfile = UserProfile(
    name: 'John Doe',
    title: 'UI/UX Designer',
    location: 'San Francisco, CA',
    projects: '127',
    followers: '2.1K',
    following: '486',
  ).obs;

  // Profile menu items
  final menuItems = [
    {'icon': Icons.person_outline, 'title': 'Personal Information'},
    {'icon': Icons.settings_outlined, 'title': 'Settings'},
    {'icon': Icons.payment_outlined, 'title': 'Payment Methods'},
    {'icon': Icons.help_outline, 'title': 'Help & Support'},
    {'icon': Icons.logout, 'title': 'Logout'},
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAnimationControllers(); // Set up animation controllers
    _setupAnimations();               // Configure animations
    _startAnimations();              // Trigger the animations
  }

  // Initializes animation controllers with respective durations
  void _initializeAnimationControllers() {
    mainController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    fabController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    listController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
  }

  // Sets up the actual animations using tweens and curves
  void _setupAnimations() {
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: mainController, curve: Curves.easeInOut),
    );

    slideAnimation = Tween<double>(begin: -100.0, end: 0.0).animate(
      CurvedAnimation(parent: mainController, curve: Curves.elasticOut),
    );

    scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: mainController, curve: Curves.bounceOut),
    );

    rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: fabController, curve: Curves.elasticOut),
    );
  }

  // Triggers animation in sequence with delays
  void _startAnimations() {
    mainController.forward();
    Future.delayed(Duration(milliseconds: 500), () {
      fabController.forward();
    });
    Future.delayed(Duration(milliseconds: 800), () {
      listController.forward();
    });
  }

  // Navigates back in the navigation stack
  void goBack() {
    Get.back();
  }

  // Displays bottom sheet with additional profile options
  void showMoreOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFFE0E5EC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: Color(0xFF6C7293)),
              title: Text('Edit Profile', style: TextStyle(color: Color(0xFF6C7293))),
              onTap: () => Get.back(),
            ),
            ListTile(
              leading: Icon(Icons.share, color: Color(0xFF6C7293)),
              title: Text('Share Profile', style: TextStyle(color: Color(0xFF6C7293))),
              onTap: () => Get.back(),
            ),
            ListTile(
              leading: Icon(Icons.block, color: Colors.red),
              title: Text('Block User', style: TextStyle(color: Colors.red)),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  // Stub for opening camera functionality
  void openCamera() {
    Get.snackbar(
      'Camera',
      'Camera functionality coming soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color(0xFF667eea),
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16),
    );
  }

  // Toggles follow/unfollow state and shows feedback
  void toggleFollow() {
    isFollowing.value = !isFollowing.value;

    String message = isFollowing.value ? 'Following ${userProfile.value.name}' : 'Unfollowed ${userProfile.value.name}';

    Get.snackbar(
      'Follow Status',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isFollowing.value ? Color(0xFF11998e) : Color(0xFF9BAACF),
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16),
    );
  }

  // Stub for sending message action
  void sendMessage() {
    Get.snackbar(
      'Message',
      'Opening chat with ${userProfile.value.name}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color(0xFF667eea),
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16),
    );
  }

  // Stub for making call action
  void makeCall() {
    Get.snackbar(
      'Call',
      'Calling ${userProfile.value.name}...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color(0xFF11998e),
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16),
    );
  }

  // Handles tap on menu items
  void onMenuItemTap(int index) {
    String title = menuItems[index]['title'] as String;

    if (title == 'Logout') {
      // Show confirmation dialog for logout
      Get.dialog(
        AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                Get.snackbar(
                  'Logout',
                  'Successfully logged out',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  borderRadius: 12,
                  margin: EdgeInsets.all(16),
                );
              },
              child: Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } else {
      // Show stub notification for other options
      Get.snackbar(
        title,
        '$title functionality coming soon!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFF667eea),
        colorText: Colors.white,
        borderRadius: 12,
        margin: EdgeInsets.all(16),
      );
    }
  }

  // Sets the pressed state of the UI element (e.g., for animations)
  void setPressed(bool pressed) {
    isPressed.value = pressed;
  }

  @override
  void onClose() {
    // Dispose animation controllers to avoid memory leaks
    mainController.dispose();
    fabController.dispose();
    listController.dispose();
    super.onClose();
  }
}

// GetX Binding for dependency injection
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // Lazily puts the ProfileController into memory when needed
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
