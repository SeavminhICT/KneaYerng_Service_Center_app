import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../models/user_profile.dart';
import '../../services/api_service.dart';
import 'address_management_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // ── Palette ──────────────────────────────────────────────────────────────
  static const Color _bg = Color(0xFFF4F6FB);
  static const Color _surface = Colors.white;
  static const Color _primary = Color(0xFF4A6CF7);
  static const Color _primaryLight = Color(0xFFEEF1FE);
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _accent = Color(0xFF22C55E);
  static const Color _danger = Color(0xFFEF4444);

  // ── Form state ────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _birthCtrl;
  String? _gender;
  String? _avatarUrl;

  late UserProfile _profile;
  bool _saving = false;
  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _firstNameCtrl = TextEditingController(text: _profile.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: _profile.lastName ?? '');
    _birthCtrl = TextEditingController(text: _profile.birth ?? '');
    _gender = _profile.gender;
    _avatarUrl = _profile.avatarUrl;
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _birthCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),
                  _buildCompletionCard(),
                  const SizedBox(height: 28),
                  _buildSectionLabel('Edit Details'),
                  const SizedBox(height: 12),
                  _buildFormCard(),
                  const SizedBox(height: 24),
                  _buildSectionLabel('Account'),
                  const SizedBox(height: 12),
                  _buildActionCard(),
                  const SizedBox(height: 32),
                  _buildSaveButton(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sliver AppBar ────────────────────────────────────────────────────────
  Widget _buildSliverAppBar() {
    final name = _profile.displayName.isNotEmpty
        ? _profile.displayName
        : 'User';
    final initials = _initialsFrom(name, _profile.email ?? '');

    return SliverAppBar(
      expandedHeight: 210,
      pinned: true,
      elevation: 0,
      backgroundColor: _surface,
      foregroundColor: _textPrimary,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: _bg,
            shape: BoxShape.circle,
            border: Border.all(color: _border),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
        ),
      ),
      centerTitle: true,
      title: Text(
        'Edit Profile',
        style: GoogleFonts.poppins(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: _textPrimary,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(color: _surface),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: _handleChangePhoto,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      height: 88,
                      width: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _primary, width: 2.5),
                        color: _primaryLight,
                      ),
                      child: ClipOval(child: _buildAvatarImage(initials)),
                    ),
                    Container(
                      height: 26,
                      width: 26,
                      decoration: BoxDecoration(
                        color: _uploadingAvatar ? _textMuted : _primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: _uploadingAvatar
                          ? const Padding(
                              padding: EdgeInsets.all(5),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _profile.email ?? '',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: _textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Completion ring card ──────────────────────────────────────────────────
  Widget _buildCompletionCard() {
    final score = _profileScore();
    final color = score >= 80
        ? _accent
        : score >= 50
        ? _primary
        : _danger;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          SizedBox(
            height: 54,
            width: 54,
            child: CustomPaint(
              painter: _RingPainter(progress: score / 100, color: color),
              child: Center(
                child: Text(
                  '$score%',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Completeness',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  score < 100
                      ? 'Fill the form below to complete your profile.'
                      : 'Your profile is fully complete!',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _textMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Editable form card ────────────────────────────────────────────────────
  Widget _buildFormCard() {
    return Form(
      key: _formKey,
      child: Container(
        decoration: _cardDecoration(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _formField(
              controller: _firstNameCtrl,
              label: 'First Name',
              icon: Icons.person_outline_rounded,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            _formField(
              controller: _lastNameCtrl,
              label: 'Last Name',
              icon: Icons.badge_outlined,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            _dateField(),
            const SizedBox(height: 14),
            _genderDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _formField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      validator: validator,
      cursorColor: _primary,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(fontSize: 13, color: _textMuted),
        prefixIcon: Icon(icon, color: _primary, size: 20),
        filled: true,
        fillColor: _bg,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _danger, width: 1.5),
        ),
      ),
    );
  }

  Widget _dateField() {
    return TextFormField(
      controller: _birthCtrl,
      readOnly: true,
      onTap: _selectDate,
      cursorColor: _primary,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
      ),
      decoration: InputDecoration(
        labelText: 'Birth Date',
        labelStyle: GoogleFonts.inter(fontSize: 13, color: _textMuted),
        prefixIcon: const Icon(Icons.cake_outlined, color: _primary, size: 20),
        filled: true,
        fillColor: _bg,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _genderDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _gender,
      decoration: InputDecoration(
        labelText: 'Gender',
        labelStyle: GoogleFonts.inter(fontSize: 13, color: _textMuted),
        prefixIcon: const Icon(Icons.wc_outlined, color: _primary, size: 20),
        filled: true,
        fillColor: _bg,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'male', child: Text('Male')),
        DropdownMenuItem(value: 'female', child: Text('Female')),
        DropdownMenuItem(value: 'other', child: Text('Other')),
      ],
      onChanged: (v) => setState(() => _gender = v),
    );
  }

  // ── Action card (Addresses only) ──────────────────────────────────────────
  Widget _buildActionCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: _surface,
        child: Container(
          decoration: _cardDecoration(),
          child: _actionRow(
            icon: Icons.location_on_outlined,
            color: const Color(0xFF10B981),
            title: 'Saved Addresses',
            subtitle: 'Pickup & delivery locations',
            onTap: _openAddresses,
          ),
        ),
      ),
    );
  }

  Widget _actionRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: color.withAlpha(24),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(fontSize: 12, color: _textMuted),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: _textMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // ── Save button ───────────────────────────────────────────────────────────
  Widget _buildSaveButton() {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A6CF7), Color(0xFF6A3DE8)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _primary.withAlpha(72),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: _saving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Save Changes',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _textMuted,
        letterSpacing: 1.2,
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A0F172A),
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
      ],
    );
  }

  Widget _buildAvatarImage(String initials) {
    final url = _avatarUrl?.trim();
    final fallback = Center(
      child: Text(
        initials,
        style: GoogleFonts.poppins(
          color: _primary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    if (url == null || url.isEmpty) return fallback;
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => fallback,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          color: _primaryLight,
          alignment: Alignment.center,
          child: const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_primary),
            ),
          ),
        );
      },
    );
  }

  bool _hasValue(String? v) => v != null && v.trim().isNotEmpty;

  String _initialsFrom(String name, String email) {
    final t = name.trim();
    if (t.isNotEmpty && t != 'User') {
      final parts = t.split(RegExp(r'\s+'));
      if (parts.length == 1) return parts.first[0].toUpperCase();
      return (parts.first[0] + parts.last[0]).toUpperCase();
    }
    if (email.isNotEmpty) return email[0].toUpperCase();
    return 'U';
  }

  int _profileScore() {
    const total = 6;
    final filled = [
      _profile.firstName,
      _profile.lastName,
      _profile.email,
      _profile.phone,
      _profile.birth,
      _profile.gender,
    ].where(_hasValue).length;
    return ((filled / total) * 100).round();
  }

  Future<void> _selectDate() async {
    DateTime? initial;
    if (_birthCtrl.text.isNotEmpty) {
      try {
        initial = DateTime.parse(_birthCtrl.text);
      } catch (_) {}
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) => Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: const ColorScheme.light(primary: _primary)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _birthCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final error = await ApiService.updateProfile(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _profile.email ?? '',
        birth: _birthCtrl.text,
        gender: _gender ?? '',
        avatarPath: null,
      );
      if (!mounted) return;
      setState(() => _saving = false);

      if (error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
        return;
      }

      // Refresh profile
      final updated = await ApiService.getUserProfile();
      if (!mounted) return;
      if (updated != null) setState(() => _profile = updated);

      _showSuccessSnackbar();
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              'Profile updated successfully!',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAddresses() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddressManagementScreen()),
    );
  }

  Future<void> _handleChangePhoto() async {
    if (_uploadingAvatar) return;
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;

    setState(() => _uploadingAvatar = true);
    try {
      final error = await ApiService.updateProfile(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _profile.email ?? '',
        birth: _birthCtrl.text,
        gender: _gender ?? '',
        avatarPath: file.path,
      );
      if (!mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
        return;
      }
      final updated = await ApiService.getUserProfile();
      if (!mounted) return;
      setState(() => _avatarUrl = updated?.avatarUrl);
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }
}

// ── Ring Painter ───────────────────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 4;
    const strokeWidth = 5.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withAlpha(30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
