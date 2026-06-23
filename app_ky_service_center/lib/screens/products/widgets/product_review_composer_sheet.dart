import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';

import '../../../theme/app_fonts.dart';
import 'product_detail_tone.dart';
import 'product_review_entry.dart';

/// Bottom sheet for composing a new product review: star rating, comment,
/// and up to a handful of photos. Pops the result as a [ProductReviewEntry]
/// when the user submits, or null when dismissed.
class ProductReviewComposerSheet extends StatefulWidget {
  const ProductReviewComposerSheet({super.key, required this.productName});

  final String productName;

  @override
  State<ProductReviewComposerSheet> createState() =>
      _ProductReviewComposerSheetState();
}

class _ProductReviewComposerSheetState
    extends State<ProductReviewComposerSheet> {
  static const int _maxImages = 4;

  final ImagePicker _picker = ImagePicker();
  int  _selectedRating  = 5;
  String _comment       = '';
  bool _isPickingImages = false;
  final List<Uint8List> _images = [];

  Future<void> _pickImages() async {
    if (_isPickingImages || _images.length >= _maxImages) return;
    setState(() => _isPickingImages = true);
    try {
      final picked = await _picker.pickMultiImage(
          imageQuality: 85, maxWidth: 1600, maxHeight: 1600);
      if (!mounted || picked.isEmpty) return;
      final slotsLeft = _maxImages - _images.length;
      final selected  = picked.take(slotsLeft).toList();
      final bytesList = <Uint8List>[];
      for (final f in selected) {
        final b = await f.readAsBytes();
        if (b.isNotEmpty) bytesList.add(b);
      }
      if (!mounted || bytesList.isEmpty) return;
      setState(() => _images.addAll(bytesList));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not pick images.')),
      );
    } finally {
      if (mounted) setState(() => _isPickingImages = false);
    }
  }

  void _removeImageAt(int i) {
    if (i < 0 || i >= _images.length) return;
    setState(() => _images.removeAt(i));
  }

  @override
  Widget build(BuildContext context) {
    final tone         = ProductDetailTone.of(context);
    final bottomInset  = MediaQuery.viewInsetsOf(context).bottom;
    final trimmed      = _comment.trim();
    final canSubmit    = trimmed.isNotEmpty || _images.isNotEmpty;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve:    Curves.easeOut,
      padding:  EdgeInsets.fromLTRB(0, 0, 0, bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color:        tone.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width:  40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color:        tone.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Write a Review',
                        style: kmFont(context, GoogleFonts.inter(
                          fontSize:   18,
                          fontWeight: FontWeight.w700,
                          color:      tone.textPrimary,
                        )),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(HugeIcons.strokeRoundedCancel01),
                      color: tone.textSub,
                    ),
                  ],
                ),
                Text(
                  widget.productName,
                  maxLines:  2,
                  overflow:  TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.5, color: tone.textSub),
                ),
                const SizedBox(height: 20),

                // Star rating
                Text(
                  'Your Rating',
                  style: TextStyle(
                    fontSize:   13.5,
                    fontWeight: FontWeight.w600,
                    color:      tone.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(5, (i) {
                    final star = i + 1;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedRating = star),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          width:  42,
                          height: 42,
                          decoration: BoxDecoration(
                            color:        star <= _selectedRating
                                ? tone.amberBg
                                : tone.surfaceAlt,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: star <= _selectedRating
                                  ? pdAmber
                                  : tone.border,
                            ),
                          ),
                          child: Icon(
                            star <= _selectedRating
                                ? HugeIcons.strokeRoundedStar
                                : HugeIcons.strokeRoundedStar,
                            color: pdAmber,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 18),

                // Comment
                Text(
                  'Comment',
                  style: TextStyle(
                    fontSize:   13.5,
                    fontWeight: FontWeight.w600,
                    color:      tone.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  maxLines:  5,
                  minLines:  3,
                  style: TextStyle(color: tone.textPrimary),
                  onChanged: (v) => setState(() => _comment = v),
                  decoration: InputDecoration(
                    hintText:    'Share your experience…',
                    hintStyle:   TextStyle(color: tone.textHint),
                    filled:      true,
                    fillColor:   tone.surfaceAlt,
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:   BorderSide(color: tone.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:   BorderSide(color: tone.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:   const BorderSide(color: pdAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Photos
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Photos (optional)',
                        style: TextStyle(
                          fontSize:   13.5,
                          fontWeight: FontWeight.w600,
                          color:      tone.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '${_images.length}/$_maxImages',
                      style: TextStyle(
                          fontSize: 12, color: tone.textSub),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed:
                      _images.length >= _maxImages || _isPickingImages
                          ? null
                          : _pickImages,
                  icon: _isPickingImages
                      ? const SizedBox(
                          width:  16,
                          height: 16,
                          child:  CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(HugeIcons.strokeRoundedImage02),
                  label: Text(
                    _isPickingImages ? 'Selecting…' : 'Upload Photos'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: pdAccent,
                    side:            BorderSide(color: tone.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                if (_images.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing:    6,
                    runSpacing: 6,
                    children: List.generate(_images.length, (i) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width:  80,
                              height: 80,
                              child:  Image.memory(
                                  _images[i], fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            top:   -5,
                            right: -5,
                            child: GestureDetector(
                              onTap: () => _removeImageAt(i),
                              child: Container(
                                width:  20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: Colors.black87,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  HugeIcons.strokeRoundedCancel01,
                                  size:  12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
                const SizedBox(height: 20),

                // Submit
                SizedBox(
                  width:  double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: !canSubmit
                        ? null
                        : () {
                            Navigator.of(context).pop(
                              ProductReviewEntry(
                                author:    'You',
                                rating:    _selectedRating,
                                comment:   trimmed,
                                images: List<Uint8List>.unmodifiable(_images),
                                createdAt: DateTime.now(),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pdAccent,
                      foregroundColor: Colors.white,
                      elevation:       0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Submit Review',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
