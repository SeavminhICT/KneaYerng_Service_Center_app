import 'package:app_ky_service_center/models/product.dart';
import 'package:app_ky_service_center/services/cart_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final cart = CartService.instance;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    cart.clear();
  });

  tearDown(cart.clear);

  test('does not add more than product stock already in cart', () {
    final product = _product(stock: 5);

    expect(cart.add(product, quantity: 5), isTrue);
    expect(cart.totalItems, 5);

    expect(cart.add(product), isFalse);
    expect(cart.totalItems, 5);
    expect(cart.items.single.quantity, 5);
  });

  test('does not add more than variant stock already in cart', () {
    final variant = _variant(id: 12, stock: 5);
    final product = _product(stock: 20, variants: [variant]);

    expect(
      cart.add(
        product,
        quantity: 5,
        variant: variant.label,
        variantId: variant.id,
        variantStock: variant.stock,
        unitPrice: variant.price,
      ),
      isTrue,
    );

    expect(
      cart.add(
        product,
        variant: variant.label,
        variantId: variant.id,
        variantStock: variant.stock,
        unitPrice: variant.price,
      ),
      isFalse,
    );
    expect(cart.totalItems, 5);
    expect(cart.items.single.quantity, 5);
  });

  test('does not increase cart quantity above known stock', () {
    final product = _product(stock: 5);
    expect(cart.add(product, quantity: 3), isTrue);

    final item = cart.items.single;
    expect(cart.updateQuantity(item, 6), isFalse);
    expect(cart.items.single.quantity, 3);

    expect(cart.updateQuantity(item, 5), isTrue);
    expect(cart.items.single.quantity, 5);
  });
}

Product _product({
  int id = 1,
  int stock = 5,
  List<ProductVariant> variants = const [],
}) {
  return Product(
    id: id,
    name: 'Test Phone',
    price: 100,
    stock: stock,
    variants: variants,
  );
}

ProductVariant _variant({required int id, required int stock}) {
  return ProductVariant(
    id: id,
    storageCapacity: '128GB',
    color: 'Black',
    condition: 'New',
    price: 120,
    stock: stock,
  );
}
