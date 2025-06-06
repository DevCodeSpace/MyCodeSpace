// Importing necessary packages for widgets, extensions, and custom exports
import 'package:banking_store/Export/export.dart';
import 'package:dart_extensions_pro/dart_extensions_pro.dart';

// Defines the LineChartSample2 as a stateful widget
class LineChartSample2 extends StatefulWidget {
  // Constructor with optional key parameter
  const LineChartSample2({super.key});

  @override
  // Creates the state for the LineChartSample2 widget
  State<LineChartSample2> createState() => _LineChartSample2State();
}

// State class for LineChartSample2
class _LineChartSample2State extends State<LineChartSample2> {
  // Defines gradient colors for the line chart
  List<Color> gradientColors = [StoreColors.darkBrown, StoreColors.darkBrown];

  @override
  // Builds the UI for the LineChartSample2 widget
  Widget build(BuildContext context) {
    // Returns a Stack to layer the line chart
    return Stack(
      children: <Widget>[
        // AspectRatio to maintain the chart's aspect ratio
        AspectRatio(
          aspectRatio: 1.40, // Sets the width-to-height ratio of the chart
          // Displays the line chart with vertical padding
          child: LineChart(mainData()).pV(4),
        ),
      ],
    );
  }

  // Widget to generate bottom axis titles (month labels)
  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    // Defines text style for axis titles
    var style = regularTextStyle(13, color: Colors.grey);
    // Variable to hold the text widget
    Widget text;
    // Switch case to assign month names based on the value
    switch (value.toInt()) {
      case 0:
        text = Text('March', style: style);
        break;
      case 1:
        text = Text('April', style: style);
        break;
      case 2:
        text = Text('May', style: style);
        break;
      case 3:
        text = Text('June', style: style);
        break;
      case 4:
        text = Text('July', style: style);
        break;
      case 5:
        text = Text('Aug', style: style);
        break;
      default:
        // Empty text for undefined values
        text = Text('', style: style);
        break;
    }

    // Returns a SideTitleWidget for the bottom axis
    return SideTitleWidget(meta: meta, child: text);
  }

  // Widget to generate left axis titles (value labels in thousands)
  Widget leftTitleWidgets(double value, TitleMeta meta) {
    // Defines text style for axis titles
    var style = regularTextStyle(13, color: Colors.grey);
    // Variable to hold the label text
    String text = '';
    // Formats values as thousands (e.g., 30k) for values between 0 and 4
    if (value.toInt() >= 0 && value.toInt() <= 4) {
      text = '${value.toInt() * 30}k';
    }

    // Returns the formatted text widget for the left axis
    return Text(text, style: style, textAlign: TextAlign.left);
  }

  // Defines the data for the line chart
  LineChartData mainData() {
    return LineChartData(
      // Configures the grid lines for the chart
      gridData: FlGridData(
        show: true, // Displays the grid
        drawVerticalLine: true, // Shows vertical grid lines
        horizontalInterval: 1, // Sets interval for horizontal lines
        verticalInterval: 1, // Sets interval for vertical lines
        // Defines the style for horizontal grid lines
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withValues(alpha: 0.3), // Light grey color
            strokeWidth: 1, // Line thickness
          );
        },
        // Defines the style for vertical grid lines
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey.withValues(alpha: 0.3), // Light grey color
            strokeWidth: 1, // Line thickness
          );
        },
      ),
      // Configures the axis titles
      titlesData: FlTitlesData(
        show: true, // Displays titles
        // Hides right axis titles
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        // Hides top axis titles
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        // Configures bottom axis titles (months)
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true, // Shows bottom titles
            reservedSize: 30, // Reserves space for titles
            interval: 1, // Sets interval for title display
            getTitlesWidget: bottomTitleWidgets, // Uses custom title widget
          ),
        ),
        // Configures left axis titles (values)
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true, // Shows left titles
            interval: 1, // Sets interval for title display
            getTitlesWidget: leftTitleWidgets, // Uses custom title widget
            reservedSize: 42, // Reserves space for titles
          ),
        ),
      ),
      // Configures the chart border
      borderData: FlBorderData(
        show: true, // Displays the border
        border: Border.fromBorderSide(
          BorderSide(
            color: Colors.grey.withValues(alpha: 0.3),
          ), // Light grey border
        ),
      ),
      minX: 0, // Minimum X-axis value
      maxX: 5, // Maximum X-axis value
      minY: -1, // Minimum Y-axis value
      maxY: 4, // Maximum Y-axis value
      // Defines the data for the line chart
      lineBarsData: [
        LineChartBarData(
          // Data points for the line chart
          spots: const [
            FlSpot(0, 1),
            FlSpot(1, 1.5),
            FlSpot(2.3, 1.2),
            FlSpot(2.9, 2.5),
            FlSpot(3.8, 1.8),
            FlSpot(4.4, 2.5),
            FlSpot(5, 2.6),
          ],
          isCurved: true, // Smooths the line with curves
          gradient: LinearGradient(
            colors: gradientColors,
          ), // Applies gradient to the line
          barWidth: 5, // Sets the thickness of the line
          isStrokeCapRound: true, // Rounds the ends of the line
          dotData: const FlDotData(show: false), // Hides data point dots
          // Configures the area below the line
          belowBarData: BarAreaData(
            show: true, // Shows the area below the line
            // Applies a transparent gradient to the area
            gradient: LinearGradient(
              colors:
                  gradientColors.map((color) => Colors.transparent).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
