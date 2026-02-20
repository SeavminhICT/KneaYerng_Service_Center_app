import 'package:flutter/material.dart';

Route<T> fadeSlideRoute<T>(
  Widget page, {
  Duration duration = const Duration(milliseconds: 450),
}) {
  return PageRouteBuilder<T>(
    transitionDuration: duration,
    reverseTransitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      );
      final slideTween = Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: slideTween.animate(curved),
          child: child,
        ),
      );
    },
  );
}
