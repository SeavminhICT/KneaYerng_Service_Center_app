import 'package:flutter/material.dart';

import '../../../theme/app_fonts.dart';
import 'all_products_common.dart';

/// Button that toggles between grid and list layouts on the all-products
/// screen.
class AllProductsViewToggleButton extends StatelessWidget {
  const AllProductsViewToggleButton({
    super.key,
    required this.isGrid,
    required this.compact,
    required this.onTap,
  });

  final bool isGrid;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 16),
        decoration: BoxDecoration(
          color: apSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: apBorder),
          boxShadow: const [
            BoxShadow(color: apShadow, blurRadius: 16, offset: Offset(0, 8)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
              size: 18,
              color: apTextPrimary,
            ),
            if (!compact) ...[
              const SizedBox(width: 8),
              Text(
                isGrid ? 'List' : 'Grid',
                style: kmFont(context, const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: apTextPrimary,
                  fontFamily: 'SF Pro Text',
                )),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
