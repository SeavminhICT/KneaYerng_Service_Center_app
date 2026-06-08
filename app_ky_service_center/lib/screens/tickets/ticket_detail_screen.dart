import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../l10n/app_localizations.dart';
import '../../models/pickup_ticket.dart';

// ── Palette ──────────────────────────────────────────────────────────────────
const _blue900  = Color(0xFF1E3A8A);
const _blue700  = Color(0xFF1D4ED8);
const _blue100  = Color(0xFFDBEAFE);
const _green600 = Color(0xFF16A34A);
const _green100 = Color(0xFFDCFCE7);
const _amber600 = Color(0xFFD97706);
const _red600   = Color(0xFFDC2626);
const _red100   = Color(0xFFFEE2E2);
const _gray900  = Color(0xFF111827);
const _gray600  = Color(0xFF4B5563);
const _gray400  = Color(0xFF9CA3AF);
const _gray100  = Color(0xFFF3F4F6);
const _white    = Color(0xFFFFFFFF);

class TicketDetailScreen extends StatefulWidget {
  const TicketDetailScreen({super.key, required this.ticket});

  final PickupTicket ticket;

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen>
    with SingleTickerProviderStateMixin {
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _startCountdown();
  }

  void _startCountdown() {
    final expiresAt = widget.ticket.pickupQrExpiresAt;
    if (expiresAt == null || widget.ticket.isUsed) return;

    _updateRemaining(expiresAt);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _updateRemaining(expiresAt);
    });
  }

  void _updateRemaining(DateTime expiresAt) {
    final diff = expiresAt.difference(DateTime.now());
    setState(() {
      _remaining = diff.isNegative ? Duration.zero : diff;
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatRemaining() {
    if (_remaining == Duration.zero) return 'Expired';
    final h = _remaining.inHours;
    final m = _remaining.inMinutes.remainder(60);
    final s = _remaining.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m remaining';
    if (m > 0) return '${m}m ${s}s remaining';
    return '${s}s remaining';
  }

  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;
    final l      = AppLocalizations.of(context);

    // Prefer the short 12-char code; fall back to the full encrypted token
    // for orders issued before the short-code feature was deployed.
    final qrData = ticket.pickupQrCode?.isNotEmpty == true
        ? ticket.pickupQrCode!
        : (ticket.pickupQrToken ?? '');

    final date = ticket.placedAt != null
        ? DateFormat('MMM dd, yyyy • hh:mm a').format(ticket.placedAt!)
        : '--';

    return Scaffold(
      backgroundColor: _gray100,
      appBar: AppBar(
        title: Text(
          l.myTickets,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: _gray900,
          ),
        ),
        backgroundColor: _white,
        foregroundColor: _gray900,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE5E7EB)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          // ── Header card ────────────────────────────────────────────────
          _HeaderCard(ticket: ticket, dateLabel: date),
          const SizedBox(height: 16),

          // ── QR card ────────────────────────────────────────────────────
          _QrCard(
            ticket: ticket,
            qrData: qrData,
            remaining: _remaining,
            formattedRemaining: _formatRemaining(),
            pulseAnimation: _pulseAnimation,
          ),
          const SizedBox(height: 16),

          // ── Order details ──────────────────────────────────────────────
          _DetailCard(
            title: 'Order Details',
            icon: Icons.receipt_long_rounded,
            rows: [
              _Row('Ticket ID',       ticket.pickupTicketId ?? '--'),
              _Row('Order',           ticket.orderNumber ?? '#${ticket.orderId}'),
              _Row('Payment',         _paymentLabel(ticket.paymentMethod)),
              _Row('Payment Status',  _paymentStatusLabel(ticket.paymentStatus),
                   valueColor: _paymentStatusColor(ticket.paymentStatus)),
              _Row('Date',            date),
            ],
          ),
          const SizedBox(height: 16),

          // ── Items ──────────────────────────────────────────────────────
          _ItemsCard(ticket: ticket),
          const SizedBox(height: 16),

          // ── Pickup info ────────────────────────────────────────────────
          _DetailCard(
            title: 'Pickup Location',
            icon: Icons.store_rounded,
            rows: const [
              _Row('Store',        'KneaYerng Service Center, Phnom Penh'),
              _Row('Instructions', 'Bring this ticket and a valid ID.'),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Header card ────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.ticket, required this.dateLabel});

  final PickupTicket ticket;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_blue900, _blue700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x331D4ED8),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.confirmation_number_rounded,
                color: _white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.orderNumber ?? 'Order #${ticket.orderId}',
                  style: const TextStyle(
                    color: _white,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ticket.customerName,
                  style: TextStyle(
                    color: _white.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateLabel,
                  style: TextStyle(
                    color: _white.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          _StatusBadge(label: ticket.statusLabel),
        ],
      ),
    );
  }
}

