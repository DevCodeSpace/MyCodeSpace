// Importing necessary packages for widgets, configuration models, and extensions
import 'package:banking_store/Export/export.dart';
import 'package:banking_store/View/home/tabs/profile/configuration_model.dart';
import 'package:dart_extensions_pro/dart_extensions_pro.dart';

// Defines the ProfileTab as a stateless widget
class ProfileTab extends StatelessWidget {
  // Constructor with optional key parameter
  const ProfileTab({super.key});

  @override
  // Builds the UI for the ProfileTab
  Widget build(BuildContext context) {
    // Returns a Scaffold widget as the main structure
    return Scaffold(
      // Sets the background color of the scaffold to white
      backgroundColor: Colors.white,
      // Uses SingleChildScrollView to allow scrolling content
      body: SingleChildScrollView(
        // Column to arrange children vertically
        child: Column(
          children: [
            // Adds vertical spacing of 80 units
            80.hBox,
            // Clips a container with rounded corners for the profile header
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              // Container for the profile header with dark green background
              child: Container(
                color: StoreColors.darkGreen,
                height: 200,
                width: double.infinity,
                // Stack to layer decorative SVGs and profile widgets
                child: Stack(
                  children: [
                    // Positioned SVG at top-right with rotation and flip
                    Positioned(
                      top: -50,
                      right: -20,
                      height: 150,
                      child: Transform.flip(
                        flipY: true,
                        flipX: true,
                        child: Transform.rotate(
                          angle: pi / 1.8,
                          // Loads SVG asset with dark brown color filter
                          child: SvgPicture.asset(
                            "assets/svgs/svg-path.svg",
                            colorFilter: ColorFilter.mode(
                              StoreColors.darkBrown,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Positioned SVG at bottom-right with rotation and flip
                    Positioned(
                      bottom: -130,
                      right: -5,
                      height: 200,
                      child: Transform.flip(
                        flipY: false,
                        flipX: true,
                        child: Transform.rotate(
                          angle: pi / 2.9,
                          // Loads SVG asset with dark teal color filter
                          child: SvgPicture.asset(
                            'assets/svgs/svg-path.svg',
                            colorFilter: ColorFilter.mode(
                              StoreColors.darkTeal,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Positioned MenuWidget at top-right
                    Positioned(
                      top: 20,
                      right: 20,
                      child: MenuWidget(color: StoreColors.darkTeal),
                    ),
                    // Positioned ProfilePictureWidget with left padding
                    Positioned(child: ProfilePictureWidget().pOnly(l: 30)),
                  ],
                ),
              ),
            ),
            // Adds vertical spacing of 30 units
            30.hBox,
            // Iterates through dummy configuration models to display widgets
            for (final model in ConfigurationModel.dummy())
              getConfigurationWidget(model),
            // Adds vertical spacing of 15 units
            15.hBox,
            // Iterates through dummy1 configuration models to display widgets
            for (final model in ConfigurationModel.dummy1())
              getConfigurationWidget(model),
            // Adds vertical spacing of 15 units
            15.hBox,
            // Iterates through dummy2 configuration models to display widgets
            for (final model in ConfigurationModel.dummy2())
              getConfigurationWidget(model),
          ],
        ),
      ).pOnly(b: 90).pH(35), // Applies bottom and horizontal padding
    );
  }

  // Function to create a configuration widget based on a ConfigurationModel
  Container getConfigurationWidget(ConfigurationModel model) {
    // Returns a Container for each configuration item
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(vertical: 6),
      // Row to arrange icon, text, and trailing widgets
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Row for icon and configuration name
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Container for the configuration icon
              Container(
                height: 40,
                width: 40,
                // Applies color and rounded corners to the icon container
                decoration: BoxDecoration(
                  color: model.iconContainerColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                // Displays the icon with specified color and size
                child: Icon(model.icon, color: model.iconColor, size: 23),
              ),
              // Adds horizontal spacing of 10 units
              10.wBox,
              // Displays the configuration name
              Text(
                model.configurationName,
                style: regularTextStyle(color: Colors.black, 16),
              ),
            ],
          ),
          // Row for hint text and trailing widget
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Conditionally displays hint text if available
              if (model.hint != null)
                Text(
                  model.hint!,
                  style: mediumTextStyle(color: Colors.grey, 16),
                ),
              // Adds horizontal spacing of 10 units
              10.wBox,
              // Displays the trailing widget (e.g., switch or arrow)
              model.trailingWidget,
            ],
          ),
        ],
      ),
    );
  }
}
