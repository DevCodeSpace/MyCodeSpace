import 'package:banking_app/Core/Theme/text_style.dart';
import 'package:banking_app/Export/export.dart';
import 'package:dart_extensions_pro/dart_extensions_pro.dart';

class TokenBonusRightWidget extends StatelessWidget {
  const TokenBonusRightWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              color: BankingColors.yellow,
              borderRadius: BorderRadius.circular(15),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.local_play, size: 25, color: Colors.white),
                const Spacer(),
                Text(
                  'Bonus received',
                  textAlign: TextAlign.center,
                  style: mediumTextStyle(15, color: Colors.white),
                ),
                5.hBox,
                Text(
                  '\$103.22',
                  textAlign: TextAlign.center,
                  style: boldTextStyle(16, color: Colors.white),
                ),
              ],
            ).p(15),
          ),
          18.hBox,
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              color: BankingColors.lightGreen,
              borderRadius: BorderRadius.circular(15),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.loyalty_rounded, size: 25, color: Colors.white),
                const Spacer(),
                Text(
                  'Loyalty Points',
                  textAlign: TextAlign.center,
                  style: mediumTextStyle(15, color: Colors.white),
                ),
                5.hBox,
                Text(
                  '1323pts',
                  textAlign: TextAlign.center,
                  style: boldTextStyle(15, color: Colors.white),
                ),
              ],
            ).p(15),
          ),
          20.hBox,
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: BankingColors.veryLightGreen,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            child: Text(
              'Borrow Tokens',
              textAlign: TextAlign.center,
              style: regularTextStyle(17, color: BankingColors.darkGreen),
            ),
          ),
        ],
      ),
    );
  }
}
