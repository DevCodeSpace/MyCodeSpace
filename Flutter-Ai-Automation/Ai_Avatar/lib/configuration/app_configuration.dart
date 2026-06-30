import 'package:connectivity_plus/connectivity_plus.dart';

import '../core/utils/import_to_export.dart';

//MARK: COLORS
const defaultTextcolor = Colors.black;

//MARK: TEXT
TextStyle regularPoppins(double fontSize, {Color color = defaultTextcolor, double? textHeight}) {
  return GoogleFonts.poppins(fontSize: fontSize.sp, fontWeight: FontWeight.w400, color: color, height: textHeight);
}

// This function is used text font style Poppins in app
TextStyle semiBoldPoppins(double fontSize, {Color color = defaultTextcolor}) {
  return GoogleFonts.poppins(fontSize: fontSize.sp, fontWeight: FontWeight.w600, color: color);
}

// This function is used text font style bold Poppins in app
TextStyle boldPoppins(double fontSize, {Color color = defaultTextcolor}) {
  return GoogleFonts.poppins(fontSize: fontSize.sp, fontWeight: FontWeight.w700, color: color);
}

// This function is used text font style manrope in app
TextStyle poppins(double fontSize, {Color color = defaultTextcolor}) {
  return GoogleFonts.manrope(fontSize: fontSize.sp, fontWeight: FontWeight.w700, color: color);
}

RxBool isConnectedWithInternet = true.obs;
Future<bool> checkConnection() async {
  try {
    final results = await Connectivity().checkConnectivity();
    final connected = results.any((r) => r != ConnectivityResult.none);
    isConnectedWithInternet.value = connected;
    return connected;
  } catch (_) {
    return isConnectedWithInternet.value;
  }
}

void loadingDialog() {
  Get.dialog(
    Center(
      child: Container(
        height: 100.h,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        // ignore: deprecated_member_use
        child: PopScope(canPop: false, onPopInvokedWithResult: (didPop, result) {}, child: Image.asset("assets/images/loaderlogo.gif")),
      ),
    ),
    barrierDismissible: false,
  );
}

Future getDisplayAlert(String title, String content) async {
  await Get.dialog(
    PopScope(
      onPopInvokedWithResult: (didPop, result) {},
      child: AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
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
    ),
    barrierDismissible: false,
  );
}
