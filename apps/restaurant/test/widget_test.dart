import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:restaurant/main.dart';

void main() {
  testWidgets('Kitchen OS boots and renders the three-column kanban shell',
      (WidgetTester tester) async {
    // Kitchen OS is tablet-landscape; size the test surface accordingly.
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const KitchenOsApp());
    await tester.pumpAndSettle();

    expect(find.text('Kitchen OS'), findsOneWidget);
    expect(find.text('New Orders'), findsOneWidget);
    expect(find.text('Preparing'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
  });
}
