import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../l10n/app_localizations.dart';
import '../../models/admin_notification_campaign.dart';
import '../../services/api_service.dart';
import 'widgets/admin_notification_audience.dart';
import 'widgets/admin_notification_colors.dart';
import 'widgets/admin_notification_composer_type.dart';
import 'widgets/admin_notification_history_card.dart';
import 'widgets/admin_notification_preview.dart';
import 'widgets/admin_notification_recipient_picker_sheet.dart';
import 'widgets/admin_notification_section_label.dart';
import 'widgets/admin_notification_type_chip.dart';

class AdminNotificationPanelScreen extends StatefulWidget {
  const AdminNotificationPanelScreen({super.key});

  @override
  State<AdminNotificationPanelScreen> createState() =>
      _AdminNotificationPanelScreenState();
}

class _AdminNotificationPanelScreenState
    extends State<AdminNotificationPanelScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _deepLinkController = TextEditingController();

  AdminComposerType _selectedType = AdminComposerType.announcement;
  AdminAudience _selectedAudience = AdminAudience.all;
  Set<int> _customRecipientIds = {};
  final Map<int, AdminNotificationRecipient> _recipientCache = {};
  bool _showDeepLink = false;

  List<AdminNotificationCampaignItem> _history = const [];
  bool _loadingHistory = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _applyTemplateForType();
    _titleController.addListener(_rebuild);
    _messageController.addListener(_rebuild);
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.removeListener(_rebuild);
    _messageController.removeListener(_rebuild);
    _titleController.dispose();
    _messageController.dispose();
    _deepLinkController.dispose();
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  Future<void> _loadHistory() async {
    setState(() => _loadingHistory = true);
    final items = await ApiService.fetchAdminNotificationHistory(limit: 40);
    if (!mounted) return;
    setState(() {
      _history = items;
      _loadingHistory = false;
    });
  }

  void _applyTemplateForType() {
    _titleController.text = _selectedType.starterTitle;
    _messageController.text = _selectedType.starterBody;
  }

  Future<void> _submit(String action) async {
    if (_submitting) return;
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();
    final deepLink = _deepLinkController.text.trim();

    if (title.isEmpty) {
      _showSnackBar('Title is required.');
      return;
    }
    if (message.isEmpty) {
      _showSnackBar('Message is required.');
      return;
    }
    if (_selectedAudience == AdminAudience.custom &&
        _customRecipientIds.isEmpty) {
      _showSnackBar('Choose at least one user.');
      return;
    }

    DateTime? scheduledFor;
    if (action == 'schedule') {
      scheduledFor = await _pickScheduleDateTime();
      if (scheduledFor == null) return;
    }

    setState(() => _submitting = true);
    final result = await ApiService.sendAdminNotification(
      type: _selectedType.label,
      title: title,
      message: message,
      audience: _selectedAudience.apiValue,
      customUserIds: _customRecipientIds.toList(growable: false),
      deepLink: deepLink.isEmpty ? null : deepLink,
      action: action,
      scheduledFor: scheduledFor,
    );
    if (!mounted) return;

    setState(() {
      _submitting = false;
      if (result.historyItem != null) {
        _history = [result.historyItem!, ..._history];
      }
    });

    if (!result.success) {
      final customErrors = result.validationErrors['custom_user_ids'];
      _showSnackBar(
        customErrors?.isNotEmpty == true ? customErrors!.first : result.message,
      );
      return;
    }
    _showSnackBar(result.message);
    if (result.historyItem == null) _loadHistory();
  }

  Future<DateTime?> _pickScheduleDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDate: now,
    );
    if (pickedDate == null || !mounted) return null;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        now.add(const Duration(minutes: 5)),
      ),
    );
    if (pickedTime == null) return null;
    final composed = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    if (composed.isBefore(now)) {
      _showSnackBar('Schedule time must be in the future.');
      return null;
    }
    return composed;
  }

  Future<void> _openCustomSegmentPicker() async {
    final selected = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdminNotificationRecipientPickerSheet(
        initialSelected: _customRecipientIds,
      ),
    );
    if (!mounted || selected == null) return;
    final recipients = await ApiService.searchAdminNotificationRecipients(
      limit: 100,
    );
    if (!mounted) return;
    setState(() {
      _customRecipientIds = selected;
      for (final r in recipients) {
        _recipientCache[r.id] = r;
      }
    });
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: adminNotificationBgPage,
      appBar: AppBar(
        backgroundColor: adminNotificationSurface,
        foregroundColor: adminNotificationTextDark,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: adminNotificationPrimary,
          unselectedLabelColor: adminNotificationTextMuted,
          indicatorColor: adminNotificationPrimary,
          indicatorWeight: 2.5,
          tabs: const [
            Tab(text: 'Compose'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildComposeTab(l),
          _buildHistoryTab(l),
        ],
      ),
    );
  }

  Widget _buildComposeTab(AppLocalizations l) {
    final previewTitle = _titleController.text.trim();
    final previewMessage = _messageController.text.trim();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        const AdminNotificationSectionLabel('Notification Type'),
        const SizedBox(height: 8),
        _card(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AdminComposerType.values
                .map(
                  (type) => AdminNotificationTypeChip(
                    type: type,
                    selected: type == _selectedType,
                    onTap: () => setState(() {
                      _selectedType = type;
                      _applyTemplateForType();
                    }),
                  ),
                )
                .toList(growable: false),
          ),
        ),
        const SizedBox(height: 14),
        const AdminNotificationSectionLabel('Message'),
        const SizedBox(height: 8),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: _inputDecoration('Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _messageController,
                maxLines: 4,
                decoration: _inputDecoration('Message'),
              ),
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: () =>
                    setState(() => _showDeepLink = !_showDeepLink),
                icon: Icon(
                  _showDeepLink
                      ? HugeIcons.strokeRoundedUnlink01
                      : HugeIcons.strokeRoundedLink01,
                  size: 16,
                ),
                label: Text(
                  _showDeepLink ? 'Remove deep link' : 'Add deep link',
                ),
                style: TextButton.styleFrom(
                  foregroundColor: adminNotificationTextMuted,
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  textStyle: const TextStyle(fontSize: 13),
                ),
              ),
              if (_showDeepLink) ...[
                const SizedBox(height: 4),
                TextField(
                  controller: _deepLinkController,
                  decoration: _inputDecoration('e.g. /orders/102'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        const AdminNotificationSectionLabel('Audience'),
        const SizedBox(height: 8),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AdminAudience.values
                    .map((audience) {
                      final selected = audience == _selectedAudience;
                      return ChoiceChip(
                        label: Text(audience.label),
                        selected: selected,
                        selectedColor: adminNotificationPrimary.withValues(
                          alpha: 0.12,
                        ),
                        side: BorderSide(
                          color: selected
                              ? adminNotificationPrimary
                              : adminNotificationBorder,
                        ),
                        labelStyle: TextStyle(
                          color: selected
                              ? adminNotificationPrimary
                              : adminNotificationTextDark,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                        onSelected: (_) =>
                            setState(() => _selectedAudience = audience),
                      );
                    })
                    .toList(growable: false),
              ),
              if (_selectedAudience == AdminAudience.custom) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _openCustomSegmentPicker,
                  icon: const Icon(HugeIcons.strokeRoundedUserGroup02, size: 18),
                  label: Text(
                    _customRecipientIds.isEmpty
                        ? 'Choose users'
                        : '${_customRecipientIds.length} users selected',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: adminNotificationPrimary,
                    side: BorderSide(
                      color: adminNotificationPrimary.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                if (_customRecipientIds.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _customRecipientIds
                        .map((id) {
                          final label = _recipientCache[id]?.name ?? 'User #$id';
                          return Chip(
                            label: Text(
                              label,
                              style: const TextStyle(fontSize: 12),
                            ),
                            onDeleted: () => setState(() {
                              _customRecipientIds = {
                                ..._customRecipientIds,
                              }..remove(id);
                            }),
                            deleteIconColor: adminNotificationTextMuted,
                            backgroundColor: const Color(0xFFF0F4FF),
                            side: BorderSide.none,
                          );
                        })
                        .toList(growable: false),
                  ),
                ],
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        const AdminNotificationSectionLabel('Preview'),
        const SizedBox(height: 8),
        AdminNotificationPreview(
          type: _selectedType,
          title: previewTitle.isEmpty ? 'Title preview' : previewTitle,
          message: previewMessage.isEmpty
              ? 'Message preview will appear here.'
              : previewMessage,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: _submitting ? null : () => _submit('send_now'),
                icon: _submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(HugeIcons.strokeRoundedSent, size: 18),
                label: const Text('Send now'),
                style: FilledButton.styleFrom(
                  backgroundColor: adminNotificationPrimary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 46),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _submitting ? null : () => _submit('schedule'),
                icon: const Icon(HugeIcons.strokeRoundedTimeSchedule, size: 16),
                label: const Text('Schedule'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 46),
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _submitting ? null : () => _submit('save_draft'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(46, 46),
                padding: EdgeInsets.zero,
              ),
              child: const Icon(HugeIcons.strokeRoundedFloppyDisk, size: 20),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryTab(AppLocalizations l) {
    return RefreshIndicator(
      onRefresh: _loadHistory,
      color: adminNotificationPrimary,
      child: _loadingHistory
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
          ? ListView(
              children: [
                const SizedBox(height: 100),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        HugeIcons.strokeRoundedTransactionHistory,
                        size: 48,
                        color: adminNotificationTextMuted.withValues(
                          alpha: 0.35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l.noData,
                        style: const TextStyle(
                          color: adminNotificationTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: _history.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) =>
                  AdminNotificationHistoryCard(entry: _history[index]),
            ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: adminNotificationTextMuted),
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
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: adminNotificationSurface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: adminNotificationBorder),
    ),
    child: child,
  );
}
