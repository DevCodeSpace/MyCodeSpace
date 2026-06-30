import 'package:ai_avtar_chat/core/utils/import_to_export.dart';
import 'package:lottie/lottie.dart';

/// Confirmation dialog with optional Cancel + a primary action button.
/// Set [isDisplayedCancelBtn] to false when the user must accept (e.g. error messages).
class AlertCustomDialog extends StatelessWidget {
  final String text;
  final String btntext;
  final Function()? ontap;
  final bool? isDisplayedCancelBtn;
  const AlertCustomDialog({super.key, required this.text, required this.ontap, required this.btntext, this.isDisplayedCancelBtn = true});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // prevent accidental back-dismiss
      child: Dialog(
        elevation: 0,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        insetPadding: EdgeInsets.all(10.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset("assets/json/alert.json", height: 100.sp, width: 100.sp, fit: BoxFit.cover).centered(),
            Text(
              text,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.black),
            ),
            20.h.heightBox,
            Row(
              spacing: 10,
              children: [
                // Cancel button — hidden when isDisplayedCancelBtn is false.
                Visibility(
                  visible: isDisplayedCancelBtn == true,
                  child: Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xff000000), width: 1.2),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(fontSize: 16.sp, color: const Color(0xff000000), fontWeight: FontWeight.w500),
                      ).pSymmetric(v: 15.h).centered(),
                    ).onTap(() => Get.back()),
                  ),
                ),
                // Primary action button (red).
                Expanded(
                  child: InkWell(
                    onTap: ontap!,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffB60611),
                        border: Border.all(style: BorderStyle.none),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        btntext,
                        style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.w500),
                      ).pSymmetric(v: 15.h).centered(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ).pOnly(left: 22.w, right: 22.w, top: 12.h, bottom: 22.h),
      ).p(6).centered(),
    );
  }
}

/// Full-screen network-error dialog — blocks all interaction until the user
/// taps Continue (which just dismisses, letting the caller retry).
Widget customNetworkDialog() {
  return PopScope(
    canPop: false,
    child: Dialog(
      elevation: 0,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      insetPadding: EdgeInsets.all(10.sp),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset("assets/json/network_off.json", height: 100.sp, width: 100.sp, fit: BoxFit.cover),
          Text(
            "Please check your internet connection!!",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          15.h.heightBox,
          Container(
            decoration: BoxDecoration(color: const Color(0xff13B723), borderRadius: BorderRadius.circular(6.r)),
            child: Text(
              'Continue',
              style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.w500),
            ).pSymmetric(v: 16.sp).centered(),
          ).onTap(() async {
            Get.back();
          }),
        ],
      ).pOnly(left: 22.w, right: 22.w, top: 12.h, bottom: 22.h),
    ).centered(),
  );
}
