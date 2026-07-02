import 'package:app_ky_service_center/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps a valid optional email', () {
    final profile = UserProfile.fromMap({'email': ' customer@example.com '});

    expect(profile.email, 'customer@example.com');
  });

  test('removes a phone number cached as an email', () {
    final profile = UserProfile.fromMap({
      'email': '85512345678',
      'phone': '85512345678',
    });

    expect(profile.email, isNull);
    expect(profile.phone, '85512345678');
  });
}
