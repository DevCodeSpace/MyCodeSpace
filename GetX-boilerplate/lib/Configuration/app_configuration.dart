import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:velocity_x/velocity_x.dart';

const primaryColor = Color(0xff00205C);
const pageBackroundColor = Colors.white;
const defaultTextcolor = Colors.black;
const drawarColor = Color(0xff212338);
const borderColor = Color(0xffEBEBEB);
const disabletextColor = Color(0xffB9B9B9);
const iconColor = Color(0xff999999);
final buttonHeight = 45.h;

Widget getHorizontalWidth(double width) {
  return SizedBox(
    width: width,
  );
}

Widget getVerticalHeight(double height) {
  return SizedBox(
    height: height,
  );
}

Widget iconBackground(Widget icons) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      border: Border.all(
        color: const Color(0xffE2E2E2),
        width: 2,
      ),
      borderRadius: BorderRadius.circular(7),
      color: const Color(0xffF2F2F2),
    ),
    child: icons,
  );
}


//Padding

double defaultPadding = 16.w;

//boxShadow

const shadow = [
  BoxShadow(
    color: Colors.grey,
  ),
  BoxShadow(
    color: Colors.black,
    spreadRadius: -7.0,
    blurRadius: 10.0,
  ),
];

//Currency
const currency = '\$';

//email Regex
RegExp emailRegEx = RegExp(
  // r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
  r'^[\w-]+(?:\.[\w-]+)*@(?:[\w-]+\.)+[a-zA-Z]{2,}$',
  caseSensitive: true,
  multiLine: false,
);

//password Regex
RegExp passwordRegEx = RegExp(
  r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$",
);

enum AlertTypes { alert, success, fail }

loadingDialog() {
  Get.dialog(
    WillPopScope(
      onWillPop: () async => false,
      child: const LoadingDialog(),
    ),
    barrierDismissible: false,
  );
}

Future getDisplayAlert(
  String title,
  String content,
) async {
  await Get.dialog(
    WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
        title: Text(title),
        content: Text(content),
        actions: [
          MaterialButton(
            child: const Text("Ok"),
            onPressed: () {
              Get.back();
              Get.focusScope?.unfocus();
            },
          )
        ],
      ),
    ),
    barrierDismissible: false,
  );
}

InputDecoration textfieldDecoration(String lableText,
    {Widget? suffixIcon,
    int borderWeight = 1,
    Color bordercolor = borderColor}) {
  return InputDecoration(
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: bordercolor,
        width: 1,
      ),
    ),
    counterText: "",
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: bordercolor, width: 1),
    ),
    label: Text(
      lableText,
      style: const TextStyle(color: Colors.grey),
    ),
    isDense: true,
    suffixIcon: suffixIcon,
    suffixIconConstraints: const BoxConstraints(
      minHeight: 20,
      minWidth: 20,
    ),
  );
}

Widget button(String text, Function onPress, {double fontSize = 16}) {
  return Container(
    height: buttonHeight,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: <Color>[primaryColor, primaryColor.withOpacity(0.5)],
      ),
      boxShadow: const [
        BoxShadow(
          color: Colors.white,
          offset: Offset(0.0, 1.7),
          blurRadius: 1.5,
        ),
      ],
      borderRadius: BorderRadius.circular(25),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onPress.call();
        },
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    ),
  );
}

Widget buttonWithBorder(String text, Function onPress, {double fontSize = 16}) {
  return Container(
    height: buttonHeight,
    decoration: BoxDecoration(
      boxShadow: const [
        BoxShadow(
          color: Colors.white,
          offset: Offset(0.0, 1.7),
          blurRadius: 1.5,
        ),
      ],
      border: Border.all(),
      borderRadius: BorderRadius.circular(25),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onPress.call();
        },
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontSize: fontSize.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    ),
  );
}

checkConnection() async {
  return await InternetConnectionChecker().hasConnection;
}

class LoadingDialog extends Dialog {
  const LoadingDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          decoration: const ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  10,
                ),
              ),
            ),
          ),
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(10),
          child: const Center(
            child: CircularProgressIndicator(
              color: primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}

Color getColorFromString(String color) {
  if (color.isNotEmptyAndNotNull) {
    var meetingColor = "0xff$color";
    meetingColor = meetingColor.replaceAll("#", "");
    return Color(int.tryParse(meetingColor) ?? 000000);
  } else {
    return Colors.white;
  }
}
