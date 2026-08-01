import 'package:flutter/material.dart';

/// A compact circular back button used on colored or gradient headers.
class CircleBackButton extends StatelessWidget {
  const CircleBackButton({
    super.key,
    this.onPressed,
    this.backgroundColor = const Color(0xFF176BFF),
    this.iconColor = Colors.white,
    this.size = 40,
  });

  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed ?? () => Navigator.maybePop(context),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            Icons.chevron_left_rounded,
            color: iconColor,
            size: size * 0.62,
          ),
        ),
      ),
    );
  }
}
