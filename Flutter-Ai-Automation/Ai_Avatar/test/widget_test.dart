import 'package:ai_avtar_chat/main.dart';
import 'package:ai_avtar_chat/modules/assistant/view/avatar_chat_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app opens to AvatarChatScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(AvatarChatScreen), findsOneWidget);
  });
}
