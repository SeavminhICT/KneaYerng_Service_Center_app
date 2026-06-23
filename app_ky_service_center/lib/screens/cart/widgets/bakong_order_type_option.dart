import 'package:flutter/material.dart';

class BakongOrderTypeOption extends StatelessWidget {
  const BakongOrderTypeOption({
    super.key,
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF0F6BFF) : Colors.white,
        foregroundColor: isSelected ? Colors.white : const Color(0xFF111827),
        side: BorderSide(
          color: isSelected ? const Color(0xFF0F6BFF) : const Color(0xFFE5E7EB),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
