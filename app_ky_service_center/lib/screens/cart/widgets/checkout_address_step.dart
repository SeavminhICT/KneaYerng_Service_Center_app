import 'package:flutter/material.dart';
import '../../../theme/app_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:latlong2/latlong.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/saved_address.dart';
import 'checkout_address_preview_card.dart';
import 'checkout_colors.dart';
import 'checkout_saved_map_card.dart';
import 'checkout_surface_card.dart';

/// Step 1 of checkout: pin a delivery location on the map and manage saved
/// addresses ("Saved Maps").
class CheckoutAddressStep extends StatelessWidget {
  const CheckoutAddressStep({
    super.key,
    required this.deliveryAddressLine,
    required this.selectedDeliveryLatLng,
    required this.savedAddresses,
    required this.loadingSavedAddresses,
    required this.selectedSavedAddressId,
    required this.primary,
    required this.onPickLocation,
    required this.onAddSavedAddress,
    required this.onSelectSavedAddress,
    required this.onEditSavedAddress,
    required this.onDeleteSavedAddress,
  });

  final String deliveryAddressLine;
  final LatLng? selectedDeliveryLatLng;
  final List<SavedAddress> savedAddresses;
  final bool loadingSavedAddresses;
  final String? selectedSavedAddressId;
  final Color primary;
  final VoidCallback onPickLocation;
  final VoidCallback onAddSavedAddress;
  final ValueChanged<SavedAddress> onSelectSavedAddress;
  final ValueChanged<SavedAddress> onEditSavedAddress;
  final ValueChanged<SavedAddress> onDeleteSavedAddress;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final coordinatesText = selectedDeliveryLatLng == null
        ? null
        : 'Pinned: '
              '${selectedDeliveryLatLng!.latitude.toStringAsFixed(6)}, '
              '${selectedDeliveryLatLng!.longitude.toStringAsFixed(6)}';

    return ListView(
      key: const ValueKey(1),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Text(
          l.deliveryAddress,
          style: kFont(context,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: checkoutInk(context),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Pin the exact map location to continue.',
          style: TextStyle(color: checkoutMuted(context), height: 1.45),
        ),
        const SizedBox(height: 18),
        CheckoutAddressPreviewCard(
          addressLine: deliveryAddressLine,
          coordinates: coordinatesText,
          onPick: onPickLocation,
        ),
        const SizedBox(height: 14),
        CheckoutSurfaceCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Saved Maps',
                    style: kFont(context,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: checkoutInk(context),
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onAddSavedAddress,
                    icon: const Icon(HugeIcons.strokeRoundedLocation01, size: 16),
                    label: Text(l.add),
                    style: TextButton.styleFrom(
                      foregroundColor: kCheckoutPrimary,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Reuse a saved pin or manage locations without leaving checkout.',
                style: TextStyle(color: checkoutMuted(context), height: 1.45),
              ),
              const SizedBox(height: 14),
              if (loadingSavedAddresses)
                Skeletonizer(
                  enabled: true,
                  child: Column(
                    children: List.generate(
                      2,
                      (index) => CheckoutSavedMapCard(
                        address: SavedAddress(
                          id: 'mock-$index',
                          name: 'Home Address',
                          phone: '012 345 678',
                          addressLine: '123 St, Phnom Penh, Cambodia',
                          note: 'Near Central Market',
                          lat: 0,
                          lng: 0,
                          createdAt: DateTime.now(),
                        ),
                        selected: false,
                        onSelect: () {},
                        onEdit: () {},
                        onDelete: () {},
                      ),
                    ),
                  ),
                )
              else if (savedAddresses.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: checkoutSurfaceAlt(context),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        HugeIcons.strokeRoundedBookmarkAdd02,
                        size: 18,
                        color: checkoutMuted(context),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'No saved maps yet. Pick a location on the map, then tap Add to save it for later.',
                          style: TextStyle(color: checkoutMuted(context), height: 1.45),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...List.generate(savedAddresses.length, (index) {
                  final address = savedAddresses[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == savedAddresses.length - 1 ? 0 : 12,
                    ),
                    child: CheckoutSavedMapCard(
                      address: address,
                      selected: address.id == selectedSavedAddressId,
                      onSelect: () => onSelectSavedAddress(address),
                      onEdit: () => onEditSavedAddress(address),
                      onDelete: () => onDeleteSavedAddress(address),
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }
}
