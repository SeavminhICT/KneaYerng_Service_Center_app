import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:latlong2/latlong.dart';

import '../../../l10n/app_localizations.dart';

class BakongDeliveryForm extends StatelessWidget {
  const BakongDeliveryForm({
    super.key,
    required this.addressController,
    required this.phoneController,
    required this.noteController,
    required this.selectedLatLng,
    required this.onSelectLocation,
  });

  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController noteController;
  final LatLng? selectedLatLng;
  final VoidCallback onSelectLocation;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    InputDecoration fieldDecoration(String hint) {
      return InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l.deliveryAddress,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onSelectLocation,
                icon: const Icon(HugeIcons.strokeRoundedLocation01, size: 16),
                label: Text(l.selectAddress),
              ),
            ],
          ),
          TextField(
            controller: addressController,
            readOnly: true,
            onTap: onSelectLocation,
            decoration: fieldDecoration(l.selectAddress),
          ),
          if (selectedLatLng != null) ...[
            const SizedBox(height: 6),
            Text(
              'Pinned: ${selectedLatLng!.latitude.toStringAsFixed(6)}, '
              '${selectedLatLng!.longitude.toStringAsFixed(6)}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
          const SizedBox(height: 10),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: fieldDecoration('Phone number'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: noteController,
            maxLines: 2,
            decoration: fieldDecoration('Delivery note (optional)'),
          ),
        ],
      ),
    );
  }
}
