import 'package:app_ky_service_center/screens/Auth/otp_screen.dart';
import 'package:app_ky_service_center/screens/Auth/registration_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> setPhoneViewport(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
  }

  testWidgets('OTP screen renders six code fields without overflow', (
    tester,
  ) async {
    await setPhoneViewport(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: OtpScreen(destination: '+85512345678', initialResendInSec: 90),
      ),
    );
    await tester.pump();

    expect(find.text('OTP Verification'), findsOneWidget);
    expect(
      find.textContaining('*** *** 678', findRichText: true),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsNWidgets(6));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('registration success card fits a phone viewport', (
    tester,
  ) async {
    await setPhoneViewport(tester);
    await tester.pumpWidget(
      const MaterialApp(home: RegistrationSuccessScreen()),
    );
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Registration Successful'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
