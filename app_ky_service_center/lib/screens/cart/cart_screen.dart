import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/cart_item.dart';
import '../../services/api_service.dart';
import '../../services/cart_service.dart';
import '../../widgets/auth_guard.dart';
import '../../widgets/page_transitions.dart';
import 'checkout_flow_screen.dart';

Map<String, String>? get _imageHeaders => null;

const _pageBg = Color(0xFFF3F7FF);
const _surface = Color(0xFFFFFFFF);
const _surfaceSoft = Color(0xFFF8FBFF);
const _border = Color(0xFFD7E3F4);
const _ink = Color(0xFF1F2D4D);
const _muted = Color(0xFF6D7C99);
const _primaryDeep = Color(0xFF5379C9);
const _primarySoft = Color(0xFFE7EEFF);
const _accent = Color(0xFFFFF4E6);
const _danger = Color(0xFFD8607A);
const _success = Color(0xFF2D8E68);
const _shadow = Color(0x14243B6A);

String _currency(double value) => '\$${value.toStringAsFixed(2)}';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

enum _ApplyState { idle, applying, successCheck, applied }

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
  final TextEditingController _promoController = TextEditingController();
  VoucherValidation? _voucher;
  bool _isApplying = false;
  _ApplyState _applyState = _ApplyState.idle;
  bool _promoExpanded = true;
  bool _showAppliedChip = false;
  String? _promoError;
  bool _isRecheckingVoucher = false;
  Timer? _recheckTimer;
  Timer? _applySuccessTimer;
  Timer? _applyChipTimer;

  late final AnimationController _promoExpandController;
  late final Animation<double> _promoExpand;
  late final Animation<double> _chevronTurns;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeOffset;

  @override
  void initState() {
    super.initState();
    _promoExpandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _promoExpand = CurvedAnimation(
      parent: _promoExpandController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _chevronTurns = Tween<double>(begin: 0, end: 0.5).animate(_promoExpand);
    if (_promoExpanded) {
      _promoExpandController.value = 1;
    }

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _shakeOffset = TweenSequence<double>(
      [
        TweenSequenceItem(tween: Tween(begin: 0, end: -6), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 6, end: -4), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -4, end: 4), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 4, end: 0), weight: 1),
      ],
    ).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));

    CartService.instance.addListener(_handleCartChanged);
  }

  @override
  void dispose() {
    CartService.instance.removeListener(_handleCartChanged);
    _recheckTimer?.cancel();
    _applySuccessTimer?.cancel();
    _applyChipTimer?.cancel();
    _promoExpandController.dispose();
    _shakeController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _openCheckoutFlow() async {
    final ok = await ensureLoggedIn(
      context,
      message: 'Please login or register to proceed to checkout.',
    );
    if (!ok) return;
    if (!mounted) return;
    final discount = _voucher?.discountFor(CartService.instance.subtotal) ?? 0;
    await Navigator.of(context).push(
      fadeSlideRoute(
        CheckoutFlowScreen(
          items: CartService.instance.items,
          voucherCode: _voucher?.code,
          initialDiscount: discount,
          fromCart: true,
        ),
      ),
    );
  }

  void _togglePromoExpanded() {
    setState(() {
      _promoExpanded = !_promoExpanded;
      _promoError = null;
    });
    if (_promoExpanded) {
      _promoExpandController.forward();
    } else {
      _promoExpandController.reverse();
    }
  }

  void _startShake() {
    if (_shakeController.isAnimating) return;
    _shakeController.forward(from: 0);
  }

  bool _shouldShakeForMessage(String? message) {
    final lower = message?.toLowerCase() ?? '';
    return lower.contains('invalid') || lower.contains('expired');
  }

  void _setPromoError(String message, {bool shake = false}) {
    setState(() {
      if (!_promoExpanded) {
        _promoExpanded = true;
      }
      _promoError = message;
    });
    if (_promoExpanded) {
      _promoExpandController.forward();
    }
    if (shake) {
      _startShake();
    }
  }

  void _handleCartChanged() {
    if (_voucher == null || _isApplying) return;
    _recheckTimer?.cancel();
    _recheckTimer = Timer(const Duration(milliseconds: 220), () {
      final subtotal = CartService.instance.subtotal;
      _revalidateVoucher(subtotal);
    });
  }

  Future<void> _revalidateVoucher(double subtotal) async {
    final currentCode = _voucher?.code ?? _promoController.text.trim();
    if (currentCode.isEmpty) return;
    if (_isApplying) return;

    setState(() {
      _isRecheckingVoucher = true;
      _promoError = null;
    });

    VoucherValidation result;
    try {
      result = await ApiService.validateVoucher(
        code: currentCode,
        subtotal: subtotal,
      );
    } catch (_) {
      result = const VoucherValidation(
        isValid: false,
        message: 'Unable to validate the promo code.',
      );
    }

    if (!mounted) return;

    if (!result.isValid) {
      final message = result.message ?? 'Promo code is no longer valid.';
      _applySuccessTimer?.cancel();
      _applyChipTimer?.cancel();
      setState(() {
        _isRecheckingVoucher = false;
        _voucher = null;
        _showAppliedChip = false;
        _applyState = _ApplyState.idle;
        _promoError = message;
        _promoExpanded = true;
        _promoController.text = currentCode;
      });
      _promoExpandController.forward();
      return;
    }

    setState(() {
      _isRecheckingVoucher = false;
      _voucher = result;
      _promoController.text = result.code ?? currentCode;
    });
  }

  Future<void> _applyVoucher(double subtotal) async {
    _applySuccessTimer?.cancel();
    _applyChipTimer?.cancel();
    _recheckTimer?.cancel();
    if (subtotal <= 0) {
      _setPromoError('Add items to the cart before applying a promo code.');
      return;
    }
    final code = _promoController.text.trim();
    if (code.isEmpty) {
      _setPromoError('Please enter a promo code.', shake: true);
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      _isApplying = true;
      _applyState = _ApplyState.applying;
      _promoError = null;
      _showAppliedChip = false;
      _isRecheckingVoucher = false;
    });

    VoucherValidation result;
    try {
      result = await ApiService.validateVoucher(code: code, subtotal: subtotal);
    } catch (_) {
      result = const VoucherValidation(
        isValid: false,
        message: 'Unable to validate the promo code.',
      );
    }
    if (!mounted) return;

    if (!result.isValid) {
      final message = result.message ?? 'Promo code is not valid.';
      if (_shouldShakeForMessage(message)) {
        _startShake();
      }
      HapticFeedback.heavyImpact();
      setState(() {
        _isApplying = false;
        _applyState = _ApplyState.idle;
        _voucher = null;
        _promoError = message;
        _promoController.text = code;
        _showAppliedChip = false;
      });
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _isApplying = false;
      _applyState = _ApplyState.successCheck;
      _voucher = result;
      _promoController.text = result.code ?? code;
      _promoError = null;
    });

    _applySuccessTimer?.cancel();
    _applySuccessTimer = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      setState(() {
        _applyState = _ApplyState.applied;
      });
    });
    _applyChipTimer?.cancel();
    _applyChipTimer = Timer(const Duration(milliseconds: 380), () {
      if (!mounted) return;
      setState(() {
        _showAppliedChip = true;
      });
    });
  }

  void _removeVoucher({String? message}) {
    _applySuccessTimer?.cancel();
    _applyChipTimer?.cancel();
    final code = _voucher?.code ?? _promoController.text.trim();
    setState(() {
      _voucher = null;
      _showAppliedChip = false;
      _applyState = _ApplyState.idle;
      _promoError = message;
      _promoController.text = code;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: CartService.instance,
      builder: (context, _) {
        final items = CartService.instance.items;
        final subtotal = CartService.instance.subtotal;
        final totalItems = CartService.instance.totalItems;
        final shipping = 0.0;
        final tax = 0.0;
        final discount = _voucher?.discountFor(subtotal) ?? 0.0;
        final total = (subtotal + shipping + tax - discount).clamp(0, 9999999);
        return Theme(
          data: theme.copyWith(
            textTheme: GoogleFonts.interTextTheme(theme.textTheme),
          ),
          child: Scaffold(
            backgroundColor: _pageBg,
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                    child: _CartHeader(
                      totalItems: totalItems,
                      onBack: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                  Expanded(
                    child: items.isEmpty
                        ? _EmptyCart(
                            onContinueShopping: () =>
                                Navigator.of(context).maybePop(),
                          )
                        : ListView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                            children: [
                              _CartMetaRow(
                                totalItems: totalItems,
                                subtotal: subtotal,
                              ),
                              const SizedBox(height: 14),
                              for (var index = 0; index < items.length; index++)
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: index == items.length - 1 ? 0 : 10,
                                  ),
                                  child: _CartItemCard(
                                    item: items[index],
                                    onRemove: () => CartService.instance.remove(
                                      items[index],
                                    ),
                                    onQuantityChanged: (value) => CartService
                                        .instance
                                        .updateQuantity(items[index], value),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              _PromoCodeCard(
                                controller: _promoController,
                                isApplying: _isApplying,
                                applyState: _applyState,
                                appliedCode: _voucher?.code,
                                discount: discount,
                                errorText: _promoError,
                                onCodeChanged: (_) {
                                  if (_promoError != null) {
                                    setState(() => _promoError = null);
                                  }
                                },
                                expandAnimation: _promoExpand,
                                chevronTurns: _chevronTurns,
                                shakeOffset: _shakeOffset,
                                showChip: _showAppliedChip,
                                isRechecking: _isRecheckingVoucher,
                                onToggleExpanded: _togglePromoExpanded,
                                onApply: () => _applyVoucher(subtotal),
                                onRemove: () => _removeVoucher(),
                              ),
                              const SizedBox(height: 16),
                              _OrderSummary(
                                subtotal: subtotal,
                                shipping: shipping,
                                tax: tax,
                                discount: discount,
                                total: total.toDouble(),
                              ),
                              const SizedBox(height: 112),
                            ],
                          ),
                  ),
                  if (items.isNotEmpty)
                    _CheckoutBar(
                      total: total.toDouble(),
                      itemCount: totalItems,
                      onCheckout: _openCheckoutFlow,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader({required this.totalItems, required this.onBack});

  final int totalItems;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconBtn(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: onBack,
          circular: true,
          iconSize: 18,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Cart',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                totalItems == 0
                    ? 'Review items before checkout'
                    : totalItems == 1
                    ? '1 item ready for checkout'
                    : '$totalItems items ready for checkout',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: _muted,
                ),
              ),
            ],
          ),
        ),
        if (totalItems > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: Text(
              '$totalItems',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: _primaryDeep,
              ),
            ),
          ),
      ],
    );
  }
}

