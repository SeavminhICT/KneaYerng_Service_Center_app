import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_fonts.dart';

/// "Images (optional)" label + upload button + selected image thumbnails
/// used on the "New Feedback" form.
class ReviewsPreviewImagePickerSection extends StatelessWidget {
  const ReviewsPreviewImagePickerSection({
    super.key,
    required this.images,
    required this.maxImages,
    required this.isPicking,
    required this.onPickImages,
    required this.onRemoveImageAt,
    required this.titleColor,
    required this.hintColor,
    required this.inputBorder,
    required this.isDark,
    required this.loadingLabel,
  });

  final List<Uint8List> images;
  final int maxImages;
  final bool isPicking;
  final VoidCallback onPickImages;
  final ValueChanged<int> onRemoveImageAt;
  final Color titleColor;
  final Color hintColor;
  final Color inputBorder;
  final bool isDark;
  final String loadingLabel;

  static const Color _brandBlue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Images',
              style: kmFont(context, GoogleFonts.inter(
                color: titleColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              )),
            ),
            const SizedBox(width: 6),
            Text(
              '(optional)',
              style: kmFont(context, GoogleFonts.inter(
                color: hintColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              )),
            ),
            const Spacer(),
            Text(
              '${images.length}/$maxImages',
              style: kmFont(context, GoogleFonts.inter(
                color: hintColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              )),
            ),
          ],
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: images.length >= maxImages || isPicking ? null : onPickImages,
          icon: isPicking
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add_photo_alternate_outlined, size: 18),
          label: Text(isPicking ? loadingLabel : 'Upload Images'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _brandBlue,
            backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
            side: BorderSide(color: inputBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        if (images.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: List<Widget>.generate(images.length, (index) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 76,
                      height: 76,
                      child: Image.memory(images[index], fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    top: -6,
                    right: -6,
                    child: InkWell(
                      onTap: () => onRemoveImageAt(index),
                      borderRadius: BorderRadius.circular(99),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: isDark ? const Color(0xFF0F172A) : Colors.white,
                          size: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ],
    );
  }
}
