import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khqr_sdk/khqr_sdk.dart';
import 'package:latlong2/latlong.dart';

import '../../models/cart_item.dart';
import '../../models/pickup_ticket.dart';
import '../../models/saved_address.dart';
import '../../services/api_service.dart';
import '../../services/address_book_service.dart';
import '../../services/cart_service.dart';
import '../Auth/login_screen.dart';
import 'delivery_location_picker.dart';
import '../main_navigation_screen.dart';
import '../profile/address_form_screen.dart';

const _checkoutPrimary = Color(0xFF4A88F7);
const _checkoutAccent = Color(0xFF111827);
const _checkoutBg = Color(0xFFF8FAFC);
const _checkoutSurface = Color(0xFFFFFFFF);
const _checkoutSurfaceAlt = Color(0xFFF3F4F6);
const _checkoutBorder = Color(0xFFE5E7EB);
const _checkoutInk = Color(0xFF111827);
const _checkoutMuted = Color(0xFF6B7280);
const _checkoutShadow = Color(0x0F111827);
const _checkoutSuccess = Color(0xFF15803D);

class CheckoutFlowScreen extends StatefulWidget {
  const CheckoutFlowScreen({
    super.key,
    required this.items,
    this.voucherCode,
    this.initialDiscount = 0,
    this.fromCart = false,
  });

  final List<CartItem> items;
  final String? voucherCode;
  final double initialDiscount;
  final bool fromCart;

  @override
  State<CheckoutFlowScreen> createState() => _CheckoutFlowScreenState();
}

class _CheckoutFlowScreenState extends State<CheckoutFlowScreen> {
  static const Color _primary = _checkoutPrimary;
  static const Color _accent = _checkoutAccent;
  static const Color _bg = _checkoutBg;
  static const List<_StepMeta> _stepMetas = [
    _StepMeta(
      label: 'Delivery',
      title: 'Delivery Method',
      subtitle: 'Choose pickup from store or home delivery.',
      icon: Icons.local_shipping_outlined,
    ),
    _StepMeta(
      label: 'Address',
      title: 'Delivery Address',
      subtitle: 'Pick the delivery location on the map.',
      icon: Icons.place_rounded,
    ),
    _StepMeta(
      label: 'Payment',
      title: 'Review costs and payment',
      subtitle: 'Check your items, totals, and select the payment option.',
      icon: Icons.account_balance_wallet_rounded,
    ),
    _StepMeta(
      label: 'Confirm',
      title: 'One last review',
      subtitle: 'Everything is ready. Verify the details before placing it.',
      icon: Icons.verified_rounded,
    ),
  ];

  static const List<_DeliveryMethod> _deliveryMethods = [
    _DeliveryMethod(
      code: 'pickup',
      title: 'Pickup from Store',
      description: 'Collect your order at the shop',
      icon: Icons.storefront_outlined,
    ),
    _DeliveryMethod(
      code: 'delivery',
      title: 'Home Delivery',
      description: 'We deliver to your address',
      icon: Icons.local_shipping_outlined,
    ),
  ];

  late final List<CartItem> _items;
  final TextEditingController _noteController = TextEditingController();
  LatLng? _selectedDeliveryLatLng;
  String _selectedDeliveryAddress = '';
  List<SavedAddress> _savedAddresses = [];
  bool _loadingSavedAddresses = true;
  String? _selectedSavedAddressId;

  int _step = 0;
  int _selectedDeliveryMethod = 1;
  int _selectedSlot = 0;
  int _selectedPayment = 0;

  bool _loadingOptions = true;
  bool _placingOrder = false;

  CheckoutOptions _options = CheckoutOptions.fallback();
  double _voucherDiscount = 0;

  @override
  void initState() {
    super.initState();
    _items = widget.items
        .map(
          (item) => CartItem(
            product: item.product,
            quantity: item.quantity,
            variant: item.variant,
          ),
        )
        .toList();
    _voucherDiscount = widget.initialDiscount;
    _loadCheckoutOptions();
    _loadSavedAddresses();
  }

