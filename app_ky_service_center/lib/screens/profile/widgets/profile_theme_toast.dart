import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'profile_colors.dart';

/// Shows a small floating snackbar confirming that light/dark mode was
/// toggled from the profile screen header.
void showProfileThemeModeToast(BuildContext context, {required bool isDark}) {
  final messenger = ScaffoldMessenger.of(context);
  final bottomInset = MediaQuery.of(context).padding.bottom;
  final title = isDark ? 'Dark mode enabled' : 'Light mode enabled';
  final subtitle = isDark
      ? 'Smoother for low-light viewing'
      : 'Clean brightness for daytime use';

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1600),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.fromLTRB(16, 0, 16, 92 + bottomInset),
        padding: EdgeInsets.zero,
        content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [Color(0xFF1D2635), Color(0xFF2B3442)]
                  : const [Color(0xFF4A88F7), Color(0xFF7DA8F7)],
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? const Color(0xFF0D1117) : profileBrandBlue)
                    .withAlpha((0.32 * 255).round()),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha((0.18 * 255).round()),
                  ),
                  child: Icon(
                    isDark ? HugeIcons.strokeRoundedMoon01 : HugeIcons.strokeRoundedSun01,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withAlpha((0.9 * 255).round()),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
}
