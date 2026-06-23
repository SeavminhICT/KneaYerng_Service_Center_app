import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// Outlined "Check Payment Status" button shown while a Bakong QR is active
/// and payment is still pending.
class BakongCheckStatusButton extends StatelessWidget {
  const BakongCheckStatusButton({
    super.key,
    required this.isChecking,
    required this.onPressed,
  });

  final bool isChecking;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isChecking ? null : onPressed,
        icon: isChecking
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(HugeIcons.strokeRoundedRefresh, size: 18),
        label: Text(isChecking ? 'Checking Payment...' : 'Check Payment Status'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Color(0xFF0F6BFF)),
          foregroundColor: const Color(0xFF0F6BFF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