class _CartMetaRow extends StatelessWidget {
  const _CartMetaRow({required this.totalItems, required this.subtotal});

  final int totalItems;
  final double subtotal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _muted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalItems == 1 ? '1 product' : '$totalItems products',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 34, color: _border),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _muted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _currency(subtotal),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                  height: 1,
                ),
              ),
            ],
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
          color: _surface,
          shape: circular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circular ? null : BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Icon(icon, color: _ink, size: iconSize),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  final CartItem item;
  final VoidCallback onRemove;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final imageUrl = product.imageUrl;
    final variant = item.variant?.trim().isNotEmpty == true
        ? item.variant!.trim()
        : '';
    final unitPrice = product.salePrice;
    final oldPrice = product.hasDiscount && product.price > unitPrice
        ? product.price
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 380;
        final imageSize = compact ? 72.0 : 80.0;

        return Container(
          padding: EdgeInsets.all(compact ? 13 : 15),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: imageSize,
                    height: imageSize,
                    decoration: BoxDecoration(
                      color: _surfaceSoft,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _border),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: imageUrl == null || imageUrl.isEmpty
                          ? const _ImageFallback(size: 22)
                          : Padding(
                              padding: const EdgeInsets.all(8),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                                alignment: Alignment.center,
                                headers: _imageHeaders,
                                errorBuilder: (_, _, _) =>
                                    const _ImageFallback(size: 22),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: compact ? 15 : 16,
                                  fontWeight: FontWeight.w600,
                                  color: _ink,
                                  height: 1.18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            _MiniIconButton(
                              icon: Icons.close_rounded,
                              onTap: onRemove,
                            ),
                          ],
                        ),
                        if (variant.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            variant,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: _muted,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              _currency(unitPrice),
                              style: TextStyle(
                                fontSize: compact ? 15 : 16,
                                fontWeight: FontWeight.w800,
                                color: product.hasDiscount ? _danger : _ink,
                              ),
                            ),
                            if (oldPrice != null)
                              Text(
                                _currency(oldPrice),
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: _muted,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            const Text(
                              'Each',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: _muted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: compact ? 10 : 12),
              Row(
                children: [
                  _QtyStepper(value: item.quantity, onChanged: onQuantityChanged),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: _muted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _currency(item.subtotal),
                        style: GoogleFonts.poppins(
                          fontSize: compact ? 18 : 19,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, _primarySoft],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove_rounded,
            onTap: value > 1 ? () => onChanged(value - 1) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$value',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _ink,
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            onTap: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? _primaryDeep : _muted.withAlpha(130),
        ),
      ),
    );
  }
}

