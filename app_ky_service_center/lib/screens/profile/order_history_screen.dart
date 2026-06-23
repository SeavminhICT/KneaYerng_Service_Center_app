import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../l10n/app_localizations.dart';
import '../../models/pickup_ticket.dart';
import '../../services/api_service.dart';
import '../../widgets/empty_state_view.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late Future<List<PickupTicket>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadHistory();
  }

  Future<List<PickupTicket>> _loadHistory() async {
    final tickets = await ApiService.fetchPickupTickets();
    return tickets.where(_isHistoryTicket).toList();
  }

  bool _isHistoryTicket(PickupTicket ticket) {
    if (ticket.pickupVerifiedAt != null) return true;
    final status = (ticket.orderStatus ?? ticket.pickupTicketStatus ?? '')
        .toLowerCase();
    return status == 'completed' || status == 'used' || status == 'expired';
  }

  Future<void> _refresh() async {
    setState(() {
      _historyFuture = _loadHistory();
    });
    await _historyFuture;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFE6EDF7) : const Color(0xFF111827);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l.orderHistory,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      body: FutureBuilder<List<PickupTicket>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          if (snapshot.hasError) {
            return _EmptyState(
              title: l.somethingWentWrong,
              subtitle: 'Please try again in a moment.',
              onRetry: _refresh,
            );
          }

          final history = isLoading
              ? List.generate(
                  4,
                  (index) => PickupTicket(
                    orderId: index,
                    orderNumber: 'Order #0000000$index',
                    pickupTicketId: 'Ticket ID #$index',
                    customerName: 'Customer Name',
                    pickupVerifiedAt: DateTime.now(),
                    totalAmount: 99.99,
                    orderStatus: 'completed',
                    items: const [],
                  ),
                )
              : (snapshot.data ?? []);

          if (!isLoading && history.isEmpty) {
            return _EmptyState(
              title: l.noOrders,
              subtitle: 'Verified or expired pickup tickets will appear here.',
              onRetry: _refresh,
            );
          }

          return Skeletonizer(
            enabled: isLoading,
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: history.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final ticket = history[index];
                  return _HistoryCard(ticket: ticket);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.ticket});

  final PickupTicket ticket;

  @override
  Widget build(BuildContext context) {
    final scannedAt = ticket.pickupVerifiedAt;
    final scanDate = scannedAt != null
        ? DateFormat('MMM dd, yyyy   hh:mm a').format(scannedAt)
        : '--';
    final amount = ticket.totalAmount ?? 0;
    final status = ticket.statusLabel;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = Theme.of(context).cardColor;
    final border = isDark ? const Color(0xFF2B3442) : const Color(0xFFE6E9F0);
    final textPrimary = isDark ? const Color(0xFFE6EDF7) : const Color(0xFF111827);
    final textMuted = isDark ? const Color(0xFF97A2B5) : const Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1D2635) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  HugeIcons.strokeRoundedInvoice01,
                  color: Color(0xFF2563EB),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.orderNumber ?? 'Order #${ticket.orderId}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ticket.pickupTicketId ?? 'Pickup Ticket',
                      style: TextStyle(
                        fontSize: 12,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(label: status),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Scan Date', value: scanDate),
          _InfoRow(label: 'Amount', value: _formatAmount(amount)),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    return NumberFormat.currency(symbol: '\$').format(amount);
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
        children: [
          SizedBox(
            width: 90,
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.onRetry,
  });

  final String title;
  final String subtitle;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return EmptyStateView(
      icon: HugeIcons.strokeRoundedInvoice01,
      iconColor: const Color(0xFF2563EB),
      title: title,
      subtitle: subtitle,
      actionLabel: l.retry,
      onAction: onRetry,
    );
  }
}
