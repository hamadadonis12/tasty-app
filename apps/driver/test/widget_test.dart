import 'package:flutter_test/flutter_test.dart';
import 'package:driver/main.dart';

void main() {
  testWidgets('Driver App boots and renders welcome screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyDriverApp());

    // Verify that the brand name and CTA are rendered.
    expect(find.text('TASTY LIFE'), findsOneWidget);
    expect(find.text('Se connecter en tant que livreur'), findsOneWidget);
  });
}
