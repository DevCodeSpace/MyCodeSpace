// Importing necessary packages for colors, tab widgets, and Flutter material/Cupertino widgets
import 'package:banking_store/Export/export.dart';
import 'package:flutter/cupertino.dart' as cupertino;

// Defines the TabPage as a stateful widget
class TabPage extends StatefulWidget {
  // Constructor with optional key parameter
  const TabPage({super.key});

  @override
  // Creates the state for the TabPage widget
  State<TabPage> createState() => _TabPageState();
}

// State class for TabPage with TickerProviderStateMixin for animations
class _TabPageState extends State<TabPage> with TickerProviderStateMixin {
  // Declares a TabController for managing tab navigation
  late TabController tabController;
  // Tracks the currently selected tab index
  int selectedTabIndex = 0;

  @override
  // Initializes the state of the widget
  void initState() {
    super.initState();
    // Initializes the TabController with 4 tabs and sets the initial index
    tabController = TabController(
      initialIndex: selectedTabIndex,
      length: 4,
      vsync: this, // Provides animation ticker for smooth transitions
    );

    // Adds a listener to update selectedTabIndex when the tab changes
    tabController.addListener(() {
      setState(() {
        selectedTabIndex = tabController.index;
      });
    });
  }

  @override
  // Builds the UI for the TabPage
  Widget build(BuildContext context) {
    // Wraps the scaffold with DefaultTabController for tab management
    return DefaultTabController(
      length: 4, // Specifies the number of tabs
      initialIndex: selectedTabIndex, // Sets the initial tab index
      child: Scaffold(
        // Uses a Stack to layer the tab content and bottom navigation bar
        body: Stack(
          children: [
            // Positioned widget to fill the screen with tab content
            Positioned.fill(
              child: TabBarView(
                controller: tabController, // Associates the TabController
                children: [
                  // Displays the HomeTab for the first tab
                  HomeTab(),
                  // Displays the WalletTab for the second tab
                  WalletTab(),
                  // Displays the InsightsTab for the third tab, passing the TabController
                  InsightsTab(controller: tabController),
                  // Displays the ProfileTab for the fourth tab
                  ProfileTab(),
                ],
              ),
            ),
            // AnimatedPositioned widget for the bottom navigation bar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300), // Animation duration
              // Hides the navigation bar when InsightsTab (index 2) is selected
              bottom: selectedTabIndex == 2 ? -100 : 0,
              left: 0,
              right: 0,
              height: 80,
              // Container for the bottom navigation bar
              child: Container(
                height: 80,
                // Applies white background and rounded top corners
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                // Row to arrange tab icons evenly
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // GestureDetector for navigating to the Home tab
                    GestureDetector(
                      onTap: () => _animateTab(0), // Switches to Home tab
                      child: Icon(
                        cupertino.CupertinoIcons.home,
                        // Changes icon color based on selection
                        color:
                            selectedTabIndex == 0
                                ? StoreColors.darkBrown
                                : Colors.grey.withValues(alpha: 0.7),
                        size: 30,
                      ),
                    ),
                    // GestureDetector for navigating to the Wallet tab
                    GestureDetector(
                      onTap: () => _animateTab(1), // Switches to Wallet tab
                      child: Icon(
                        Icons.wallet,
                        // Changes icon color based on selection
                        color:
                            selectedTabIndex == 1
                                ? StoreColors.darkBrown
                                : Colors.grey.withValues(alpha: 0.7),
                        size: 30,
                      ),
                    ),
                    // GestureDetector for navigating to the Insights tab
                    GestureDetector(
                      onTap: () => _animateTab(2), // Switches to Insights tab
                      child: Icon(
                        Icons.calculate_rounded,
                        // Changes icon color based on selection
                        color:
                            selectedTabIndex == 2
                                ? StoreColors.darkBrown
                                : Colors.grey.withValues(alpha: 0.7),
                        size: 30,
                      ),
                    ),
                    // GestureDetector for navigating to the Profile tab
                    GestureDetector(
                      onTap: () => _animateTab(3), // Switches to Profile tab
                      child: Icon(
                        Icons.person,
                        // Changes icon color based on selection
                        color:
                            selectedTabIndex == 3
                                ? StoreColors.darkBrown
                                : Colors.grey.withValues(alpha: 0.7),
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to animate tab transitions
  void _animateTab(int index) {
    // Animates to the specified tab index
    tabController.animateTo(index);
  }
}
