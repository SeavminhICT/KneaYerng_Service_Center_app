import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/repair_job.dart';
import '../../services/api_service.dart';
import '../../theme/app_palette.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/page_transitions.dart';
import 'technician_job_detail_screen.dart';

class TechnicianJobListScreen extends StatefulWidget {
  const TechnicianJobListScreen({super.key});

  @override
  State<TechnicianJobListScreen> createState() => _TechnicianJobListScreenState();
}

class _TechnicianJobListScreenState extends State<TechnicianJobListScreen> {
  late Future<List<RepairJob>> _jobsFuture;
  String _filter = 'active';

  static const _buckets = <String, List<String>>{
    'active': [
      'assigned',
      'accepted',
      'diagnosing',
      'waiting_customer_approval',
      'approved',
      'in_progress',
      'waiting_parts',
      'testing',
    ],
    'new': ['assigned'],
    'completed': ['repair_completed', 'ready_for_pickup', 'delivered'],
    'cancelled': ['cannot_repair', 'cancelled'],
  };

  @override
  void initState() {
    super.initState();
    _jobsFuture = ApiService.fetchAssignedRepairs();
  }

  Future<void> _refresh() async {
    setState(() {
      _jobsFuture = ApiService.fetchAssignedRepairs();
    });
    await _jobsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Repair Jobs'), centerTitle: false),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _buckets.keys.map((key) {
                  final selected = _filter == key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_bucketLabel(key)),
                      selected: selected,
                      onSelected: (_) => setState(() => _filter = key),
                      selectedColor: AppPalette.primarySoft,
                      labelStyle: TextStyle(
                        color: selected ? AppPalette.primary : AppPalette.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<List<RepairJob>>(
                future: _jobsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final all = snapshot.data ?? [];
                  final statuses = _buckets[_filter] ?? const [];
                  final jobs = all.where((j) => statuses.contains(j.status)).toList();

                  if (jobs.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 80),
                        EmptyStateView(
                          icon: Icons.build_outlined,
                          title: 'No repair jobs here',
                          subtitle: 'Jobs assigned to you will show up in this list.',
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: jobs.length,
                    itemBuilder: (context, index) => _JobCard(job: jobs[index], onOpen: _refresh),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _bucketLabel(String key) {
    switch (key) {
      case 'active':
        return 'Active';
      case 'new':
        return 'New';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return key;
    }
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job, required this.onOpen});

  final RepairJob job;
  final VoidCallback onOpen;

  Color _statusColor() {
    switch (job.status) {
      case 'assigned':
        return Colors.amber.shade700;
      case 'cannot_repair':
      case 'cancelled':
        return AppPalette.error;
      case 'delivered':
      case 'repair_completed':
      case 'ready_for_pickup':
        return AppPalette.success;
      default:
        return AppPalette.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppPalette.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await Navigator.of(context).push(
            fadeSlideRoute(TechnicianJobDetailScreen(repairId: job.id)),
          );
          onOpen();
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job.deviceModel ?? 'Unknown device',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor().withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      job.statusLabel,
                      style: TextStyle(
                        color: _statusColor(),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (job.problems.isNotEmpty)
                Text(
                  job.problems.join(', '),
                  style: const TextStyle(color: AppPalette.textMuted, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              else if (job.issueType != null)
                Text(
                  job.issueType!,
                  style: const TextStyle(color: AppPalette.textMuted, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 14, color: AppPalette.textMuted),
                  const SizedBox(width: 4),
                  Text(job.customerName ?? '-', style: const TextStyle(fontSize: 12)),
                  const Spacer(),
                  if (job.createdAt != null)
                    Text(
                      DateFormat('MMM d, HH:mm').format(job.createdAt!),
                      style: const TextStyle(fontSize: 11, color: AppPalette.textMuted),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
