import 'dart:async';

import 'package:flutter/material.dart';
import '../../theme/app_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:latlong2/latlong.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../l10n/app_localizations.dart';
import '../../models/cart_item.dart';
import '../../models/saved_address.dart';
import '../../services/api_service.dart';
import '../../services/address_book_service.dart';
import '../../services/cart_service.dart';
import '../Auth/login_screen.dart';
import 'delivery_location_picker.dart';
import '../main_navigation_screen.dart';
import '../profile/address_form_screen.dart';
import 'widgets/checkout_address_step.dart';
import 'widgets/checkout_bottom_total_bar.dart';
import 'widgets/checkout_colors.dart';
import 'widgets/checkout_confirm_step.dart';
import 'widgets/checkout_delivery_method.dart';
import 'widgets/checkout_icon_button.dart';
import 'widgets/checkout_khqr_payment_sheet.dart';
import 'widgets/checkout_method_step.dart';
import 'widgets/checkout_payment_step.dart';
import 'widgets/checkout_step_header.dart';

const _cPrimary = kCheckoutPrimary;
Color _cSurface(BuildContext c) => checkoutSurface(c);
Color _cInk(BuildContext c)     => checkoutInk(c);

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
  static const Color _primary = _cPrimary;
  static const List<CheckoutStepMeta> _stepMetas = [
    CheckoutStepMeta(
      label: 'Delivery',
      title: 'Delivery Method',
      subtitle: 'Choose pickup from store or home delivery.',
      icon: HugeIcons.strokeRoundedDeliveryTruck01,
    ),
    CheckoutStepMeta(
      label: 'Address',
      title: 'Delivery Address',
      subtitle: 'Pick the delivery location on the map.',
      icon: HugeIcons.strokeRoundedMapsLocation01,
    ),
    CheckoutStepMeta(
      label: 'Payment',
      title: 'Review costs and payment',
      subtitle: 'Check your items, totals, and select the payment option.',
      icon: HugeIcons.strokeRoundedWallet01,
    ),
    CheckoutStepMeta(
      label: 'Confirm',
      title: 'One last review',
      subtitle: 'Everything is ready. Verify the details before placing it.',
      icon: HugeIcons.strokeRoundedCheckmarkCircle02,
    ),
  ];

  static const List<CheckoutDeliveryMethod> _deliveryMethods = [
    CheckoutDeliveryMethod(
      code: 'pickup',
      title: 'Pickup from Store',
      description: 'Collect your order at the shop',
      icon: HugeIcons.strokeRoundedStore01,
    ),
    CheckoutDeliveryMethod(
      code: 'delivery',
      title: 'Home Delivery',
      description: 'We deliver to your address',
      icon: HugeIcons.strokeRoundedDeliveryTruck01,
    ),
  ];

  late final List<CartItem> _items;
  final TextEditingController _noteController    = TextEditingController();
  final TextEditingController _promoController   = TextEditingController();
  final TextEditingController _phoneController   = TextEditingController();
  LatLng? _selectedDeliveryLatLng;
  String _selectedDeliveryAddress = '';
  List<SavedAddress> _savedAddresses = [];
  bool _loadingSavedAddresses = true;
  String? _selectedSavedAddressId;

  int _step = 0;
  int _selectedDeliveryMethod = 1;
  int _selectedSlot = 0;
  int _selectedPayment = 0;

  bool _loadingOptions  = true;
  bool _placingOrder    = false;
  bool _applyingPromo   = false;
  bool _promoApplied    = false;
  String? _promoError;
  String? _appliedPromoCode;

  // true = phone came from profile (read-only display), false = user must type
  bool _phoneFromProfile = false;

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
            variantId: item.variantId,
            variantImageUrl: item.variantImageUrl,
            variantStock: item.variantStock,
            unitPrice: item.unitPrice,
          ),
        )
        .toList();
    _voucherDiscount = widget.initialDiscount;
    _loadCheckoutOptions();
    _loadSavedAddresses();
    _loadUserPhone();
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

  Future<void> _loadUserPhone() async {
    final profile = await ApiService.getUserProfile();
    if (!mounted) return;
    final phone = profile?.phone?.trim() ?? '';
    setState(() {
      _phoneFromProfile = phone.isNotEmpty;
      _phoneController.text = phone;
    });
  }

  Future<void> _applyPromoCode() async {
    final code = _promoController.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _applyingPromo = true;
      _promoError    = null;
    });
    final result = await ApiService.validateVoucher(
      code: code,
      subtotal: _subtotal,
    );
    if (!mounted) return;
    if (result.isValid) {
      setState(() {
        _promoApplied      = true;
        _appliedPromoCode  = code;
        _voucherDiscount   = result.discountFor(_subtotal);
        _applyingPromo     = false;
        _promoError        = null;
      });
    } else {
      setState(() {
        _promoApplied     = false;
        _appliedPromoCode = null;
        _voucherDiscount  = 0;
        _applyingPromo    = false;
        _promoError       = result.message ?? 'Invalid promo code.';
      });
    }
  }

  void _removePromoCode() {
    setState(() {
      _promoApplied     = false;
      _appliedPromoCode = null;
      _voucherDiscount  = 0;
      _promoError       = null;
      _promoController.clear();
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _promoController.dispose();
    _phoneController.dispose();
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
      description: '',
    );
    const cod = CheckoutPaymentMethod(
      code: 'cod',
      label: 'Cash on Delivery',
      description: '',
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

  CheckoutStepMeta get _currentStepMeta => _stepMetas[_step];

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
        return HugeIcons.strokeRoundedQrCode01;
      case 'cash':
      case 'cod':
        return HugeIcons.strokeRoundedMoney01;
      case 'card':
        return HugeIcons.strokeRoundedCreditCard;
      case 'bank_transfer':
        return HugeIcons.strokeRoundedBank;
      default:
        return HugeIcons.strokeRoundedWallet01;
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
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete location'),
        content: const Text('Remove this saved location?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.delete),
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

  void _showNotice(String message, {bool isError = true}) {
    if (!mounted) return;
    final accent = isError ? const Color(0xFFEF4444) : kCheckoutPrimary;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: checkoutSurface(context),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: accent.withValues(alpha: 0.35)),
        ),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isError
                    ? HugeIcons.strokeRoundedAlertCircle
                    : HugeIcons.strokeRoundedInformationCircle,
                color: accent,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: checkoutInk(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _jumpToStep(int targetStep) {
    if (targetStep == _step || targetStep < 0 || targetStep > 3) return;

    if (targetStep == 0) {
      setState(() => _step = 0);
      return;
    }

    if (_isPickup) {
      if (targetStep == 1) {
        _showNotice('Address step is not needed for pickup orders.');
        return;
      }
      setState(() {
        _selectedPayment = 0;
        _step = targetStep;
      });
      return;
    }

    if (targetStep >= 2 && !_hasValidDeliveryAddress) {
      _showNotice('Please complete your delivery address first.');
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
        _showNotice('Please complete your delivery address.');
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

  // Cart/buy-now items can carry variant ids cached from a previous app
  // session. If the backend's product_variants have since changed, the
  // stale id fails the "exists:product_variants,id" check on order create.
  // Re-fetch each product live and re-resolve the matching variant right
  // before submitting.
  Future<void> _revalidateItemVariants() async {
    for (var i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (item.variantId == null) continue;

      final fresh = await ApiService.fetchProductById(item.product.id);
      if (fresh == null) continue;

      final activeVariants = fresh.variants.where((v) => v.isActive).toList();
      if (activeVariants.isEmpty) {
        _items[i] = CartItem(
          product: item.product,
          remoteId: item.remoteId,
          quantity: item.quantity,
          variant: null,
          variantId: null,
          unitPrice: item.unitPrice,
        );
        continue;
      }

      final match = activeVariants.firstWhere(
        (v) => v.label == item.variant,
        orElse: () => activeVariants.first,
      );

      if (match.id != item.variantId) {
        _items[i] = CartItem(
          product: item.product,
          remoteId: item.remoteId,
          quantity: item.quantity,
          variant: match.label,
          variantId: match.id,
          variantImageUrl: match.imageUrl,
          variantStock: match.stock,
          unitPrice: match.price,
        );
      }
    }
  }

  Future<void> _placeOrder() async {
    if (_placingOrder) return;
    if (_items.isEmpty) {
      _showNotice('Your cart is empty.');
      return;
    }

    final token = await ApiService.getToken();
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      final l = AppLocalizations.of(context);
      final shouldLogin = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login required'),
          content: const Text('Please log in to place your order.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l.cancel),
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

    // Use the in-screen applied promo code, falling back to cart-passed code
    var voucherCode = _appliedPromoCode ?? widget.voucherCode?.trim();
    if (voucherCode != null && voucherCode.isNotEmpty && !_promoApplied) {
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

    await _revalidateItemVariants();

    final payload = _items
        .map(
          (item) => {
            'product_id': item.product.id,
            'item_type': 'product',
            'item_id': item.product.id,
            if (item.variantId != null) 'product_variant_id': item.variantId,
            if (item.variant != null && item.variant!.trim().isNotEmpty)
              'variant_label': item.variant!.trim(),
            'product_name': item.product.name,
            'quantity': item.quantity,
            'price': item.effectiveUnitPrice,
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
      _showNotice('Please complete your delivery address.');
      return;
    }
    final slot = _options.deliverySlots.isEmpty
        ? null
        : _options.deliverySlots[_selectedSlot].label;
    final deliveryNote = _isPickup
        ? null
        : _composeDeliveryNote(_deliveryNoteValue, slot);
    final customerDisplayName = customerName;
    final deliveryPhone = _phoneController.text.trim();

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
      deliveryPhone: deliveryPhone.isEmpty ? null : deliveryPhone,
      deliveryNote: deliveryNote,
      deliveryLat: _isPickup ? null : _selectedDeliveryLatLng?.latitude,
      deliveryLng: _isPickup ? null : _selectedDeliveryLatLng?.longitude,
      voucherCode: voucherCode,
    );

    if (!mounted) return;

    setState(() => _placingOrder = false);

    if (!result.isSuccess) {
      _showNotice(result.errorMessage ?? 'Unable to place order.');
      return;
    }

    if (selectedPaymentMethod == 'aba_qr') {
      if (result.orderId == null) {
        _showNotice('Order created without id. Try again.');
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
        _showNotice(generated.errorMessage ?? 'Unable to generate KHQR.');
        return;
      }
      final displayQrString = generated.qrString!;

      final paid = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => CheckoutKhqrPaymentSheet(
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

    final l = AppLocalizations.of(context);
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
            child: Text(l.ok),
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
          initialIndex: 2,
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
    final l = AppLocalizations.of(context);
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackNavigation();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 64,
          leadingWidth: 56,
          leading: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 0, 10),
            child: CheckoutIconButton(
              icon: HugeIcons.strokeRoundedArrowLeft01,
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
            l.checkout,
            style: kFont(context,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _cInk(context),
            ),
          ),
          actions: const [SizedBox(width: 56)],
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: _cSurface(context),
          surfaceTintColor: Colors.transparent,
          foregroundColor: _cInk(context),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(58),
            child: CheckoutStepHeader(
              steps: _stepMetas,
              currentStep: _step,
              primary: _primary,
              onStepTap: _jumpToStep,
            ),
          ),
        ),
        body: Skeletonizer(
          enabled: _loadingOptions,
          child: Column(
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
              CheckoutBottomTotalBar(
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
      ),
    );
  }

  Widget _buildStepBody() {
    switch (_step) {
      case 0:
        return CheckoutMethodStep(
          deliveryMethods: _deliveryMethods,
          selectedIndex: _selectedDeliveryMethod,
          deliveryFee: _options.deliveryFee,
          primary: _primary,
          onSelect: (index) {
            setState(() {
              _selectedDeliveryMethod = index;
              _selectedPayment = 0;
            });
          },
        );
      case 1:
        return CheckoutAddressStep(
          deliveryAddressLine: _deliveryAddressLine,
          selectedDeliveryLatLng: _selectedDeliveryLatLng,
          savedAddresses: _savedAddresses,
          loadingSavedAddresses: _loadingSavedAddresses,
          selectedSavedAddressId: _selectedSavedAddressId,
          primary: _primary,
          onPickLocation: _pickDeliveryLocation,
          onAddSavedAddress: _addSavedAddress,
          onSelectSavedAddress: _applySavedAddress,
          onEditSavedAddress: _editSavedAddress,
          onDeleteSavedAddress: _deleteSavedAddress,
        );
      case 2:
        return CheckoutPaymentStep(
          phoneController: _phoneController,
          phoneFromProfile: _phoneFromProfile,
          onUseDifferentNumber: () =>
              setState(() => _phoneFromProfile = false),
          promoController: _promoController,
          promoApplied: _promoApplied,
          applyingPromo: _applyingPromo,
          appliedPromoCode: _appliedPromoCode,
          promoError: _promoError,
          onApplyPromo: _applyPromoCode,
          onRemovePromo: _removePromoCode,
          paymentMethods: _checkoutPaymentMethods,
          selectedPaymentIndex: _selectedPayment,
          isPickup: _isPickup,
          primary: _primary,
          paymentMethodIcon: _paymentMethodIcon,
          onSelectPayment: (index) =>
              setState(() => _selectedPayment = index),
          items: _items,
          subtotal: _subtotal,
          shipping: _shipping,
          tax: _tax,
          discount: _discount,
          total: _grandTotal,
        );
      default:
        final paymentMethod = _checkoutPaymentMethods[_selectedPayment];
        final slot = _options.deliverySlots.isEmpty
            ? null
            : _options.deliverySlots[_selectedSlot];
        final pinnedLine = _selectedDeliveryLatLng == null
            ? null
            : 'Pinned: '
                  '${_selectedDeliveryLatLng!.latitude.toStringAsFixed(6)}, '
                  '${_selectedDeliveryLatLng!.longitude.toStringAsFixed(6)}';
        final slotLabel = slot?.label.trim();
        final deliveryNote = _deliveryNoteValue?.trim();
        final deliveryLines = _isPickup
            ? const ['Pickup from Store', 'Collect your order at the shop']
            : [
                _deliveryAddressLine,
                pinnedLine,
                (slotLabel?.isNotEmpty ?? false) ? slotLabel : null,
                (deliveryNote?.isNotEmpty ?? false) ? deliveryNote : null,
              ].whereType<String>().toList();

        return CheckoutConfirmStep(
          isPickup: _isPickup,
          paymentLabel: paymentMethod.label,
          deliveryLines: deliveryLines,
          subtotal: _subtotal,
          shipping: _shipping,
          tax: _tax,
          discount: _discount,
          total: _grandTotal,
          primary: _primary,
        );
    }
  }
}
