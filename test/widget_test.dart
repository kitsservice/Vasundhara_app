import 'package:flutter_test/flutter_test.dart';

import 'package:vasundhara/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VasundharaApp());

    // Verify that Vasundhara text is found.
    expect(find.text('Vasundhara'), findsWidgets);
  });
}
