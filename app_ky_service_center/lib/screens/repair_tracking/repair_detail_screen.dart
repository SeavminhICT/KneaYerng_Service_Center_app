import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/repair_job.dart';
import '../../services/api_service.dart';
import '../../theme/app_palette.dart';

class RepairDetailScreen extends StatefulWidget {
  const RepairDetailScreen({super.key, required this.repairId});

  final int repairId;

  @override
  State<RepairDetailScreen> createState() => _RepairDetailScreenState();
}

class _RepairDetailScreenState extends State<RepairDetailScreen> {
  RepairJob? _job;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final job = await ApiService.fetchRepairDetail(widget.repairId);
    if (!mounted) return;
    setState(() {
      _job = job;
      _loading = false;
    });
  }

  Future<void> _respondToQuotation(bool approve) async {
    final quotationId = _job?.quotation?.id;
    if (quotationId == null) return;
    setState(() => _busy = true);
    final ok = approve
        ? await ApiService.approveRepairQuotation(quotationId)
        : await ApiService.rejectRepairQuotation(quotationId);
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? (approve ? 'Quotation approved.' : 'Quotation rejected.')
              : 'Something went wrong. Please try again.',
        ),
      ),
    );
    if (ok) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Repair #${widget.repairId}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _job == null
              ? const Center(child: Text('Unable to load this repair job.'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    children: [
                      _headerCard(_job!),
                      if (_job!.status == 'waiting_customer_approval' && _job!.quotation != null) ...[
                        const SizedBox(height: 16),
                        _quotationCard(_job!),
                      ],
                      if (_job!.invoice != null) ...[
                        const SizedBox(height: 16),
                        _invoiceCard(_job!),
                      ],
                      const SizedBox(height: 16),
                      _timelineCard(_job!),
                    ],
                  ),
                ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.border),
      ),
      child: child,
    );
  }

  Widget _headerCard(RepairJob job) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job.deviceModel ?? 'Unknown device',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppPalette.primarySoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  job.statusLabel,
                  style: const TextStyle(
                    color: AppPalette.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (job.problems.isNotEmpty) ...[
            const Text('Reported problems', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppPalette.textMuted)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: job.problems
                  .map((p) => Chip(
                        label: Text(p, style: const TextStyle(fontSize: 12)),
                        backgroundColor: AppPalette.background,
                        side: const BorderSide(color: AppPalette.border),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 10),
          ],
          if (job.technicianName != null) ...[
            const Divider(height: 20),
            Row(
              children: [
                const Icon(Icons.build_outlined, size: 16, color: AppPalette.textMuted),
                const SizedBox(width: 6),
                Text('Technician: ${job.technicianName}'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _quotationCard(RepairJob job) {
    final quotation = job.quotation!;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Repair Quotation', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          _costRow('Parts', quotation.partsCost),
          _costRow('Service fee', quotation.laborCost),
          const Divider(height: 20),
          _costRow('Total', quotation.totalCost, bold: true),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : () => _respondToQuotation(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppPalette.error,
                    side: const BorderSide(color: AppPalette.error),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _busy ? null : () => _respondToQuotation(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Approve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _costRow(String label, double amount, {bool bold = false}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      fontSize: bold ? 15 : 13,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('\$${amount.toStringAsFixed(2)}', style: style),
        ],
      ),
    );
  }

  Widget _invoiceCard(RepairJob job) {
    final invoice = job.invoice!;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Invoice', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text(invoice.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Total: \$${invoice.total.toStringAsFixed(2)}'),
          Text('Payment: ${invoice.paymentStatus}'),
        ],
      ),
    );
  }

  Widget _timelineCard(RepairJob job) {
    if (job.statusLogs.isEmpty) return const SizedBox.shrink();
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Status History', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...job.statusLogs.map((log) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: AppPalette.primary, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.status
                              .split('_')
                              .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
                              .join(' '),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        if (log.loggedAt != null)
                          Text(
                            DateFormat('MMM d, HH:mm').format(log.loggedAt!),
                            style: const TextStyle(fontSize: 11, color: AppPalette.textMuted),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