// ── QR card ────────────────────────────────────────────────────────────────

class _QrCard extends StatelessWidget {
  const _QrCard({
    required this.ticket,
    required this.qrData,
    required this.remaining,
    required this.formattedRemaining,
    required this.pulseAnimation,
  });

  final PickupTicket ticket;
  final String qrData;
  final Duration remaining;
  final String formattedRemaining;
  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context) {
    final isActive  = ticket.isActive && qrData.isNotEmpty;
    final isUsed    = ticket.isUsed;
    final isExpired = ticket.isExpired;

    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Top label ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                const Icon(Icons.qr_code_2_rounded, color: _blue700, size: 22),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Scan to Verify Pickup',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: _gray900,
                    ),
                  ),
                ),
                if (isActive)
                  AnimatedBuilder(
                    animation: pulseAnimation,
                    builder: (_, child) => Opacity(
                      opacity: pulseAnimation.value,
                      child: child,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _green100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: _green600,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Active',
                            style: TextStyle(
                              color: _green600,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (isUsed)
                  _smallChip('Used', _green100, _green600),
                if (!isUsed && isExpired)
                  _smallChip('Expired', _red100, _red600),
              ],
            ),
          ),

          // ── Dashed divider ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: _DashedDivider(),
          ),

          // ── QR code ────────────────────────────────────────────────
          if (qrData.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUsed || isExpired
                    ? const Color(0xFFF9FAFB)
                    : _white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive
                      ? _blue100
                      : const Color(0xFFE5E7EB),
                  width: 2,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ColorFiltered(
                    colorFilter: (isUsed || isExpired)
                        ? const ColorFilter.matrix([
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0,      0,      0,      1, 0,
                          ])
                        : const ColorFilter.mode(
                            Colors.transparent, BlendMode.color),
                    child: QrImageView(
                      data: qrData,
                      size: 240,
                      backgroundColor: _white,
                      // M-level (15 % recovery) is the sweet spot:
                      // enough redundancy for a scratched screen,
                      // small enough for large scannable modules.
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: _gray900,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: _gray900,
                      ),
                    ),
                  ),
                  if (isUsed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _green600.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'VERIFIED',
                        style: TextStyle(
                          color: _white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  if (!isUsed && isExpired)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _red600.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'EXPIRED',
                        style: TextStyle(
                          color: _white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                ],
              ),
            )
          else
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 180,
              decoration: BoxDecoration(
                color: _gray100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.qr_code_rounded, size: 48, color: _gray400),
                    SizedBox(height: 10),
                    Text(
                      'QR not available',
                      style: TextStyle(color: _gray400, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),

          // ── Short code + countdown ─────────────────────────────────
          if (qrData.isNotEmpty) ...[
            const SizedBox(height: 14),
            // Display the short code so admin can also type it manually
            if (ticket.pickupQrCode?.isNotEmpty == true)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _gray100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.tag_rounded,
                        size: 14, color: _gray400),
                    const SizedBox(width: 6),
                    Text(
                      ticket.pickupQrCode!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _gray600,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
          ],

          // ── Bottom instructions ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                if (isActive && remaining > Duration.zero) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 13,
                        color: remaining.inMinutes < 30
                            ? _amber600
                            : _gray400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formattedRemaining,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: remaining.inMinutes < 30
                              ? _amber600
                              : _gray400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  isUsed
                      ? 'This ticket has been used and verified.'
                      : isExpired
                          ? 'This QR has expired. Please contact the store.'
                          : 'Show this QR at the pickup counter.\nIncrease screen brightness for best results.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _gray400,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallChip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Items card ─────────────────────────────────────────────────────────────

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.ticket});

  final PickupTicket ticket;

  @override
  Widget build(BuildContext context) {
    final amount = ticket.totalAmount ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_bag_outlined,
                  color: _blue700, size: 18),
              const SizedBox(width: 8),
              Text(
                'Items (${ticket.items.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: _gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (ticket.items.isEmpty)
            const Text('No items', style: TextStyle(color: _gray400))
          else ...[
            for (final item in ticket.items) _ItemRow(item: item),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: Color(0xFFE5E7EB)),
            ),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: _gray900,
                    ),
                  ),
                ),
                Text(
                  NumberFormat.currency(symbol: '\$').format(amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: _blue700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final PickupTicketItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _blue100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${item.quantity}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: _blue700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: _gray900,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            NumberFormat.currency(symbol: '\$').format(item.lineTotal),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: _gray600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Detail card ────────────────────────────────────────────────────────────

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.title,
    required this.icon,
    required this.rows,
  });

  final String title;
  final IconData icon;
  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _blue700, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: _gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final row in rows) _RowWidget(row: row),
        ],
      ),
    );
  }
}