  Future<void> _loadCheckoutOptions() async {
    final loaded = await ApiService.fetchCheckoutOptions();
    if (!mounted) return;

    setState(() {
      _options = loaded;
      _loadingOptions = false;
      if (_selectedPayment >= _checkoutPaymentMethods.length) {
        _selectedPayment = 0;
      }
      if (_selectedSlot >= _options.deliverySlots.length) {
        _selectedSlot = 0;
      }
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  bool get _isPickup =>
      _deliveryMethods[_selectedDeliveryMethod].code == 'pickup';

  bool get _hasValidDeliveryAddress =>
      _selectedDeliveryLatLng != null &&
      _selectedDeliveryAddress.trim().isNotEmpty;

  String get _deliveryAddressLine => _selectedDeliveryAddress.trim();

  String? get _deliveryNoteValue {
    final note = _noteController.text.trim();
    return note.isEmpty ? null : note;
  }

  List<CheckoutPaymentMethod> get _checkoutPaymentMethods {
    const bakong = CheckoutPaymentMethod(
      code: 'aba_qr',
      label: 'Bakong QR Payment',
      description: 'Scan to pay with Bakong KHQR',
    );
    const cod = CheckoutPaymentMethod(
      code: 'cod',
      label: 'Cash on Delivery',
      description: 'Pay with cash when your order arrives',
    );
    if (_isPickup) {
      return const [bakong];
    }
    return const [bakong, cod];
  }

  double get _subtotal =>
      _items.fold<double>(0, (sum, item) => sum + item.subtotal);

  double get _shipping => _isPickup ? 0 : _options.deliveryFee;

  double get _tax => _subtotal * _options.taxRate;

  double get _discount {
    if (_voucherDiscount <= 0) return 0;
    final maxAllowed = _subtotal + _shipping + _tax;
    if (_voucherDiscount > maxAllowed) return maxAllowed;
    return _voucherDiscount;
  }

  double get _grandTotal =>
      (_subtotal + _shipping + _tax - _discount).clamp(0, 9999999);

  _StepMeta get _currentStepMeta => _stepMetas[_step];

  String get _stepButtonText {
    if (_step == 3) {
      return _placingOrder ? 'Placing Order...' : 'Place Order';
    }
    if (_step == 0) {
      return 'Continue';
    }
    if (_step == 1) {
      return 'Continue to Payment';
    }
    return 'Continue to Confirm';
  }

  IconData _paymentMethodIcon(String code) {
    switch (code) {
      case 'aba_qr':
        return Icons.qr_code_2_rounded;
      case 'cash':
      case 'cod':
        return Icons.payments_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      case 'bank_transfer':
        return Icons.account_balance_rounded;
      default:
        return Icons.wallet_rounded;
    }
  }

  String? _composeDeliveryNote(String? note, String? slot) {
    final parts = <String>[];
    if (note != null && note.trim().isNotEmpty) {
      parts.add(note.trim());
    }
    if (slot != null && slot.trim().isNotEmpty) {
      parts.add('Delivery slot: ${slot.trim()}');
    }
    if (parts.isEmpty) return null;
    return parts.join(' | ');
  }

  Future<void> _pickDeliveryLocation() async {
    final result = await Navigator.of(context).push<DeliveryLocationResult>(
      MaterialPageRoute(
        builder: (_) => DeliveryLocationPicker(
          initialLocation: _selectedDeliveryLatLng,
          initialAddress: _selectedDeliveryAddress.trim().isEmpty
              ? null
              : _selectedDeliveryAddress,
        ),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      _selectedSavedAddressId = null;
      _selectedDeliveryLatLng = result.latLng;
      _selectedDeliveryAddress = result.address.trim();
    });
  }

  void _applySavedAddress(SavedAddress address) {
    setState(() {
      _selectedSavedAddressId = address.id;
      _selectedDeliveryLatLng = LatLng(address.lat, address.lng);
      _selectedDeliveryAddress = address.addressLine;
      _noteController.text = address.note;
    });
  }

  Future<void> _addSavedAddress() async {
    final draftAddress =
        _selectedDeliveryLatLng != null ||
            _selectedDeliveryAddress.trim().isNotEmpty ||
            _noteController.text.trim().isNotEmpty
        ? SavedAddress(
            id: 'draft_${DateTime.now().millisecondsSinceEpoch}',
            name: 'Saved Location',
            phone: '',
            addressLine: _selectedDeliveryAddress.trim(),
            note: _noteController.text.trim(),
            lat: _selectedDeliveryLatLng?.latitude ?? 0,
            lng: _selectedDeliveryLatLng?.longitude ?? 0,
            createdAt: DateTime.now(),
          )
        : null;

    final result = await Navigator.of(context).push<SavedAddress>(
      MaterialPageRoute(
        builder: (_) => draftAddress == null
            ? const AddressFormScreen()
            : AddressFormScreen(initial: draftAddress),
      ),
    );

    if (result == null) return;
    await _loadSavedAddresses(
      selectedId: result.id,
      syncSelectedLocation: true,
    );
  }

  Future<void> _editSavedAddress(SavedAddress address) async {
    final result = await Navigator.of(context).push<SavedAddress>(
      MaterialPageRoute(builder: (_) => AddressFormScreen(initial: address)),
    );

    if (result == null) return;
    await _loadSavedAddresses(
      selectedId: result.id,
      syncSelectedLocation: true,
    );
  }

  Future<void> _deleteSavedAddress(SavedAddress address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete location'),
        content: const Text('Remove this saved location?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final wasSelected = _selectedSavedAddressId == address.id;
    await AddressBookService.remove(address.id);
    if (!mounted) return;

    if (wasSelected) {
      _noteController.clear();
      setState(() {
        _selectedSavedAddressId = null;
        _selectedDeliveryLatLng = null;
        _selectedDeliveryAddress = '';
      });
    }

    await _loadSavedAddresses();
  }

  Future<void> _loadSavedAddresses({
    String? selectedId,
    bool syncSelectedLocation = false,
  }) async {
    final loaded = (await AddressBookService.load()).reversed.toList();
    if (!mounted) return;

    SavedAddress? selectedAddress;
    final targetId = selectedId ?? _selectedSavedAddressId;
    if (targetId != null) {
      for (final address in loaded) {
        if (address.id == targetId) {
          selectedAddress = address;
          break;
        }
      }
    }

    if (syncSelectedLocation && selectedAddress != null) {
      _noteController.text = selectedAddress.note;
    }

    setState(() {
      _savedAddresses = loaded;
      _loadingSavedAddresses = false;
      if (selectedAddress != null) {
        _selectedSavedAddressId = selectedAddress.id;
        _selectedDeliveryLatLng = LatLng(
          selectedAddress.lat,
          selectedAddress.lng,
        );
        _selectedDeliveryAddress = selectedAddress.addressLine;
      } else if (targetId != null &&
          loaded.every((address) => address.id != targetId)) {
        _selectedSavedAddressId = null;
      }
    });
  }

  void _jumpToStep(int targetStep) {
    if (targetStep == _step || targetStep < 0 || targetStep > 3) return;

    if (targetStep == 0) {
      setState(() => _step = 0);
      return;
    }

    if (_isPickup) {
      if (targetStep == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address step is not needed for pickup orders.'),
          ),
        );
        return;
      }
      setState(() {
        _selectedPayment = 0;
        _step = targetStep;
      });
      return;
    }

    if (targetStep >= 2 && !_hasValidDeliveryAddress) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete your delivery address first.'),
        ),
      );
      setState(() => _step = 1);
      return;
    }

