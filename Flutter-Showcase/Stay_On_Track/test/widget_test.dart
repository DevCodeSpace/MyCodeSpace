import 'package:flutter_test/flutter_test.dart';
import 'package:track_app_usage/main.dart';

void main() {
  testWidgets('StayOnTrack App load smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify StayOnTrack logo/brand text is present on the Splash Screen
    expect(find.text('StayOnTrack'), findsOneWidget);
  });
}
