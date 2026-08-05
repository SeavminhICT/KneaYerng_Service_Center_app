import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/repair_job.dart';
import '../../services/api_service.dart';
import '../../theme/app_palette.dart';

class TechnicianJobDetailScreen extends StatefulWidget {
  const TechnicianJobDetailScreen({super.key, required this.repairId});

  final int repairId;

  @override
  State<TechnicianJobDetailScreen> createState() => _TechnicianJobDetailScreenState();
}

class _TechnicianJobDetailScreenState extends State<TechnicianJobDetailScreen> {
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

  Future<void> _runAction(Future<bool> Function() action, {String? successMessage}) async {
    setState(() => _busy = true);
    final ok = await action();
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      if (successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage)));
      }
      await _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong. Please try again.')),
      );
    }
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
                      const SizedBox(height: 16),
                      _actionSection(_job!),
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
          if ((job.issueType ?? '').isNotEmpty) ...[
            const Text('Notes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppPalette.textMuted)),
            const SizedBox(height: 4),
            Text(job.issueType!),
            const SizedBox(height: 10),
          ],
          const Divider(height: 20),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: AppPalette.textMuted),
              const SizedBox(width: 6),
              Text(job.customerName ?? '-'),
            ],
          ),
          if ((job.customerPhone ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 16, color: AppPalette.textMuted),
                const SizedBox(width: 6),
                Text(job.customerPhone!),
              ],
            ),
          ],
          if (job.quotation != null) ...[
            const Divider(height: 20),
            Text(
              'Quotation: \$${job.quotation!.totalCost.toStringAsFixed(2)} (${job.quotation!.status})',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionSection(RepairJob job) {
    switch (job.status) {
      case 'assigned':
        return _assignedActions(job);
      case 'accepted':
        return _diagnosticForm(job);
      case 'diagnosing':
        return _quotationForm(job);
      case 'waiting_customer_approval':
        return _infoCard('Waiting for the customer to approve the quotation.');
      case 'approved':
        return _simpleTransitionButton(job, 'in_progress', 'Start Repair');
      case 'in_progress':
        return Column(
          children: [
            _partsUsageCard(job),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _simpleTransitionButton(job, 'waiting_parts', 'Waiting for Parts', outlined: true)),
                const SizedBox(width: 10),
                Expanded(child: _simpleTransitionButton(job, 'testing', 'Start Testing')),
              ],
            ),
            const SizedBox(height: 10),
            _simpleTransitionButton(job, 'cannot_repair', 'Cannot Repair', danger: true),
          ],
        );
      case 'waiting_parts':
        return _simpleTransitionButton(job, 'in_progress', 'Resume Repair');
      case 'testing':
        return _qcForm(job);
      case 'repair_completed':
        return _infoCard('Repair completed. Waiting for the shop to hand the device back.');
      case 'ready_for_pickup':
        return _infoCard('Device is ready for pickup.');
      case 'delivered':
        return _infoCard('Delivered to the customer.');
      case 'cannot_repair':
      case 'cancelled':
        return _infoCard('This job is closed.');
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _infoCard(String text) {
    return _card(
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppPalette.textMuted),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: AppPalette.textMuted))),
        ],
      ),
    );
  }

  Widget _assignedActions(RepairJob job) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _busy
                ? null
                : () => _runAction(
                      () => ApiService.acceptRepairJob(job.id),
                      successMessage: 'Job accepted.',
                    ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Accept Job'),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _busy ? null : () => _showReasonDialog(
                  title: 'Reject Job',
                  hint: 'Reason for rejecting (e.g. busy, missing parts)',
                  onSubmit: (reason) => _runAction(
                    () => ApiService.rejectRepairJob(job.id, reason),
                    successMessage: 'Job rejected.',
                  ),
                ),
                child: const Text('Reject'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: _busy ? null : () => _showReasonDialog(
                  title: 'Request Reassignment',
                  hint: 'Why should this job go to another technician?',
                  onSubmit: (reason) => _runAction(
                    () => ApiService.requestRepairReassignment(job.id, reason),
                    successMessage: 'Reassignment requested.',
                  ),
                ),
                child: const Text('Reassign'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showReasonDialog({
    required String title,
    required String hint,
    required Future<void> Function(String reason) onSubmit,
  }) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(hintText: hint, border: const OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (reason != null && reason.isNotEmpty) {
      await onSubmit(reason);
    }
  }

  Widget _simpleTransitionButton(
    RepairJob job,
    String target,
    String label, {
    bool outlined = false,
    bool danger = false,
  }) {
    final button = ElevatedButton(
      onPressed: _busy
          ? null
          : () => _runAction(
                () => ApiService.updateRepairStatus(job.id, target),
                successMessage: 'Status updated.',
              ),
      style: ElevatedButton.styleFrom(
        backgroundColor: danger ? AppPalette.error : AppPalette.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(label),
    );
    if (!outlined) return SizedBox(width: double.infinity, child: button);
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _busy
            ? null
            : () => _runAction(
                  () => ApiService.updateRepairStatus(job.id, target),
                  successMessage: 'Status updated.',
                ),
        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
        child: Text(label),
      ),
    );
  }

  Widget _diagnosticForm(RepairJob job) {
    final descController = TextEditingController();
    final laborController = TextEditingController();
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Start Diagnosis', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          TextField(
            controller: descController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'What did you find?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: laborController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Service fee (\$)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _busy
                  ? null
                  : () => _runAction(
                        () => ApiService.submitRepairDiagnostic(
                          job.id,
                          problemDescription: descController.text.trim(),
                          laborCost: double.tryParse(laborController.text.trim()),
                        ),
                        successMessage: 'Diagnosis saved.',
                      ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Save Diagnosis'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quotationForm(RepairJob job) {
    final partsController = TextEditingController(
      text: job.quotation != null ? job.quotation!.partsCost.toStringAsFixed(2) : '',
    );
    final laborController = TextEditingController(
      text: job.quotation != null ? job.quotation!.laborCost.toStringAsFixed(2) : '',
    );
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Send Quotation to Customer', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          TextField(
            controller: partsController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Parts cost (\$)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: laborController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Service fee (\$)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _busy
                  ? null
                  : () => _runAction(
                        () => ApiService.submitRepairQuotation(
                          job.id,
                          partsCost: double.tryParse(partsController.text.trim()) ?? 0,
                          laborCost: double.tryParse(laborController.text.trim()) ?? 0,
                        ),
                        successMessage: 'Quotation sent to customer.',
                      ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Send Quotation'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _partsUsageCard(RepairJob job) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Use a part', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _busy ? null : () => _openPartsPicker(job),
              icon: const Icon(Icons.add_box_outlined),
              label: const Text('Pick part from inventory'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPartsPicker(RepairJob job) async {
    final parts = await ApiService.fetchTechnicianParts();
    if (!mounted) return;
    if (parts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No parts in stock.')),
      );
      return;
    }

    Map<String, dynamic>? selectedPart;
    final qtyController = TextEditingController(text: '1');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select a part', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      itemCount: parts.length,
                      itemBuilder: (context, index) {
                        final part = parts[index];
                        final selected = selectedPart != null && selectedPart!['id'] == part['id'];
                        return ListTile(
                          title: Text(part['name']?.toString() ?? ''),
                          subtitle: Text('Stock: ${part['stock']} · \$${part['unit_cost']}'),
                          selected: selected,
                          selectedTileColor: AppPalette.primarySoft,
                          onTap: () => setModalState(() => selectedPart = Map<String, dynamic>.from(part)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedPart == null
                          ? null
                          : () async {
                              Navigator.pop(context);
                              final qty = int.tryParse(qtyController.text.trim()) ?? 1;
                              await _runAction(
                                () => ApiService.submitPartsUsage(
                                  job.id,
                                  partId: selectedPart!['id'] as int,
                                  quantity: qty,
                                ),
                                successMessage: 'Part added to repair.',
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPalette.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Add Part'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static const _qcItems = <String, String>{
    'touch': 'Touch Screen',
    'face_id': 'Face ID / Fingerprint',
    'camera': 'Camera',
    'charging': 'Charging',
    'speaker': 'Speaker',
    'microphone': 'Microphone',
    'wifi': 'Wi-Fi',
    'bluetooth': 'Bluetooth',
  };

  Widget _qcForm(RepairJob job) {
    final results = <String, String>{for (final key in _qcItems.keys) key: 'na'};
    final notesController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setLocalState) {
        return _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Final Testing Checklist', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text(
                'Any "Fail" sends the job back to In Progress; all pass/N/A completes the repair.',
                style: TextStyle(fontSize: 12, color: AppPalette.textMuted),
              ),
              const SizedBox(height: 10),
              ..._qcItems.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(entry.value)),
                      DropdownButton<String>(
                        value: results[entry.key],
                        items: const [
                          DropdownMenuItem(value: 'na', child: Text('N/A')),
                          DropdownMenuItem(value: 'pass', child: Text('Pass')),
                          DropdownMenuItem(value: 'fail', child: Text('Fail')),
                        ],
                        onChanged: (value) => setLocalState(() => results[entry.key] = value ?? 'na'),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Notes (optional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _busy
                      ? null
                      : () => _runAction(
                            () => ApiService.submitRepairQc(
                              job.id,
                              results: results,
                              notes: notesController.text.trim(),
                            ),
                            successMessage: 'Test results saved.',
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Submit Test Results'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _timelineCard(RepairJob job) {
    if (job.statusLogs.isEmpty) return const SizedBox.shrink();
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('History', style: TextStyle(fontWeight: FontWeight.w700)),
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
                          log.status.split('_').map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1)).join(' '),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        if (log.note != null && log.note!.isNotEmpty)
                          Text(log.note!, style: const TextStyle(fontSize: 12, color: AppPalette.textMuted)),
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
