import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../l10n/app_localizations.dart';
import 'profile_colors.dart';

/// Shows the "Log Out?" confirmation dialog and resolves to `true` if the
/// user confirms, `false` if they cancel, or `null` if dismissed.
Future<bool?> showProfileLogoutConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF7FAFF), Color(0xFFFFF4EA)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F1E2A78),
                blurRadius: 28,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      profileBrandBlue.withAlpha((0.92 * 255).round()),
                      profileBrandPeach.withAlpha((0.92 * 255).round()),
                    ],
                  ),
                ),
                child: const Icon(
                  HugeIcons.strokeRoundedLogout01,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),
              Builder(
                builder: (context) {
                  final l = AppLocalizations.of(context);
                  return Text(
                    l.logoutConfirm,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'You will need to log in again to access your account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: BorderSide(
                          color: Colors.black.withAlpha((0.12 * 255).round()),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: Colors.white.withAlpha(
                          (0.75 * 255).round(),
                        ),
                      ),
                      child: Builder(builder: (context) {
                        final l = AppLocalizations.of(context);
                        return Text(l.cancel, style: const TextStyle(fontWeight: FontWeight.w700));
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        foregroundColor: Colors.white,
                        backgroundColor: profileBrandBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Builder(builder: (context) {
                        final l = AppLocalizations.of(context);
                        return Text(l.yes, style: const TextStyle(fontWeight: FontWeight.w700));
                      }),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
