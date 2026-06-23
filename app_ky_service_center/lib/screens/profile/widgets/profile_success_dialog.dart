import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_fonts.dart';
import 'profile_colors.dart';

/// Shows a generic success confirmation dialog (e.g. after updating the
/// profile photo) with a checkmark icon, title, message and an OK button.
Future<void> showProfileSuccessDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A0F172A),
                blurRadius: 30,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 68,
                width: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [profileHeroStart, profileHeroEnd],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x334A88F7),
                      blurRadius: 18,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  HugeIcons.strokeRoundedTick01,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              Builder(
                builder: (context) {
                  return Text(
                    title,
                    textAlign: TextAlign.center,
                    style: kmFont(context, GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: profileTextPrimary(context),
                    )),
                  );
                },
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  return Text(
                    message,
                    textAlign: TextAlign.center,
                    style: kmFont(context, GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.45,
                      color: profileTextMuted(context),
                    )),
                  );
                },
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
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
                    return Text(l.ok, style: kmFont(context, GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)));
                  }),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
