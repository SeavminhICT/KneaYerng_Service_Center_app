import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../l10n/app_localizations.dart';
import '../../models/pickup_ticket.dart';

class TicketDetailScreen extends StatelessWidget {
  const TicketDetailScreen({super.key, required this.ticket});

  final PickupTicket ticket;

  static const String _pickupLocation =
      'KneaYerng Service Center, Phnom Penh';
  static const String _pickupInstructions =
      'Bring this ticket and a valid ID to the pickup counter.';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final date = ticket.placedAt != null
        ? DateFormat('MMM dd, yyyy • hh:mm a').format(ticket.placedAt!)
        : '--';
    final amount = ticket.totalAmount ?? 0;
    final qrToken = ticket.pickupQrToken ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFE6EDF7) : const Color(0xFF111827);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l.myTickets,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeaderCard(
            orderLabel: ticket.orderNumber ?? 'Order #${ticket.orderId}',
            customerName: ticket.customerName,
            statusLabel: ticket.statusLabel,
            dateLabel: date,
          ),
          const SizedBox(height: 12),
          _QrCard(token: qrToken, ticketId: ticket.pickupTicketId),
          const SizedBox(height: 12),
          _SectionCard(
            title: l.myTickets,
            children: [
              _InfoRow(label: 'Order ID', value: '${ticket.orderId}'),
              _InfoRow(
                label: 'Ticket ID',
                value: ticket.pickupTicketId ?? '--',
              ),
              _InfoRow(label: 'Payment Method', value: _paymentLabel()),
              _InfoRow(
                label: 'Payment Status',
                value: _paymentStatusLabel(),
              ),
              _InfoRow(label: 'Order Date', value: date),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: l.quantity,
            children: ticket.items.isEmpty
                ? [
                    Text(
                      l.noData,
                      style: TextStyle(color: isDark ? const Color(0xFF97A2B5) : const Color(0xFF6B7280)),
                    ),
                  ]
                : ticket.items
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1D2635) : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${item.quantity}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFFE6EDF7) : const Color(0xFF374151),
                                ),
                              ),
                            ),
                            Text(
                              NumberFormat.currency(symbol: '\$')
                                  .format(item.lineTotal),
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: l.total,
            children: [
              Row(
                children: [
                  Text(
                    l.price,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFE6EDF7) : const Color(0xFF374151),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    NumberFormat.currency(symbol: '\$').format(amount),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Pickup Information',
            children: const [
              _InfoRow(label: 'Location', value: _pickupLocation),
              _InfoRow(label: 'Instructions', value: _pickupInstructions),
            ],
          ),
        ],
      ),
    );
  }

  String _paymentLabel() {
    final method = (ticket.paymentMethod ?? '').toLowerCase();
    switch (method) {
      case 'aba':
      case 'aba_qr':
      case 'bakong':
        return 'Bakong';
      case 'cod':
        return 'Cash on Delivery';
      case 'cash':
        return 'Cash';
      case 'wallet':
        return 'Wallet';
      default:
        return method.isEmpty ? 'Bakong' : method.toUpperCase();
    }
  }

  String _paymentStatusLabel() {
    final status = (ticket.paymentStatus ?? '').toLowerCase();
    if (status == 'paid') return 'Paid';
    if (status == 'unpaid') return 'Unpaid';
    if (status == 'processing') return 'Processing';
    if (status == 'failed') return 'Failed';
    if (status.isEmpty) return 'Paid';
    return status[0].toUpperCase() + status.substring(1);
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.orderLabel,
    required this.customerName,
    required this.statusLabel,
    required this.dateLabel,
  });

  final String orderLabel;
  final String customerName;
  final String statusLabel;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = Theme.of(context).cardColor;
    final border = isDark ? const Color(0xFF2B3442) : const Color(0xFFE6E9F0);
    final textPrimary = isDark ? const Color(0xFFE6EDF7) : const Color(0xFF111827);
    final textMuted = isDark ? const Color(0xFF97A2B5) : const Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1D2635) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  customerName,
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateLabel,
                  style: TextStyle(
                    color: textMuted.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          _StatusPill(label: statusLabel),
        ],
      ),
    );
  }
}

class _QrCard extends StatelessWidget {
  const _QrCard({required this.token, this.ticketId});

  final String token;
  final String? ticketId;

  @override
  Widget build(BuildContext context) {
    const qrSize = 260.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = Theme.of(context).cardColor;
    final border = isDark ? const Color(0xFF2B3442) : const Color(0xFFE6E9F0);
    final textPrimary = isDark ? const Color(0xFFE6EDF7) : const Color(0xFF111827);
    final textMuted = isDark ? const Color(0xFF97A2B5) : const Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Text(
            ticketId ?? 'Pickup QR Code',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (token.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: QrImageView(
                data: token,
                size: qrSize,
                backgroundColor: Colors.white,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
              ),
            )
          else
            Container(
              height: qrSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1D2635) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'QR not available',
                style: TextStyle(color: textMuted),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'Scan this code at the pickup counter for verification.',
            style: TextStyle(
              fontSize: 12,
              color: textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Tip: increase screen brightness and keep the code steady.',
            style: TextStyle(
              fontSize: 11,
              color: textMuted.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = Theme.of(context).cardColor;
    final border = isDark ? const Color(0xFF2B3442) : const Color(0xFFE6E9F0);
    final textPrimary = isDark ? const Color(0xFFE6EDF7) : const Color(0xFF111827);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFE6EDF7) : const Color(0xFF111827);
    final textMuted = isDark ? const Color(0xFF97A2B5) : const Color(0xFF6B7280);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final lower = label.toLowerCase();
    Color bg;
    Color fg;
    if (lower == 'active') {
      bg = const Color(0xFFE0EAFF);
      fg = const Color(0xFF1D4ED8);
    } else if (lower == 'used') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
    } else if (lower == 'expired') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFB91C1C);
    } else {
      bg = const Color(0xFFE5E7EB);
      fg = const Color(0xFF6B7280);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
