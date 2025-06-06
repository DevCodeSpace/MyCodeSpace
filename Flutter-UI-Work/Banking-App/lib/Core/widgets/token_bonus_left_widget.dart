import 'package:banking_app/Core/Theme/app_color.dart';
import 'package:banking_app/Core/Theme/text_style.dart';
import 'package:dart_extensions_pro/dart_extensions_pro.dart';
import 'package:flutter/material.dart';

class TokenBonusLeftWidget extends StatelessWidget {
  const TokenBonusLeftWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 278,

            width: double.infinity,
            decoration: BoxDecoration(
              color: BankingColors.darkRed,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CircularProgressIndicator(
                          value: 31 / 100,
                          backgroundColor: BankingColors.lightRed,
                          color: BankingColors.veryLightRed,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            BankingColors.yellow,
                          ),
                          strokeWidth: 12,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Center(
                        child: Text(
                          '31%',
                          style: boldTextStyle(22, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                25.hBox,
                Text(
                  'Tokens bought\nfor 13%',
                  textAlign: TextAlign.center,
                  style: regularTextStyle(13, color: Colors.white),
                ),
                const Spacer(),
                Text(
                  '900 TYI',
                  textAlign: TextAlign.center,
                  style: boldTextStyle(23, color: BankingColors.yellow),
                ),
              ],
            ).pOnly(t: 40, b: 25).pH(10),
          ),
          20.hBox,
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: BankingColors.veryLightRed,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            child: Text(
              'Get Tokens',
              textAlign: TextAlign.center,
              style: regularTextStyle(17, color: BankingColors.darkRed),
            ),
          ),
        ],
      ),
    );
  }
}
