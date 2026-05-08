import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/admin_notification_campaign.dart';
import '../../services/api_service.dart';

const Color _panelPrimary = Color(0xFF4A88F7);
const Color _panelBackground = Color(0xFFF5F7FB);
const Color _panelSurface = Colors.white;
const Color _panelBorder = Color(0xFFE4EAF4);
const Color _panelText = Color(0xFF111827);
const Color _panelMuted = Color(0xFF6B7280);

enum _ComposerType { announcement, promotion, alert, info, reminder }

enum _Audience { all, active, newUsers, inactive, premium, custom }

class AdminNotificationPanelScreen extends StatefulWidget {
  const AdminNotificationPanelScreen({super.key});

  @override
  State<AdminNotificationPanelScreen> createState() =>
      _AdminNotificationPanelScreenState();
}

class _AdminNotificationPanelScreenState
    extends State<AdminNotificationPanelScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _deepLinkController = TextEditingController();

  _ComposerType _selectedType = _ComposerType.announcement;
  _Audience _selectedAudience = _Audience.all;
  Set<int> _customRecipientIds = <int>{};
  final Map<int, AdminNotificationRecipient> _recipientCache = {};

  List<AdminNotificationCampaignItem> _history = const [];
  bool _loadingHistory = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _applyTemplateForType();
    _titleController.addListener(_handlePreviewChanged);
    _messageController.addListener(_handlePreviewChanged);
    _deepLinkController.addListener(_handlePreviewChanged);
    _loadHistory();
  }

  @override
  void dispose() {
    _titleController.removeListener(_handlePreviewChanged);
    _messageController.removeListener(_handlePreviewChanged);
    _deepLinkController.removeListener(_handlePreviewChanged);
    _titleController.dispose();
    _messageController.dispose();
    _deepLinkController.dispose();
    super.dispose();
  }

  void _handlePreviewChanged() {
    if (!mounted) return;
    setState(() {});
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

    if (_selectedAudience == _Audience.custom && _customRecipientIds.isEmpty) {
      _showSnackBar('Choose at least one user for custom segment.');
      return;
    }

    DateTime? scheduledFor;
    if (action == 'schedule') {
      scheduledFor = await _pickScheduleDateTime();
      if (scheduledFor == null) {
        return;
      }
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
      if (customErrors != null && customErrors.isNotEmpty) {
        _showSnackBar(customErrors.first);
      } else {
        _showSnackBar(result.message);
      }
      return;
    }

    _showSnackBar(result.message);

    if (result.historyItem == null) {
      _loadHistory();
    }
  }

  Future<DateTime?> _pickScheduleDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDate: now,
    );
    if (pickedDate == null) return null;

    if (!mounted) return null;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(minutes: 5))),
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
      builder: (context) {
        return _RecipientPickerSheet(initialSelected: _customRecipientIds);
      },
    );

    if (!mounted || selected == null) return;

    final recipients = await ApiService.searchAdminNotificationRecipients(
      limit: 100,
    );
    if (!mounted) return;

    setState(() {
      _customRecipientIds = selected;
      for (final recipient in recipients) {
        _recipientCache[recipient.id] = recipient;
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
    final previewTitle = _titleController.text.trim();
    final previewMessage = _messageController.text.trim();
    final previewLink = _deepLinkController.text.trim();

    return Scaffold(
      backgroundColor: _panelBackground,
      appBar: AppBar(
        backgroundColor: _panelSurface,
        foregroundColor: _panelText,
        title: const Text(
          'Admin Notification Panel',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: _loadingHistory ? null : _loadHistory,
            icon: _loadingHistory
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notification Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _panelText,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _ComposerType.values
                      .map((type) {
                        final selected = type == _selectedType;
                        return ChoiceChip(
                          label: Text(type.label),
                          selected: selected,
                          selectedColor: _panelPrimary.withValues(alpha: 0.14),
                          side: BorderSide(
                            color: selected ? _panelPrimary : _panelBorder,
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedType = type;
                              _applyTemplateForType();
                            });
                          },
                        );
                      })
                      .toList(growable: false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Compose',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _panelText,
                  ),
                ),
                const SizedBox(height: 12),
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
              ],
            ),
          ),
          const SizedBox(height: 12),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Audience',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _panelText,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _Audience.values
                      .map((audience) {
                        final selected = audience == _selectedAudience;
                        return ChoiceChip(
                          label: Text(audience.label),
                          selected: selected,
                          selectedColor: _panelPrimary.withValues(alpha: 0.14),
                          side: BorderSide(
                            color: selected ? _panelPrimary : _panelBorder,
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedAudience = audience;
                            });
                          },
                        );
                      })
                      .toList(growable: false),
                ),
                if (_selectedAudience == _Audience.custom) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _openCustomSegmentPicker,
                    icon: const Icon(Icons.groups_rounded),
                    label: Text(
                      _customRecipientIds.isEmpty
                          ? 'Choose users in custom segment'
                          : 'Selected ${_customRecipientIds.length} users',
                    ),
                  ),
                  if (_customRecipientIds.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _customRecipientIds
                          .map((id) {
                            final recipient = _recipientCache[id];
                            final label = recipient?.name ?? 'User #$id';
                            return Chip(
                              label: Text(label),
                              onDeleted: () {
                                setState(() {
                                  _customRecipientIds = {..._customRecipientIds}
                                    ..remove(id);
                                });
                              },
                            );
                          })
                          .toList(growable: false),
                    ),
                  ],
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          _card(
            child: TextField(
              controller: _deepLinkController,
              decoration: _inputDecoration('Deep Link (example: /orders/102)'),
            ),
          ),
          const SizedBox(height: 12),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Live Preview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _panelText,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedType.label.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.1,
                          color: Colors.white.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        previewTitle.isEmpty
                            ? 'Title preview will appear here'
                            : previewTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        previewMessage.isEmpty
                            ? 'Message preview will update as you type.'
                            : previewMessage,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.86),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        previewLink.isEmpty ? 'No deep link' : previewLink,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
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
                    : const Icon(Icons.send_rounded),
                label: const Text('Send now'),
                style: FilledButton.styleFrom(
                  backgroundColor: _panelPrimary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(140, 46),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _submitting ? null : () => _submit('schedule'),
                icon: const Icon(Icons.schedule_rounded),
                label: const Text('Schedule'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(120, 46),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _submitting ? null : () => _submit('save_draft'),
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save draft'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(130, 46),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'History',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _panelText,
            ),
          ),
          const SizedBox(height: 10),
          if (_loadingHistory)
            const Center(child: CircularProgressIndicator())
          else if (_history.isEmpty)
            _card(
              child: const Text(
                'No actions yet. Send, schedule, or save a draft to see history rows here.',
                style: TextStyle(color: _panelMuted),
              ),
            )
          else
            ..._history.map((entry) {
              final summary = entry.summary;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(
                                entry.status,
                              ).withValues(alpha: 0.13),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _statusLabel(entry.status),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _statusColor(entry.status),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatDateTime(entry.createdAt),
                            style: const TextStyle(
                              color: _panelMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.title,
                        style: const TextStyle(
                          fontSize: 15,
                          color: _panelText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${entry.type} • Audience: ${_audienceLabelFromApi(entry.audience)} • Action: ${_actionLabel(entry.action)}',
                        style: const TextStyle(
                          color: _panelMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Targeted ${summary.targetedUsers}, delivered ${summary.delivered}, failed ${summary.failed}',
                        style: const TextStyle(color: _panelText, fontSize: 13),
                      ),
                      if (entry.deepLink != null && entry.deepLink!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            entry.deepLink!,
                            style: const TextStyle(
                              color: _panelMuted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      if (entry.scheduledFor != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'Scheduled for ${_formatDateTime(entry.scheduledFor)}',
                            style: const TextStyle(
                              color: _panelMuted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8FAFD),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _panelBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _panelBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _panelPrimary),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panelSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _panelBorder),
      ),
      child: child,
    );
  }
}

class _RecipientPickerSheet extends StatefulWidget {
  const _RecipientPickerSheet({required this.initialSelected});

  final Set<int> initialSelected;

  @override
  State<_RecipientPickerSheet> createState() => _RecipientPickerSheetState();
}

class _RecipientPickerSheetState extends State<_RecipientPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
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
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: _panelSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.78,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
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
                  fontWeight: FontWeight.w800,
                  color: _panelText,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select users to include in this audience.',
                style: TextStyle(color: _panelMuted, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name, email, or phone',
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _panelBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _panelBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _panelPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _recipients.isEmpty
                    ? const Center(
                        child: Text(
                          'No users found.',
                          style: TextStyle(color: _panelMuted),
                        ),
                      )
                    : ListView.separated(
                        itemBuilder: (context, index) {
                          final recipient = _recipients[index];
                          final selected = _selected.contains(recipient.id);
                          final subtitle = [
                            if ((recipient.email ?? '').trim().isNotEmpty)
                              recipient.email!.trim(),
                            if ((recipient.phone ?? '').trim().isNotEmpty)
                              recipient.phone!.trim(),
                            'Orders: ${recipient.ordersCount}',
                          ].join(' • ');

                          return CheckboxListTile(
                            value: selected,
                            activeColor: _panelPrimary,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 2,
                            ),
                            title: Text(
                              recipient.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onChanged: (checked) {
                              setState(() {
                                if (checked == true) {
                                  _selected = {..._selected, recipient.id};
                                } else {
                                  _selected = {..._selected}
                                    ..remove(recipient.id);
                                }
                              });
                            },
                          );
                        },
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1, color: _panelBorder),
                        itemCount: _recipients.length,
                      ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(_selected),
                      style: FilledButton.styleFrom(
                        backgroundColor: _panelPrimary,
                      ),
                      child: Text('Apply (${_selected.length})'),
                    ),
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

extension on _ComposerType {
  String get label {
    switch (this) {
      case _ComposerType.announcement:
        return 'Announcement';
      case _ComposerType.promotion:
        return 'Promotion';
      case _ComposerType.alert:
        return 'Alert';
      case _ComposerType.info:
        return 'Info';
      case _ComposerType.reminder:
        return 'Reminder';
    }
  }

  String get starterTitle {
    switch (this) {
      case _ComposerType.announcement:
        return 'New service center update';
      case _ComposerType.promotion:
        return 'Limited-time repair promotion';
      case _ComposerType.alert:
        return 'Important account alert';
      case _ComposerType.info:
        return 'Useful info for your next visit';
      case _ComposerType.reminder:
        return 'Friendly reminder from KY Service Center';
    }
  }

  String get starterBody {
    switch (this) {
      case _ComposerType.announcement:
        return 'We have a new announcement for all customers. Open the app for details.';
      case _ComposerType.promotion:
        return 'Get special pricing on selected repair services this week only.';
      case _ComposerType.alert:
        return 'Please review this important update as soon as possible.';
      case _ComposerType.info:
        return 'We added new support options to help you faster.';
      case _ComposerType.reminder:
        return 'This is your reminder to check your latest service update.';
    }
  }
}

extension on _Audience {
  String get label {
    switch (this) {
      case _Audience.all:
        return 'All users';
      case _Audience.active:
        return 'Active';
      case _Audience.newUsers:
        return 'New';
      case _Audience.inactive:
        return 'Inactive';
      case _Audience.premium:
        return 'Premium';
      case _Audience.custom:
        return 'Custom segment';
    }
  }

  String get apiValue {
    switch (this) {
      case _Audience.all:
        return 'all';
      case _Audience.active:
        return 'active';
      case _Audience.newUsers:
        return 'new';
      case _Audience.inactive:
        return 'inactive';
      case _Audience.premium:
        return 'premium';
      case _Audience.custom:
        return 'custom';
    }
  }
}

String _formatDateTime(DateTime? value) {
  if (value == null) return 'Unknown';
  final date = value.toLocal();
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${date.year}-$month-$day $hour:$minute';
}

String _statusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'sent':
      return 'Sent';
    case 'scheduled':
      return 'Scheduled';
    case 'draft':
      return 'Draft';
    default:
      return status;
  }
}

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'sent':
      return const Color(0xFF0F9D58);
    case 'scheduled':
      return const Color(0xFFF59E0B);
    case 'draft':
      return const Color(0xFF4A88F7);
    default:
      return const Color(0xFF6B7280);
  }
}

String _actionLabel(String action) {
  switch (action.toLowerCase()) {
    case 'send_now':
      return 'Send now';
    case 'schedule':
      return 'Schedule';
    case 'save_draft':
      return 'Save draft';
    default:
      return action;
  }
}

String _audienceLabelFromApi(String audience) {
  switch (audience.toLowerCase()) {
    case 'all':
      return 'All users';
    case 'active':
      return 'Active';
    case 'new':
      return 'New';
    case 'inactive':
      return 'Inactive';
    case 'premium':
      return 'Premium';
    case 'custom':
      return 'Custom';
    default:
      return audience;
  }
}
