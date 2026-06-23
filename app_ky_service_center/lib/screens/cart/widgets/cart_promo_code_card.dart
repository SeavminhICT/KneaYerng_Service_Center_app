import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_fonts.dart';
import 'cart_colors.dart';

/// Apply-state for the promo/voucher CTA button, shared with cart_screen.dart.
enum CartApplyState { idle, applying, successCheck, applied }

/// Collapsible card for entering / displaying an applied promo code.
class CartPromoCodeCard extends StatelessWidget {
  const CartPromoCodeCard({
    super.key,
    required this.controller,
    required this.isApplying,
    required this.applyState,
    required this.onApply,
    required this.onRemove,
    required this.appliedCode,
    required this.discount,
    required this.errorText,
    required this.onCodeChanged,
    required this.expandAnimation,
    required this.chevronTurns,
    required this.shakeOffset,
    required this.showChip,
    required this.isRechecking,
    required this.onToggleExpanded,
  });

  final TextEditingController controller;
  final bool isApplying;
  final CartApplyState applyState;
  final VoidCallback onApply;
  final VoidCallback onRemove;
  final String? appliedCode;
  final double discount;
  final String? errorText;
  final ValueChanged<String> onCodeChanged;
  final Animation<double> expandAnimation;
  final Animation<double> chevronTurns;
  final Animation<double> shakeOffset;
  final bool showChip;
  final bool isRechecking;
  final VoidCallback onToggleExpanded;

  bool get _inputEnabled => !isApplying && applyState == CartApplyState.idle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final hasError = errorText != null && errorText!.isNotEmpty;
    final showChipView = showChip && (appliedCode?.isNotEmpty ?? false);

    Widget buildApplyChild() {
      switch (applyState) {
        case CartApplyState.applying:
          return const SizedBox(
            key: ValueKey('applying'),
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          );
        case CartApplyState.successCheck:
          return const Icon(HugeIcons.strokeRoundedTick01, key: ValueKey('check'), size: 20);
        case CartApplyState.applied:
        case CartApplyState.idle:
          return Text(l.apply, key: const ValueKey('apply'));
      }
    }

    Widget buildInputArea() {
      return Column(
        key: const ValueKey('input'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: shakeOffset,
            builder: (context, child) =>
                Transform.translate(offset: Offset(shakeOffset.value, 0), child: child),
            child: Column(
              children: [
                // Input
                TextField(
                  controller: controller,
                  enabled: _inputEnabled,
                  onChanged: onCodeChanged,
                  textInputAction: TextInputAction.done,
                  onSubmitted: _inputEnabled ? (_) => onApply() : null,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cartInk),
                  decoration: InputDecoration(
                    hintText: 'Enter promo code',
                    hintStyle: const TextStyle(color: cartMuted, fontWeight: FontWeight.w400),
                    filled: true,
                    fillColor: cartSurfaceSoft,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: hasError ? cartDanger : cartBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: hasError ? cartDanger : cartBorder),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: cartBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: hasError ? cartDanger : cartPrimaryDeep, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Apply button — full width
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _inputEnabled ? onApply : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cartPrimaryDeep,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: cartPrimaryDeep.withAlpha(100),
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: buildApplyChild(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Error
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: hasError
                ? Padding(
                    key: const ValueKey('err'),
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      errorText!,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cartDanger),
                    ),
                  )
                : const SizedBox(key: ValueKey('no-err')),
          ),
          const SizedBox(height: 10),
          const Text(
            'Codes are checked instantly against your current cart subtotal.',
            style: TextStyle(fontSize: 11.5, height: 1.5, color: cartMuted),
          ),
        ],
      );
    }

    Widget buildChip() {
      final code = appliedCode ?? '';
      return Container(
        key: const ValueKey('chip'),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFEDF7F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBFE4D3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFBFE4D3)),
              ),
              child: const Icon(HugeIcons.strokeRoundedCheckmarkCircle02, color: cartSuccess, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: cartInk),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    discount > 0
                        ? 'You saved ${cartCurrency(discount)}'
                        : 'Voucher applied to this order.',
                    style: const TextStyle(fontSize: 12, color: cartSuccess, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onRemove,
              style: TextButton.styleFrom(
                foregroundColor: cartMuted,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              child: Text(l.remove),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cartSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: cartShadow, blurRadius: 14, offset: Offset(0, 4))],
      ),
      child: AnimatedBuilder(
        animation: expandAnimation,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ───────────────────────────────────────────────
            InkWell(
              onTap: onToggleExpanded,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: cartPrimarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        HugeIcons.strokeRoundedTicket01,
                        size: 18,
                        color: cartPrimaryDeep,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Promo code',
                            style: kmFont(context, GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: cartInk,
                              height: 1.2,
                            )),
                          ),
                          if (!showChipView)
                            const Text(
                              'Optional',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: cartMuted),
                            ),
                        ],
                      ),
                    ),
                    // Rechecking / applied badge
                    if (isRechecking)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: cartPrimaryDeep),
                      )
                    else if (showChipView)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDF7F2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Applied',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cartSuccess),
                        ),
                      ),
                    const SizedBox(width: 10),
                    RotationTransition(
                      turns: chevronTurns,
                      child: const Icon(HugeIcons.strokeRoundedArrowDown01, color: cartMuted, size: 22),
                    ),
                  ],
                ),
              ),
            ),
            // ── Expandable body ──────────────────────────────────────────
            SizeTransition(
              sizeFactor: expandAnimation,
              axisAlignment: -1,
              child: FadeTransition(
                opacity: expandAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: showChipView ? buildChip() : buildInputArea(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
