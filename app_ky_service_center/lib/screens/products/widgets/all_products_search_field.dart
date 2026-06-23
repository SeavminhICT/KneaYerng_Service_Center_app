import 'package:flutter/material.dart';

import '../../../theme/app_fonts.dart';
import 'all_products_common.dart';

/// Search input used at the top of the all-products screen.
class AllProductsSearchField extends StatelessWidget {
  const AllProductsSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: apSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: apBorder),
        boxShadow: const [
          BoxShadow(color: apShadow, blurRadius: 16, offset: Offset(0, 8)),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onTapOutside: (_) {
          focusNode.unfocus();
        },
        textInputAction: TextInputAction.search,
        maxLength: 80,
        style: kmFont(context, const TextStyle(
          fontSize: 14,
          color: apTextPrimary,
          fontFamily: 'SF Pro Text',
        )),
        decoration: InputDecoration(
          hintText: 'Search products, brands, repairs...',
          hintStyle: kmFont(context, const TextStyle(
            color: apTextMuted,
            fontFamily: 'SF Pro Text',
          )),
          counterText: '',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    controller.clear();
                    onChanged?.call('');
                  },
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
