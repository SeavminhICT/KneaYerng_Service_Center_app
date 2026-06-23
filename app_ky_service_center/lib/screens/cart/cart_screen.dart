import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../services/api_service.dart';
import '../../services/cart_service.dart';
import '../../widgets/auth_guard.dart';
import '../../widgets/page_transitions.dart';
import '../support/support_chat_screen.dart';
import 'checkout_flow_screen.dart';
import 'widgets/cart_checkout_bar.dart';
import 'widgets/cart_colors.dart';
import 'widgets/cart_dismiss_background.dart';
import 'widgets/cart_empty_state.dart';
import 'widgets/cart_header.dart';
import 'widgets/cart_item_card.dart';
import 'widgets/cart_order_summary.dart';
import 'widgets/cart_promo_code_card.dart';

// ── Main screen ─────────────────────────────────────────────────────────────
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
  final TextEditingController _promoController = TextEditingController();
  VoucherValidation? _voucher;
  bool _isApplying = false;
  CartApplyState _applyState = CartApplyState.idle;
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
    if (_promoExpanded) _promoExpandController.value = 1;

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _shakeOffset = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 6, end: -4), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -4, end: 4), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 4, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));

    CartService.instance.addListener(_handleCartChanged);
    unawaited(CartService.instance.loadFromApi());
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
      if (!_promoExpanded) _promoExpanded = true;
      _promoError = message;
    });
    if (_promoExpanded) _promoExpandController.forward();
    if (shake) _startShake();
  }

  void _handleCartChanged() {
    if (_voucher == null || _isApplying) return;
    _recheckTimer?.cancel();
    _recheckTimer = Timer(const Duration(milliseconds: 220), () {
      _revalidateVoucher(CartService.instance.subtotal);
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
      result = await ApiService.validateVoucher(code: currentCode, subtotal: subtotal);
    } catch (_) {
      result = const VoucherValidation(isValid: false, message: 'Unable to validate the promo code.');
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
        _applyState = CartApplyState.idle;
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
      _applyState = CartApplyState.applying;
      _promoError = null;
      _showAppliedChip = false;
      _isRecheckingVoucher = false;
    });

    VoucherValidation result;
    try {
      result = await ApiService.validateVoucher(code: code, subtotal: subtotal);
    } catch (_) {
      result = const VoucherValidation(isValid: false, message: 'Unable to validate the promo code.');
    }
    if (!mounted) return;

    if (!result.isValid) {
      final message = result.message ?? 'Promo code is not valid.';
      if (_shouldShakeForMessage(message)) _startShake();
      HapticFeedback.heavyImpact();
      setState(() {
        _isApplying = false;
        _applyState = CartApplyState.idle;
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
      _applyState = CartApplyState.successCheck;
      _voucher = result;
      _promoController.text = result.code ?? code;
      _promoError = null;
    });

    _applySuccessTimer?.cancel();
    _applySuccessTimer = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      setState(() => _applyState = CartApplyState.applied);
    });
    _applyChipTimer?.cancel();
    _applyChipTimer = Timer(const Duration(milliseconds: 380), () {
      if (!mounted) return;
      setState(() => _showAppliedChip = true);
    });
  }

  void _removeVoucher({String? message}) {
    _applySuccessTimer?.cancel();
    _applyChipTimer?.cancel();
    final code = _voucher?.code ?? _promoController.text.trim();
    setState(() {
      _voucher = null;
      _showAppliedChip = false;
      _applyState = CartApplyState.idle;
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
        final items     = CartService.instance.items;
        final subtotal  = CartService.instance.subtotal;
        final totalItems= CartService.instance.totalItems;
        const shipping  = 0.0;
        const tax       = 0.0;
        final discount  = _voucher?.discountFor(subtotal) ?? 0.0;
        final total     = (subtotal + shipping + tax - discount).clamp(0, 9999999).toDouble();

        return Theme(
          data: theme.copyWith(textTheme: GoogleFonts.soraTextTheme(theme.textTheme)),
          child: Scaffold(
            backgroundColor: cartBg,
            floatingActionButton: Padding(
              padding: EdgeInsets.only(bottom: items.isNotEmpty ? 90 : 0),
              child: FloatingActionButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SupportChatScreen(
                      contextType: 'cart',
                      subject: 'Cart Support',
                    ),
                  ),
                ),
                backgroundColor: cartPrimaryDeep,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: const Icon(HugeIcons.strokeRoundedHeadset, size: 22),
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // ── Header ──────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: CartHeader(
                      totalItems: totalItems,
                      onBack: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                  // ── Body ────────────────────────────────────────────────
                  Expanded(
                    child: items.isEmpty
                        ? CartEmptyState(onContinueShopping: () => Navigator.of(context).maybePop())
                        : ListView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                            children: [
                              for (var i = 0; i < items.length; i++) ...[
                                if (i > 0) const SizedBox(height: 12),
                                Dismissible(
                                  key: ValueKey(identityHashCode(items[i])),
                                  direction: DismissDirection.endToStart,
                                  background: const CartDismissBackground(),
                                  onDismissed: (_) => CartService.instance.remove(items[i]),
                                  child: CartItemCard(
                                    item: items[i],
                                    onRemove: () => CartService.instance.remove(items[i]),
                                    onQuantityChanged: (v) =>
                                        CartService.instance.updateQuantity(items[i], v),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              CartPromoCodeCard(
                                controller: _promoController,
                                isApplying: _isApplying,
                                applyState: _applyState,
                                appliedCode: _voucher?.code,
                                discount: discount,
                                errorText: _promoError,
                                onCodeChanged: (_) {
                                  if (_promoError != null) setState(() => _promoError = null);
                                },
                                expandAnimation: _promoExpand,
                                chevronTurns: _chevronTurns,
                                shakeOffset: _shakeOffset,
                                showChip: _showAppliedChip,
                                isRechecking: _isRecheckingVoucher,
                                onToggleExpanded: _togglePromoExpanded,
                                onApply: () => _applyVoucher(subtotal),
                                onRemove: _removeVoucher,
                              ),
                              const SizedBox(height: 16),
                              CartOrderSummary(
                                subtotal: subtotal,
                                shipping: shipping,
                                tax: tax,
                                discount: discount,
                                total: total,
                              ),
                              const SizedBox(height: 100),
                            ],
                          ),
                  ),
                  // ── Checkout bar ─────────────────────────────────────────
                  if (items.isNotEmpty)
                    CartCheckoutBar(
                      total: total,
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
