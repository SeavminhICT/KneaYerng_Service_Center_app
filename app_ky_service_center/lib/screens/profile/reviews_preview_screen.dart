import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_fonts.dart';
import 'widgets/reviews_preview_comment_field.dart';
import 'widgets/reviews_preview_feedback_entry.dart';
import 'widgets/reviews_preview_header.dart';
import 'widgets/reviews_preview_history_section.dart';
import 'widgets/reviews_preview_image_picker_section.dart';
import 'widgets/reviews_preview_star_rating.dart';
import 'widgets/reviews_preview_submit_button.dart';
import 'widgets/reviews_preview_success_dialog.dart';

class ReviewsPreviewScreen extends StatefulWidget {
  const ReviewsPreviewScreen({super.key, this.productName = 'Samsung'});

  final String productName;

  @override
  State<ReviewsPreviewScreen> createState() => _ReviewsPreviewScreenState();
}

class _ReviewsPreviewScreenState extends State<ReviewsPreviewScreen> {
  static const int _maxImages = 4;
  static const String _historyStorageKey = 'profile_feedback_history_v1';

  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _commentController = TextEditingController();
  final List<Uint8List> _images = <Uint8List>[];
  final List<FeedbackEntry> _history = <FeedbackEntry>[];

  int _rating = 0;
  bool _isPickingImages = false;
  bool _isSubmitting = false;
  bool _isLoadingHistory = true;
  bool _hasNewSubmission = false;