    setState(() => _step = targetStep);
  }

  int _previousStep() {
    if (_step <= 0) return 0;
    if (_isPickup) {
      if (_step == 3) return 2;
      if (_step == 2) return 0;
      return 0;
    }
    return (_step - 1).clamp(0, 3);
  }

  Future<bool> _handleBackNavigation() async {
    if (_step == 0) {
      return true;
    }
    setState(() => _step = _previousStep());
    return false;
  }

  Future<void> _continueStep() async {
    if (_step == 0) {
      setState(() {
        if (_isPickup) {
          _selectedPayment = 0;
          _step = 2;
        } else {
          _step = 1;
        }
      });
      return;
    }

    if (_step == 1) {
      if (!_hasValidDeliveryAddress) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please complete your delivery address.'),
          ),
        );
        return;
      }
      setState(() => _step = 2);
      return;
    }

    if (_step == 2) {
      setState(() => _step = 3);
      return;
    }

    if (_step == 3) {
      await _placeOrder();
      return;
    }

    setState(() {
      _step = (_step + 1).clamp(0, 3);
    });
  }

  Future<void> _placeOrder() async {
    if (_placingOrder) return;

    final token = await ApiService.getToken();
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      final shouldLogin = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login required'),
          content: const Text('Please log in to place your order.'),
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
        ),
      );

      if (shouldLogin == true && mounted) {
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
      return;
    }

    setState(() => _placingOrder = true);

    var voucherCode = widget.voucherCode?.trim();
    if (voucherCode != null && voucherCode.isNotEmpty) {
      final result = await ApiService.validateVoucher(
        code: voucherCode,
        subtotal: _subtotal,
      );
      if (result.isValid) {
        _voucherDiscount = result.discountFor(_subtotal);
      } else {
        voucherCode = null;
        _voucherDiscount = 0;
      }
    }

    final profile = await ApiService.getUserProfile();
    final customerName = profile?.displayName.trim().isNotEmpty == true
        ? profile!.displayName.trim()
        : (profile?.email?.trim().isNotEmpty == true
              ? profile!.email!.trim()
              : 'Customer');

    final payload = _items
        .map(
          (item) => {
            'product_id': item.product.id,
            'item_type': 'product',
            'item_id': item.product.id,
            'product_name': item.product.name,
            'quantity': item.quantity,
            'price': item.product.salePrice,
          },
        )
        .toList();

    final selectedPaymentMethod =
        _checkoutPaymentMethods[_selectedPayment].code;
    final orderPaymentMethod = selectedPaymentMethod == 'aba_qr'
        ? 'aba'
        : selectedPaymentMethod;
    if (!mounted) return;
    if (!_isPickup && !_hasValidDeliveryAddress) {
      setState(() => _placingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete your delivery address.')),
      );
      return;
    }
    final slot = _options.deliverySlots.isEmpty
        ? null
        : _options.deliverySlots[_selectedSlot].label;
    final deliveryNote = _isPickup
        ? null
        : _composeDeliveryNote(_deliveryNoteValue, slot);
    final customerDisplayName = customerName;
    final deliveryPhone = profile?.phone?.trim();

    final result = await ApiService.createOrder(
      customerName: customerDisplayName,
      customerEmail: profile?.email,
      items: payload,
      orderType: _isPickup ? 'pickup' : 'delivery',
      paymentMethod: orderPaymentMethod,
      paymentStatus:
          (orderPaymentMethod == 'cash' || orderPaymentMethod == 'cod')
          ? 'unpaid'
          : 'processing',
      deliveryAddress: _isPickup ? null : _deliveryAddressLine,
      deliveryPhone: _isPickup || deliveryPhone == null || deliveryPhone.isEmpty
          ? null
          : deliveryPhone,
      deliveryNote: deliveryNote,
      deliveryLat: _isPickup ? null : _selectedDeliveryLatLng?.latitude,
      deliveryLng: _isPickup ? null : _selectedDeliveryLatLng?.longitude,
      voucherCode: voucherCode,
    );

    if (!mounted) return;

    setState(() => _placingOrder = false);

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Unable to place order.'),
        ),
      );
      return;
    }

    if (selectedPaymentMethod == 'aba_qr') {
      if (result.orderId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order created without id. Try again.')),
        );
        return;
      }
      final totalAmount = result.totalAmount ?? _grandTotal;

      final generated = await ApiService.generateKhqr(
        orderId: result.orderId!,
        amount: totalAmount,
        currency: 'USD',
      );

      if (!mounted) return;

      if (!generated.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(generated.errorMessage ?? 'Unable to generate KHQR.'),
          ),
        );
        return;
      }
      final displayQrString = generated.qrString!;

      final paid = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _KhqrPaymentSheet(
          amount: totalAmount,
          orderId: result.orderId!,
          orderNumber: result.orderNumber,
          orderType: _isPickup ? 'pickup' : 'delivery',
          transactionId: generated.transactionId!,
          qrString: displayQrString,
          expiresAtIso: generated.expiresAt,
        ),
      );

      if (paid == true && widget.fromCart) {
        CartService.instance.clear();
      }
      if (!mounted) return;
      if (paid == true) {
        if (_isPickup) {
          Navigator.of(context).pop(true);
        } else {
          await _openDeliveryTrackingAfterSuccess(result);
        }
      }
      return;
    }

    if (widget.fromCart) {
      CartService.instance.clear();
    }

    if (!_isPickup) {
      await _openDeliveryTrackingAfterSuccess(result);
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order placed'),
        content: Text(
          result.orderNumber != null
              ? 'Your order ${result.orderNumber} has been created successfully.'
              : 'Your order has been created successfully.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _openDeliveryTrackingAfterSuccess(
    OrderCreateResult result,
  ) async {
    final orderId = result.orderId;
    final orderNumber = result.orderNumber?.trim();
    if (orderId == null && (orderNumber == null || orderNumber.isEmpty)) {
      if (!mounted) return;
      Navigator.of(context).pop(true);
      return;
    }

    await Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MainNavigationScreen(
          initialIndex: 3,
          initialDeliveryOrderId: orderId,
          initialDeliveryOrderNumber: orderNumber,
          initialDeliveryStatus: result.orderStatus ?? 'pending',
          initialDeliveryAddress:
              result.deliveryAddress?.trim().isNotEmpty == true
              ? result.deliveryAddress!.trim()
              : _deliveryAddressLine,
          initialDeliveryAmount: result.totalAmount ?? _grandTotal,
          initialDeliveryPlacedAt: result.placedAt ?? DateTime.now(),
        ),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackNavigation();
      },
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 64,
          leadingWidth: 56,
          leading: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 0, 10),
            child: _IconBtn(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () async {
                final shouldPop = await _handleBackNavigation();
                if (shouldPop && context.mounted) {
                  Navigator.of(context).maybePop();
                }
              },
              circular: true,
              iconSize: 18,
            ),
          ),
          title: Text(
            'Checkout',
            style: GoogleFonts.sora(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _checkoutInk,
            ),
          ),
          actions: const [SizedBox(width: 56)],
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: _checkoutSurface,
          surfaceTintColor: Colors.transparent,
          foregroundColor: _checkoutInk,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(88),
            child: _StepHeader(
              steps: _stepMetas,
              currentStep: _step,
              primary: _primary,
              accent: _accent,
              onStepTap: _jumpToStep,
            ),
          ),
        ),
        body: _loadingOptions
            ? Center(child: CircularProgressIndicator(color: _primary))
            : Column(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.05, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: _buildStepBody(),
                    ),
                  ),
                  _BottomTotalBar(
                    total: _grandTotal,
                    buttonText: _stepButtonText,
                    onPressed: _placingOrder ? null : _continueStep,
                    primary: _primary,
                    stepLabel: _currentStepMeta.label,
                    compact: _step == 2,
                    stepHint: _step == 3
                        ? 'Review is complete. Submit when you are ready.'
                        : _step == 2
                        ? 'Select a payment method to continue.'
                        : _currentStepMeta.subtitle,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStepBody() {
    switch (_step) {
      case 0:
        return _buildMethodStep();
      case 1:
        return _buildAddressStep();
      case 2:
        return _buildPaymentStep();
      default:
        return _buildConfirmStep();
    }
  }

  Widget _buildMethodStep() {
    return ListView(
      key: const ValueKey(0),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Text(
          'Delivery Method',
          style: GoogleFonts.sora(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _checkoutInk,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Select how you want to receive this order.',
          style: TextStyle(color: _checkoutMuted, height: 1.45),
        ),
        const SizedBox(height: 16),
        ...List.generate(_deliveryMethods.length, (index) {
          final method = _deliveryMethods[index];
          final selected = _selectedDeliveryMethod == index;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SelectCard(
              selected: selected,
              title: method.title,
              subtitle: method.description,
              trailing: method.code == 'delivery'
                  ? '+\$${_options.deliveryFee.toStringAsFixed(2)}'
                  : 'Free',
              onTap: () {
                setState(() {
                  _selectedDeliveryMethod = index;
                  _selectedPayment = 0;
                });
              },
              primary: _primary,
              icon: method.icon,
              assetPath: null,
              badge: method.code == 'pickup'
                  ? 'Bakong only'
                  : 'Address required',
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAddressStep() {
    final coordinatesText = _selectedDeliveryLatLng == null
        ? null
        : 'Pinned: '
              '${_selectedDeliveryLatLng!.latitude.toStringAsFixed(6)}, '
              '${_selectedDeliveryLatLng!.longitude.toStringAsFixed(6)}';

    return ListView(
      key: const ValueKey(1),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Text(
          'Delivery Address',
          style: GoogleFonts.sora(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _checkoutInk,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Pin the exact map location to continue.',
          style: TextStyle(color: _checkoutMuted, height: 1.45),
        ),
        const SizedBox(height: 18),
        _AddressPreviewCard(
          addressLine: _deliveryAddressLine,
          coordinates: coordinatesText,
          onPick: _pickDeliveryLocation,
        ),
        const SizedBox(height: 14),
        _SurfaceCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Saved Maps',
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _checkoutInk,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _addSavedAddress,
                    icon: const Icon(Icons.add_location_alt_outlined, size: 16),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Reuse a saved pin or manage locations without leaving checkout.',
                style: TextStyle(color: _checkoutMuted, height: 1.45),
              ),
              const SizedBox(height: 14),
              if (_loadingSavedAddresses)
                const Center(child: CircularProgressIndicator())
              else if (_savedAddresses.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _checkoutSurfaceAlt,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'No saved maps yet. Pick a location on the map, then tap Add to save it for later.',
                    style: TextStyle(color: _checkoutMuted, height: 1.45),
                  ),
                )
              else
                ...List.generate(_savedAddresses.length, (index) {
                  final address = _savedAddresses[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == _savedAddresses.length - 1 ? 0 : 12,
                    ),
                    child: _SavedMapCard(
                      address: address,
                      selected: address.id == _selectedSavedAddressId,
                      onSelect: () => _applySavedAddress(address),
                      onEdit: () => _editSavedAddress(address),
                      onDelete: () => _deleteSavedAddress(address),
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStep() {
    return ListView(
      key: const ValueKey(2),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      children: [
        _buildPaymentMethodCard(),
        const SizedBox(height: 14),
        _OrderItemsCard(items: _items),
        const SizedBox(height: 14),
        _SummaryCard(
          subtotal: _subtotal,
          shipping: _shipping,
          tax: _tax,
          discount: _discount,
          total: _grandTotal,
          primary: _primary,
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard() {
    return _SurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment method',
            style: GoogleFonts.sora(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _checkoutInk,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _isPickup
                ? 'Bakong QR is the only available payment method for pickup.'
                : 'Delivery orders support KHQR/Bakong QR or Cash on Delivery.',
            style: const TextStyle(color: _checkoutMuted, height: 1.45),
          ),
          const SizedBox(height: 16),
          ...List.generate(_checkoutPaymentMethods.length, (index) {
            final method = _checkoutPaymentMethods[index];
            final selected = _selectedPayment == index;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == _checkoutPaymentMethods.length - 1 ? 0 : 12,
              ),
              child: _SelectCard(
                selected: selected,
                title: method.label,
                subtitle: method.description,
                trailing: '',
                onTap: () => setState(() => _selectedPayment = index),
                primary: _primary,
                icon: _paymentMethodIcon(method.code),
                assetPath: method.code == 'aba_qr'
                    ? 'assets/images/BakongLogo.png'
                    : null,
                badge: method.code == 'aba_qr' ? 'QR Payment' : 'Pay Later',
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildConfirmStep() {
    final paymentMethod = _checkoutPaymentMethods[_selectedPayment];
    final slot = _options.deliverySlots.isEmpty
        ? null
        : _options.deliverySlots[_selectedSlot];
    final deliveryLines = _isPickup
        ? const ['Pickup from Store', 'Collect your order at the shop']
        : [
            _deliveryAddressLine,
            if (_selectedDeliveryLatLng != null)
              'Pinned: '
                  '${_selectedDeliveryLatLng!.latitude.toStringAsFixed(6)}, '
                  '${_selectedDeliveryLatLng!.longitude.toStringAsFixed(6)}',
            if (slot != null && slot.label.trim().isNotEmpty) slot.label,
            if (_deliveryNoteValue != null) _deliveryNoteValue!,
          ];

    return ListView(
      key: const ValueKey(3),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Text(
          'Confirm Order',
          style: GoogleFonts.sora(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _checkoutInk,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _isPickup
              ? 'Review pickup, payment, and pricing before placing the order.'
              : 'Review the address, payment, and pricing before placing the order.',
          style: const TextStyle(color: _checkoutMuted, height: 1.45),
        ),
        const SizedBox(height: 14),
        _ReviewMetaCard(
          orderType: _isPickup ? 'Pickup' : 'Delivery',
          paymentLabel: paymentMethod.label,
          total: _grandTotal,
          primary: _primary,
        ),
        const SizedBox(height: 12),
        _ConfirmCard(
          title: _isPickup ? 'Pickup' : 'Delivery Address',
          icon: _isPickup ? Icons.storefront_outlined : Icons.place_rounded,
          lines: deliveryLines,
        ),
        const SizedBox(height: 12),
        _ReviewTotalsCard(
          subtotal: _subtotal,
          shipping: _shipping,
          tax: _tax,
          discount: _discount,
          total: _grandTotal,
          primary: _primary,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.steps,
    required this.currentStep,
    required this.primary,
    required this.accent,
    required this.onStepTap,
  });

  final List<_StepMeta> steps;
  final int currentStep;
  final Color primary;
  final Color accent;
  final ValueChanged<int> onStepTap;

  @override
  Widget build(BuildContext context) {
    final current = steps[currentStep];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      decoration: BoxDecoration(
        color: _checkoutSurface,
        border: Border(
          top: BorderSide(color: _checkoutBorder.withValues(alpha: 0.65)),
          bottom: BorderSide(color: _checkoutBorder.withValues(alpha: 0.85)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  current.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.sora(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Step ${currentStep + 1}/${steps.length}',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(steps.length, (index) {
              final isCurrent = index == currentStep;
              final isDone = index < currentStep;
              final active = index <= currentStep;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => onStepTap(index),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: active
                                      ? primary.withValues(
                                          alpha: isCurrent ? 1 : 0.14,
                                        )
                                      : _checkoutSurfaceAlt,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: active ? primary : _checkoutBorder,
                                  ),
                                ),
                                child: Center(
                                  child: isDone
                                      ? Icon(
                                          Icons.check_rounded,
                                          size: 14,
                                          color: primary,
                                        )
                                      : Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            color: isCurrent
                                                ? Colors.white
                                                : active
                                                ? primary
                                                : _checkoutMuted,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                steps[index].label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: active ? _checkoutInk : _checkoutMuted,
                                  fontWeight: active
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (index != steps.length - 1)
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          height: 2,
                          color: active
                              ? primary.withValues(alpha: 0.26)
                              : _checkoutBorder,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.circular = false,
    this.iconSize = 20,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool circular;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(circular ? 999 : 16),
      child: Container(
        width: circular ? 42 : 44,
        height: circular ? 42 : 44,
        decoration: BoxDecoration(
          color: _checkoutSurface,
          shape: circular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circular ? null : BorderRadius.circular(16),
          border: Border.all(color: _checkoutBorder),
        ),
        child: Icon(icon, size: iconSize, color: _checkoutInk),
      ),
    );
  }
}

class _AddressPreviewCard extends StatelessWidget {
  const _AddressPreviewCard({
    required this.addressLine,
    this.coordinates,
    required this.onPick,
  });

  final String addressLine;
  final String? coordinates;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final hasContent = addressLine.isNotEmpty;

    return _SurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Map Location',
                style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _checkoutInk,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: hasContent
                      ? _checkoutPrimary.withValues(alpha: 0.1)
                      : _checkoutSurfaceAlt,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  hasContent ? 'Pinned' : 'Required',
                  style: TextStyle(
                    color: hasContent ? _checkoutPrimary : _checkoutMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: onPick,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: hasContent
                    ? _checkoutPrimary.withValues(alpha: 0.06)
                    : _checkoutSurfaceAlt,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: hasContent
                      ? _checkoutPrimary.withValues(alpha: 0.22)
                      : _checkoutBorder,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: hasContent
                          ? _checkoutPrimary.withValues(alpha: 0.14)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      hasContent
                          ? Icons.location_on_rounded
                          : Icons.map_outlined,
                      color: hasContent ? _checkoutPrimary : _checkoutInk,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasContent
                              ? 'Selected delivery point'
                              : 'Choose delivery point on map',
                          style: const TextStyle(
                            color: _checkoutInk,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hasContent
                              ? addressLine
                              : 'Tap here to open the map and pin the customer location.',
                          style: TextStyle(
                            color: hasContent
                                ? _checkoutInk
                                : const Color(0xFF6B7280),
                            height: 1.45,
                          ),
                        ),
                        if (coordinates != null &&
                            coordinates!.trim().isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              coordinates!,
                              style: const TextStyle(
                                color: _checkoutMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onPick,
                  icon: Icon(
                    hasContent
                        ? Icons.edit_location_alt_outlined
                        : Icons.map_outlined,
                    size: 18,
                  ),
                  label: Text(hasContent ? 'Update Pin' : 'Open Map'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _checkoutPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SavedMapCard extends StatelessWidget {
  const _SavedMapCard({
    required this.address,
    required this.selected,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  final SavedAddress address;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? _checkoutPrimary.withValues(alpha: 0.06)
              : _checkoutSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _checkoutPrimary : _checkoutBorder,
            width: selected ? 1.4 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _checkoutPrimary.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : const [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: selected
                        ? _checkoutPrimary.withValues(alpha: 0.14)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    selected
                        ? Icons.location_on_rounded
                        : Icons.location_on_outlined,
                    color: selected ? _checkoutPrimary : _checkoutInk,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              address.name.trim().isEmpty
                                  ? 'Saved Location'
                                  : address.name,
                              style: const TextStyle(
                                color: _checkoutInk,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (selected)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _checkoutPrimary.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Selected',
                                style: TextStyle(
                                  color: _checkoutPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        address.addressLine,
                        style: const TextStyle(
                          color: _checkoutInk,
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                        ),
                      ),
                      if (address.note.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _checkoutSurfaceAlt,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            address.note,
                            style: const TextStyle(
                              color: _checkoutMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onSelect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selected
                          ? _checkoutInk
                          : _checkoutPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(selected ? 'Using This Map' : 'Use This Map'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 20),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectCard extends StatelessWidget {
  const _SelectCard({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
    required this.primary,
    required this.icon,
    this.assetPath,
    this.badge,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback onTap;
  final Color primary;
  final IconData icon;
  final String? assetPath;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final hasAsset = assetPath != null && assetPath!.trim().isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.06) : _checkoutSurface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? primary : _checkoutBorder,
            width: selected ? 1.6 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 12),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: _checkoutShadow,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: hasAsset ? 78 : 48,
              height: hasAsset ? 42 : 48,
              decoration: BoxDecoration(
                color: hasAsset
                    ? Colors.white
                    : selected
                    ? primary.withValues(alpha: 0.14)
                    : _checkoutSurfaceAlt,
                borderRadius: BorderRadius.circular(hasAsset ? 14 : 18),
                border: hasAsset
                    ? Border.all(
                        color: selected
                            ? primary.withValues(alpha: 0.24)
                            : _checkoutBorder,
                      )
                    : null,
              ),
              child: hasAsset
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Image.asset(
                          assetPath!,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                        ),
                      ),
                    )
                  : Icon(icon, color: selected ? primary : _checkoutInk),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.sora(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _checkoutInk,
                              ),
                            ),
                            if (badge != null && badge!.trim().isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? primary.withValues(alpha: 0.14)
                                      : _checkoutSurfaceAlt,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  badge!,
                                  style: TextStyle(
                                    color: selected ? primary : _checkoutInk,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (trailing.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            trailing,
                            style: TextStyle(
                              color: trailing.toLowerCase() == 'free'
                                  ? _checkoutSuccess
                                  : _checkoutInk,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _checkoutMuted,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 30,
              height: 30,
              child: Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                size: 22,
                color: selected ? primary : _checkoutMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderItemsCard extends StatelessWidget {
  const _OrderItemsCard({required this.items});

  final List<CartItem> items;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Order items',
                style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _checkoutInk,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _checkoutSurfaceAlt,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${items.length} items',
                  style: const TextStyle(
                    color: _checkoutMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _checkoutSurfaceAlt.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: 58,
                        height: 58,
                        child:
                            item.product.imageUrl != null &&
                                item.product.imageUrl!.isNotEmpty
                            ? Image.network(
                                item.product.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _FallbackProductTile(
                                    quantity: item.quantity,
                                  );
                                },
                              )
                            : _FallbackProductTile(quantity: item.quantity),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _checkoutInk,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _checkoutSurface,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Qty ${item.quantity}',
                              style: const TextStyle(
                                color: _checkoutMuted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$${item.subtotal.toStringAsFixed(2)}',
                      style: GoogleFonts.sora(
                        fontWeight: FontWeight.w700,
                        color: _checkoutInk,
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
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.discount,
    required this.total,
    required this.primary,
  });

  final double subtotal;
  final double shipping;
  final double tax;
  final double discount;
  final double total;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Payment summary',
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _checkoutInk,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Live total',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _checkoutSurfaceAlt.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                _SummaryRow(label: 'Subtotal', value: subtotal),
                _SummaryRow(label: 'Shipping Fee', value: shipping),
                _SummaryRow(label: 'Tax', value: tax),
                if (discount > 0)
                  _SummaryRow(
                    label: 'Discount',
                    value: -discount,
                    color: const Color(0xFF16A34A),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primary.withValues(alpha: 0.14),
                  const Color(0xFFF4F8FF),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primary.withValues(alpha: 0.16)),
            ),
            child: _SummaryRow(
              label: 'Grand Total',
              value: total,
              bold: true,
              color: primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.color,
  });

  final String label;
  final double value;
  final bool bold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: bold ? _checkoutInk : _checkoutMuted,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value < 0
                ? '-\$${value.abs().toStringAsFixed(2)}'
                : '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              color: color ?? _checkoutInk,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              fontSize: bold ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewMetaCard extends StatelessWidget {
  const _ReviewMetaCard({
    required this.orderType,
    required this.paymentLabel,
    required this.total,
    required this.primary,
  });

  final String orderType;
  final String paymentLabel;
  final double total;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _ReviewMetaItem(label: 'Order Type', value: orderType),
          ),
          Container(width: 1, height: 38, color: _checkoutBorder),
          Expanded(
            child: _ReviewMetaItem(
              label: 'Payment',
              value: paymentLabel,
              alignEnd: true,
            ),
          ),
          Container(width: 1, height: 38, color: _checkoutBorder),
          Expanded(
            child: _ReviewMetaItem(
              label: 'Total',
              value: '\$${total.toStringAsFixed(2)}',
              valueColor: primary,
              alignEnd: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewMetaItem extends StatelessWidget {
  const _ReviewMetaItem({
    required this.label,
    required this.value,
    this.valueColor,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: alignEnd
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _checkoutMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: alignEnd ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              color: valueColor ?? _checkoutInk,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTotalsCard extends StatelessWidget {
  const _ReviewTotalsCard({
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.discount,
    required this.total,
    required this.primary,
  });

  final double subtotal;
  final double shipping;
  final double tax;
  final double discount;
  final double total;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pricing',
            style: GoogleFonts.sora(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _checkoutInk,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Subtotal', value: subtotal),
          _SummaryRow(label: 'Shipping', value: shipping),
          _SummaryRow(label: 'Tax', value: tax),
          if (discount > 0)
            _SummaryRow(
              label: 'Discount',
              value: -discount,
              color: const Color(0xFF16A34A),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: _checkoutBorder),
          ),
          _SummaryRow(label: 'Total', value: total, bold: true, color: primary),
        ],
      ),
    );
  }
}

class _ConfirmCard extends StatelessWidget {
  const _ConfirmCard({
    required this.title,
    required this.lines,
    required this.icon,
  });

  final String title;
  final List<String> lines;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final visibleLines = lines.where((line) => line.trim().isNotEmpty).toList();
    final primaryLine = visibleLines.isEmpty ? '' : visibleLines.first;
    final secondaryLines = visibleLines.length > 1
        ? visibleLines.skip(1).toList()
        : const <String>[];
    return _SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _checkoutSurfaceAlt,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: _checkoutPrimary),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.sora(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _checkoutInk,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _checkoutSurfaceAlt,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _checkoutBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (primaryLine.isNotEmpty)
                  Text(
                    primaryLine,
                    style: const TextStyle(
                      color: _checkoutInk,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                if (secondaryLines.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  ...secondaryLines.asMap().entries.map((entry) {
                    final isLast = entry.key == secondaryLines.length - 1;
                    return Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 4),
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          color: _checkoutMuted,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomTotalBar extends StatelessWidget {
  const _BottomTotalBar({
    required this.total,
    required this.buttonText,
    required this.onPressed,
    required this.primary,
    required this.stepLabel,
    required this.stepHint,
    this.compact = false,
  });

  final double total;
  final String buttonText;
  final VoidCallback? onPressed;
  final Color primary;
  final String stepLabel;
  final String stepHint;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, compact ? 8 : 10, 16, compact ? 12 : 18),
        decoration: BoxDecoration(
          color: _checkoutSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: const Border(top: BorderSide(color: _checkoutBorder)),
          boxShadow: const [
            BoxShadow(
              color: _checkoutShadow,
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: compact
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        stepLabel,
                        style: GoogleFonts.sora(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _checkoutPrimary,
                        ),
                      ),
                      if (stepHint.trim().isNotEmpty) ...[
                        SizedBox(height: compact ? 2 : 4),
                        Text(
                          stepHint,
                          maxLines: compact ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _checkoutMuted,
                            height: compact ? 1.25 : 1.4,
                            fontSize: compact ? 13 : 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 11 : 12,
                    vertical: compact ? 8 : 10,
                  ),
                  decoration: BoxDecoration(
                    color: _checkoutSurfaceAlt,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _checkoutBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          color: _checkoutMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: GoogleFonts.sora(
                          fontWeight: FontWeight.w800,
                          fontSize: compact ? 16 : 18,
                          color: _checkoutInk,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: compact ? 10 : 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: compact ? 14 : 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  buttonText,
                  style: GoogleFonts.sora(
                    fontWeight: FontWeight.w700,
                    fontSize: compact ? 14 : 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepMeta {
  const _StepMeta({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String label;
  final String title;
  final String subtitle;
  final IconData icon;
}

class _DeliveryMethod {
  const _DeliveryMethod({
    required this.code,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String code;
  final String title;
  final String description;
  final IconData icon;
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _checkoutSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _checkoutBorder),
        boxShadow: const [
          BoxShadow(
            color: _checkoutShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FallbackProductTile extends StatelessWidget {
  const _FallbackProductTile({required this.quantity});

  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _checkoutSurfaceAlt,
      child: Center(
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _checkoutSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'x$quantity',
              style: GoogleFonts.sora(
                fontWeight: FontWeight.w700,
                color: _checkoutMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KhqrPaymentSheet extends StatefulWidget {
  const _KhqrPaymentSheet({
    required this.amount,
    required this.orderId,
    required this.orderType,
    required this.transactionId,
    required this.qrString,
    this.orderNumber,
    this.expiresAtIso,
  });

  final double amount;
  final int orderId;
  final String orderType;
  final String transactionId;
  final String qrString;
  final String? orderNumber;
  final String? expiresAtIso;

  @override
  State<_KhqrPaymentSheet> createState() => _KhqrPaymentSheetState();
}

class _KhqrPaymentSheetState extends State<_KhqrPaymentSheet> {
  static const Duration _checkInterval = Duration(seconds: 3);

  bool _isChecking = false;
  bool _isSuccess = false;
  final bool _isScanned = false;
  bool _isTerminalFailure = false;
  bool _autoCheckStopped = false;
  bool _isOpeningTicket = false;
  bool _didAutoOpenTicket = false;
  int _checkAttempts = 0;
  int _maxCheckAttempts = 200;
  String? _lastStatus;
  String? _statusMessage;
  DateTime? _expiresAt;
  Timer? _checkTimer;
  Timer? _countdownTimer;

  bool _isSuccessStatus(String status) {
    switch (status.toUpperCase()) {
      case 'SUCCESS':
      case 'PAID':
      case 'COMPLETED':
      case 'APPROVED':
      case 'OK':
        return true;
      default:
        return false;
    }
  }

  bool _isFailureStatus(String status) {
    switch (status.toUpperCase()) {
      case 'FAILED':
      case 'INVALID_TRANSACTION':
      case 'EXPIRED':
      case 'TIMEOUT':
      case 'CANCELLED':
      case 'CANCELED':
      case 'REJECTED':
        return true;
      default:
        return false;
    }
  }

  void _logKhqrEvent({
    required String event,
    String? status,
    String? message,
    String? fromBank,
    String? paidAtIso,
    double? amount,
    String? currency,
    String? bankHash,
  }) {
    final payload = <String, dynamic>{
      'event': event,
      'amount': (amount ?? widget.amount).toStringAsFixed(2),
      'currency': currency ?? 'USD',
      'fromBank': fromBank ?? 'unknown',
      'dateTime': paidAtIso ?? DateTime.now().toIso8601String(),
      'status': status,
      'md5': widget.transactionId,
    };
    if (bankHash != null && bankHash.isNotEmpty) {
      payload['bankHash'] = bankHash;
    }
    if (message != null && message.isNotEmpty) {
      payload['message'] = message;
    }
    debugPrint(jsonEncode(payload));
  }

  void _setStatusMessage(String? message) {
    if (!mounted || _statusMessage == message) return;
    setState(() {
      _statusMessage = message;
    });
  }

  @override
  void initState() {
    super.initState();
    _expiresAt = _parseExpiresAt(widget.expiresAtIso);
    _maxCheckAttempts = _deriveMaxAttempts();
    _statusMessage = 'Waiting for payment confirmation...';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startChecking();
      }
    });
  }

  @override
  void dispose() {
    _stopChecking();
    _stopCountdown();
    super.dispose();
  }

  DateTime? _parseExpiresAt(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      return DateTime.parse(value).toLocal();
    } catch (_) {
      return null;
    }
  }

  int _deriveMaxAttempts() {
    final expiresAt = _expiresAt;
    if (expiresAt == null) return 200;
    final remaining = expiresAt.difference(DateTime.now()).inSeconds;
    if (remaining <= 0) return 1;
    final attempts = (remaining / _checkInterval.inSeconds).ceil() + 2;
    if (attempts < 10) return 10;
    if (attempts > 400) return 400;
    return attempts;
  }

  bool get _isExpired {
    final expiresAt = _expiresAt;
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt);
  }

  void _startChecking() {
    _stopChecking();
    _startCountdown();
    _autoCheckStopped = false;
    _checkAttempts = 0;
    _maxCheckAttempts = _deriveMaxAttempts();
    _checkStatus(fromTimer: true);
    _checkTimer = Timer.periodic(_checkInterval, (_) {
      if (!mounted || _isSuccess || _isTerminalFailure) {
        _stopChecking();
        return;
      }
      _checkStatus(fromTimer: true);
    });
  }

  void _stopChecking() {
    _checkTimer?.cancel();
    _checkTimer = null;
  }

  void _startCountdown() {
    _stopCountdown();
    if (_expiresAt == null) return;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _isSuccess || _isTerminalFailure) {
        _stopCountdown();
        return;
      }
      if (_isExpired) {
        _stopCountdown();
        _stopChecking();
        setState(() {
          _isTerminalFailure = true;
          _statusMessage = 'QR expired. Please generate a new one.';
        });
      }
    });
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  bool get _shouldOfferPickupTicket => widget.orderType == 'pickup';

  Future<PickupTicket?> _findMatchingTicket() async {
    for (var attempt = 0; attempt < 5; attempt++) {
      final tickets = await ApiService.fetchPickupTickets();
      for (final ticket in tickets) {
        if (ticket.orderId == widget.orderId) {
          return ticket;
        }
        final orderNumber = widget.orderNumber;
        if (orderNumber != null &&
            orderNumber.isNotEmpty &&
            ticket.orderNumber == orderNumber) {
          return ticket;
        }
      }
      if (attempt < 4) {
        await Future<void>.delayed(const Duration(milliseconds: 800));
      }
    }
    return null;
  }

  Future<void> _openTicketDetail({bool showFeedback = true}) async {
    if (_isOpeningTicket || !_shouldOfferPickupTicket) return;

    setState(() {
      _isOpeningTicket = true;
    });

    final ticket = await _findMatchingTicket();
    if (!mounted) return;

    setState(() {
      _isOpeningTicket = false;
    });

    if (ticket == null) {
      if (showFeedback) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pickup ticket is still being generated. Please try again.',
            ),
          ),
        );
      }
      return;
    }

    await Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) =>
            MainNavigationScreen(initialIndex: 0, initialPickupTicket: ticket),
      ),
      (_) => false,
    );
  }

  Future<void> _handlePaymentSuccess() async {
    if (!_shouldOfferPickupTicket || _didAutoOpenTicket) return;
    _didAutoOpenTicket = true;
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    await _openTicketDetail(showFeedback: false);
  }

  Future<void> _checkStatus({bool fromTimer = false}) async {
    if (_isChecking || _isSuccess || _isTerminalFailure || _autoCheckStopped) {
      return;
    }
    if (_checkAttempts >= _maxCheckAttempts) {
      _stopChecking();
      if (mounted) {
        setState(() {
          _autoCheckStopped = true;
          _statusMessage = 'Payment still pending. Auto-check paused.';
        });
      }
      return;
    }
    if (_isExpired) {
      if (mounted) {
        setState(() {
          _isTerminalFailure = true;
          _statusMessage = 'QR expired. Please generate a new one.';
        });
      }
      _stopChecking();
      return;
    }

    _isChecking = true;
    _checkAttempts += 1;

    final result = await ApiService.checkKhqrTransaction(
      transactionId: widget.transactionId,
    );

    if (!mounted) return;
    _isChecking = false;
    final normalizedStatus = result.status.toUpperCase();
    if (_lastStatus != normalizedStatus) {
      _lastStatus = normalizedStatus;
      _logKhqrEvent(
        event: 'RESULT',
        status: result.status,
        message: result.message,
        fromBank: result.fromAccountId,
        paidAtIso: result.paidAtIso,
        amount: result.amount,
        currency: result.currency,
        bankHash: result.bakongHash,
      );
    }

    if (_isSuccessStatus(result.status)) {
      _logKhqrEvent(
        event: 'PAID',
        status: 'SUCCESS',
        fromBank: result.fromAccountId,
        paidAtIso: result.paidAtIso,
        amount: result.amount,
        currency: result.currency,
        bankHash: result.bakongHash,
      );
      _stopChecking();
      _stopCountdown();
      setState(() {
        _isSuccess = true;
        _statusMessage = 'Payment confirmed.';
      });
      _handlePaymentSuccess();
      return;
    }

    if (_isFailureStatus(result.status)) {
      _stopChecking();
      _stopCountdown();
      if (!mounted) return;
      setState(() {
        _isTerminalFailure = true;
        _statusMessage =
            result.status.toUpperCase() == 'EXPIRED' ||
                result.status.toUpperCase() == 'TIMEOUT'
            ? 'QR expired. Please generate a new one.'
            : 'Payment failed. Please try again.';
      });
      return;
    }

    if (normalizedStatus == 'NOT_FOUND') {
      if (_isExpired) {
        _stopChecking();
        _stopCountdown();
        if (!mounted) return;
        setState(() {
          _isTerminalFailure = true;
          _statusMessage = 'QR expired before payment was found.';
        });
      } else if (fromTimer && mounted) {
        if (_statusMessage == null) {
          _setStatusMessage('Waiting for payment confirmation...');
        }
      } else if (!fromTimer) {
        _setStatusMessage(result.message ?? result.status);
      }
      return;
    }

    if (fromTimer) {
      if (_statusMessage == null) {
        _setStatusMessage('Waiting for payment confirmation...');
      }
      return;
    }
    _setStatusMessage(result.message ?? result.status);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = 16 + MediaQuery.of(context).padding.bottom;
    final showQr = !_isSuccess && !_isScanned;
    final showScanned = !_isSuccess && _isScanned;

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF3F4F6),
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        padding: EdgeInsets.fromLTRB(18, 14, 18, bottomInset),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _isChecking
                        ? null
                        : () {
                            _stopChecking();
                            Navigator.of(context).pop(false);
                          },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF334155),
                      minimumSize: const Size(34, 34),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Bakong KHQR',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: showQr
                    ? _buildQrStep()
                    : showScanned
                    ? _buildScannedStep()
                    : _buildPaidStep(),
              ),
              const SizedBox(height: 18),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrStep() {
    return Container(
      key: const ValueKey('qr-step'),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'KHQR Payment',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _qrMetaRow('Merchant', 'KNEA YERNG SERVICE CENTER'),
                        const SizedBox(height: 6),
                        _qrMetaRow(
                          'Amount',
                          '\$${widget.amount.toStringAsFixed(2)} USD',
                        ),
                        const SizedBox(height: 6),
                        _qrMetaRow(
                          'Reference',
                          '#${widget.transactionId.substring(0, 8)}',
                        ),
                        const SizedBox(height: 6),
                        _qrMetaRow('Network', 'Bakong KHQR'),
                      ],
                    ),
                  ),
                ),
                Stack(
                  children: [
                    KhqrCardWidget(
                      width: 240,
                      qr: widget.qrString,
                      receiverName: 'KneaYerng Service Center',
                      amount: widget.amount,
                      currency: KhqrCurrency.usd,
                      duration: null,
                      isLoading: false,
                      isError: false,
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Align(
                          alignment: const Alignment(0, 0.42),
                          child: Container(
                            width: 46,
                            height: 46,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1.5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/logo_bakong.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Scan the KHQR with Bakong or\nany supported banking app',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_statusMessage != null) ...[
            const SizedBox(height: 10),
            Container(
              width: 280,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: _isTerminalFailure
                    ? const Color(0xFFFEF2F2)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _isTerminalFailure
                      ? const Color(0xFFFECACA)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                _statusMessage!,
                style: TextStyle(
                  fontSize: 12,
                  color: _isTerminalFailure
                      ? const Color(0xFFB91C1C)
                      : const Color(0xFF475569),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _qrMetaRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildScannedStep() {
    return Container(
      key: const ValueKey('scanned-step'),
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 94,
                height: 94,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  color: Color(0xFF9CA3AF),
                  size: 66,
                ),
              ),
              const Positioned(
                right: -2,
                bottom: -2,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Color(0xFF06B6D4),
                  child: Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const Text(
            'QR code is scanned',
            style: TextStyle(
              fontSize: 26,
              color: Color(0xFF3F3F46),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Please follow in app screen instruction.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF334155),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_statusMessage != null) ...[
            const SizedBox(height: 14),
            Text(
              _statusMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: _isTerminalFailure
                    ? const Color(0xFFB91C1C)
                    : (_isSuccess
                          ? const Color(0xFF166534)
                          : const Color(0xFF64748B)),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaidStep() {
    return Container(
      key: const ValueKey('paid-step'),
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF06B6D4),
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 18),
          const Text(
            'Payment Successful',
            style: TextStyle(
              fontSize: 30,
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your payment was successful.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.amount.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 41,
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  'USD',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextButton.icon(
            onPressed: null,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Get PDF Receipt'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF06B6D4),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isSuccess) {
      return Column(
        children: [
          if (_shouldOfferPickupTicket) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isOpeningTicket ? null : _openTicketDetail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _isOpeningTicket
                      ? 'Opening Pickup Ticket...'
                      : 'View Pickup Ticket',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF111827),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      );
    }

    if (_isTerminalFailure) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
            foregroundColor: const Color(0xFF111827),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Close',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
