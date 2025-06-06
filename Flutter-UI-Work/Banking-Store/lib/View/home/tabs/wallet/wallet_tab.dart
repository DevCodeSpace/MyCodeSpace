// Importing necessary packages for widgets, extensions, and custom exports
import 'package:banking_store/Export/export.dart';
import 'package:dart_extensions_pro/dart_extensions_pro.dart';

// Defines the WalletTab as a stateful widget
class WalletTab extends StatefulWidget {
  // Constructor with optional key parameter
  const WalletTab({super.key});

  @override
  // Creates the state for the WalletTab widget
  State<WalletTab> createState() => _WalletTabState();
}

// State class for WalletTab
class _WalletTabState extends State<WalletTab> {
  // Tracks the selected index for the time period filter
  int selectedIndex = 3;

  @override
  // Builds the UI for the WalletTab widget
  Widget build(BuildContext context) {
    // Defines a list of colors for portfolio items
    final colors = [
      StoreColors.darkGreen,
      StoreColors.ligthPink,
      StoreColors.darkTeal,
    ];
    // Defines a list of time period options for the chart filter
    final list = ['1D', '1M', '3M', '6M', '1Y', 'ALL'];
    // Returns a Scaffold widget as the main structure
    return Scaffold(
      // Sets the background color of the scaffold to white
      backgroundColor: Colors.white,
      // Uses a Stack to layer the content
      body: Stack(
        children: [
          // Positioned widget to hold the scrollable content
          Positioned(
            top: 0,
            // Sets height to screen height minus bottom navigation bar
            height: MediaQuery.of(context).size.height - 80,
            // SingleChildScrollView to enable scrolling
            child: SingleChildScrollView(
              // SizedBox to constrain the content width and height
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                // Column to arrange content vertically
                child: Column(
                  children: [
                    // Adds vertical spacing of 70 units
                    70.hBox,
                    // Row for search and settings icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Displays a search icon
                        Icon(
                          Icons.search_rounded,
                          color: StoreColors.darkGreen.withValues(alpha: 0.9),
                          size: 28,
                        ),
                        // GestureDetector for navigating to the notification page
                        GestureDetector(
                          onTap: () {
                            Get.toNamed(Routes.notificationPage);
                          },
                          // Displays a settings icon
                          child: Icon(
                            Icons.settings_rounded,
                            color: StoreColors.darkGreen.withValues(alpha: 0.9),
                            size: 28,
                          ),
                        ),
                      ],
                    ).pH(30), // Applies horizontal padding of 30 units
                    // Adds vertical spacing of 30 units
                    30.hBox,
                    // Row for investment-related labels
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Displays 'Investments' label
                        Text(
                          'Investments',
                          style: semiBoldTextStyle(color: Colors.grey, 15),
                        ),
                        // Displays 'Auto-investment' label
                        Text(
                          'Auto-investment',
                          style: semiBoldTextStyle(color: Colors.grey, 15),
                        ),
                      ],
                    ).pH(30), // Applies horizontal padding of 30 units
                    // Row for investment amount and auto-investment switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Expanded widget for investment amount
                        Expanded(
                          flex: 2,
                          // Displays investment amount with rich text
                          child: Text.rich(
                            TextSpan(
                              text: '\$',
                              style: semiBoldTextStyle(
                                color: StoreColors.darkGreen,
                                25,
                              ),
                              children: [
                                TextSpan(
                                  text: '70,000',
                                  style: semiBoldTextStyle(
                                    color: StoreColors.darkGreen,
                                    45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Expanded widget for auto-investment switch
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            // Switch for toggling auto-investment
                            child: Switch(
                              value: true, // Default state is enabled
                              onChanged: (value) {}, // Empty callback
                              activeColor: StoreColors.darkGreen,
                              // Sets thumb color to white
                              thumbColor:
                                  WidgetStateProperty.resolveWith<Color?>(
                                    (states) => Colors.white,
                                  ),
                              activeTrackColor: StoreColors.darkGreen,
                              inactiveThumbColor: Colors.white,
                              inactiveTrackColor: StoreColors.darkGreen,
                              // Removes track outline
                              trackOutlineWidth:
                                  WidgetStateProperty.resolveWith<double?>(
                                    (_) => 0,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ).pH(30), // Applies horizontal padding of 30 units
                    // Adds vertical spacing of 10 units
                    10.hBox,
                    // Row for performance indicator and time period
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Clipped container for performance change indicator
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            decoration: BoxDecoration(
                              color: StoreColors.darkBrown,
                            ),
                            // Displays performance change (e.g., +$5,000 / +21%)
                            child: Text(
                                  '+\$5,000 / +21%',
                                  style: semiBoldTextStyle(
                                    color: Colors.white,
                                    15,
                                  ),
                                )
                                .pH(8)
                                .pV(
                                  2,
                                ), // Applies horizontal and vertical padding
                          ),
                        ),
                        // Adds horizontal spacing of 10 units
                        10.wBox,
                        // Displays 'past year' text
                        Text(
                          'past year',
                          style: semiBoldTextStyle(color: Colors.black54, 15),
                        ),
                      ],
                    ).pH(30), // Applies horizontal padding of 30 units
                    // Adds vertical spacing of 25 units
                    25.hBox,
                    // Displays a line chart widget
                    LineChartSample2().pH(30), // Applies horizontal padding
                    // Adds vertical spacing of 10 units
                    10.hBox,
                    // SizedBox for horizontal time period filter
                    SizedBox(
                      height: 53,
                      // ListView.builder for rendering time period options
                      child: ListView.builder(
                        shrinkWrap: true, // Shrinks to fit content
                        scrollDirection:
                            Axis.horizontal, // Horizontal scrolling
                        itemCount: list.length, // Number of time period options
                        itemBuilder: (context, index) {
                          // Container for each time period option
                          return Container(
                            margin: const EdgeInsets.all(7),
                            // Applies different colors based on selection
                            decoration: BoxDecoration(
                              color:
                                  index == selectedIndex
                                      ? StoreColors.darkGreen
                                      : StoreColors.lightGrey,
                              borderRadius: BorderRadius.circular(35),
                            ),
                            alignment: Alignment.center,
                            // Displays the time period label (e.g., 1D, 1M)
                            child: Text(
                              list[index],
                              style: semiBoldTextStyle(
                                color:
                                    index == selectedIndex
                                        ? Colors.white
                                        : Colors.grey,
                                13,
                              ),
                            ).pH(18), // Applies horizontal padding
                          ).pOnly(
                            l: index == 0 ? 30 : 0,
                          ); // Adds left padding for first item
                        },
                      ),
                    ),
                    // Adds vertical spacing of 20 units
                    20.hBox,
                    // Row for portfolio title and navigation icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Displays 'Portfolio' title
                        Text(
                          'Portfolio',
                          style: semiBoldTextStyle(color: Colors.grey, 17),
                        ),
                        // Displays forward arrow icon
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.grey,
                          size: 18,
                        ),
                      ],
                    ).pOnly(l: 30, r: 30), // Applies left and right padding
                    // Adds vertical spacing of 10 units
                    10.hBox,
                    // Expanded widget for portfolio list
                    Expanded(
                      // ListView.builder for rendering portfolio items
                      child: ListView.builder(
                        shrinkWrap: true, // Shrinks to fit content
                        padding: EdgeInsets.zero, // Removes default padding
                        itemCount:
                            PaymentModel.dummy()
                                .length, // Number of portfolio items
                        physics:
                            const NeverScrollableScrollPhysics(), // Disables scrolling
                        itemBuilder: (context, index) {
                          // Retrieves the current portfolio item
                          final model = PaymentModel.dummy()[index];
                          // SizedBox for each portfolio item
                          return SizedBox(
                            height: 80,
                            // Row to arrange portfolio item details
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Row for icon and portfolio details
                                Row(
                                  children: [
                                    // Container for portfolio item icon
                                    Container(
                                      height: 50,
                                      width: 50,
                                      // Applies color and rounded corners
                                      decoration: BoxDecoration(
                                        color: colors[index % colors.length],
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          bottomLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      // Displays the first letter of the portfolio name
                                      child: Text(
                                        model.name
                                            .substring(0, 1)
                                            .toLowerCase(),
                                        textAlign: TextAlign.center,
                                        style: semiBoldTextStyle(
                                          color: Colors.white,
                                          27,
                                        ),
                                      ),
                                    ),
                                    // Adds horizontal spacing of 10 units
                                    10.wBox,
                                    // Column for portfolio name and authorization
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Displays portfolio name
                                        Text(
                                          model.name,
                                          style: boldTextStyle(
                                            color: Colors.black,
                                            17,
                                          ),
                                        ),
                                        // Displays authorization value
                                        Text(
                                          model.authorization.value,
                                          style: boldTextStyle(
                                            color: Colors.grey,
                                            13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // Column for price and date
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Displays formatted price with commas
                                    Text(
                                      '\$ ${model.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                      style: boldTextStyle(
                                        color: Colors.black,
                                        17,
                                      ),
                                    ),
                                    // Displays date and time
                                    Text(
                                      model.dateTime,
                                      style: semiBoldTextStyle(
                                        color: Colors.grey,
                                        12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ).pSymmetric(
                              h: 30,
                              v: 15,
                            ), // Applies symmetric padding
                          ).pV(5); // Adds vertical padding of 5 units
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
