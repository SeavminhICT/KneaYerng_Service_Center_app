import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/user_profile.dart';
import '../../services/api_service.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/circle_back_button.dart';
import 'address_management_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // ── Static palette ────────────────────────────────────────────────────────
  static const Color _brandBlue = Color(0xFF4A88F7);
  static const Color _heroStart = Color(0xFF4A88F7);
  static const Color _heroEnd   = Color(0xFF96B5F2);
  static const Color _danger    = Color(0xFFE65054);
  static const Color _accent    = Color(0xFF22C55E);

  // ── Resolved at build() — use these everywhere ────────────────────────────
  Color _bg          = const Color(0xFFF6F9FF);
  Color _surface     = Colors.white;
  Color _border      = const Color(0xFFE6ECF5);
  Color _textPrimary = const Color(0xFF111827);
  Color _textMuted   = const Color(0xFF6B7280);
  Color _primary     = const Color(0xFF4A88F7);

  void _resolveColors(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    _bg          = dark ? const Color(0xFF1D2635) : const Color(0xFFF6F9FF);
    _surface     = dark ? const Color(0xFF161B22) : Colors.white;
    _border      = dark ? const Color(0xFF2B3442) : const Color(0xFFE6ECF5);
    _textPrimary = dark ? const Color(0xFFE6EDF7) : const Color(0xFF111827);
    _textMuted   = dark ? const Color(0xFF97A2B5) : const Color(0xFF6B7280);
    _primary     = _brandBlue;
  }

  // ── Form state ────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameCtrl;
  late TextEditingController _phoneCtrl;
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
    _fullNameCtrl = TextEditingController(text: _profile.displayName == 'User' ? '' : _profile.displayName);
    _phoneCtrl = TextEditingController(text: _profile.phone ?? '');
    _birthCtrl = TextEditingController(text: _profile.birth ?? '');
    _gender = _profile.gender;
    _avatarUrl = _profile.avatarUrl;
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _birthCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    _resolveColors(context);
    final l = AppLocalizations.of(context);
    final name = _profile.displayName.isNotEmpty ? _profile.displayName : 'User';
    final initials = _initialsFrom(name, _profile.email ?? '');

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.soraTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [
            // ── Gradient Header ──
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_heroStart, _heroEnd],
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  child: Column(
                    children: [
                      // Top bar
                      Row(
                        children: [
                          CircleBackButton(onPressed: () => Navigator.of(context).maybePop()),
                          const Spacer(),
                          Text(
                            l.editProfile,
                            style: kFont(context, 
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 38),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Avatar
                      GestureDetector(
                        onTap: _handleChangePhoto,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              height: 96,
                              width: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              child: ClipOval(child: _buildAvatarImage(initials)),
                            ),
                            Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: _uploadingAvatar
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF3B63FF),
                                  width: 2,
                                ),
                              ),
                              child: _uploadingAvatar
                                  ? const Padding(
                                      padding: EdgeInsets.all(6),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF3B63FF),
                                      ),
                                    )
                                  : const Icon(
                                      HugeIcons.strokeRoundedCamera01,
                                      size: 14,
                                      color: Color(0xFF3B63FF),
                                    ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: kFont(context, 
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _profile.email ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Scrollable Body ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCompletionCard(),
                    const SizedBox(height: 24),
                    _buildSectionLabel(l.editProfile),
                    const SizedBox(height: 12),
                    _buildFormCard(),
                    const SizedBox(height: 20),
                    _buildSectionLabel(l.personalInfo),
                    const SizedBox(height: 12),
                    _buildActionCard(),
                    const SizedBox(height: 28),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Completion card ───────────────────────────────────────────────────────
  Widget _buildCompletionCard() {
    final score = _profileScore();
    final color = score >= 80 ? _accent : score >= 50 ? _primary : _danger;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  score >= 100
                      ? HugeIcons.strokeRoundedCheckmarkBadge01
                      : HugeIcons.strokeRoundedUser,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Completeness',
                      style: kFont(context, 
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    Text(
                      score < 100
                          ? 'Fill the form below to complete your profile'
                          : 'Your profile is fully complete!',
                      style: TextStyle(fontSize: 12, color: _textMuted),
                    ),
                  ],
                ),
              ),
              Text(
                '$score%',
                style: kFont(context, 
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 7,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  // ── Editable form card ────────────────────────────────────────────────────
  Widget _buildFormCard() {
    final l = AppLocalizations.of(context);
    return Form(
      key: _formKey,
      child: Container(
        decoration: _cardDecoration(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _formField(
              controller: _fullNameCtrl,
              label: l.fullName,
              icon: HugeIcons.strokeRoundedUser,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l.requiredField : null,
            ),
            const SizedBox(height: 14),
            _formField(
              controller: _phoneCtrl,
              label: l.phoneNumber,
              icon: HugeIcons.strokeRoundedCall,
              keyboard: TextInputType.phone,
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
      style: kmFont(context, GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
      )),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: kmFont(context, GoogleFonts.inter(fontSize: 13, color: _textMuted)),
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
          borderSide: BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _primary, width: 1.5),
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
      style: kmFont(context, GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
      )),
      decoration: InputDecoration(
        labelText: 'Birth Date',
        labelStyle: kmFont(context, GoogleFonts.inter(fontSize: 13, color: _textMuted)),
        prefixIcon: Icon(HugeIcons.strokeRoundedBirthdayCake, color: _primary, size: 20),
        filled: true,
        fillColor: _bg,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _genderDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _gender,
      decoration: InputDecoration(
        labelText: 'Gender',
        labelStyle: kmFont(context, GoogleFonts.inter(fontSize: 13, color: _textMuted)),
        prefixIcon: Icon(HugeIcons.strokeRoundedFemaleSymbol, color: _primary, size: 20),
        filled: true,
        fillColor: _bg,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _primary, width: 1.5),
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
    final l = AppLocalizations.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: _surface,
        child: Container(
          decoration: _cardDecoration(),
          child: _actionRow(
            icon: HugeIcons.strokeRoundedLocation01,
            color: const Color(0xFF10B981),
            title: l.savedAddresses,
            subtitle: l.isKhmer ? 'ទីតាំងទទួលទំនិញ និងដឹកជញ្ជូន' : 'Pickup & delivery locations',
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
                    style: kmFont(context, GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    )),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: kmFont(context, GoogleFonts.inter(fontSize: 12, color: _textMuted)),
                  ),
                ],
              ),
            ),
            Icon(
              HugeIcons.strokeRoundedArrowRight01,
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
                  AppLocalizations.of(context).save,
                  style: kmFont(context, GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  )),
                ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: kmFont(context, GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _textMuted,
        letterSpacing: 1.2,
      )),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _border, width: 1.2),
      boxShadow: [
        BoxShadow(
          color: _brandBlue.withValues(alpha: 0.06),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  Widget _buildAvatarImage(String initials) {
    final url = _avatarUrl?.trim();
    final fallback = Center(
      child: Text(
        initials,
        style: kmFont(context, GoogleFonts.poppins(
          color: _primary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
        )),
      ),
    );
    if (url == null || url.isEmpty) return fallback;
    return AppNetworkImage(
      url,
      fit: BoxFit.cover,
      errorWidget: (context, _, error) => fallback,
    );
  }

  bool _hasValue(String? v) => v != null && v.trim().isNotEmpty;

  (String, String) _splitFullName(String fullName) {
    final t = fullName.trim();
    if (t.isEmpty) return ('', '');
    final parts = t.split(RegExp(r'\s+'));
    if (parts.length == 1) return (parts.first, '');
    return (parts.first, parts.sublist(1).join(' '));
  }

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
        ).copyWith(colorScheme: ColorScheme.light(primary: _primary)),
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
      // Only send email if it looks like a real email (not a phone number)
      final rawEmail = _profile.email?.trim() ?? '';
      final isValidEmail = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$')
          .hasMatch(rawEmail);
      final (firstName, lastName) = _splitFullName(_fullNameCtrl.text);
      final error = await ApiService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: isValidEmail ? rawEmail : '',
        phone: _phoneCtrl.text.trim(),
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
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(HugeIcons.strokeRoundedCheckmarkCircle02, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              l.successfullySaved,
              style: kmFont(context, GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              )),
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
      final rawEmail2 = _profile.email?.trim() ?? '';
      final isValidEmail2 = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$')
          .hasMatch(rawEmail2);
      final (firstName2, lastName2) = _splitFullName(_fullNameCtrl.text);
      final error = await ApiService.updateProfile(
        firstName: firstName2,
        lastName: lastName2,
        email: isValidEmail2 ? rawEmail2 : '',
        phone: _phoneCtrl.text.trim(),
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

