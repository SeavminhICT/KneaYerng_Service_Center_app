import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/admin_notification_campaign.dart';
import '../../../services/api_service.dart';
import 'admin_notification_colors.dart';

/// Bottom sheet that lets an admin search for and select a custom set of
/// notification recipients. Returns the selected set of user ids via
/// `Navigator.pop` when dismissed with a result.
class AdminNotificationRecipientPickerSheet extends StatefulWidget {
  const AdminNotificationRecipientPickerSheet({
    super.key,
    required this.initialSelected,
  });
  final Set<int> initialSelected;

  @override
  State<AdminNotificationRecipientPickerSheet> createState() =>
      _AdminNotificationRecipientPickerSheetState();
}

class _AdminNotificationRecipientPickerSheetState
    extends State<AdminNotificationRecipientPickerSheet> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  bool _loading = true;
  List<AdminNotificationRecipient> _recipients = const [];
  late Set<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initialSelected};
    _fetchRecipients();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), _fetchRecipients);
  }

  Future<void> _fetchRecipients() async {
    setState(() => _loading = true);
    final list = await ApiService.searchAdminNotificationRecipients(
      query: _searchController.text,
      limit: 80,
    );
    if (!mounted) return;
    setState(() {
      _recipients = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.78,
        decoration: const BoxDecoration(
          color: adminNotificationSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6DCE8),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Custom Segment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: adminNotificationTextDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Select users to include.',
              style: TextStyle(color: adminNotificationTextMuted, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, email, or phone',
                prefixIcon: const Icon(HugeIcons.strokeRoundedSearch01, size: 20),
                filled: true,
                fillColor: const Color(0xFFF8FAFD),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: adminNotificationBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: adminNotificationBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: adminNotificationPrimary),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _recipients.isEmpty
                  ? Center(
                      child: Text(
                        l.noData,
                        style: const TextStyle(
                          color: adminNotificationTextMuted,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _recipients.length,
                      separatorBuilder: (_, _) => const Divider(
                        height: 1,
                        color: adminNotificationBorder,
                      ),
                      itemBuilder: (context, index) {
                        final recipient = _recipients[index];
                        final selected = _selected.contains(recipient.id);
                        final subtitle = [
                          if ((recipient.email ?? '').trim().isNotEmpty)
                            recipient.email!.trim(),
                          if ((recipient.phone ?? '').trim().isNotEmpty)
                            recipient.phone!.trim(),
                          'Orders: ${recipient.ordersCount}',
                        ].join(' · ');
                        return CheckboxListTile(
                          value: selected,
                          activeColor: adminNotificationPrimary,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 2,
                          ),
                          title: Text(
                            recipient.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onChanged: (checked) => setState(() {
                            if (checked == true) {
                              _selected = {..._selected, recipient.id};
                            } else {
                              _selected = {..._selected}..remove(recipient.id);
                            }
                          }),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 46),
                    ),
                    child: Text(l.cancel),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(_selected),
                    style: FilledButton.styleFrom(
                      backgroundColor: adminNotificationPrimary,
                      minimumSize: const Size(0, 46),
                    ),
                    child: Text('${l.apply} (${_selected.length})'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
