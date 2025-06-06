import 'package:banking_app/Core/Theme/app_color.dart';
import 'package:banking_app/Core/Theme/text_style.dart';
import 'package:banking_app/Core/widgets/icon_holder_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String heading;
  final String? subHeading;
  const Header({required this.heading, this.subHeading, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(CupertinoIcons.line_horizontal_3, size: 30),
          Expanded(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: heading,
                style: regularTextStyle(21, color: Colors.black54),
                children: [
                  if (subHeading != null)
                    TextSpan(
                      text: subHeading,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
          IconHolder(
            iconData: Icons.notifications_active_outlined,
            iconColor: Colors.black,
            side: 50,
            backgroundColor: BankingColors.veryLightGrey,
            iconSize: 23,
            radius: 13,
          ),
        ],
      ),
    );
  }
}
