import 'package:flutter/material.dart';

import '../../models/saved_address.dart';
import '../../services/address_book_service.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text(
          'Address Management',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _addAddress,
            icon: const Icon(Icons.add_location_alt_outlined),
          ),
        ],
      ),
      body: FutureBuilder<List<SavedAddress>>(
        future: _addressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _EmptyState(
              title: 'Unable to load addresses',
              subtitle: 'Please try again in a moment.',
              onRetry: _refresh,
            );
          }

          final addresses = snapshot.data ?? [];
          if (addresses.isEmpty) {
            return _EmptyState(
              title: 'No saved locations',
              subtitle: 'Tap + to add a new location in Cambodia.',
              onRetry: _addAddress,
              buttonLabel: 'Add Location',
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final address = addresses[index];
                return _AddressCard(
                  address: address,
                  onEdit: () => _editAddress(address),
                  onDelete: () => _deleteAddress(address),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addAddress,
        backgroundColor: const Color(0xFF2563EB),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add Location'),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E9F0)),
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
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    if (address.phone.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        address.phone,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            address.addressLine,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (address.note.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              address.note,
              style: const TextStyle(
                color: Color(0xFF6B7280),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                color: Color(0xFF2563EB),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
