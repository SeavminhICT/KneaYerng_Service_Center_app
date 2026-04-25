import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khqr_sdk/khqr_sdk.dart';
import 'package:latlong2/latlong.dart';

import '../../models/pickup_ticket.dart';
import '../../models/user_profile.dart';
import '../../services/api_service.dart' as api;
import '../../services/bakong_payment_service.dart';
import '../../services/cart_service.dart';
import '../Auth/login_screen.dart';
import '../main_navigation_screen.dart';
import 'delivery_location_picker.dart';

class BakongCheckoutSheet extends StatefulWidget {
  const BakongCheckoutSheet({super.key, required this.total, this.voucherCode});

  final double total;
  final String? voucherCode;

  @override
  State<BakongCheckoutSheet> createState() => _BakongCheckoutSheetState();
}

class _BakongCheckoutSheetState extends State<BakongCheckoutSheet> {
  BakongQrData? _khqrData;
  bool _isLoading = true;
  bool _isError = false;
  String? _errorMessage;
  bool _isChecking = false;
  bool _isSuccess = false;
  bool _isTerminalFailure = false;
  String? _statusMessage;
  String _billNumber = '';
  String? _orderNumber;
  int? _orderId;
  double? _amount;
  String _orderType = 'pickup';
  LatLng? _deliveryLatLng;
  String? _transactionId;
  DateTime? _expiresAt;
  Timer? _checkTimer;
  int _checkAttempts = 0;
  int _maxCheckAttempts = 200;
  bool _isOpeningTicket = false;
  bool _didAutoOpenTicket = false;

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
    _stopChecking();
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
    _stopChecking();
    setState(() {
      _isLoading = true;
      _isError = false;
      _errorMessage = null;
      _khqrData = null;
      _transactionId = null;
      _expiresAt = null;
      _isSuccess = false;
      _isTerminalFailure = false;
      _statusMessage = null;
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

    final generated = await api.ApiService.generateKhqr(
      orderId: _orderId!,
      amount: amountForQr,
      currency: 'USD',
    );

    if (!generated.isSuccess) {
      if (!mounted || _orderType != currentOrderType) return;
      setState(() {
        _isError = true;
        _errorMessage = generated.errorMessage ?? 'Unable to generate KHQR.';
        _isLoading = false;
      });
      return;
    }

    if (!mounted || _orderType != currentOrderType) return;
    setState(() {
      _khqrData = BakongQrData(
        qr: generated.qrString!,
        md5Hash: generated.transactionId!,
      );
      _transactionId = generated.transactionId;
      _expiresAt = _parseExpiresAt(generated.expiresAt);
      _isLoading = false;
      _statusMessage = 'Waiting for payment confirmation...';
    });
    _startChecking();
  }

  double _resolveAmount() {
    if (widget.total > 0) {
      return widget.total;
    }
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
            'price': item.product.salePrice,
          },
        )
        .toList();