  bool get _canSubmit => !_isSubmitting && _rating > 0;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(_onCommentChanged);
    _loadHistory();
  }

  @override
  void dispose() {
    _commentController.removeListener(_onCommentChanged);
    _commentController.dispose();
    super.dispose();
  }

  void _onCommentChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_historyStorageKey);
      List<FeedbackEntry> loaded;

      if (raw == null || raw.trim().isEmpty) {
        loaded = _seedHistory();
        await prefs.setString(
          _historyStorageKey,
          jsonEncode(loaded.map((entry) => entry.toMap()).toList()),
        );
      } else {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final parsed = <FeedbackEntry>[];
          for (final item in decoded) {
            if (item is Map) {
              parsed.add(
                FeedbackEntry.fromMap(Map<String, dynamic>.from(item)),
              );
            }
          }
          loaded = parsed.isEmpty ? _seedHistory() : parsed;
        } else {
          loaded = _seedHistory();
        }
      }

      if (!mounted) return;
      setState(() {
        _history
          ..clear()
          ..addAll(loaded);
        _isLoadingHistory = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _history
          ..clear()
          ..addAll(_seedHistory());
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _persistHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = _history.take(100).map((entry) => entry.toMap()).toList();
      await prefs.setString(_historyStorageKey, jsonEncode(payload));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback saved in session only.')),
      );
    }
  }

  List<FeedbackEntry> _seedHistory() {
    final now = DateTime.now();
    return <FeedbackEntry>[
      FeedbackEntry(
        id: 'seed_1',
        userName: 'Sokha P.',
        rating: 5,
        comment: 'Great quality and fast support team. Very happy with it.',
        imageBase64: const <String>[],
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      FeedbackEntry(
        id: 'seed_2',
        userName: 'Dara M.',
        rating: 4,
        comment: 'Product is good. Delivery was on time and packed well.',
        imageBase64: const <String>[],
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
      ),
      FeedbackEntry(
        id: 'seed_3',
        userName: 'Vichea T.',
        rating: 5,
        comment: 'User interface is clean and easy to use. Thanks team.',
        imageBase64: const <String>[],
        createdAt: now.subtract(const Duration(days: 2, hours: 7)),
      ),
    ];
  }

  Future<void> _pickImages() async {
    if (_isPickingImages || _images.length >= _maxImages) return;

    setState(() => _isPickingImages = true);
    try {
      final picked = await _imagePicker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (!mounted || picked.isEmpty) return;

      final slotsLeft = _maxImages - _images.length;
      final selectedFiles = picked.take(slotsLeft).toList();
      final newImages = <Uint8List>[];

      for (final image in selectedFiles) {
        final bytes = await image.readAsBytes();
        if (bytes.isNotEmpty) {
          newImages.add(bytes);
        }
      }

      if (!mounted) return;
      if (newImages.isNotEmpty) {
        setState(() => _images.addAll(newImages));
      }

      if (picked.length > slotsLeft) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Only 4 images are allowed.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not pick images. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPickingImages = false);
      }
    }
  }

  void _removeImageAt(int index) {
    if (index < 0 || index >= _images.length) return;
    setState(() => _images.removeAt(index));
  }

  Future<void> _submitFeedback() async {
    if (!_canSubmit) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 460));
    if (!mounted) return;

    final now = DateTime.now();
    final entry = FeedbackEntry(
      id: now.microsecondsSinceEpoch.toString(),
      userName: 'You',
      rating: _rating,
      comment: _commentController.text.trim(),
      imageBase64: _images.map(base64Encode).toList(),
      createdAt: now,
    );

    setState(() {
      _history.insert(0, entry);
      _rating = 0;
      _images.clear();
      _isSubmitting = false;
      _hasNewSubmission = true;
    });
    _commentController.clear();

    await _persistHistory();
    if (!mounted) return;
    await _showSubmitSuccessDialog();
  }

  Future<void> _showSubmitSuccessDialog() async {
    await showGeneralDialog<void>(
      context: context,
      useRootNavigator: false,
      barrierDismissible: false,
      barrierLabel: 'Feedback submitted',
      barrierColor: Colors.black.withAlpha((0.45 * 255).round()),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return const SafeArea(
          child: Center(child: ReviewsPreviewSuccessDialog()),
        );
      },
      transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
        final scale = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.86, end: 1).animate(scale),
            child: child,
          ),
        );
      },
    );
  }

  void _closePage() {
    Navigator.of(context).pop(_hasNewSubmission ? true : false);
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final panelBg = Theme.of(context).cardColor;
    final panelBorder = isDark ? const Color(0xFF2B3442) : const Color(0xFFDCE5F2);
    final titleColor = isDark ? const Color(0xFFE6EDF7) : const Color(0xFF1E293B);
    final hintColor = isDark ? const Color(0xFF97A2B5) : const Color(0xFF64748B);
    final inputBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFEFF3FA);
    final inputBorder = isDark ? const Color(0xFF2B3442) : const Color(0xFFD4DEEE);
    final headerTextColor = titleColor;
    final headerMutedColor = hintColor;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          color: scaffoldBg,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                ReviewsPreviewHeader(
                  onBack: _closePage,
                  panelBg: panelBg,
                  panelBorder: panelBorder,
                  titleColor: headerTextColor,
                  mutedColor: headerMutedColor,
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: AnimatedPadding(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      padding: EdgeInsets.fromLTRB(
                        12,
                        0,
                        12,
                        keyboardInset + 10,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Container(
                          decoration: BoxDecoration(
                            color: panelBg,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: panelBorder),
                          ),
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                            children: [
                              Text(
                                'New Feedback',
                                style: kmFont(context, GoogleFonts.inter(
                                  color: titleColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                )),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.productName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: kmFont(context, GoogleFonts.inter(
                                  color: hintColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                )),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Rate',
                                style: kmFont(context, GoogleFonts.inter(
                                  color: titleColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                )),
                              ),
                              const SizedBox(height: 10),
                              ReviewsPreviewStarRating(
                                rating: _rating,
                                isDark: isDark,
                                onChanged: (star) =>
                                    setState(() => _rating = star),
                              ),
                              const SizedBox(height: 18),
                              ReviewsPreviewCommentField(
                                controller: _commentController,
                                titleColor: titleColor,
                                hintColor: hintColor,
                                inputBg: inputBg,
                                inputBorder: inputBorder,
                              ),
                              const SizedBox(height: 18),
                              ReviewsPreviewImagePickerSection(
                                images: _images,
                                maxImages: _maxImages,
                                isPicking: _isPickingImages,
                                onPickImages: _pickImages,
                                onRemoveImageAt: _removeImageAt,
                                titleColor: titleColor,
                                hintColor: hintColor,
                                inputBorder: inputBorder,
                                isDark: isDark,
                                loadingLabel: l.loading,
                              ),
                              const SizedBox(height: 20),
                              ReviewsPreviewSubmitButton(
                                canSubmit: _canSubmit,
                                isSubmitting: _isSubmitting,
                                isDark: isDark,
                                onPressed: _submitFeedback,
                              ),
                              const SizedBox(height: 24),
                              Divider(
                                height: 1,
                                color: panelBorder.withAlpha(
                                  (0.8 * 255).round(),
                                ),
                              ),
                              const SizedBox(height: 18),
                              ReviewsPreviewHistorySection(
                                isLoading: _isLoadingHistory,
                                history: _history,
                                formatTimeAgo: _formatTimeAgo,
                                titleColor: titleColor,
                                hintColor: hintColor,
                                panelBorder: panelBorder,
                                isDark: isDark,
                                emptyLabel: l.noData,
                              ),
                            ],
                          ),
                        ),
                      ),
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
