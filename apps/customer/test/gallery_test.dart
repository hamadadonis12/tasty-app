import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:customer/gallery_app.dart';

void main() {
  testWidgets('Gallery boots and lists the 4 surfaces', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const GalleryApp());
    await tester.pumpAndSettle();

    expect(find.text('TastyLife — Screen Gallery'), findsOneWidget);
    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('Driver'), findsOneWidget);
    expect(find.text('Restaurant'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    // Status badges render at the top of the catalog.
    expect(find.textContaining('live'), findsWidgets);
    expect(find.textContaining('missing'), findsWidgets);
  });
}
