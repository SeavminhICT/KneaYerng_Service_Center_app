import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../l10n/app_localizations.dart';
import '../../models/saved_address.dart';
import '../../services/address_book_service.dart';
import '../../widgets/empty_state_view.dart';
import 'address_form_screen.dart';

class AddressManagementScreen extends StatefulWidget {
  const AddressManagementScreen({super.key});

  @override
  State<AddressManagementScreen> createState() => _AddressManagementScreenState();
}

class _AddressManagementScreenState extends State<AddressManagementScreen> {
  late Future<List<SavedAddress>> _addressesFuture;

  @override
  void initState() {
    super.initState();
    _addressesFuture = AddressBookService.load();
  }

  Future<void> _refresh() async {
    setState(() {
      _addressesFuture = AddressBookService.load();
    });
    await _addressesFuture;
  }

  Future<void> _addAddress() async {
    final result = await Navigator.of(context).push<SavedAddress>(
      MaterialPageRoute(builder: (_) => const AddressFormScreen()),
    );
    if (result == null) return;
    await _refresh();
  }

  Future<void> _editAddress(SavedAddress address) async {
    final result = await Navigator.of(context).push<SavedAddress>(
      MaterialPageRoute(builder: (_) => AddressFormScreen(initial: address)),
    );
    if (result == null) return;
    await _refresh();
  }

  Future<void> _deleteAddress(SavedAddress address) async {
    await AddressBookService.remove(address.id);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFE6EDF7) : const Color(0xFF111827);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l.savedAddresses,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _addAddress,
            icon: const Icon(HugeIcons.strokeRoundedLocationAdd01),
          ),
        ],
      ),
      body: FutureBuilder<List<SavedAddress>>(
        future: _addressesFuture,
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          if (snapshot.hasError) {
            return _EmptyState(
              title: l.somethingWentWrong,
              subtitle: 'Please try again in a moment.',
              onRetry: _refresh,
              buttonLabel: l.retry,
            );
          }

          final addresses = isLoading
              ? List.generate(
                  3,
                  (index) => SavedAddress(
                    id: 'mock-$index',
                    name: 'Home Address',
                    phone: '012 345 678',
                    addressLine: '123 St, Phnom Penh, Cambodia',
                    note: 'Near Central Market',
                    lat: 0,
                    lng: 0,
                    createdAt: DateTime.now(),
                  ),
                )
              : (snapshot.data ?? []);

          if (!isLoading && addresses.isEmpty) {
            return _EmptyState(
              title: l.noData,
              subtitle: 'Tap + to add a new location in Cambodia.',
              onRetry: _addAddress,
              buttonLabel: l.addNewAddress,
            );
          }

          return Skeletonizer(
            enabled: isLoading,
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: addresses.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final address = addresses[index];
                  return _AddressCard(
                    address: address,
                    onEdit: isLoading ? () {} : () => _editAddress(address),
                    onDelete: isLoading ? () {} : () => _deleteAddress(address),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addAddress,
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        icon: const Icon(HugeIcons.strokeRoundedLocationAdd01),
        label: Text(l.addNewAddress),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  final SavedAddress address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = Theme.of(context).cardColor;
    final border = isDark ? const Color(0xFF2B3442) : const Color(0xFFE6E9F0);
    final textPrimary = isDark ? const Color(0xFFE6EDF7) : const Color(0xFF111827);
    final textMuted = isDark ? const Color(0xFF97A2B5) : const Color(0xFF6B7280);
    final textBody = isDark ? const Color(0xFFD3E0F8) : const Color(0xFF374151);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1D2635) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  HugeIcons.strokeRoundedLocation01,
                  color: Color(0xFF2563EB),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    if (address.phone.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        address.phone,
                        style: TextStyle(
                          fontSize: 12,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(HugeIcons.strokeRoundedEdit02),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(HugeIcons.strokeRoundedDelete02),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            address.addressLine,
            style: TextStyle(
              color: textBody,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (address.note.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              address.note,
              style: TextStyle(
                color: textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.onRetry,
    this.buttonLabel = 'Refresh',
  });

  final String title;
  final String subtitle;
  final Future<void> Function() onRetry;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    return EmptyStateView(
      icon: HugeIcons.strokeRoundedLocation01,
      iconColor: const Color(0xFF2563EB),
      title: title,
      subtitle: subtitle,
      actionLabel: buttonLabel,
      onAction: onRetry,
    );
  }
}
