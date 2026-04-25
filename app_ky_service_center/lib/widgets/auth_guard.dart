import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../screens/Auth/login_screen.dart';
import '../screens/Auth/register_screen.dart';

enum _AuthChoice { login, register, cancel }

Future<bool> ensureLoggedIn(
  BuildContext context, {
  String? message,
}) async {
  final token = await ApiService.getToken();
  if (token != null && token.isNotEmpty) return true;
  if (!context.mounted) return false;

  final choice = await showDialog<_AuthChoice>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Login required'),
        content: Text(
          message ?? 'Please login or register to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(_AuthChoice.cancel),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(_AuthChoice.register),
            child: const Text('Register'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(_AuthChoice.login),
            child: const Text('Login'),
          ),
        ],
      );
    },
  );

  if (!context.mounted) return false;
  switch (choice) {
    case _AuthChoice.login:
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      break;
    case _AuthChoice.register:
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const RegisterScreen()),
      );
      break;
    case _AuthChoice.cancel:
    default:
      break;
  }
  return false;
}
