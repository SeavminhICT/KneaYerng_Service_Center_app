import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4CC),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "My Cart",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.shopping_cart_outlined,
                        size: 80, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      "Your cart is empty",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
