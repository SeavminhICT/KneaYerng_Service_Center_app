import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/language_service.dart';
import '../../../theme/app_fonts.dart';
import 'profile_colors.dart';

/// One navigable row in [ProfileSettingsList].
class ProfileSettingsItem {
  const ProfileSettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
}

/// Card containing the list of account/settings rows (edit profile,
/// notifications, language, privacy, support chat, help center, etc).
class ProfileSettingsList extends StatelessWidget {
  const ProfileSettingsList({super.key, required this.items});

  final List<ProfileSettingsItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: profileSurface(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) _SettingsDivider(),
            _SettingsRow(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.item});

  final ProfileSettingsItem item;

  @override
  Widget build(BuildContext context) {
    final textPrimary = profileTextPrimary(context);
    final textMuted = profileTextMuted(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: profileSurfaceAlt(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: profileBrandBlue, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: kmFont(context, GoogleFonts.inter(
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      )),
                    ),
                    if (item.subtitle != null)
                      Text(
                        item.subtitle!,
                        style: kmFont(context, GoogleFonts.inter(
                          color: textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        )),
                      ),
                  ],
                ),
              ),
              Icon(
                HugeIcons.strokeRoundedArrowRight01,
                size: 16,
                color: textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: profileBorder(context)),
    );
  }
}

/// Shows the language-selection bottom sheet, letting the user switch
/// between English and Khmer. [onLanguageChanged] is invoked after a
/// successful change so the caller can refresh its own state (e.g.
/// trigger a setState and show a confirmation snackbar).
void showProfileLanguagePicker(
  BuildContext context, {
  required AppLocalizations l,
  required ValueChanged<String> onLanguageChanged,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: profileSurface(context),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          final current = LanguageService.instance.locale.languageCode;
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: profileBorder(context),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l.selectLanguage,
                  style: kmFont(context, GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: profileTextPrimary(context),
                  )),
                ),
                const SizedBox(height: 18),
                _LangOption(
                  flag: '🇺🇸',
                  name: l.english,
                  selected: current == 'en',
                  onTap: () async {
                    final nav = Navigator.of(ctx);
                    await LanguageService.instance.setLanguage('en');
                    nav.pop();
                    onLanguageChanged('en');
                  },
                ),
                const SizedBox(height: 10),
                _LangOption(
                  flag: '🇰🇭',
                  name: l.khmer,
                  selected: current == 'km',
                  onTap: () async {
                    final nav = Navigator.of(ctx);
                    await LanguageService.instance.setLanguage('km');
                    nav.pop();
                    onLanguageChanged('km');
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _LangOption extends StatelessWidget {
  const _LangOption({
    required this.flag,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String flag;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? profileBrandBlue.withValues(alpha: 0.10)
              : profileSurfaceAlt(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? profileBrandBlue : profileBorder(context),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                style: kmFont(context, GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: profileTextPrimary(context),
                )),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: profileBrandBlue, size: 22),
          ],
        ),
      ),
    );
  }
}
