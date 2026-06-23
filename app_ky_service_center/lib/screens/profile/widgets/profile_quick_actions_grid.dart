import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../theme/app_fonts.dart';
import 'profile_colors.dart';

/// One shortcut action displayed in [ProfileQuickActionsGrid].
class ProfileQuickAction {
  const ProfileQuickAction({
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final List<Color> colors;
  final VoidCallback onTap;
}

/// Two-column grid of quick-action shortcut cards (e.g. Reviews, Warranty).
class ProfileQuickActionsGrid extends StatelessWidget {
  const ProfileQuickActionsGrid({super.key, required this.actions});

  final List<ProfileQuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.18,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return _QuickActionCard(action: action);
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.action});

  final ProfileQuickAction action;

  @override
  Widget build(BuildContext context) {
    final isDark = profileIsDark(context);
    final textPrimary = profileTextPrimary(context);
    final textMuted = profileTextMuted(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: action.colors,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x120F172A),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withAlpha((0.14 * 255).round())
                        : Colors.white.withAlpha((0.72 * 255).round()),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(action.icon, color: profileBrandBlue, size: 22),
                ),
                const Spacer(),
                Text(
                  action.label,
                  style: kmFont(context, GoogleFonts.poppins(
                    color: textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  )),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Open',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      HugeIcons.strokeRoundedArrowRight01,
                      size: 14,
                      color: textMuted,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
