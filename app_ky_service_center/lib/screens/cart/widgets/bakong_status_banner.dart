import 'package:flutter/material.dart';

/// Status banner shown above the QR card while a Bakong payment is pending,
/// checking, or has failed. Displays a spinner/icon, status text, and the
/// optional QR expiry countdown.
class BakongStatusBanner extends StatelessWidget {
  const BakongStatusBanner({
    super.key,
    required this.statusText,
    required this.statusColor,
    required this.statusIcon,
    required this.isChecking,
    required this.isSuccess,
    required this.isTerminalFailure,
    this.expiresCountdown,
  });

  final String statusText;
  final Color statusColor;
  final IconData statusIcon;
  final bool isChecking;
  final bool isSuccess;
  final bool isTerminalFailure;
  final String? expiresCountdown;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          if (!isSuccess && !isTerminalFailure && isChecking)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(statusIcon, color: statusColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          if (expiresCountdown != null)
            Text(
              expiresCountdown!,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}
