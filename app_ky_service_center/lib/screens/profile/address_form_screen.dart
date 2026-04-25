import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../models/saved_address.dart';
import '../../services/address_book_service.dart';
import '../cart/delivery_location_picker.dart';

class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({
    super.key,
    this.initial,
    this.initialLocation,
    this.initialAddress,
    this.initialNote,
  });

  final SavedAddress? initial;
  final LatLng? initialLocation;
  final String? initialAddress;
  final String? initialNote;

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final TextEditingController _noteController = TextEditingController();

  LatLng? _selectedLatLng;
  String _selectedAddress = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _noteController.text = initial.note;
      _selectedLatLng = LatLng(initial.lat, initial.lng);
      _selectedAddress = initial.addressLine;
      return;
    }

    _noteController.text = widget.initialNote?.trim() ?? '';
    _selectedLatLng = widget.initialLocation;
    _selectedAddress = widget.initialAddress?.trim() ?? '';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.of(context).push<DeliveryLocationResult>(
      MaterialPageRoute(
        builder: (_) => DeliveryLocationPicker(
          initialLocation: _selectedLatLng,
          initialAddress: _selectedAddress.isEmpty ? null : _selectedAddress,
        ),
      ),
    );

    if (result == null) return;

    setState(() {
      _selectedLatLng = result.latLng;
      _selectedAddress = result.address;
    });
  }

  Future<void> _save() async {
    final note = _noteController.text.trim();
    final isDraft = widget.initial?.id.startsWith('draft_') ?? false;

    if (_selectedLatLng == null || _selectedAddress.trim().isEmpty) {
      _showError('Please select a location on the map.');
      return;
    }

    setState(() => _saving = true);

    final id = widget.initial == null || isDraft
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : widget.initial!.id;
    final address = SavedAddress(
      id: id,
      name: widget.initial?.name.trim().isNotEmpty == true
          ? widget.initial!.name.trim()
          : 'Saved Location',
      phone: widget.initial?.phone.trim() ?? '',
      addressLine: _selectedAddress,
      note: note,
      lat: _selectedLatLng!.latitude,
      lng: _selectedLatLng!.longitude,
      createdAt:
          widget.initial == null || isDraft
          ? DateTime.now()
          : widget.initial!.createdAt,
    );

    if (widget.initial == null || isDraft) {
      await AddressBookService.add(address);
    } else {
      await AddressBookService.update(address);
    }

    if (!mounted) return;
    Navigator.of(context).pop(address);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Location' : 'Add New Location',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _FormCard(
            title: 'Remark',
            child: Column(
              children: [
                _InputField(
                  label: 'Note (optional)',
                  controller: _noteController,
                  hint: 'Floor, landmark, etc.',
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _FormCard(
            title: 'Current Location (Cambodia)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedAddress.isEmpty
                      ? 'Tap to select your location'
                      : _selectedAddress,
                  style: TextStyle(
                    color: _selectedAddress.isEmpty
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF111827),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _pickLocation,
                    icon: const Icon(Icons.my_location),
                    label: Text(
                      _selectedLatLng == null
                          ? 'Pick Location'
                          : 'Update Location',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _saving ? 'Saving...' : (isEditing ? 'Save Changes' : 'Save'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
