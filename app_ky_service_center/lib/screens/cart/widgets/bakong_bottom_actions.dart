import 'package:flutter/material.dart';

/// "View Ticket" (success + pickup only) and "Done" buttons shown at the
/// bottom of the Bakong checkout sheet.
class BakongBottomActions extends StatelessWidget {
  const BakongBottomActions({
    super.key,
    required this.showViewTicket,
    required this.isOpeningTicket,
    required this.onViewTicket,
    required this.isLoading,
    required this.onDone,
    required this.doneLabel,
  });

  final bool showViewTicket;
  final bool isOpeningTicket;
  final VoidCallback onViewTicket;
  final bool isLoading;
  final VoidCallback onDone;
  final String doneLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showViewTicket) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isOpeningTicket ? null : onViewTicket,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(isOpeningTicket ? 'Opening ticket...' : 'View Ticket'),
            ),
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : onDone,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F6BFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(doneLabel),
          ),
        ),
      ],
    );
  }
}