    return api.ApiService.createOrder(
      customerName: customerName,
      customerEmail: customerEmail,
      items: payload,
      paymentMethod: 'aba',
      paymentStatus: 'processing',
      orderType: orderType,
      deliveryAddress: deliveryAddress,
      deliveryPhone: deliveryPhone,
      deliveryNote: _appendCoordinates(deliveryNote, deliveryLatLng),
      deliveryLat: deliveryLatLng?.latitude,
      deliveryLng: deliveryLatLng?.longitude,
      voucherCode: widget.voucherCode,
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

    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));

    final refreshed = await api.ApiService.getToken();
    return refreshed != null && refreshed.isNotEmpty;
  }

  void _handleOrderTypeChange(String nextType) {
    if (_orderType == nextType) return;
    _stopChecking();
    setState(() {
      _orderType = nextType;
      _isError = false;
      _errorMessage = null;
      _khqrData = null;
      _transactionId = null;
      _expiresAt = null;
      _isSuccess = false;
      _isTerminalFailure = false;
      _statusMessage = null;
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

  int _deriveMaxAttempts() {
    final expiresAt = _expiresAt;
    if (expiresAt == null) return 200;
    final remaining = expiresAt.difference(DateTime.now()).inSeconds;
    if (remaining <= 0) return 1;
    final attempts = (remaining / 3).ceil() + 2;
    if (attempts < 10) return 10;
    if (attempts > 400) return 400;
    return attempts;
  }

  void _startChecking() {
    _stopChecking();
    _checkAttempts = 0;
    _maxCheckAttempts = _deriveMaxAttempts();
    if (mounted) {
      _setStatusMessage('Waiting for payment confirmation...');
    }
    _checkStatus(fromTimer: true);
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (_) {
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

  void _setStatusMessage(String? message) {
    if (!mounted || _statusMessage == message) return;
    setState(() {
      _statusMessage = message;
    });
  }

  Future<void> _checkStatus({bool fromTimer = false}) async {
    if (_isChecking || _isSuccess || _isTerminalFailure) return;
    if (_checkAttempts >= _maxCheckAttempts) {
      _stopChecking();
      if (mounted) {
        setState(() {
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

    final transactionId = _transactionId;
    if (transactionId == null || transactionId.isEmpty) return;

    _isChecking = true;
    _checkAttempts += 1;

    final result = await api.ApiService.checkKhqrTransaction(
      transactionId: transactionId,
    );

    if (!mounted) return;
    _isChecking = false;

    final normalizedStatus = result.status.toUpperCase();
    if (normalizedStatus == 'SUCCESS') {
      _stopChecking();
      setState(() {
        _isSuccess = true;
        _statusMessage = 'Payment confirmed.';
      });
      CartService.instance.clear();
      _handlePaymentSuccess();
      return;
    }

    if ([
      'FAILED',
      'EXPIRED',
      'TIMEOUT',
      'INVALID_TRANSACTION',
    ].contains(normalizedStatus)) {
      _stopChecking();
      if (!mounted) return;
      setState(() {
        _isTerminalFailure = true;
        _statusMessage =
            normalizedStatus == 'EXPIRED' || normalizedStatus == 'TIMEOUT'
            ? 'QR expired. Please generate a new one.'
            : 'Payment failed. Please try again.';
      });
      return;
    }

    if (normalizedStatus == 'NOT_FOUND') {
      if (_isExpired) {
        _stopChecking();
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

  Future<void> _handlePaymentSuccess() async {
    if (_orderType != 'pickup' || _didAutoOpenTicket) return;
    _didAutoOpenTicket = true;
    await _openTicketDetail(showFeedback: false);
  }

  Future<void> _openTicketDetail({bool showFeedback = true}) async {
    if (_isOpeningTicket || _orderType != 'pickup') return;

    setState(() {
      _isOpeningTicket = true;
    });

    final match = await _findMatchingTicket();
    if (!mounted) return;

    if (!mounted) return;
    setState(() {
      _isOpeningTicket = false;
    });

    if (match == null) {
      if (showFeedback) {
        _showSnackBar(
          'Ticket is being generated. Please try again in a moment.',
        );
      }
      return;
    }

    await Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) =>
            MainNavigationScreen(initialIndex: 0, initialPickupTicket: match),
      ),
      (_) => false,
    );
  }

  Future<PickupTicket?> _findMatchingTicket() async {
    final orderId = _orderId;
    if (orderId == null) return null;

    for (var attempt = 0; attempt < 5; attempt++) {
      final tickets = await api.ApiService.fetchPickupTickets();
      for (final ticket in tickets) {
        if (ticket.orderId == orderId) {
          return ticket;
        }
        if (_orderNumber != null &&
            _orderNumber!.isNotEmpty &&
            ticket.orderNumber == _orderNumber) {
          return ticket;
        }
      }
      if (attempt < 4) {
        await Future<void>.delayed(const Duration(milliseconds: 800));
      }
    }
    return null;
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _copyKhqr() async {
    final qr = _khqrData?.qr;
    if (qr == null || qr.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: qr));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('KHQR copied to clipboard')));
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
    final duration = _expiresAt == null
        ? config.qrExpiry
        : _expiresAt!.difference(DateTime.now());
    final statusText = _isSuccess
        ? 'Payment confirmed.'
        : (_isTerminalFailure
              ? (_statusMessage ?? 'Payment failed. Please try again.')
              : (_statusMessage ?? 'Waiting for payment confirmation...'));
    final statusColor = _isSuccess
        ? const Color(0xFF16A34A)
        : (_isTerminalFailure
              ? const Color(0xFFDC2626)
              : const Color(0xFF6B7280));
    final showQrCard =
        _orderType == 'pickup' || _isLoading || _isError || _khqrData != null;

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
                'Bakong KHQR Payment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Scan the KHQR with Bakong or any supported banking app.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    if (!_isSuccess && !_isTerminalFailure)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    if (!_isSuccess && !_isTerminalFailure)
                      const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (_expiresAt != null)
                      Text(
                        _expiresCountdown,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
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
                      duration: duration.isNegative ? Duration.zero : duration,
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
                      _InfoRow(label: 'Order ID', value: _orderId.toString()),
                    _InfoRow(
                      label: 'Bill No.',
                      value: _billNumber.isEmpty ? '-' : _billNumber,
                    ),
                    _InfoRow(
                      label: 'Reference',
                      value: _khqrData?.md5Hash ?? '-',
                      valueStyle: const TextStyle(fontSize: 11),
                    ),
                    if (_expiresAt != null)
                      _InfoRow(label: 'Expires In', value: _expiresCountdown),
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
                      child: const Text('Copy Reference'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_isSuccess && _orderType == 'pickup') ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isOpeningTicket ? null : _openTicketDetail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isOpeningTicket ? 'Opening ticket...' : 'View Ticket',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_isSuccess && _orderId != null) {
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
        backgroundColor: isSelected ? const Color(0xFF0F6BFF) : Colors.white,
        foregroundColor: isSelected ? Colors.white : const Color(0xFF111827),
        side: BorderSide(
          color: isSelected ? const Color(0xFF0F6BFF) : const Color(0xFFE5E7EB),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueStyle});

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
              style:
                  valueStyle ??
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
