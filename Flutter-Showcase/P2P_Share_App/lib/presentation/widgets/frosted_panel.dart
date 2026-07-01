import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

class FrostedPanel extends StatelessWidget {
  const FrostedPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: AppTheme.blur,
          child: Container(
            padding: padding,
            decoration: AppTheme.frostedDecoration(),
            child: child,
          ),
        ),
      ),
    );
  }
}