class _MiniIconButton extends StatelessWidget {
  const _MiniIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: _surfaceSoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Icon(icon, size: 16, color: _muted),
      ),
    );
  }
}

class _PromoCodeCard extends StatelessWidget {
  const _PromoCodeCard({
    required this.controller,
    required this.isApplying,
    required this.applyState,
    required this.onApply,
    required this.onRemove,
    required this.appliedCode,
    required this.discount,
    required this.errorText,
    required this.onCodeChanged,
    required this.expandAnimation,
    required this.chevronTurns,
    required this.shakeOffset,
    required this.showChip,
    required this.isRechecking,
    required this.onToggleExpanded,
  });

  final TextEditingController controller;
  final bool isApplying;
  final _ApplyState applyState;
  final VoidCallback onApply;
  final VoidCallback onRemove;
  final String? appliedCode;
  final double discount;
  final String? errorText;
  final ValueChanged<String> onCodeChanged;
  final Animation<double> expandAnimation;
  final Animation<double> chevronTurns;
  final Animation<double> shakeOffset;
  final bool showChip;
  final bool isRechecking;
  final VoidCallback onToggleExpanded;

  bool get _inputEnabled => !isApplying && applyState == _ApplyState.idle;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final applyButtonEnabled = _inputEnabled;
    final showChipView = showChip && (appliedCode?.isNotEmpty ?? false);

