import 'package:dart_extensions_pro/dart_extensions_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

//Padding

double defaultPadding = 16.w;

//boxShadow

const shadow = [
  BoxShadow(color: Colors.grey),
  BoxShadow(color: Colors.black, spreadRadius: -7.0, blurRadius: 10.0),
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

Future getDisplayAlert(String title, String content) async {
  await Get.dialog(
    AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
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
        ),
      ],
    ),
    barrierDismissible: false,
  );
}

class LoadingDialog extends Dialog {
  const LoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          decoration: const ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          width: 80,
          height: 80,
          child: Center(
            child: CircularProgressIndicator(color: Colors.amberAccent),
          ).p(10),
        ),
      ),
    );
  }
}
