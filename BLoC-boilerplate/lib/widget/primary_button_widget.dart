// Common fill button for all screen
import 'package:bloc_boiler_plate/const/primary_theme.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class PrimaryButtonWidget extends StatelessWidget {
  final String? label;
  final bool isLoading;
  final Function()? onTap;
  final Widget? child;

  const PrimaryButtonWidget(
      {super.key, this.label, this.isLoading = false, this.onTap, this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: 45,
      onPressed: onTap,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      color: primaryColor,
      child: Center(
        child: Visibility(
          visible: isLoading,
          replacement: child ??
              Text(
                label ?? "--",
                style: const TextStyle(
                    color: pageBackgroundColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ).pSymmetric(v: 10),
          child: const SizedBox(
            height: 30,
            width: 30,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
        ),
      ),
    );
  }
}
