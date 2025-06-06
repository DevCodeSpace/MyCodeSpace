import 'package:book_store/Export/export.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 200,
        width: 350,
        color: BookStoreColors.darkBlue,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'images/gradient.png',
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.9, -1.7),
                    colors: [
                      BookStoreColors.darkRed,
                      BookStoreColors.darkRed.withValues(alpha: 0.3),
                    ],
                    radius: 1,
                    focalRadius: 1,
                    stops: [0, 1],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
