import 'package:flutter/material.dart';
import 'app_colors.dart';

TextStyle regularPoppins(double fontSize, {Color textColor = AppColors.blackColor}) {
  return TextStyle(fontFamily: 'Poppins', color: textColor, fontSize: fontSize, fontWeight: FontWeight.w400);
}

TextStyle mediumPoppins(double fontSize, {Color textColor = AppColors.blackColor}) {
  return TextStyle(fontFamily: 'Poppins', color: textColor, fontSize: fontSize, fontWeight: FontWeight.w500);
}

TextStyle semiboldPoppins(double fontSize, {Color textColor = AppColors.blackColor}) {
  return TextStyle(fontFamily: 'Poppins', color: textColor, fontSize: fontSize, fontWeight: FontWeight.w600);
}

TextStyle boldPoppins(double fontSize, {Color textColor = AppColors.blackColor}) {
  return TextStyle(fontFamily: 'Poppins', color: textColor, fontSize: fontSize, fontWeight: FontWeight.w700);
}

TextStyle customPoppins(double fontSize, {Color textColor = AppColors.blackColor, FontWeight? fontWeight}) {
  return TextStyle(fontFamily: 'Poppins', color: textColor, fontSize: fontSize, fontWeight: fontWeight);
}
