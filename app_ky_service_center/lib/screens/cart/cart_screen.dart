import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../models/product.dart';
import '../../models/cart_item.dart';
import '../../services/cart_service.dart';
import '../../services/api_service.dart';
import 'bakong_checkout_sheet.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _promoController = TextEditingController();
  VoucherValidation? _voucher;
  bool _isApplying = false;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _openBakongCheckout(BuildContext context, double total) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BakongCheckoutSheet(total: total),
    );
  }

  Future<void> _showVoucherAlert({
    required bool success,
    required String message,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 120,
              width: 120,
              child: Lottie.asset(
                'assets/lottie/discount.json',
                repeat: success,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: success
                    ? const Color(0xFF15803D)
                    : const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _applyVoucher(double subtotal) async {
    if (subtotal <= 0) {
      await _showVoucherAlert(
        success: false,
        message: 'Add items to the cart before applying a promo code.',
      );
      return;
    }
    final code = _promoController.text.trim();
    if (code.isEmpty) {
      await _showVoucherAlert(
        success: false,
        message: 'Please enter a promo code.',
      );
      return;
    }
    setState(() => _isApplying = true);
    VoucherValidation result;
    try {
      result = await ApiService.validateVoucher(
        code: code,
        subtotal: subtotal,
      );
    } catch (_) {
      result = VoucherValidation(
        isValid: false,
        message: 'Unable to validate the promo code.',
      );
    }
    if (!mounted) return;
    setState(() {
      _isApplying = false;
      _voucher = result.isValid ? result : null;
      if (!result.isValid) {
        _promoController.clear();
      } else {
        _promoController.text = result.code ?? code;
      }
    });
    await _showVoucherAlert(
      success: result.isValid,
      message: result.message ??
          (result.isValid
              ? 'Promo code applied successfully.'
              : 'Promo code is not valid.'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartService.instance,
      builder: (context, _) {
        final items = CartService.instance.items;
        final subtotal = CartService.instance.subtotal;
        final totalItems = CartService.instance.totalItems;
        final shipping = items.isEmpty ? 0.0 : 9.99;
        final tax = subtotal * 0.08;
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
                                TextButton(
                                  onPressed: () {},
                                  child: const Text('Edit'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ...items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _CartItemCard(
                                  item: item,
                                  onRemove: () =>
                                      CartService.instance.remove(item),
                                  onQuantityChanged: (value) =>
                                      CartService.instance.updateQuantity(
                                    item,
                                    value,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            _PromoCodeCard(
                              controller: _promoController,
                              isApplying: _isApplying,
                              appliedCode: _voucher?.code,
                              discount: discount,
                              onApply: () => _applyVoucher(subtotal),
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
                              action: 'See All',
                            ),
                            const SizedBox(height: 10),
                            const _RecommendationsRow(),
                            const SizedBox(height: 80),
                          ],
                        ),
                ),
                if (items.isNotEmpty)
                  _CheckoutBar(
                    total: total.toDouble(),
                    onCheckout: () => _openBakongCheckout(context, total.toDouble()),
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
  const _CartAppBar({
    required this.onBack,
    required this.totalItems,
  });

  final VoidCallback onBack;
  final int totalItems;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          _CircleButton(
            icon: Icons.arrow_back,
            onTap: onBack,
          ),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
          _CircleButton(
            icon: Icons.more_horiz,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E9F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductThumb(imageUrl: product.imageUrl),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.variant ?? 'Color: Black | Size: Standard',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 10),
                _QtyStepper(
                  value: item.quantity,
                  onChanged: onQuantityChanged,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline, size: 20),
                color: const Color(0xFF9CA3AF),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${item.subtotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  const _ProductThumb({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      width: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageUrl == null || imageUrl!.isEmpty
            ? const Icon(Icons.image_not_supported, color: Color(0xFF9CA3AF))
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                headers: const {
                  'User-Agent': 'Mozilla/5.0',
                  'Accept':
                      'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
                },
                errorBuilder: (_, __, ___) => const _ImageFallback(),
              ),
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _StepButton(
            icon: Icons.remove,
            onTap: () => onChanged(value > 1 ? value - 1 : 1),
          ),
          SizedBox(
            width: 32,
            child: Center(
              child: Text(
                '$value',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add,
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
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 18,
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE6E9F0)),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

class _PromoCodeCard extends StatelessWidget {
  const _PromoCodeCard({
    required this.controller,
    required this.isApplying,
    required this.onApply,
    required this.appliedCode,
    required this.discount,
  });

  final TextEditingController controller;
  final bool isApplying;
  final VoidCallback onApply;
  final String? appliedCode;
  final double discount;

  @override
  Widget build(BuildContext context) {
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
            'Promo Code',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          if (appliedCode != null && appliedCode!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Applied: ${appliedCode!} (-\$${discount.toStringAsFixed(2)})',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF16A34A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
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
                      borderSide:
                          const BorderSide(color: Color(0xFFE6E9F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Color(0xFFE6E9F0)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: isApplying ? null : onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F6BFF),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isApplying
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
          _SummaryRow(label: 'Subtotal', value: subtotal),
          _SummaryRow(label: 'Shipping', value: shipping),
          _SummaryRow(label: 'Tax', value: tax),
          if (discount > 0)
            _SummaryRow(
              label: 'Discount',
              value: -discount,
              valueColor: const Color(0xFF16A34A),
            ),
          const Divider(height: 20),
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
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ],
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
          Text(
            label,
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
          const Spacer(),
          Text(
            value < 0
                ? '-\$${value.abs().toStringAsFixed(2)}'
                : '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
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
  const _RecommendationsRow();

  List<Product> get _recommendations => const [
        Product(
          id: 901,
          name: 'Portable Bluetooth Speaker',
          price: 29.0,
          imageUrl:
              'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=900&q=80',
        ),
        Product(
          id: 902,
          name: 'Adjustable Phone Stand',
          price: 19.0,
          imageUrl:
              'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=900&q=80',
        ),
        Product(
          id: 903,
          name: 'Premium USB-C Cable',
          price: 9.0,
          imageUrl:
              'https://images.unsplash.com/photo-1518458028785-8fbcd101ebb9?auto=format&fit=crop&w=900&q=80',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _recommendations.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = _recommendations[index];
          return Container(
            width: 130,
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
                      fit: BoxFit.cover,
                      headers: const {
                        'User-Agent': 'Mozilla/5.0',
                        'Accept':
                            'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
                      },
                      errorBuilder: (_, __, ___) => const _ImageFallback(),
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
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F6BFF),
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
          Icon(Icons.shopping_cart_outlined, size: 72, color: Color(0xFF9CA3AF)),
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
