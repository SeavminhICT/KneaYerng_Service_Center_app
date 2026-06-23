import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../l10n/app_localizations.dart';
import '../../models/pickup_ticket.dart';
import '../../services/api_service.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/page_transitions.dart';
import 'ticket_detail_screen.dart';

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color _screenBg(BuildContext context) =>
    Theme.of(context).scaffoldBackgroundColor;

Color _surface(BuildContext context) =>
    _isDark(context) ? const Color(0xFF161B22) : Colors.white;

Color _surfaceAlt(BuildContext context) =>
    _isDark(context) ? const Color(0xFF1D2635) : const Color(0xFFEFF6FF);

Color _border(BuildContext context) =>
    _isDark(context) ? const Color(0xFF2B3442) : const Color(0xFFE6E9F0);

Color _textPrimary(BuildContext context) =>
    _isDark(context) ? const Color(0xFFE6EDF7) : const Color(0xFF111827);

Color _textMuted(BuildContext context) =>
    _isDark(context) ? const Color(0xFF97A2B5) : const Color(0xFF6B7280);

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  late Future<List<PickupTicket>> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _ticketsFuture = ApiService.fetchPickupTickets();
  }

  Future<void> _refresh() async {
    setState(() {
      _ticketsFuture = ApiService.fetchPickupTickets();
    });
    await _ticketsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _screenBg(context),
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).myTickets,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: _surface(context),
          foregroundColor: _textPrimary(context),
          elevation: 0,
          bottom: TabBar(
            labelColor: _textPrimary(context),
            unselectedLabelColor: _textMuted(context),
            indicatorColor: const Color(0xFF2563EB),
            tabs: const [
              Tab(text: 'Incoming'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: FutureBuilder<List<PickupTicket>>(
          future: _ticketsFuture,
          builder: (context, snapshot) {
            final isLoading = snapshot.connectionState == ConnectionState.waiting;

            if (snapshot.hasError) {
              return _EmptyState(
                title: 'Unable to load tickets',
                subtitle: 'Please try again in a moment.',
                onRetry: _refresh,
              );
            }

            final tickets = isLoading
                ? List.generate(
                    4,
                    (index) => PickupTicket(
                      orderId: index,
                      orderNumber: 'Order #0000000$index',
                      customerName: 'Customer Name',
                      placedAt: DateTime.now(),
                      totalAmount: 99.99,
                      orderStatus: 'active',
                      items: const [],
                    ),
                  )
                : (snapshot.data ?? []);

            final incomingTickets = tickets
                .where((ticket) => ticket.isActive)
                .toList();
            final completedTickets = tickets
                .where((ticket) => !ticket.isActive)
                .toList();

            if (!isLoading) {
              incomingTickets.sort(
                (a, b) => _statusWeight(a).compareTo(_statusWeight(b)),
              );
              completedTickets.sort(
                (a, b) => _statusWeight(a).compareTo(_statusWeight(b)),
              );
            }

            return Skeletonizer(
              enabled: isLoading,
              child: TabBarView(
                children: [
                  _buildTicketList(
                    tickets: incomingTickets,
                    emptyTitle: 'No incoming tickets',
                    emptySubtitle:
                        'Active pickup tickets will appear here after a successful Bakong payment.',
                  ),
                  _buildTicketList(
                    tickets: isLoading ? incomingTickets : completedTickets,
                    emptyTitle: 'No completed tickets',
                    emptySubtitle:
                        'Used or expired pickup tickets will appear here after verification.',
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTicketList({
    required List<PickupTicket> tickets,
    required String emptyTitle,
    required String emptySubtitle,
  }) {
    if (tickets.isEmpty) {
      return _EmptyState(
        title: emptyTitle,
        subtitle: emptySubtitle,
        onRetry: _refresh,
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tickets.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return _TicketCard(
            ticket: ticket,
            onView: () {
              Navigator.of(
                context,
              ).push(fadeSlideRoute(TicketDetailScreen(ticket: ticket)));
            },
          );
        },
      ),
    );
  }
}

int _statusWeight(PickupTicket ticket) {
  if (ticket.isActive) return 0;
  if (ticket.isUsed) return 1;
  return 2;
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket, required this.onView});

  final PickupTicket ticket;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final date = ticket.placedAt != null
        ? DateFormat('MMM dd, yyyy • hh:mm a').format(ticket.placedAt!)
        : '--';
    final amount = ticket.totalAmount ?? 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onView,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _surface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border(context)),
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
                      color: _surfaceAlt(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      HugeIcons.strokeRoundedQrCode01,
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
                            color: _textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 12,
                            color: _textMuted(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(label: ticket.statusLabel),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ticket.customerName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _textMuted(context),
                      ),
                    ),
                  ),
                  Text(
                    NumberFormat.currency(symbol: '\$').format(amount),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _textPrimary(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onView,
                  child: Text(
                    AppLocalizations.of(context).viewAll,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
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
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
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
    return EmptyStateView(
      icon: HugeIcons.strokeRoundedTicket01,
      iconColor: const Color(0xFF2563EB),
      title: title,
      subtitle: subtitle,
      actionLabel: AppLocalizations.of(context).retry,
      onAction: onRetry,
    );
  }
}
