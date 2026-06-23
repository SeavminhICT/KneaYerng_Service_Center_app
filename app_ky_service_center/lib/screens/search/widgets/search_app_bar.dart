import 'package:flutter/material.dart';

import 'search_cart_button.dart';
import 'search_results_tone.dart';

/// App bar with an embedded search field and grid/list toggle, used at the
/// top of [SearchResultsScreen].
class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SearchAppBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isGrid,
    required this.onChanged,
    required this.onSubmitted,
    required this.onToggleView,
    required this.onCartTap,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isGrid;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onToggleView;
  final VoidCallback onCartTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 56);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: searchSurface,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // top row: back + title + cart
            SizedBox(
              height: kToolbarHeight,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: searchInk),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Search',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: searchInk,
                      ),
                    ),
                  ),
                  SearchCartButton(onTap: onCartTap),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            // search bar row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: searchBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: searchBorder),
                      ),
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        textInputAction: TextInputAction.search,
                        onChanged: onChanged,
                        onSubmitted: onSubmitted,
                        maxLength: 80,
                        style: const TextStyle(
                          fontSize: 14,
                          color: searchInk,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search products, brands…',
                          hintStyle: const TextStyle(
                            color: searchMuted,
                            fontSize: 14,
                          ),
                          counterText: '',
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: searchMuted,
                            size: 20,
                          ),
                          prefixIconConstraints: const BoxConstraints(minWidth: 44),
                          suffixIcon: controller.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: searchMuted,
                                  ),
                                  onPressed: () {
                                    controller.clear();
                                    onChanged('');
                                  },
                                ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // grid / list toggle
                  GestureDetector(
                    onTap: onToggleView,
                    child: Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        color: searchBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: searchBorder),
                      ),
                      child: Icon(
                        isGrid
                            ? Icons.view_list_rounded
                            : Icons.grid_view_rounded,
                        color: searchInk,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
