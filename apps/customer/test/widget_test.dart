import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:customer/main.dart';

void main() {
  testWidgets('CustomerApp boots into onboarding splash', (tester) async {
    // The onboarding flow is phone-sized; default test viewport is too small.
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const CustomerApp());
    // Splash renders the new TastyLife brand mark (TASTY + LIFE wordmarks
    // in the Bagel Fat One logo) and the city tagline before auto-advance.
    expect(find.text('TASTY'), findsOneWidget);
    expect(find.text('LIFE'), findsOneWidget);
    expect(find.text('Kinshasa · Brazzaville'), findsOneWidget);
  });
}
