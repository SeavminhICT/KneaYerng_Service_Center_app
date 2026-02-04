import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khqr_sdk/khqr_sdk.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/user_profile.dart';
import '../../services/api_service.dart' as api;
import '../../services/bakong_payment_service.dart';
import '../../services/cart_service.dart';
import '../Auth/login_screen.dart';
import 'delivery_location_picker.dart';

class BakongCheckoutSheet extends StatefulWidget {
  const BakongCheckoutSheet({
    super.key,
    required this.total,
  });

  final double total;

  @override
  State<BakongCheckoutSheet> createState() => _BakongCheckoutSheetState();
}

class _BakongCheckoutSheetState extends State<BakongCheckoutSheet> {
  BakongQrData? _khqrData;
  bool _isLoading = true;
  bool _isError = false;
  String? _errorMessage;
  String _billNumber = '';
  String? _orderNumber;
  int? _orderId;
  double? _amount;
  String _orderType = 'pickup';
  LatLng? _deliveryLatLng;

  final TextEditingController _deliveryAddressController =
      TextEditingController();
  final TextEditingController _deliveryPhoneController =
      TextEditingController();
  final TextEditingController _deliveryNoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateQr();
  }

  @override
  void dispose() {
    _deliveryAddressController.dispose();
    _deliveryPhoneController.dispose();
    _deliveryNoteController.dispose();
    super.dispose();
  }

  Future<void> _generateQr() async {
    final isLoggedIn = await _ensureLoggedIn();
    if (!isLoggedIn) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = 'Please log in to place an order.';
      });
      return;
    }

    final currentOrderType = _orderType;
    setState(() {
      _isLoading = true;
      _isError = false;
      _errorMessage = null;
      _khqrData = null;
      _orderNumber = null;
      _orderId = null;
      _amount = null;
    });

    _billNumber = BakongPaymentService.generateBillNumber();
    _amount = _resolveAmount();

    String? deliveryAddress;
    String? deliveryPhone;
    String? deliveryNote;

    if (currentOrderType == 'delivery') {
      final address = _deliveryAddressController.text.trim();
      final phone = _deliveryPhoneController.text.trim();

      if (address.isEmpty) {
        setState(() {
          _isError = true;
          _errorMessage = 'Please select a delivery location.';
          _isLoading = false;
        });
        return;
      }
      if (_deliveryLatLng == null) {
        setState(() {
          _isError = true;
          _errorMessage = 'Please drop a pin on the map for delivery.';
          _isLoading = false;
        });
        return;
      }
      if (phone.isEmpty) {
        setState(() {
          _isError = true;
          _errorMessage = 'Delivery phone is required.';
          _isLoading = false;
        });
        return;
      }

      deliveryAddress = address;
      deliveryPhone = phone;
      deliveryNote = _deliveryNoteController.text.trim();
    }

    if (_amount == null || _amount! <= 0) {
      setState(() {
        _isError = true;
        _errorMessage = 'Cart total must be greater than 0.';
        _isLoading = false;
      });
      return;
    }

    final orderResult = await _createOrder(
      orderType: currentOrderType,
      deliveryAddress: deliveryAddress,
      deliveryPhone: deliveryPhone,
      deliveryNote: deliveryNote,
      deliveryLatLng: _deliveryLatLng,
    );
    if (!mounted || _orderType != currentOrderType) return;
    if (!orderResult.isSuccess) {
      setState(() {
        _isError = true;
        _errorMessage = orderResult.errorMessage ?? 'Unable to create order.';
        _isLoading = false;
      });
      return;
    }

    _orderNumber = orderResult.orderNumber;
    _orderId = orderResult.orderId;
    final amountForQr = orderResult.totalAmount ?? _amount ?? widget.total;

    if (!mounted || _orderType != currentOrderType) return;
    setState(() {
      _amount = amountForQr;
    });

    try {
      final response = BakongPaymentService.generateQr(
        amount: amountForQr,
        billNumber: _billNumber,
      );

      if (!response.isSuccess || response.data == null) {
        if (!mounted || _orderType != currentOrderType) return;
        setState(() {
          _isError = true;
          _errorMessage = response.errorMessage ?? 'Unable to generate KHQR.';
          _isLoading = false;
        });
        return;
      }

      if (!mounted || _orderType != currentOrderType) return;
      setState(() {
        _khqrData = response.data;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted || _orderType != currentOrderType) return;
      setState(() {
        _isError = true;
        _errorMessage = 'Unable to generate KHQR.';
        _isLoading = false;
      });
    }
  }

  double _resolveAmount() {
    final cartSubtotal = CartService.instance.subtotal;
    if (cartSubtotal > 0) {
      return cartSubtotal;
    }
    return widget.total;
  }

  Future<api.OrderCreateResult> _createOrder({
    required String orderType,
    String? deliveryAddress,
    String? deliveryPhone,
    String? deliveryNote,
    LatLng? deliveryLatLng,
  }) async {
    final items = CartService.instance.items;
    if (items.isEmpty) {
      return const api.OrderCreateResult(errorMessage: 'Your cart is empty.');
    }

    final profile = await api.ApiService.getUserProfile();
    final customerName = _resolveCustomerName(profile);
    final customerEmail = profile?.email;

    final payload = items
        .map(
          (item) => {
            'product_id': item.product.id,
            'product_name': item.product.name,
            'quantity': item.quantity,
            'price': item.product.price,
          },
        )
        .toList();

    return api.ApiService.createOrder(
      customerName: customerName,
      customerEmail: customerEmail,
      items: payload,
      paymentMethod: 'wallet',
      paymentStatus: 'paid',
      orderType: orderType,
      deliveryAddress: deliveryAddress,
      deliveryPhone: deliveryPhone,
      deliveryNote: _appendCoordinates(deliveryNote, deliveryLatLng),
    );
  }

  String _resolveCustomerName(UserProfile? profile) {
    final rawName = profile?.displayName.trim() ?? '';
    if (rawName.isNotEmpty && rawName != 'User') {
      return rawName;
    }
    final email = profile?.email?.trim() ?? '';
    if (email.isNotEmpty) {
      return email;
    }
    return 'Customer';
  }

  Future<bool> _ensureLoggedIn() async {
    final token = await api.ApiService.getToken();
    if (token != null && token.isNotEmpty) {
      return true;
    }
    if (!mounted) return false;

    final shouldLogin = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Login required'),
          content: const Text('Please log in to place an order.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Login'),
            ),
          ],
        );
      },
    );

    if (shouldLogin != true || !mounted) return false;

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );

    final refreshed = await api.ApiService.getToken();
    return refreshed != null && refreshed.isNotEmpty;
  }

  void _handleOrderTypeChange(String nextType) {
    if (_orderType == nextType) return;
    setState(() {
      _orderType = nextType;
      _isError = false;
      _errorMessage = null;
      _khqrData = null;
      _orderNumber = null;
      _orderId = null;
      _isLoading = false;
    });

    if (nextType == 'pickup') {
      _generateQr();
      return;
    }

    Future.microtask(_promptLocation);
  }

  Future<void> _promptLocation() async {
    final result = await Navigator.of(context).push<DeliveryLocationResult>(
      MaterialPageRoute(
        builder: (_) => DeliveryLocationPicker(
          initialLocation: _deliveryLatLng,
          initialAddress: _deliveryAddressController.text.trim(),
        ),
      ),
    );

    if (!mounted || result == null) return;
    setState(() {
      _deliveryLatLng = result.latLng;
      _deliveryAddressController.text = result.address.trim();
    });
  }

  String? _appendCoordinates(String? note, LatLng? latLng) {
    if (latLng == null) return note;
    final coords =
        'Lat:${latLng.latitude.toStringAsFixed(6)},Lng:${latLng.longitude.toStringAsFixed(6)}';
    if (note == null || note.isEmpty) {
      return coords;
    }
    if (note.contains(coords)) {
      return note;
    }
    return '$note | $coords';
  }

  Future<void> _copyKhqr() async {
    final qr = _khqrData?.qr;
    if (qr == null || qr.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: qr));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('KHQR copied to clipboard')),
    );
  }

  Future<void> _copyReference() async {
    final ref = _khqrData?.md5Hash;
    if (ref == null || ref.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: ref));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reference copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = BakongPaymentService.config;
    final amount = _amount ?? _resolveAmount();
    final total = amount.toStringAsFixed(2);
    final showQrCard = _orderType == 'pickup' ||
        _isLoading ||
        _isError ||
        _khqrData != null;

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 10,
          bottom: 16 + MediaQuery.of(context).padding.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const Text(
                'Pay with Bakong',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Scan the KHQR using Bakong or any KHQR-supported app.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _OrderTypeOption(
                      label: 'Pickup',
                      isSelected: _orderType == 'pickup',
                      onTap: _isLoading
                          ? null
                          : () => _handleOrderTypeChange('pickup'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _OrderTypeOption(
                      label: 'Delivery',
                      isSelected: _orderType == 'delivery',
                      onTap: _isLoading
                          ? null
                          : () => _handleOrderTypeChange('delivery'),
                    ),
                  ),
                ],
              ),
              if (_orderType == 'delivery') ...[
                const SizedBox(height: 12),
                _DeliveryForm(
                  addressController: _deliveryAddressController,
                  phoneController: _deliveryPhoneController,
                  noteController: _deliveryNoteController,
                  selectedLatLng: _deliveryLatLng,
                  onSelectLocation: _promptLocation,
                ),
                if (_khqrData == null || _isError) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _generateQr,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F6BFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Generate KHQR'),
                    ),
                  ),
                ],
              ],
              if (showQrCard) ...[
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth < 360
                        ? constraints.maxWidth
                        : 360.0;
                    return KhqrCardWidget(
                      width: width,
                      qr: _khqrData?.qr ?? '',
                      receiverName: config.merchantName,
                      amount: amount,
                      currency: config.currency,
                      duration: config.qrExpiry,
                      isLoading: _isLoading,
                      isError: _isError,
                      onRetry: _generateQr,
                      onRegenerate: _generateQr,
                      retryButtonText: 'Try again',
                      regenerateButtonText: 'Refresh QR',
                    );
                  },
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  _errorMessage ?? '',
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    _InfoRow(label: 'Total', value: '\$$total'),
                    if (_orderNumber != null)
                      _InfoRow(label: 'Order No.', value: _orderNumber!),
                    if (_orderNumber == null && _orderId != null)
                      _InfoRow(
                        label: 'Order ID',
                        value: _orderId.toString(),
                      ),
                    _InfoRow(
                      label: 'Bill No.',
                      value: _billNumber.isEmpty ? '-' : _billNumber,
                    ),
                    _InfoRow(
                      label: 'Reference',
                      value: _khqrData?.md5Hash ?? '-',
                      valueStyle: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _khqrData == null ? null : _copyKhqr,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF0F6BFF)),
                        foregroundColor: const Color(0xFF0F6BFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Copy KHQR'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _khqrData == null ? null : _copyReference,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        foregroundColor: const Color(0xFF111827),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Copy Ref'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_orderId != null) {
                            CartService.instance.clear();
                          }
                          Navigator.of(context).maybePop();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F6BFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderTypeOption extends StatelessWidget {
  const _OrderTypeOption({
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor:
            isSelected ? const Color(0xFF0F6BFF) : Colors.white,
        foregroundColor: isSelected ? Colors.white : const Color(0xFF111827),
        side: BorderSide(
          color: isSelected ? const Color(0xFF0F6BFF) : const Color(0xFFE5E7EB),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _DeliveryForm extends StatelessWidget {
  const _DeliveryForm({
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
              const Text(
                'Delivery Location',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onSelectLocation,
                icon: const Icon(Icons.location_on_outlined, size: 16),
                label: const Text('Select'),
              ),
            ],
          ),
          TextField(
            controller: addressController,
            readOnly: true,
            onTap: onSelectLocation,
            decoration: fieldDecoration('Select delivery location'),
          ),
          if (selectedLatLng != null) ...[
            const SizedBox(height: 6),
            Text(
              'Pinned: ${selectedLatLng!.latitude.toStringAsFixed(6)}, '
              '${selectedLatLng!.longitude.toStringAsFixed(6)}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: valueStyle ??
                  const TextStyle(
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
