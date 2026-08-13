import 'package:flutter/services.dart';

String googleSignInErrorMessage(Object error) {
  if (error is PlatformException) {
    final code = error.code.toLowerCase();
    final message = (error.message ?? '').toLowerCase();

    if (code == 'network_error' || message.contains('apiexception: 7')) {
      return 'Google Sign-In cannot reach Google services. Check the emulator/device internet connection, use a Google Play emulator image, then try again.';
    }

    if (message.contains('apiexception: 10') || code == 'sign_in_failed') {
      return 'Google Sign-In is not configured for this app build. Check the Android package name, SHA-1 fingerprint, and web client ID in Firebase.';
    }
  }

  return 'Google Sign-In failed. Please try again.';
}
