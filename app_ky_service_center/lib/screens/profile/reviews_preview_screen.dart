import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewsPreviewScreen extends StatefulWidget {
  const ReviewsPreviewScreen({super.key, this.productName = 'Samsung'});

  final String productName;

  @override
  State<ReviewsPreviewScreen> createState() => _ReviewsPreviewScreenState();
}

class _ReviewsPreviewScreenState extends State<ReviewsPreviewScreen> {
  static const int _maxImages = 4;
  static const String _historyStorageKey = 'profile_feedback_history_v1';

  static const Color _panelBackground = Color(0xFFF8FAFC);
  static const Color _panelBorder = Color(0xFFDCE5F2);
  static const Color _hintColor = Color(0xFF64748B);
  static const Color _titleColor = Color(0xFF1E293B);
  static const Color _brandBlue = Color(0xFF2563EB);
  static const Color _starColor = Color(0xFFF2A93B);

  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _commentController = TextEditingController();
  final List<Uint8List> _images = <Uint8List>[];
  final List<_FeedbackEntry> _history = <_FeedbackEntry>[];

  int _rating = 0;
  bool _isPickingImages = false;
  bool _isSubmitting = false;
  bool _isLoadingHistory = true;
  bool _hasNewSubmission = false;

  bool get _canSubmit =>
      !_isSubmitting &&
      _rating > 0 &&
      _commentController.text.trim().isNotEmpty;

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
      List<_FeedbackEntry> loaded;

