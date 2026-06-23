import 'package:flutter/material.dart';

/// Simple value object describing a selectable delivery method option
/// (pickup from store vs. home delivery) shown on the first checkout step.
class CheckoutDeliveryMethod {
  const CheckoutDeliveryMethod({
    required this.code,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String code;
  final String title;
  final String description;
  final IconData icon;
}
