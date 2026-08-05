import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/repair_job.dart';
import '../../services/api_service.dart';
import '../../theme/app_palette.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/page_transitions.dart';
import 'repair_detail_screen.dart';
import 'track_repair_screen.dart';

class MyRepairsScreen extends StatefulWidget {
  const MyRepairsScreen({super.key});

  @override
  State<MyRepairsScreen> createState() => _MyRepairsScreenState();
}

class _MyRepairsScreenState extends State<MyRepairsScreen> {
  late Future<List<RepairJob>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.fetchMyRepairs();
  }

  Future<void> _refresh() async {
    setState(() => _future = ApiService.fetchMyRepairs());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Repairs'),
        centerTitle: false,
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              fadeSlideRoute(const TrackRepairScreen()),
            ),
            icon: const Icon(Icons.search, size: 18),
            label: const Text('Track by Invoice'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<RepairJob>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final jobs = snapshot.data ?? [];
            if (jobs.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 80),
                  EmptyStateView(
                    icon: Icons.build_outlined,
                    title: 'No repair jobs yet',
                    subtitle: 'When you drop off a device for repair, it will show up here.',
                  ),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
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
                        fadeSlideRoute(RepairDetailScreen(repairId: job.id)),
                      );
                      _refresh();
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
                                  job.deviceModel ?? 'Repair #${job.id}',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
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
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (job.problems.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              job.problems.join(', '),
                              style: const TextStyle(color: AppPalette.textMuted, fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (job.technicianName != null) ...[
                                const Icon(Icons.build_outlined, size: 14, color: AppPalette.textMuted),
                                const SizedBox(width: 4),
                                Text(job.technicianName!, style: const TextStyle(fontSize: 12)),
                              ],
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
              },
            );
          },
        ),
      ),
    );
  }
}
