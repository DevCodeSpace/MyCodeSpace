import 'package:banking_app/Core/Theme/text_style.dart';
import 'package:banking_app/Export/export.dart';
import 'package:dart_extensions_pro/dart_extensions_pro.dart';

class TotalBalanceWidget extends StatelessWidget {
  const TotalBalanceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: '\$3,782.',
            style: boldTextStyle(34, color: Colors.black),
            children: [
              TextSpan(
                text: '02',
                style: TextStyle(
                  color: BankingColors.lightGrey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        10.wBox,
        Container(
          decoration: BoxDecoration(
            color: BankingColors.plantGreen,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '+4.50%',
            style: mediumTextStyle(12, color: Colors.white),
          ).pSymmetric(h: 12, v: 5),
        ),
      ],
    );
  }
}
