import 'package:banking_store/Export/export.dart';

TextStyle regularTextStyle(double? fontsize, {Color? color}) {
  return TextStyle(
    fontSize: (fontsize ?? 14),
    fontWeight: FontWeight.normal,
    color: color ?? Colors.black,
  );
}

TextStyle mediumTextStyle(double? fontsize, {Color? color}) {
  return TextStyle(
    fontSize: (fontsize ?? 14),
    fontWeight: FontWeight.w500,
    color: color ?? Colors.black,
  );
}

TextStyle semiBoldTextStyle(double? fontsize, {Color? color}) {
  return TextStyle(
    fontSize: (fontsize ?? 14),
    fontWeight: FontWeight.w600,
    color: color ?? Colors.black,
  );
}

TextStyle boldTextStyle(double? fontsize, {Color? color}) {
  return TextStyle(
    fontSize: (fontsize ?? 14),
    fontWeight: FontWeight.bold,
    color: color ?? Colors.black,
  );
}
