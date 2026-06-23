import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/saved_address.dart';
import 'checkout_colors.dart';

const Color _cPrimary = kCheckoutPrimary;

/// Card representing one saved address/map pin, with select/edit/delete
/// actions, used in the delivery address step.
class CheckoutSavedMapCard extends StatelessWidget {
  const CheckoutSavedMapCard({
    super.key,
    required this.address,
    required this.selected,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  final SavedAddress address;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? _cPrimary.withValues(alpha: 0.06)
              : checkoutSurface(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? _cPrimary : checkoutBorder(context),
            width: selected ? 1.3 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _cPrimary.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : const [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: selected
                        ? _cPrimary.withValues(alpha: 0.14)
                        : checkoutSurfaceAlt(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    selected
                        ? HugeIcons.strokeRoundedLocation01
                        : HugeIcons.strokeRoundedLocation01,
                    color: selected ? _cPrimary : checkoutInk(context),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              address.name.trim().isEmpty
                                  ? 'Saved Location'
                                  : address.name,
                              style: TextStyle(
                                color: checkoutInk(context),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (selected)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _cPrimary.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Selected',
                                style: TextStyle(
                                  color: _cPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          if (!selected)
                            Icon(
                              HugeIcons.strokeRoundedRadioButton,
                              size: 18,
                              color: checkoutMuted(context).withValues(alpha: 0.85),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        address.addressLine,
                        style: TextStyle(
                          color: checkoutInk(context),
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                        ),
                      ),
                      if (address.note.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: checkoutSurfaceAlt(context),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            address.note,
                            style: TextStyle(
                              color: checkoutMuted(context),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: onSelect,
                    style: FilledButton.styleFrom(
                      backgroundColor: selected
                          ? (isCheckoutDark(context) ? const Color(0xFF2D3A52) : const Color(0xFF111827))
                          : _cPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(selected ? 'Using This Map' : 'Use This Map'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(HugeIcons.strokeRoundedEdit01, size: 20),
                  tooltip: l.edit,
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(HugeIcons.strokeRoundedDelete01, size: 20),
                  tooltip: l.delete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
