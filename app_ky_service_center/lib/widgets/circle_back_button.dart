import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// A round back button with a translucent fill, used on colored or
/// gradient header backgrounds.
class CircleBackButton extends StatelessWidget {
  const CircleBackButton({
    super.key,
    this.onPressed,
    this.icon = HugeIcons.strokeRoundedArrowLeft01,
    this.color = Colors.white,
    this.size = 40,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed ?? () => Navigator.maybePop(context),
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: color, size: size * 0.55),
      ),
    );
  }
}
