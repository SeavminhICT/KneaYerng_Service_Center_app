import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/product.dart';
import '../../models/cart_item.dart';
import '../../services/cart_service.dart';
import '../../services/api_service.dart';
import '../../widgets/page_transitions.dart';
import 'checkout_flow_screen.dart';

Map<String, String>? get _imageHeaders => null;

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

enum _ApplyState { idle, applying, successCheck, applied }

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
  final TextEditingController _promoController = TextEditingController();
  late Future<List<Product>> _recommendationsFuture;
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
    _recommendationsFuture = _loadRecommendations();
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

  Future<void> _openCheckoutFlow(BuildContext context) async {
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

  Future<List<Product>> _loadRecommendations() async {
    try {
      return await ApiService.fetchProducts(status: 'active');
    } catch (_) {
      return [];
    }
  }

  void _addRecommendedProduct(Product product) {
    CartService.instance.add(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        behavior: SnackBarBehavior.floating,
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
        return Scaffold(
          backgroundColor: const Color(0xFFF6F7FB),
          body: SafeArea(
            child: Column(
              children: [
                _CartAppBar(
                  totalItems: totalItems,
                  onBack: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: items.isEmpty
                      ? const _EmptyCart()
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
                          children: [
                            Row(
                              children: [
                                Text(
                                  '$totalItems items in cart',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '\$${subtotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ListView.separated(
                              itemCount: items.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return _CartItemCard(
                                  item: item,
                                  onRemove: () =>
                                      CartService.instance.remove(item),
                                  onQuantityChanged: (value) => CartService
                                      .instance
                                      .updateQuantity(item, value),
                                );
                              },
                            ),
                            const SizedBox(height: 6),
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
                            const SizedBox(height: 14),
                            _OrderSummary(
                              subtotal: subtotal,
                              shipping: shipping,
                              tax: tax,
                              discount: discount,
                              total: total.toDouble(),
                            ),
                            const SizedBox(height: 16),
                            const _SectionHeader(
                              title: 'You might also like',
                              action: 'Live Products',
                            ),
                            const SizedBox(height: 10),
                            _RecommendationsRow(
                              productsFuture: _recommendationsFuture,
                              cartItems: items,
                              onAdd: _addRecommendedProduct,
                            ),
                            const SizedBox(height: 80),
                          ],
                        ),
                ),
                if (items.isNotEmpty)
                  _CheckoutBar(
                    total: total.toDouble(),
                    onCheckout: () => _openCheckoutFlow(context),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CartAppBar extends StatelessWidget {
  const _CartAppBar({required this.onBack, required this.totalItems});

  final VoidCallback onBack;
  final int totalItems;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          _CircleButton(icon: Icons.arrow_back, onTap: onBack),
          const Spacer(),
          Row(
            children: [
              const Text(
                'Shopping Cart',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(width: 6),
              if (totalItems > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$totalItems',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F6BFF),
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          _CircleButton(icon: Icons.more_horiz, onTap: () {}),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      radius: 22,
      onTap: onTap,
      child: Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE6E9F0)),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF111827)),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageUrl == null || imageUrl.isEmpty
                  ? const _ImageFallback()
                  : Padding(
                      padding: const EdgeInsets.all(6),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        headers: _imageHeaders,
                        errorBuilder: (_, _, _) => const _ImageFallback(),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Color(0xFF111827),
                          height: 1.2,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onRemove,
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.variant?.trim().isNotEmpty == true
                      ? item.variant!
                      : 'Color: Default  |  Size: Standard',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _QtyStepper(
                      value: item.quantity,
                      onChanged: onQuantityChanged,
                    ),
                    const Spacer(),
                    Text(
                      '\$${item.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
      height: 26,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove,
            onTap: () => onChanged(value > 1 ? value - 1 : 1),
          ),
          Container(width: 1, color: const Color(0xFFE5E7EB)),
          SizedBox(
            width: 26,
            child: Center(
              child: Text(
                '$value',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          Container(width: 1, color: const Color(0xFFE5E7EB)),
          _StepButton(icon: Icons.add, onTap: () => onChanged(value + 1)),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 26,
        alignment: Alignment.center,
        child: Icon(icon, size: 14, color: const Color(0xFF6B7280)),
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
          return const Icon(Icons.check_circle, key: ValueKey('check'));
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
                      hintText: 'Enter coupon code',
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: hasError
                              ? const Color(0xFFDC2626)
                              : const Color(0xFFE6E9F0),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: hasError
                              ? const Color(0xFFDC2626)
                              : const Color(0xFFE6E9F0),
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE6E9F0)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: applyButtonEnabled ? onApply : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F6BFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      errorText ?? '',
                      style: const TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : const SizedBox(key: ValueKey('error-empty')),
          ),
        ],
      );
    }

    Widget buildChip() {
      final code = appliedCode ?? '';
      final discountText = discount > 0
          ? '-\$${discount.toStringAsFixed(2)}'
          : '';
      return Container(
        key: const ValueKey('chip'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Text(
                code,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            if (discountText.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                discountText,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF16A34A),
                ),
              ),
            ],
            const Spacer(),
            TextButton(
              onPressed: onRemove,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF111827),
              ),
              child: const Text('Remove'),
            ),
          ],
        ),
      );
    }

    final showChipView = showChip && (appliedCode?.isNotEmpty ?? false);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E9F0)),
      ),
      child: AnimatedBuilder(
        animation: expandAnimation,
        builder: (context, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: onToggleExpanded,
                borderRadius: BorderRadius.circular(10),
                child: Row(
                  children: [
                    const Text(
                      'Promo Code',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    RotationTransition(
                      turns: chevronTurns,
                      child: const Icon(Icons.expand_more),
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
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: isRechecking
                    ? const Padding(
                        key: ValueKey('rechecking'),
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          'Rechecking voucher...',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : const SizedBox(key: ValueKey('rechecking-empty')),
              ),
              SizeTransition(
                sizeFactor: expandAnimation,
                axisAlignment: -1,
                child: FadeTransition(
                  opacity: expandAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.06),
                      end: Offset.zero,
                    ).animate(expandAnimation),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
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
    final discountRow = widget.discount > 0
        ? _SummaryRow(
            key: const ValueKey('discount'),
            label: 'Discount',
            value: -widget.discount,
            valueColor: const Color(0xFF16A34A),
          )
        : const SizedBox(key: ValueKey('discount-empty'));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E9F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _SummaryRow(label: 'Subtotal', value: widget.subtotal),
          _SummaryRow(label: 'Shipping', value: widget.shipping),
          _SummaryRow(label: 'Tax', value: widget.tax),
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
            child: discountRow,
          ),
          const Divider(height: 20),
          AnimatedBuilder(
            animation: _totalController,
            builder: (context, _) {
              final displayTotal = _totalController.isAnimating
                  ? _totalAnimation.value
                  : widget.total;
              return Row(
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Text(
                    '\$${displayTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              );
            },
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
  });

  final String label;
  final double value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF6B7280))),
          const Spacer(),
          Text(
            value < 0
                ? '-\$${value.abs().toStringAsFixed(2)}'
                : '\$${value.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.w600, color: valueColor),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action});

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ),
        TextButton(onPressed: () {}, child: Text(action)),
      ],
    );
  }
}

