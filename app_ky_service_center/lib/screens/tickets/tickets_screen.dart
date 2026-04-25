import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/pickup_ticket.dart';
import '../../services/api_service.dart';
import '../../widgets/page_transitions.dart';
import 'ticket_detail_screen.dart';

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
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: AppBar(
          title: const Text(
            'My Tickets',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF111827),
          elevation: 0,
          bottom: const TabBar(
            labelColor: Color(0xFF1F2937),
            indicatorColor: Color(0xFF2563EB),
            tabs: [
              Tab(text: 'Incoming'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: FutureBuilder<List<PickupTicket>>(
          future: _ticketsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _EmptyState(
                title: 'Unable to load tickets',
                subtitle: 'Please try again in a moment.',
                onRetry: _refresh,
              );
            }

            final tickets = snapshot.data ?? [];
            final incomingTickets = tickets
                .where((ticket) => ticket.isActive)
                .toList();
            final completedTickets = tickets
                .where((ticket) => !ticket.isActive)
                .toList();

            incomingTickets.sort(
              (a, b) => _statusWeight(a).compareTo(_statusWeight(b)),
            );
            completedTickets.sort(
              (a, b) => _statusWeight(a).compareTo(_statusWeight(b)),
            );

            return TabBarView(
              children: [
                _buildTicketList(
                  tickets: incomingTickets,
                  emptyTitle: 'No incoming tickets',
                  emptySubtitle:
                      'Active pickup tickets will appear here after a successful Bakong payment.',
                ),
                _buildTicketList(
                  tickets: completedTickets,
                  emptyTitle: 'No completed tickets',
                  emptySubtitle:
                      'Used or expired pickup tickets will appear here after verification.',
                ),
              ],
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE6E9F0)),
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
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.qr_code_2_rounded,
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
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  Text(
                    NumberFormat.currency(symbol: '\$').format(amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onView,
                  child: const Text(
                    'View Ticket',
                    style: TextStyle(fontWeight: FontWeight.w700),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.confirmation_number_outlined,
                color: Color(0xFF2563EB),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
