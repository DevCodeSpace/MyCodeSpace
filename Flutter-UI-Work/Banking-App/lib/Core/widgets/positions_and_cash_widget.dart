import 'package:banking_app/Core/Theme/app_color.dart';
import 'package:banking_app/Core/Theme/text_style.dart';
import 'package:dart_extensions_pro/dart_extensions_pro.dart';
import 'package:flutter/material.dart';

class PositionsAndCashWidget extends StatelessWidget {
  const PositionsAndCashWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children:
          [
            ['Positions', '\$3723.23'],
            ['Cash', '\$124.23'],
          ].map((row) {
            return Expanded(
              child: Container(
                height: 97,
                margin:
                    row[0] == 'Positions'
                        ? const EdgeInsets.only(right: 10)
                        : const EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  color: BankingColors.veryLightGrey,
                  borderRadius: BorderRadius.circular(13),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          row[0],
                          style: regularTextStyle(
                            15,
                            color: BankingColors.darkBlueGrey,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 15,
                          color: Colors.grey.shade500,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(row[1], style: boldTextStyle(18, color: Colors.black)),
                  ],
                ).pSymmetric(h: 20, v: 19),
              ),
            );
          }).toList(),
    );
  }
}
