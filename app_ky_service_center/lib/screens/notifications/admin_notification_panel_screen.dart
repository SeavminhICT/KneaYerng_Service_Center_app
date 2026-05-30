import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/admin_notification_campaign.dart';
import '../../services/api_service.dart';

const Color _primary = Color(0xFF4A88F7);
const Color _surface = Colors.white;
const Color _border = Color(0xFFE8EDF5);
const Color _textDark = Color(0xFF111827);
const Color _textMuted = Color(0xFF6B7280);
const Color _bgPage = Color(0xFFF5F7FB);

enum _ComposerType { announcement, promotion, alert, info, reminder }

enum _Audience { all, active, newUsers, inactive, premium, custom }

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

  _ComposerType _selectedType = _ComposerType.announcement;
  _Audience _selectedAudience = _Audience.all;
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
    if (_selectedAudience == _Audience.custom && _customRecipientIds.isEmpty) {
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
      builder: (context) =>
          _RecipientPickerSheet(initialSelected: _customRecipientIds),
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
      backgroundColor: _bgPage,
      appBar: AppBar(
        backgroundColor: _surface,
        foregroundColor: _textDark,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: _primary,
          unselectedLabelColor: _textMuted,
          indicatorColor: _primary,
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
        _SectionLabel('Notification Type'),
        const SizedBox(height: 8),
        _card(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _ComposerType.values
                .map(
                  (type) => _TypeChip(
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
        _SectionLabel('Message'),
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
                      ? Icons.link_off_rounded
                      : Icons.add_link_rounded,
                  size: 16,
                ),
                label: Text(
                  _showDeepLink ? 'Remove deep link' : 'Add deep link',
                ),
                style: TextButton.styleFrom(
                  foregroundColor: _textMuted,
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
        _SectionLabel('Audience'),
        const SizedBox(height: 8),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _Audience.values
                    .map((audience) {
                      final selected = audience == _selectedAudience;
                      return ChoiceChip(
                        label: Text(audience.label),
                        selected: selected,
                        selectedColor: _primary.withValues(alpha: 0.12),
                        side: BorderSide(
                          color: selected ? _primary : _border,
                        ),
                        labelStyle: TextStyle(
                          color: selected ? _primary : _textDark,
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
              if (_selectedAudience == _Audience.custom) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _openCustomSegmentPicker,
                  icon: const Icon(Icons.groups_rounded, size: 18),
                  label: Text(
                    _customRecipientIds.isEmpty
                        ? 'Choose users'
                        : '${_customRecipientIds.length} users selected',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primary,
                    side: BorderSide(color: _primary.withValues(alpha: 0.4)),
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
                            deleteIconColor: _textMuted,
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
        _SectionLabel('Preview'),
        const SizedBox(height: 8),
        _NotificationPreview(
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
                    : const Icon(Icons.send_rounded, size: 18),
                label: const Text('Send now'),
                style: FilledButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 46),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _submitting ? null : () => _submit('schedule'),
                icon: const Icon(Icons.schedule_rounded, size: 16),
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
              child: const Icon(Icons.save_outlined, size: 20),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryTab(AppLocalizations l) {
    return RefreshIndicator(
      onRefresh: _loadHistory,
      color: _primary,
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
                        Icons.history_rounded,
                        size: 48,
                        color: _textMuted.withValues(alpha: 0.35),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l.noData,
                        style: const TextStyle(color: _textMuted),
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
                  _HistoryCard(entry: _history[index]),
            ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: _textMuted),
    filled: true,
    fillColor: const Color(0xFFF8FAFD),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _primary),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _border),
    ),
    child: child,
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: _textMuted,
      letterSpacing: 0.4,
    ),
  );
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.type,
    required this.selected,
    required this.onTap,
  });
  final _ComposerType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = type.color;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : const Color(0xFFF8FAFD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? color : _border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(type.icon, size: 15, color: selected ? color : _textMuted),
            const SizedBox(width: 6),
            Text(
              type.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? color : _textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationPreview extends StatelessWidget {
  const _NotificationPreview({
    required this.type,
    required this.title,
    required this.message,
  });
  final _ComposerType type;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: type.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(type.icon, size: 18, color: type.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'KY Service',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'now',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.entry});
  final AdminNotificationCampaignItem entry;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(entry.status);
    final summary = entry.summary;
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _StatusBadge(status: entry.status),
                        const Spacer(),
                        Text(
                          _formatDateTime(entry.createdAt),
                          style: const TextStyle(
                            color: _textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entry.type}  ·  ${_audienceLabelFromApi(entry.audience)}',
                      style: const TextStyle(color: _textMuted, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _StatPill(
                          icon: Icons.people_outline_rounded,
                          label: '${summary.targetedUsers}',
                          color: const Color(0xFF4A88F7),
                        ),
                        const SizedBox(width: 10),
                        _StatPill(
                          icon: Icons.check_circle_outline_rounded,
                          label: '${summary.delivered}',
                          color: const Color(0xFF0F9D58),
                        ),
                        if (summary.failed > 0) ...[
                          const SizedBox(width: 10),
                          _StatPill(
                            icon: Icons.error_outline_rounded,
                            label: '${summary.failed}',
                            color: const Color(0xFFEF4444),
                          ),
                        ],
                      ],
                    ),
                    if (entry.scheduledFor != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 12,
                            color: _textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Scheduled ${_formatDateTime(entry.scheduledFor)}',
                            style: const TextStyle(
                              color: _textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 3),
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _RecipientPickerSheet extends StatefulWidget {
  const _RecipientPickerSheet({required this.initialSelected});
  final Set<int> initialSelected;

  @override
  State<_RecipientPickerSheet> createState() => _RecipientPickerSheetState();
}

class _RecipientPickerSheetState extends State<_RecipientPickerSheet> {
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
          color: _surface,
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
                color: _textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Select users to include.',
              style: TextStyle(color: _textMuted, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, email, or phone',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                filled: true,
                fillColor: const Color(0xFFF8FAFD),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _primary),
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
                        style: const TextStyle(color: _textMuted),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _recipients.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, color: _border),
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
                          activeColor: _primary,
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
                      backgroundColor: _primary,
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

  IconData get icon {
    switch (this) {
      case _ComposerType.announcement:
        return Icons.campaign_rounded;
      case _ComposerType.promotion:
        return Icons.local_offer_rounded;
      case _ComposerType.alert:
        return Icons.warning_amber_rounded;
      case _ComposerType.info:
        return Icons.info_outline_rounded;
      case _ComposerType.reminder:
        return Icons.notifications_outlined;
    }
  }

  Color get color {
    switch (this) {
      case _ComposerType.announcement:
        return const Color(0xFF4A88F7);
      case _ComposerType.promotion:
        return const Color(0xFF8B5CF6);
      case _ComposerType.alert:
        return const Color(0xFFEF4444);
      case _ComposerType.info:
        return const Color(0xFF06B6D4);
      case _ComposerType.reminder:
        return const Color(0xFFF59E0B);
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
        return 'All';
      case _Audience.active:
        return 'Active';
      case _Audience.newUsers:
        return 'New';
      case _Audience.inactive:
        return 'Inactive';
      case _Audience.premium:
        return 'Premium';
      case _Audience.custom:
        return 'Custom';
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
  if (value == null) return '';
  final d = value.toLocal();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
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
      return const Color(0xFF6B7280);
    default:
      return const Color(0xFF6B7280);
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
