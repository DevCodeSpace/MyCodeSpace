// Profile Screen View
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:profimotion/Controller/profile_controller.dart';
import 'package:profimotion/View/neumorphic_container.dart';

// Main Profile Screen using GetX
class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE0E5EC),
      body: SafeArea(
        child: AnimatedBuilder(
          animation:
              controller.mainController, // Rebuilds on main animation changes
          builder: (context, child) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildHeader(), // Top header with back and more buttons
                    SizedBox(height: 30),
                    _buildProfileAvatar(), // Circular profile picture with camera icon
                    SizedBox(height: 20),
                    _buildNameSection(), // User name, title, location
                    SizedBox(height: 30),
                    _buildStatsSection(), // Stats: Projects, Followers, Following
                    SizedBox(height: 30),
                    _buildActionButtons(), // Follow, Message, Call buttons
                    SizedBox(height: 30),
                    _buildMenuItems(), // List of menu items with animation
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Header with back button, title, and more options
  Widget _buildHeader() {
    return Transform.translate(
      offset: Offset(controller.slideAnimation.value, 0),
      child: Opacity(
        opacity: controller.fadeAnimation.value,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            GestureDetector(
              onTap: controller.goBack,
              child: NeumorphicContainer(
                width: 50,
                height: 50,
                child: Icon(Icons.arrow_back, color: Color(0xFF6C7293)),
              ),
            ),
            // Title
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C7293),
              ),
            ),
            // More options button
            GestureDetector(
              onTap: controller.showMoreOptions,
              child: NeumorphicContainer(
                width: 50,
                height: 50,
                child: Icon(Icons.more_vert, color: Color(0xFF6C7293)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Profile Avatar with camera button overlay
  Widget _buildProfileAvatar() {
    return Transform.scale(
      scale: controller.scaleAnimation.value,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer neumorphic avatar container
          NeumorphicContainer(
            width: 140,
            height: 140,
            borderRadius: 70,
            child: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ClipOval(
                child: Container(
                  color: Colors.transparent,
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ), // Placeholder icon
                ),
              ),
            ),
          ),
          // Camera icon button
          Positioned(
            bottom: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: controller.fabController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: controller.rotateAnimation.value * 2 * 3.14159,
                  child: GestureDetector(
                    onTap: controller.openCamera,
                    child: NeumorphicContainer(
                      width: 40,
                      height: 40,
                      borderRadius: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                          ),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // User name, title, and location text
  Widget _buildNameSection() {
    return Transform.translate(
      offset: Offset(0, controller.slideAnimation.value),
      child: Opacity(
        opacity: controller.fadeAnimation.value,
        child: Obx(
          () => Column(
            children: [
              // Name
              Text(
                controller.userProfile.value.name,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C7293),
                ),
              ),
              SizedBox(height: 8),
              // Title
              Text(
                controller.userProfile.value.title,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF9BAACF),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              // Location
              Text(
                controller.userProfile.value.location,
                style: TextStyle(fontSize: 14, color: Color(0xFFB0B8D4)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Projects, Followers, Following stats
  Widget _buildStatsSection() {
    return Transform.scale(
      scale: controller.scaleAnimation.value,
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(controller.userProfile.value.projects, 'Projects'),
            _buildStatItem(controller.userProfile.value.followers, 'Followers'),
            _buildStatItem(controller.userProfile.value.following, 'Following'),
          ],
        ),
      ),
    );
  }

  // Single stat tile
  Widget _buildStatItem(String number, String label) {
    return NeumorphicContainer(
      width: 100,
      height: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6C7293),
            ),
          ),
          SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Color(0xFF9BAACF))),
        ],
      ),
    );
  }

  // Follow, Message, Call buttons row
  Widget _buildActionButtons() {
    return Transform.scale(
      scale: controller.scaleAnimation.value,
      child: Row(
        children: [
          // Follow / Following button with toggle
          Expanded(
            flex: 3,
            child: Obx(
              () => GestureDetector(
                onTap: controller.toggleFollow,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  child: NeumorphicContainer(
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: LinearGradient(
                          colors:
                              controller.isFollowing.value
                                  ? [Color(0xFF9BAACF), Color(0xFFB0B8D4)]
                                  : [Color(0xFF667eea), Color(0xFF764ba2)],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          controller.isFollowing.value ? 'Following' : 'Follow',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 15),
          // Message button
          Expanded(
            child: GestureDetector(
              onTap: controller.sendMessage,
              child: NeumorphicContainer(
                height: 50,
                child: Icon(Icons.message, color: Color(0xFF6C7293)),
              ),
            ),
          ),
          SizedBox(width: 15),
          // Call button
          Expanded(
            child: GestureDetector(
              onTap: controller.makeCall,
              child: NeumorphicContainer(
                height: 50,
                child: Icon(Icons.call, color: Color(0xFF6C7293)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds animated list of menu items
  Widget _buildMenuItems() {
    return AnimatedBuilder(
      animation: controller.listController,
      builder: (context, child) {
        return Obx(
          () => Column(
            children: List.generate(
              controller.menuItems.length,
              (index) => _buildAnimatedMenuItem(
                controller.menuItems[index]['icon'] as IconData,
                controller.menuItems[index]['title'] as String,
                index,
              ),
            ),
          ),
        );
      },
    );
  }

  // Single animated menu item row
  Widget _buildAnimatedMenuItem(IconData icon, String title, int index) {
    final double startInterval = (index * 0.15).clamp(0.0, 0.7); // start time
    final double endInterval = (0.4 + index * 0.15).clamp(0.4, 1.0); // end time

    // Slide in animation
    final animation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: controller.listController,
        curve: Interval(startInterval, endInterval, curve: Curves.easeOutBack),
      ),
    );

    // Fade-in animation
    final opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller.listController,
        curve: Interval(startInterval, endInterval, curve: Curves.easeIn),
      ),
    );

    return Transform.translate(
      offset: Offset(animation.value, 0),
      child: Opacity(
        opacity: opacityAnimation.value,
        child: Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: GestureDetector(
            onTapDown: (_) => controller.setPressed(true),
            onTapUp: (_) {
              controller.setPressed(false);
              controller.onMenuItemTap(index); // Trigger menu tap
            },
            onTapCancel: () => controller.setPressed(false),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 100),
              child: NeumorphicContainer(
                height: 70,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // Icon circle
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF667eea).withValues(alpha: 0.3),
                              Color(0xFF764ba2).withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                        child: Icon(icon, color: Color(0xFF6C7293), size: 22),
                      ),
                      SizedBox(width: 20),
                      // Title text
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6C7293),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Right arrow
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
        ),
      ),
    );
  }
}
