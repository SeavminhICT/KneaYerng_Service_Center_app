import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:khqr_sdk/khqr_sdk.dart';

import '../../models/cart_item.dart';
import '../../services/api_service.dart';
import '../../services/bakong_payment_service.dart';
import '../../services/cart_service.dart';
import '../Auth/login_screen.dart';

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
  static const Color _primary = Color(0xFF6366F1);
  static const Color _bg = Color(0xFFF3F4F6);

  final List<_CheckoutAddress> _addresses = [
    const _CheckoutAddress(
      tag: 'Home',
      name: 'John Anderson',
      phone: '+855 12 345 678',
      line: '1234 Oak Street, Apartment 5B, New York, NY 10001',
      note: 'Near Central Park Entrance',
    ),
    const _CheckoutAddress(
      tag: 'Office',
      name: 'Sarah Johnson',
      phone: '+855 93 123 456',
      line: '456 Business Ave, Suite 200, Phnom Penh',
      note: 'Next to Coffee Shop',
    ),
  ];

  final List<_DeliveryMethod> _deliveryMethods = const [
    _DeliveryMethod(
      code: 'delivery',
      title: 'Home Delivery',
      subtitle: 'Deliver to selected address',
    ),
    _DeliveryMethod(
      code: 'pickup',
      title: 'Store Pickup',
      subtitle: 'Pick up from nearest store',
    ),
  ];

  late final List<CartItem> _items;

  int _step = 0;
  int _selectedAddress = 0;
  int _selectedDeliveryMethod = 0;
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
  }

  Future<void> _loadCheckoutOptions() async {
    final loaded = await ApiService.fetchCheckoutOptions();
    if (!mounted) return;

    setState(() {
      _options = loaded;
      _loadingOptions = false;
      if (_selectedPayment >= _options.paymentMethods.length) {
        _selectedPayment = 0;
      }
      if (_selectedSlot >= _options.deliverySlots.length) {
        _selectedSlot = 0;
      }
    });
  }

  bool get _isPickup =>
      _deliveryMethods[_selectedDeliveryMethod].code == 'pickup';

  List<CheckoutPaymentMethod> get _checkoutPaymentMethods {
    final methods = List<CheckoutPaymentMethod>.from(_options.paymentMethods);
    final hasQr = methods.any((method) => method.code == 'aba_qr');
    if (!hasQr) {
      methods.insert(
        0,
        const CheckoutPaymentMethod(
          code: 'aba_qr',
          label: 'Bakong QR',
          description: 'Scan KHQR to pay for pickup order',
        ),
      );
    }
    return methods;
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
            'price': item.product.price,
          },
        )
        .toList();

    final selectedPaymentMethod =
        _checkoutPaymentMethods[_selectedPayment].code;
    final orderPaymentMethod = selectedPaymentMethod == 'aba_qr'
        ? 'aba'
        : selectedPaymentMethod;
    final selectedAddress = _addresses[_selectedAddress];
    final slot = _options.deliverySlots.isEmpty
        ? null
        : _options.deliverySlots[_selectedSlot].label;

    final result = await ApiService.createOrder(
      customerName: customerName,
      customerEmail: profile?.email,
      items: payload,
      orderType: _isPickup ? 'pickup' : 'delivery',
      paymentMethod: orderPaymentMethod,
      paymentStatus:
          (orderPaymentMethod == 'cash' || orderPaymentMethod == 'cod')
          ? 'unpaid'
          : 'processing',
      deliveryAddress: _isPickup ? null : selectedAddress.line,
      deliveryPhone: _isPickup ? null : selectedAddress.phone,
      deliveryNote: _isPickup ? null : slot,
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

      final sdkKhqr = BakongPaymentService.generateQr(
        amount: totalAmount,
        billNumber:
            '${result.orderId!}-${DateTime.now().millisecondsSinceEpoch}',
      );
      final sdkQr = sdkKhqr.data?.qr;
      final sdkMd5 = sdkKhqr.data?.md5Hash;
      if (sdkQr == null || sdkQr.isEmpty || sdkMd5 == null || sdkMd5.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              sdkKhqr.errorMessage ?? 'Unable to generate valid KHQR.',
            ),
          ),
        );
        return;
      }

      final generated = await ApiService.generateKhqr(
        orderId: result.orderId!,
        amount: totalAmount,
        currency: 'USD',
        requestTransactionId: sdkMd5,
        requestQrString: sdkQr,
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
        Navigator.of(context).pop(true);
      }
      return;
    }

    if (widget.fromCart) {
      CartService.instance.clear();
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

  @override
  Widget build(BuildContext context) {
    final steps = const ['Delivery', 'Address', 'Payment', 'Confirm'];

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
      ),
      body: _loadingOptions
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _StepHeader(
                  labels: steps,
                  currentStep: _step,
                  primary: _primary,
                ),
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
                  buttonText: _step == 3
                      ? (_placingOrder ? 'Placing Order...' : 'Place Order')
                      : _step == 0
                      ? (_isPickup
                            ? 'Continue to Payment'
                            : 'Continue to Address')
                      : _step == 1
                      ? 'Continue to Payment'
                      : 'Continue to Confirm',
                  onPressed: _placingOrder ? null : _continueStep,
                ),
              ],
            ),
    );
  }

  Widget _buildStepBody() {
    switch (_step) {
      case 0:
        return _buildDeliveryStep();
      case 1:
        return _buildAddressStep();
      case 2:
        return _buildPaymentStep();
      default:
        return _buildConfirmStep();
    }
  }

  Widget _buildAddressStep() {
    return ListView(
      key: const ValueKey(0),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      children: [
        const Text(
          'Delivery Address',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 10),
        ...List.generate(_addresses.length, (index) {
          final address = _addresses[index];
          final selected = _selectedAddress == index;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _AddressCard(
              address: address,
              selected: selected,
              onTap: () => setState(() => _selectedAddress = index),
              primary: _primary,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDeliveryStep() {
    return ListView(
      key: const ValueKey(1),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      children: [
        const Text(
          'Delivery Method',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 10),
        ...List.generate(_deliveryMethods.length, (index) {
          final method = _deliveryMethods[index];
          final selected = _selectedDeliveryMethod == index;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SelectCard(
              selected: selected,
              title: method.title,
              subtitle: method.subtitle,
              trailing: method.code == 'delivery'
                  ? '\$${_options.deliveryFee.toStringAsFixed(2)}'
                  : 'Free',
              onTap: () => setState(() => _selectedDeliveryMethod = index),
              primary: _primary,
            ),
          );
        }),
        if (!_isPickup) ...[
          const SizedBox(height: 10),
          const Text(
            'Preferred Delivery Time',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 10),
          ...List.generate(_options.deliverySlots.length, (index) {
            final slot = _options.deliverySlots[index];
            final selected = _selectedSlot == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SelectCard(
                selected: selected,
                title: slot.label,
                subtitle: slot.description,
                trailing: '',
                onTap: () => setState(() => _selectedSlot = index),
                primary: _primary,
              ),
            );
          }),
        ] else ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Row(
              children: [
                Icon(Icons.qr_code_2_rounded, color: Color(0xFF2563EB)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pickup orders continue to payment with QR option.',
                    style: TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentStep() {
    return ListView(
      key: const ValueKey(2),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      children: [
        _OrderItemsCard(items: _items),
        const SizedBox(height: 12),
        _SummaryCard(
          subtotal: _subtotal,
          shipping: _shipping,
          tax: _tax,
          discount: _discount,
          total: _grandTotal,
        ),
        const SizedBox(height: 12),
        const Text(
          'Payment Method',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 10),
        ...List.generate(_checkoutPaymentMethods.length, (index) {
          final method = _checkoutPaymentMethods[index];
          final selected = _selectedPayment == index;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SelectCard(
              selected: selected,
              title: method.label,
              subtitle: method.description,
              trailing: '',
              onTap: () => setState(() => _selectedPayment = index),
              primary: _primary,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildConfirmStep() {
    final address = _addresses[_selectedAddress];
    final deliveryMethod = _deliveryMethods[_selectedDeliveryMethod];
    final paymentMethod = _checkoutPaymentMethods[_selectedPayment];
    final slot = _options.deliverySlots[_selectedSlot];

    return ListView(
      key: const ValueKey(3),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      children: [
        _ConfirmCard(
          title: 'Shipping Address',
          lines: _isPickup
              ? ['Store Pickup (No address required)']
              : [
                  address.tag,
                  address.name,
                  address.phone,
                  address.line,
                  address.note,
                ],
        ),
        const SizedBox(height: 12),
        _ConfirmCard(
          title: 'Delivery',
          lines: [deliveryMethod.title, slot.label],
        ),
        const SizedBox(height: 12),
        _ConfirmCard(
          title: 'Payment',
          lines: [paymentMethod.label, paymentMethod.description],
        ),
        const SizedBox(height: 12),
        _SummaryCard(
          subtotal: _subtotal,
          shipping: _shipping,
          tax: _tax,
          discount: _discount,
          total: _grandTotal,
        ),
      ],
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.labels,
    required this.currentStep,
    required this.primary,
  });

  final List<String> labels;
  final int currentStep;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      color: Colors.white,
      child: Row(
        children: List.generate(labels.length, (index) {
          final active = index <= currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active ? primary : const Color(0xFFE5E7EB),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: active ? Colors.white : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
                if (index != labels.length - 1)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      height: 2,
                      color: index < currentStep
                          ? primary
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.selected,
    required this.onTap,
    required this.primary,
  });

  final _CheckoutAddress address;
  final bool selected;
  final VoidCallback onTap;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? primary : const Color(0xFFE5E7EB),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: selected
                    ? primary.withValues(alpha: 0.16)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                address.tag,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected ? primary : const Color(0xFF6B7280),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              address.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              address.phone,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 2),
            Text(address.line),
            const SizedBox(height: 2),
            Text(
              address.note,
              style: const TextStyle(color: Color(0xFF6B7280)),
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
  });

  final bool selected;
  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback onTap;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? primary : const Color(0xFFE5E7EB),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  trailing,
                  style: TextStyle(
                    color: trailing.toLowerCase() == 'free'
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF111827),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? primary : const Color(0xFFD1D5DB),
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
                'Order Items',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                '${items.length} items',
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${item.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
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
  });

  final double subtotal;
  final double shipping;
  final double tax;
  final double discount;
  final double total;

  @override
  Widget build(BuildContext context) {
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
          const Text(
            'Payment Summary',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Subtotal', value: subtotal),
          _SummaryRow(label: 'Shipping Fee', value: shipping),
          _SummaryRow(label: 'Tax', value: tax),
          if (discount > 0)
            _SummaryRow(
              label: 'Discount',
              value: -discount,
              color: const Color(0xFF16A34A),
            ),
          const Divider(height: 20),
          _SummaryRow(
            label: 'Grand Total',
            value: total,
            bold: true,
            color: const Color(0xFF4F46E5),
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
              color: bold ? const Color(0xFF111827) : const Color(0xFF6B7280),
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value < 0
                ? '-\$${value.abs().toStringAsFixed(2)}'
                : '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              color: color ?? const Color(0xFF111827),
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              fontSize: bold ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmCard extends StatelessWidget {
  const _ConfirmCard({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...lines
              .where((line) => line.trim().isNotEmpty)
              .map(
                (line) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    line,
                    style: const TextStyle(color: Color(0xFF374151)),
                  ),
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
  });

  final double total;
  final String buttonText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KhqrPaymentSheet extends StatefulWidget {
  const _KhqrPaymentSheet({
    required this.amount,
    required this.transactionId,
    required this.qrString,
    this.expiresAtIso,
  });

  final double amount;
  final String transactionId;
  final String qrString;
  final String? expiresAtIso;

  @override
  State<_KhqrPaymentSheet> createState() => _KhqrPaymentSheetState();
}

class _KhqrPaymentSheetState extends State<_KhqrPaymentSheet> {
  static const Duration _checkInterval = Duration(seconds: 5);
  static const int _maxCheckAttempts = 20;

  bool _isChecking = false;
  bool _isSuccess = false;
  bool _isScanned = false;
  bool _isTerminalFailure = false;
  bool _autoCheckStopped = false;
  int _checkAttempts = 0;
  String? _lastStatus;
  String? _statusMessage;
  DateTime? _expiresAt;
  Timer? _checkTimer;

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

  @override
  void initState() {
    super.initState();
    _expiresAt = _parseExpiresAt(widget.expiresAtIso);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startChecking();
      }
    });
  }

  @override
  void dispose() {
    _stopChecking();
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

  bool get _isExpired {
    final expiresAt = _expiresAt;
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt);
  }

  String get _expiresCountdown {
    final expiresAt = _expiresAt;
    if (expiresAt == null) return '--:--';
    final remaining = expiresAt.difference(DateTime.now());
    if (remaining.isNegative) return '00:00';
    final minutes = remaining.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = remaining.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _markScanned() {
    if (_isChecking || _isSuccess || _isTerminalFailure) return;
    _logKhqrEvent(event: 'SCAN', status: 'SCANNED');
    setState(() {
      _isScanned = true;
      _statusMessage = 'Waiting for payment confirmation...';
    });
    _startChecking();
  }

  void _startChecking() {
    _stopChecking();
    _autoCheckStopped = false;
    _checkAttempts = 0;
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

  Future<void> _checkStatus({bool fromTimer = false}) async {
    if (_isChecking || _isSuccess || _isTerminalFailure || _autoCheckStopped) {
      return;
    }
    if (_checkAttempts >= _maxCheckAttempts) {
      _stopChecking();
      if (mounted) {
        setState(() {
          _autoCheckStopped = true;
          _statusMessage =
              'Payment still pending. Auto-check stopped. Please check later.';
        });
      }
      return;
    }
    if (_isExpired) {
      if (mounted) {
        setState(() {
          _isTerminalFailure = true;
          _statusMessage = 'Payment failed: QR expired.';
        });
      }
      _stopChecking();
      return;
    }

    setState(() {
      _isChecking = true;
      _statusMessage = null;
    });
    _checkAttempts += 1;

    final result = await ApiService.checkKhqrTransaction(
      transactionId: widget.transactionId,
    );

    if (!mounted) return;
    setState(() {
      _isChecking = false;
      _statusMessage = result.message ?? result.status;
    });
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
      setState(() {
        _isSuccess = true;
        _statusMessage = 'Payment successful';
      });
      return;
    }

    if (_isFailureStatus(result.status)) {
      _stopChecking();
      if (!mounted) return;
      setState(() {
        _isTerminalFailure = true;
        _statusMessage = 'Payment failed';
      });
      return;
    }

    if (normalizedStatus == 'NOT_FOUND') {
      if (_isExpired) {
        _stopChecking();
        if (!mounted) return;
        setState(() {
          _isTerminalFailure = true;
          _statusMessage =
              'Payment failed: transaction not found before expiry.';
        });
      } else if (fromTimer && mounted) {
        setState(() {
          _statusMessage = 'Waiting for payment confirmation...';
        });
      }
    }
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
                      'ABA KHQR',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Color(0xFF22D3EE)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _expiresCountdown,
                        style: const TextStyle(
                          color: Color(0xFF334155),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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
                      colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.qr_code_2_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'KHQR PAYMENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
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
                        _qrMetaRow('Merchant', 'YUDDHO SEAVMINH'),
                        const SizedBox(height: 6),
                        _qrMetaRow(
                          'Amount',
                          '\$${widget.amount.toStringAsFixed(2)} USD',
                        ),
                        const SizedBox(height: 6),
                        _qrMetaRow(
                          'Order',
                          '#${widget.transactionId.substring(0, 8)}',
                        ),
                        const SizedBox(height: 6),
                        _qrMetaRow('Expires In', _expiresCountdown),
                      ],
                    ),
                  ),
                ),
                KhqrCardWidget(
                  width: 240,
                  qr: widget.qrString,
                  receiverName: 'KneaYerng Service Center',
                  amount: widget.amount,
                  currency: KhqrCurrency.usd,
                  duration: const Duration(minutes: 5),
                  isLoading: false,
                  isError: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Scan with mobile banking app\nthat supports KHQR',
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
      return SizedBox(
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
      );
    }

    return const SizedBox.shrink();
  }
}

class _CheckoutAddress {
  const _CheckoutAddress({
    required this.tag,
    required this.name,
    required this.phone,
    required this.line,
    required this.note,
  });

  final String tag;
  final String name;
  final String phone;
  final String line;
  final String note;
}

class _DeliveryMethod {
  const _DeliveryMethod({
    required this.code,
    required this.title,
    required this.subtitle,
  });

  final String code;
  final String title;
  final String subtitle;
}
