import 'package:flutter/material.dart';

/// Row of "Copy KHQR" / "Copy Reference" outlined buttons shown beneath the
/// order summary card in the Bakong checkout sheet.
class BakongCopyActionsRow extends StatelessWidget {
  const BakongCopyActionsRow({
    super.key,
    required this.canCopy,
    required this.onCopyKhqr,
    required this.onCopyReference,
  });

  final bool canCopy;
  final VoidCallback onCopyKhqr;
  final VoidCallback onCopyReference;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: canCopy ? onCopyKhqr : null,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Color(0xFF0F6BFF)),
              foregroundColor: const Color(0xFF0F6BFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Copy KHQR'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: canCopy ? onCopyReference : null,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              foregroundColor: const Color(0xFF111827),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Copy Reference'),
          ),
        ),
      ],
    );
  }
}
