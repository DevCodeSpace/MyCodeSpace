// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:banking_store/Export/export.dart';
import 'package:dart_extensions_pro/dart_extensions_pro.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Delay for 2 seconds and open the notification page
    Future.delayed(Duration(seconds: 3), () {
      // Get.to(TabPage());
      Get.offAllNamed(Routes.tabPage);
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // right top black
          Positioned(
            top: 20,
            right: -70,
            height: 250,
            child: Transform.rotate(
              angle: 4.5,
              child: SvgPicture.asset(
                'assets/svgs/svg-path.svg',
                colorFilter: ColorFilter.mode(
                  StoreColors.darkTeal,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          // left side orangeish
          Positioned(
            top: 5,
            left: -205,
            height: 450,
            child: Transform.rotate(
              angle: pi,
              child: SvgPicture.asset(
                'assets/svgs/svg-path.svg',
                colorFilter: ColorFilter.mode(
                  StoreColors.darkBrown,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          // Right side dark green
          Positioned(
            bottom: 180,
            right: -220,
            height: 450,
            child: Transform.rotate(
              angle: 2 * pi,
              child: SvgPicture.asset(
                'assets/svgs/svg-path.svg',
                colorFilter: ColorFilter.mode(
                  StoreColors.darkGreen,
                  BlendMode.srcIn,
                ),
              ),
              // Image(
              //   image: Svg('assets/svgs/svg-path.svg'),
              //   color: StoreColors.darkGreen,
              // ),
            ),
          ),
          Positioned(
            child: Align(
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: 2 * pi,
                child: Padding(
                  padding: const EdgeInsets.only(top: 200, right: 120),
                  child: SvgPicture.asset(
                    height: 100,
                    width: 90,
                    'assets/svgs/svg-path.svg',
                    colorFilter: ColorFilter.mode(
                      StoreColors.darkTeal,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Right bottom corner side dark orange
          Positioned(
            bottom: -340,
            right: -240,
            height: 450,
            child: Transform.flip(
              flipX: true,
              flipY: true,
              child: SvgPicture.asset(
                "assets/svgs/svg-path.svg",
                colorFilter: ColorFilter.mode(
                  StoreColors.darkBrown,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),

          // left bottom corner side
          // some unknown color name haha
          Positioned(
            bottom: -130,
            left: -250,
            height: 450,
            child: Transform.rotate(
              angle: pi * 0.5,
              child: SvgPicture.asset(
                "assets/svgs/svg-path.svg",
                colorFilter: ColorFilter.mode(
                  StoreColors.ligthPink,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),

          Positioned.fill(
            bottom: 100,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'warren',
                    style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                  ),
                  15.hBox,
                  Text(
                    'Warren conducts your financial life\nso you can make good money\ndecisions with confidence.',
                    style: TextStyle(fontSize: 17),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
