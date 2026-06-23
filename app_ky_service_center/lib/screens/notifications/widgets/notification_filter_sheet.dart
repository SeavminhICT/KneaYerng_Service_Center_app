import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../l10n/app_localizations.dart';
import 'notification_item.dart';
import 'notification_tone.dart';

/// Bottom sheet allowing the user to pick a [NotificationFilter].
class NotificationFilterSheet extends StatelessWidget {
  const NotificationFilterSheet({super.key, required this.selected});

  final NotificationFilter selected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final filters = NotificationFilter.values;
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: notificationSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6DCE8),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l.filter,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: notificationTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose which notification types should appear in the list.',
              style: TextStyle(fontSize: 13, color: notificationTextMuted),
            ),
            const SizedBox(height: 18),
            ...filters.map((filter) {
              final isSelected = filter == selected;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.of(context).pop(filter),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFEFF4FF)
                            : const Color(0xFFF8FAFD),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? notificationPrimary
                              : notificationBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              filterLabel(filter),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? notificationPrimary
                                    : notificationTextPrimary,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              HugeIcons.strokeRoundedCheckmarkCircle02,
                              color: notificationPrimary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
