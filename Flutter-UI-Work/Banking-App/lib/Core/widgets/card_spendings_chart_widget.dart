import 'package:banking_app/Core/Theme/text_style.dart';
import 'package:banking_app/Export/export.dart';
import 'package:dart_extensions_pro/dart_extensions_pro.dart';

class CardSpendingsChartWidget extends StatelessWidget {
  const CardSpendingsChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 222,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200, width: .8),
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100.withValues(alpha: .6),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dashboard',
                style: regularTextStyle(17, color: Colors.black),
              ),
              Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black),
            ],
          ),
          15.hBox,
          LineChartSample(
            lineColor: BankingColors.lightGreen,
            gradientColors: [
              BankingColors.lightGreen.withValues(alpha: 0.7),
              BankingColors.lightGreen.withValues(alpha: 0),
            ],
            textColor: Colors.black,
            verticalLinesColor: Colors.grey.shade600,
            showBorder: false,
            showYAxisTiles: false,
          ),
        ],
      ).pOnly(l: 20, r: 29, t: 20, b: 0),
    );
  }
}
