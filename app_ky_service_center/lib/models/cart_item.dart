import 'product.dart';

class CartItem {
  CartItem({
    required this.product,
    this.quantity = 1,
    this.variant,
  });

  final Product product;
  int quantity;
  final String? variant;

  double get subtotal => product.price * quantity;
}
