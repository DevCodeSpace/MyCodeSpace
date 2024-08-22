import 'package:bloc_boiler_plate/const/primary_theme.dart';
import 'package:bloc_boiler_plate/state/form_validate_state.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

/// Common error message for all screen. also handle message type like error, warning and success
class ErrorMessageBoxWidget extends StatelessWidget {
  final String? message;
  final MsgStatus isError;

  const ErrorMessageBoxWidget(
      {super.key, this.message, this.isError = MsgStatus.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: msgColor.withOpacity(0.2)),
      child: Text(
        message ?? "",
        style: TextStyle(color: msgColor, fontSize: 14),
      ).pSymmetric(h: 20, v: 10),
    );
  }

  Color get msgColor {
    switch (isError) {
      case MsgStatus.error:
        return const Color(0xffDC3545);
      case MsgStatus.success:
        return Colors.green;
      case MsgStatus.warning:
        return primaryColor;
    }
  }
}