class _Row {
  const _Row(this.label, this.value, {this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;
}

class _RowWidget extends StatelessWidget {
  const _RowWidget({required this.row});

  final _Row row;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              row.label,
              style: const TextStyle(
                color: _gray400,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              row.value,
              style: TextStyle(
                color: row.valueColor ?? _gray900,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status badge ───────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final lower = label.toLowerCase();
    late Color bg;
    late Color fg;
    if (lower == 'active' || lower == 'approved' || lower == 'processing') {
      bg = const Color(0xFF1E40AF).withValues(alpha: 0.2);
      fg = const Color(0xFFBADAFF);
    } else if (lower == 'complete' || lower == 'used') {
      bg = _green600.withValues(alpha: 0.2);
      fg = const Color(0xFF86EFAC);
    } else if (lower == 'expired' || lower == 'cancelled' || lower == 'rejected') {
      bg = _red600.withValues(alpha: 0.2);
      fg = const Color(0xFFFCA5A5);
    } else {
      bg = _white.withValues(alpha: 0.15);
      fg = _white.withValues(alpha: 0.85);
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

// ── Dashed divider ─────────────────────────────────────────────────────────

class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 6.0;
        const gapWidth  = 4.0;
        final count = (constraints.maxWidth / (dashWidth + gapWidth)).floor();
        return Row(
          children: List.generate(count, (_) => Padding(
            padding: const EdgeInsets.only(right: gapWidth),
            child: Container(
              width: dashWidth,
              height: 1,
              color: const Color(0xFFE5E7EB),
            ),
          )),
        );
      },
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────

String _paymentLabel(String? method) {
  switch ((method ?? '').toLowerCase()) {
    case 'aba':
    case 'aba_qr':
    case 'bakong':
      return 'Bakong QR';
    case 'cod':
      return 'Cash on Delivery';
    case 'cash':
      return 'Cash';
    default:
      final m = (method ?? '').trim();
      return m.isEmpty ? 'Bakong QR' : m.toUpperCase();
  }
}

String _paymentStatusLabel(String? status) {
  switch ((status ?? '').toLowerCase()) {
    case 'paid':
      return 'Paid';
    case 'unpaid':
      return 'Unpaid';
    case 'processing':
      return 'Processing';
    case 'failed':
      return 'Failed';
    default:
      final s = (status ?? '').trim();
      return s.isEmpty ? 'Paid' : '${s[0].toUpperCase()}${s.substring(1)}';
  }
}

Color _paymentStatusColor(String? status) {
  switch ((status ?? '').toLowerCase()) {
    case 'paid':
      return _green600;
    case 'failed':
      return _red600;
    case 'processing':
      return _amber600;
    default:
      return _gray600;
  }
}
