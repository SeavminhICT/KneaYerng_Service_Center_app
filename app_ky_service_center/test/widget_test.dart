import 'package:flutter_test/flutter_test.dart';

import 'package:app_ky_service_center/main.dart';

void main() {
  testWidgets('App bootstraps and renders shell', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.byType(MyApp), findsOneWidget);
  });
}
