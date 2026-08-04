import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/api_service.dart';
import '../../theme/app_palette.dart';

/// No-login repair tracking: the customer enters the Invoice ID printed on
/// their receipt plus the last few digits of the phone number on file, and
/// gets back a trimmed status view without needing an account.
class TrackRepairScreen extends StatefulWidget {
  const TrackRepairScreen({super.key});

  @override
  State<TrackRepairScreen> createState() => _TrackRepairScreenState();
}

class _TrackRepairScreenState extends State<TrackRepairScreen> {
  final _invoiceController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _result;
  String? _error;

  Future<void> _search() async {
    final invoice = _invoiceController.text.trim();
    final phone = _phoneController.text.trim();
    if (invoice.isEmpty || phone.isEmpty) {
      setState(() => _error = 'Enter both the Invoice ID and phone digits.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    final result = await ApiService.trackRepairAsGuest(
      invoiceNumber: invoice,
      phoneLastDigits: phone,
    );

    if (!mounted) return;
    setState(() {
      _loading = false;
      _result = result;
      _error = result == null ? 'No matching repair found. Check the Invoice ID and phone digits.' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Repair')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'No account needed — enter your Invoice ID and the last digits of your phone number.',
              style: TextStyle(color: AppPalette.textMuted),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _invoiceController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Invoice ID',
                hintText: 'e.g. INV-7L3SNOFM',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Last digits of your phone number',
                hintText: 'e.g. 1222',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _search,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Track Repair'),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: AppPalette.error)),
            ],
            if (_result != null) ...[
              const SizedBox(height: 20),
              _resultCard(_result!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _resultCard(Map<String, dynamic> data) {
    final problems = (data['problems'] is List)
        ? List<String>.from((data['problems'] as List).map((e) => e.toString()))
        : <String>[];
    final timeline = (data['timeline'] is List) ? data['timeline'] as List : const [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppPalette.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  data['device_model']?.toString() ?? 'Repair #${data['repair_id']}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppPalette.primarySoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (data['status_label']?.toString() ?? '').replaceAll('_', ' '),
                  style: const TextStyle(color: AppPalette.primary, fontWeight: FontWeight.w700, fontSize: 11),
                ),
              ),
            ],
          ),
          if (problems.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(problems.join(', '), style: const TextStyle(color: AppPalette.textMuted)),
          ],
          if (data['technician_name'] != null) ...[
            const SizedBox(height: 8),
            Text('Technician: ${data['technician_name']}'),
          ],
          if (data['estimated_total'] != null) ...[
            const SizedBox(height: 8),
            Text('Estimated total: \$${data['estimated_total']}'),
          ],
          if (timeline.isNotEmpty) ...[
            const Divider(height: 24),
            const Text('History', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...timeline.map((entry) {
              final map = Map<String, dynamic>.from(entry as Map);
              final loggedAt = DateTime.tryParse(map['logged_at']?.toString() ?? '');
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        (map['status']?.toString() ?? '').replaceAll('_', ' '),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (loggedAt != null)
                      Text(
                        DateFormat('MMM d, HH:mm').format(loggedAt),
                        style: const TextStyle(fontSize: 11, color: AppPalette.textMuted),
                      ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