class _RecommendationsRow extends StatelessWidget {
  const _RecommendationsRow({
    required this.productsFuture,
    required this.cartItems,
    required this.onAdd,
  });

  final Future<List<Product>> productsFuture;
  final List<CartItem> cartItems;
  final ValueChanged<Product> onAdd;

  @override
  Widget build(BuildContext context) {
    final cartIds = cartItems.map((e) => e.product.id).toSet();
    return FutureBuilder<List<Product>>(
      future: productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 96,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final allProducts = snapshot.data ?? const <Product>[];
        final recommended = allProducts
            .where((item) => !cartIds.contains(item.id))
            .take(8)
            .toList();

        if (recommended.isEmpty) {
          return const SizedBox(
            height: 64,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'No recommendation products available.',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }

        return SizedBox(
          height: 172,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recommended.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = recommended[index];
              return Container(
                width: 154,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE6E9F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          item.imageUrl ?? '',
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          headers: _imageHeaders,
                          errorBuilder: (_, _, _) => const _ImageFallback(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F6BFF),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => onAdd(item),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFBFDBFE),
                              ),
                            ),
                            child: const Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F6BFF),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.total, required this.onCheckout});

  final double total;
  final VoidCallback onCheckout;

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
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const Spacer(),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F6BFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.shopping_cart_outlined,
            size: 72,
            color: Color(0xFF9CA3AF),
          ),
          SizedBox(height: 12),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F4F6),
      child: const Center(
        child: Icon(Icons.image_not_supported, color: Color(0xFF9CA3AF)),
      ),
    );
  }
}