      if (raw == null || raw.trim().isEmpty) {
        loaded = _seedHistory();
        await prefs.setString(
          _historyStorageKey,
          jsonEncode(loaded.map((entry) => entry.toMap()).toList()),
        );
      } else {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final parsed = <_FeedbackEntry>[];
          for (final item in decoded) {
            if (item is Map) {
              parsed.add(
                _FeedbackEntry.fromMap(Map<String, dynamic>.from(item)),
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

  List<_FeedbackEntry> _seedHistory() {
    final now = DateTime.now();
    return <_FeedbackEntry>[
      _FeedbackEntry(
        id: 'seed_1',
        userName: 'Sokha P.',
        rating: 5,
        comment: 'Great quality and fast support team. Very happy with it.',
        imageBase64: const <String>[],
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      _FeedbackEntry(
        id: 'seed_2',
        userName: 'Dara M.',
        rating: 4,
        comment: 'Product is good. Delivery was on time and packed well.',
        imageBase64: const <String>[],
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
      ),
      _FeedbackEntry(
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
    final entry = _FeedbackEntry(
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
          child: Center(child: _FeedbackSubmitSuccessDialog()),
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
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0B1220), Color(0xFF101A2D)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _closePage,
                        splashRadius: 20,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Feedback Center',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Rate, comment, and share photos',
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                            color: _panelBackground,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: _panelBorder),
                          ),
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                            children: [
                              Text(
                                'New Feedback',
                                style: GoogleFonts.inter(
                                  color: _titleColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.productName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  color: _hintColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Rate',
                                style: GoogleFonts.inter(
                                  color: _titleColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: List<Widget>.generate(5, (index) {
                                  final star = index + 1;
                                  final selected = star <= _rating;
                                  return AnimatedScale(
                                    duration: const Duration(milliseconds: 140),
                                    curve: Curves.easeOutBack,
                                    scale: selected ? 1 : 0.97,
                                    child: InkWell(
                                      onTap: () =>
                                          setState(() => _rating = star),
                                      borderRadius: BorderRadius.circular(14),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 170,
                                        ),
                                        curve: Curves.easeOut,
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? const Color(0xFFFFF7E6)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: selected
                                                ? const Color(0xFFF3C56A)
                                                : const Color(0xFFD6DFED),
                                          ),
                                        ),
                                        child: Icon(
                                          selected
                                              ? Icons.star_rounded
                                              : Icons.star_border_rounded,
                                          color: _starColor,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Comment',
                                style: GoogleFonts.inter(
                                  color: _titleColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _commentController,
                                maxLines: 4,
                                minLines: 4,
                                decoration: InputDecoration(
                                  hintText:
                                      'Share your experience with this product.',
                                  hintStyle: GoogleFonts.inter(
                                    color: _hintColor.withAlpha(
                                      (0.85 * 255).round(),
                                    ),
                                    fontSize: 15,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFEFF3FA),
                                  contentPadding: const EdgeInsets.all(14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD4DEEE),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD4DEEE),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF95B8F5),
                                      width: 1.3,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Text(
                                    'Images',
                                    style: GoogleFonts.inter(
                                      color: _titleColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '(optional)',
                                    style: GoogleFonts.inter(
                                      color: _hintColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${_images.length}/$_maxImages',
                                    style: GoogleFonts.inter(
                                      color: _hintColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              OutlinedButton.icon(
                                onPressed:
                                    _images.length >= _maxImages ||
                                        _isPickingImages
                                    ? null
                                    : _pickImages,
                                icon: _isPickingImages
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.add_photo_alternate_outlined,
                                        size: 18,
                                      ),
                                label: Text(
                                  _isPickingImages
                                      ? 'Selecting...'
                                      : 'Upload Images',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _brandBlue,
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: Color(0xFFD4DEEE),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                              if (_images.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 9,
                                  runSpacing: 9,
                                  children: List<Widget>.generate(
                                    _images.length,
                                    (index) {
                                      return Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: SizedBox(
                                              width: 76,
                                              height: 76,
                                              child: Image.memory(
                                                _images[index],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: -6,
                                            right: -6,
                                            child: InkWell(
                                              onTap: () =>
                                                  _removeImageAt(index),
                                              borderRadius:
                                                  BorderRadius.circular(99),
                                              child: Container(
                                                width: 20,
                                                height: 20,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF0F172A),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.close_rounded,
                                                  color: Colors.white,
                                                  size: 13,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _canSubmit
                                      ? _submitFeedback
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        (_canSubmit || _isSubmitting)
                                        ? _brandBlue
                                        : const Color(0xFFE5E7EB),
                                    foregroundColor:
                                        (_canSubmit || _isSubmitting)
                                        ? Colors.white
                                        : const Color(0xFF9CA3AF),
                                    disabledBackgroundColor: const Color(
                                      0xFFE5E7EB,
                                    ),
                                    disabledForegroundColor: const Color(
                                      0xFF9CA3AF,
                                    ),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: _isSubmitting
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'Submit Feedback',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Divider(
                                height: 1,
                                color: _panelBorder.withAlpha(
                                  (0.8 * 255).round(),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Feedback History',
                                      style: GoogleFonts.inter(
                                        color: _titleColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEAF1FF),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '${_history.length} users',
                                      style: GoogleFonts.inter(
                                        color: _brandBlue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'All user feedback appears below.',
                                style: GoogleFonts.inter(
                                  color: _hintColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 14),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                child: _isLoadingHistory
                                    ? Container(
                                        key: const ValueKey('loading_history'),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 26,
                                        ),
                                        alignment: Alignment.center,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : _history.isEmpty
                                    ? Container(
                                        key: const ValueKey('empty_history'),
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: _panelBorder,
                                          ),
                                        ),
                                        child: Text(
                                          'No feedback yet. Be the first to rate and comment.',
                                          style: GoogleFonts.inter(
                                            color: _hintColor,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      )
                                    : Column(
                                        key: const ValueKey('history_list'),
                                        children: _history.map((entry) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 12,
                                            ),
                                            child: _FeedbackHistoryCard(
                                              entry: entry,
                                              timeLabel: _formatTimeAgo(
                                                entry.createdAt,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
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

class _FeedbackHistoryCard extends StatelessWidget {
  const _FeedbackHistoryCard({required this.entry, required this.timeLabel});

  final _FeedbackEntry entry;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final decodedImages = entry.decodeImages();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE5F2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFEAF1FF),
                child: Text(
                  entry.initial,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF2563EB),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.userName,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF1E293B),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeLabel,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E6),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFF3C56A)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Color(0xFFF2A93B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.rating}',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF7C5710),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            entry.comment,
            style: GoogleFonts.inter(
              color: const Color(0xFF334155),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          if (decodedImages.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: decodedImages.map((bytes) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: Image.memory(bytes, fit: BoxFit.cover),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _FeedbackSubmitSuccessDialog extends StatefulWidget {
  const _FeedbackSubmitSuccessDialog();

  @override
  State<_FeedbackSubmitSuccessDialog> createState() =>
      _FeedbackSubmitSuccessDialogState();
}

class _FeedbackSubmitSuccessDialogState
    extends State<_FeedbackSubmitSuccessDialog> {
  bool _didClose = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      _closeDialog();
    });
  }

  void _closeDialog() {
    if (_didClose || !mounted) return;
    _didClose = true;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFDCE5F2)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 22,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.72, end: 1),
                duration: const Duration(milliseconds: 420),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  width: 74,
                  height: 74,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Feedback Submitted',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFF1E293B),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Thank you for sharing.\nYour feedback is now in history.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _closeDialog,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackEntry {
  const _FeedbackEntry({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.imageBase64,
    required this.createdAt,
  });

  final String id;
  final String userName;
  final int rating;
  final String comment;
  final List<String> imageBase64;
  final DateTime createdAt;

  String get initial {
    final trimmed = userName.trim();
    if (trimmed.isEmpty) return 'U';
    return trimmed.characters.first.toUpperCase();
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'user_name': userName,
      'rating': rating,
      'comment': comment,
      'images': imageBase64,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory _FeedbackEntry.fromMap(Map<String, dynamic> map) {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final rawRating = map['rating'];
    final parsedRating = switch (rawRating) {
      int value => value,
      double value => value.round(),
      String value => int.tryParse(value) ?? 5,
      _ => 5,
    };
    final createdAtMs = switch (map['created_at']) {
      int value => value,
      double value => value.toInt(),
      String value => int.tryParse(value) ?? nowMs,
      _ => nowMs,
    };

    final rawImages = map['images'];
    final images = switch (rawImages) {
      List<dynamic> value =>
        value
            .map((item) => item.toString())
            .where((item) => item.trim().isNotEmpty)
            .toList(),
      _ => <String>[],
    };

    return _FeedbackEntry(
      id: map['id']?.toString() ?? nowMs.toString(),
      userName: map['user_name']?.toString().trim().isNotEmpty == true
          ? map['user_name'].toString().trim()
          : 'Unknown User',
      rating: parsedRating.clamp(1, 5).toInt(),
      comment: map['comment']?.toString().trim().isNotEmpty == true
          ? map['comment'].toString().trim()
          : 'No comment',
      imageBase64: images,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
    );
  }

  List<Uint8List> decodeImages() {
    final images = <Uint8List>[];
    for (final encoded in imageBase64) {
      try {
        final bytes = base64Decode(encoded);
        if (bytes.isNotEmpty) {
          images.add(bytes);
        }
      } catch (_) {
        continue;
      }
    }
    return images;
  }
}