    Widget buildApplyChild() {
      switch (applyState) {
        case _ApplyState.applying:
          return Row(
            key: const ValueKey('applying'),
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 8),
              Text('Applying...'),
            ],
          );
        case _ApplyState.successCheck:
          return const Icon(Icons.check_circle_rounded, key: ValueKey('check'));
        case _ApplyState.applied:
          return const Text('Applied', key: ValueKey('applied'));
        case _ApplyState.idle:
          return const Text('Apply', key: ValueKey('apply'));
      }
    }

    Widget buildInputArea() {
      return Column(
        key: const ValueKey('input'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: shakeOffset,
            builder: (context, child) => Transform.translate(
              offset: Offset(shakeOffset.value, 0),
              child: child,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: _inputEnabled,
                    onChanged: onCodeChanged,
                    textInputAction: TextInputAction.done,
                    onSubmitted: applyButtonEnabled ? (_) => onApply() : null,
                    decoration: InputDecoration(
                      hintText: 'Enter promo code',
                      hintStyle: const TextStyle(
                        color: _muted,
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: _surfaceSoft,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: hasError ? _danger : _border,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: hasError ? _danger : _border,
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: _border),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: applyButtonEnabled ? onApply : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryDeep,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _primaryDeep.withAlpha(120),
                    disabledForegroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.7,
                          end: 1.0,
                        ).animate(animation),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: buildApplyChild(),
                  ),
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.12),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: hasError
                ? Padding(
                    key: const ValueKey('error'),
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      errorText ?? '',
                      style: const TextStyle(
                        color: _danger,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : const SizedBox(key: ValueKey('error-empty')),
          ),
          const SizedBox(height: 10),
          const Text(
            'Codes are checked instantly against your current cart subtotal.',
            style: TextStyle(fontSize: 12, height: 1.4, color: _muted),
          ),
        ],
      );
    }

    Widget buildChip() {
      final code = appliedCode ?? '';

      return Container(
        key: const ValueKey('chip'),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFE9F7EE)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFCAE8D7)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFCAE8D7)),
              ),
              child: const Icon(
                Icons.verified_rounded,
                color: _success,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    discount > 0
                        ? 'Voucher applied. You saved ${_currency(discount)}.'
                        : 'Voucher applied to this order.',
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      color: _muted,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onRemove,
              style: TextButton.styleFrom(
                foregroundColor: _ink,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              child: const Text('Remove'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
      ),
      child: AnimatedBuilder(
        animation: expandAnimation,
        builder: (context, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: onToggleExpanded,
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _primarySoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.confirmation_number_outlined,
                        size: 20,
                        color: _primaryDeep,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Promo code',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _ink,
                            ),
                          ),
                          if (!showChipView)
                            const Text(
                              'Optional',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _muted,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (isRechecking)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _surfaceSoft,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: _border),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _primaryDeep,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Updating',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _muted,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (showChipView)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9F7EE),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFCAE8D7)),
                        ),
                        child: Text(
                          'Applied',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _success,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    RotationTransition(
                      turns: chevronTurns,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _surfaceSoft,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _border),
                        ),
                        child: const Icon(
                          Icons.expand_more_rounded,
                          size: 20,
                          color: _ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizeTransition(
                sizeFactor: expandAnimation,
                axisAlignment: -1,
                child: FadeTransition(
                  opacity: expandAnimation,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      alignment: Alignment.topCenter,
                      clipBehavior: Clip.none,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(
                                begin: 0.96,
                                end: 1.0,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: showChipView ? buildChip() : buildInputArea(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OrderSummary extends StatefulWidget {
  const _OrderSummary({
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
  State<_OrderSummary> createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<_OrderSummary>
    with SingleTickerProviderStateMixin {
  late final AnimationController _totalController;
  late Animation<double> _totalAnimation;

  @override
  void initState() {
    super.initState();
    _totalController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _totalAnimation = AlwaysStoppedAnimation(widget.total);
  }

  @override
  void didUpdateWidget(covariant _OrderSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.total != widget.total) {
      final begin = _totalAnimation.value;
      _totalAnimation = Tween<double>(begin: begin, end: widget.total).animate(
        CurvedAnimation(parent: _totalController, curve: Curves.easeOut),
      );
      _totalController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _totalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      _SummaryRow(label: 'Subtotal', value: widget.subtotal),
      _SummaryRow(
        label: 'Shipping',
        value: widget.shipping,
        displayText: widget.shipping == 0 ? 'Free' : null,
        valueColor: widget.shipping == 0 ? _success : null,
      ),
      if (widget.tax > 0) _SummaryRow(label: 'Tax', value: widget.tax),
      if (widget.discount > 0)
        _SummaryRow(
          key: const ValueKey('discount'),
          label: 'Discount',
          value: -widget.discount,
          valueColor: _success,
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order summary',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: _ink,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Column(
              key: ValueKey('${widget.tax}_${widget.discount}'),
              children: rows,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: _border),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: _surfaceSoft,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _border),
            ),
            child: AnimatedBuilder(
              animation: _totalController,
              builder: (context, _) {
                final displayTotal = _totalController.isAnimating
                    ? _totalAnimation.value
                    : widget.total;
                return Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Total due',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _muted,
                        ),
                      ),
                    ),
                    Text(
                      _currency(displayTotal),
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                        height: 1,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.displayText,
  });

  final String label;
  final double value;
  final Color? valueColor;
  final String? displayText;

  @override
  Widget build(BuildContext context) {
    final text =
        displayText ??
        (value < 0 ? '-${_currency(value.abs())}' : _currency(value));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _muted,
            ),
          ),
          const Spacer(),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: valueColor ?? _ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({
    required this.total,
    required this.itemCount,
    required this.onCheckout,
  });

  final double total;
  final int itemCount;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: const Border(top: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _surfaceSoft,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total due',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _muted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currency(total),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    itemCount == 1 ? '1 item' : '$itemCount items',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 72,
              child: ElevatedButton(
                onPressed: onCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryDeep,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Proceed to checkout',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onContinueShopping});

  final VoidCallback onContinueShopping;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _surface.withAlpha(244),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: _border),
              boxShadow: const [
                BoxShadow(
                  color: _shadow,
                  blurRadius: 24,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_accent, _primarySoft],
                    ),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: _border),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 52,
                    color: _primaryDeep,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Your cart is empty',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Browse products and add the ones you want to order. They will appear here with a clearer checkout summary.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, height: 1.55, color: _muted),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onContinueShopping,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryDeep,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Continue shopping',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        size: size,
        color: _muted,
      ),
    );
  }
}
