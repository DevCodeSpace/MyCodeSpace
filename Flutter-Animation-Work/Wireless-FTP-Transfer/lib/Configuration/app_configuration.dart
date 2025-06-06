// ignore_for_file: deprecated_member_use

import 'package:animations_app/Helper/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

const primaryColor = Color(0xff3ace9c);
const whiteColor = Colors.white;
const pageBackroundColor = Colors.white;
const blackColor = Colors.black;
const bottomSelectionColor = Color(0xffA6941A);
const bottomUnSelectionColor = Color(0xff5E5F60);
const containerBorderColor = Color(0xffEFEFEF);
const greyTetxColor = Color(0xff8888A4);
const backgroundLightColor = Color(0xffF6F7FA);
const greenColor = Color(0xff13b723);

TextStyle regularPoppins(int fontSize, {Color textColor = primaryColor}) {
  return GoogleFonts.poppins(
    color: textColor,
    fontSize: fontSize.sp,
    fontWeight: FontWeight.w400,
  );
}

TextStyle semiboldPoppins(int fontSize, {Color textColor = primaryColor}) {
  return GoogleFonts.poppins(
    color: textColor,
    fontSize: fontSize.sp,
    fontWeight: FontWeight.w600, // Poppins uses w600 for semibold
  );
}

TextStyle boldPoppins(int fontSize, {Color textColor = primaryColor}) {
  return GoogleFonts.poppins(
    color: textColor,
    fontSize: fontSize.sp,
    fontWeight: FontWeight.w700,
  );
}

TextStyle customPoppins(
  int fontSize, {
  Color textColor = primaryColor,
  FontWeight? fontWeight,
}) {
  return GoogleFonts.poppins(
    color: textColor,
    fontSize: fontSize.sp,
    fontWeight: fontWeight,
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

Future getDisplayAlert(
  String title,
  String content,
) async {
  await Get.dialog(
    AlertDialog(
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

// Show the 'Coming Soon' dialog
void showComingSoonDialog() {
  showGeneralDialog(
    context: Get.context!,
    pageBuilder: (context, animation, secondaryAnimation) =>
        Container(), // No content in pageBuilder
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      // Apply animation to transition
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutBack, // Curved animation for smooth transition
      );

      return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0)
              .animate(curvedAnimation), // Scale transition effect
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0)
                .animate(curvedAnimation), // Fade transition effect
            child: Dialog(
              elevation: 0,
              backgroundColor:
                  Colors.transparent, // Transparent background for dialog
              child: Container(
                padding: const EdgeInsets.all(
                    24), // Padding for content inside the dialog
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade50, // Gradient color for the background
                      Colors.white,
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(24), // Rounded corners for dialog
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade100.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, 10), // Shadow effects
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Minimize space occupation
                  children: [
                    // Enhanced Rocket Animation Container
                    Container(
                      width: 80,
                      height: 80,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape
                            .circle, // Circular shape for the rocket icon
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade200.withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.rocket_launch_rounded,
                        size: 40,
                        color: Colors.white, // Icon color
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Enhanced Title with Gradient Animation
                    AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        return ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade600,
                              Colors.blue.shade400,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                            transform: GradientRotation(animation.value *
                                3.14 *
                                2), // Rotation effect on gradient
                          ).createShader(bounds),
                          child: const Text(
                            'Coming Soon!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Feature Tags (Cloud Storage, Sync, Secure)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        buildFeatureTag('Cloud Storage', Icons.cloud_outlined),
                        buildFeatureTag('Sync', Icons.sync_rounded),
                        buildFeatureTag('Secure', Icons.security_rounded),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Description text
                    Text(
                      'We\'re working hard to bring you this exciting new feature. Stay tuned for updates!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Enhanced Button with Tween animation for scaling
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 0.9 +
                              (0.1 * value), // Scales the button with animation
                          child: child,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade600
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade200.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: const Offset(
                                  0, 4), // Shadow effect for button
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.pop(
                                context), // Dismiss the dialog on tap
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Got it',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ));
    },
    transitionDuration:
        const Duration(milliseconds: 400), // Duration of the transition
  );
}
