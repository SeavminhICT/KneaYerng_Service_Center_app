import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // Recommended for date formatting
import '../../models/user_profile.dart';
import '../../services/api_service.dart';

class PersonalInfoScreen extends StatefulWidget {
  final UserProfile profile;

  const PersonalInfoScreen({super.key, required this.profile});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _birthCtrl; // Keep this as a controller
  late TextEditingController _emailCtrl;

  String? _gender;
  bool _saving = false;
  bool _uploadingAvatar = false;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: widget.profile.firstName ?? '');
    _lastNameCtrl  = TextEditingController(text: widget.profile.lastName ?? '');
    // Initialize with the profile data
    _birthCtrl     = TextEditingController(text: widget.profile.birth ?? '');
    _emailCtrl     = TextEditingController(text: widget.profile.email ?? '');
    _gender        = widget.profile.gender;
    _avatarUrl     = widget.profile.avatarUrl;
  }

  // New function to handle the Date Picker
  Future<void> _selectDate() async {
    DateTime? initial;
    if (_birthCtrl.text.isNotEmpty) {
      try {
        initial = DateTime.parse(_birthCtrl.text);
      } catch (_) {
        initial = null;
      }
    }
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(), // Cannot be born in the future
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() {
        // Formats date to YYYY-MM-DD
        _birthCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandBlue = Color(0xFF1E5EFF);
    const brandMint = Color(0xFF00C2A8);
    const brandPeach = Color(0xFFFFB870);
    const canvas = Color(0xFFF6F7FB);
    const titleStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
      color: Colors.black87,
    );

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        title: const Text('Personal Information', style: titleStyle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEAF2FF), Color(0xFFFFF2E5)],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _animatedEntry(
                    0,
                    _headerCard(
                      firstName: widget.profile.firstName ?? '',
                      lastName: widget.profile.lastName ?? '',
                      phone: widget.profile.phone ?? '',
                      email: widget.profile.email ?? '',
                      accent: brandBlue,
                      avatarUrl: _avatarUrl,
                      onChangePhoto: _handleChangePhoto,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _animatedEntry(1, _sectionTitle('Basic Info')),
                  const SizedBox(height: 8),
                  _animatedEntry(
                    2,
                    _field('First Name', _firstNameCtrl, Icons.person_outline),
                  ),
                  _animatedEntry(
                    3,
                    _field('Last Name', _lastNameCtrl, Icons.badge_outlined),
                  ),
                  _animatedEntry(
                    4,
                    _dateField(
                      'Birth Date',
                      _birthCtrl,
                      Icons.calendar_month_outlined,
                    ),
                  ),
                  _animatedEntry(5, _genderDropdown()),
                  const SizedBox(height: 8),
                  const SizedBox(height: 24),
                  _animatedEntry(
                    9,
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _saving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Save Changes'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _animatedEntry(10, _accentRow(brandMint, brandPeach)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerCard({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required Color accent,
    required String? avatarUrl,
    required VoidCallback onChangePhoto,
  }) {
    final initials = (firstName.isNotEmpty || lastName.isNotEmpty)
        ? '${firstName.isNotEmpty ? firstName[0].toUpperCase() : ''}${lastName.isNotEmpty ? lastName[0].toUpperCase() : ''}'
        : 'U';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x1A1E2A78), blurRadius: 16, offset: Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: accent,
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null
                      ? Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: InkWell(
                  onTap: _uploadingAvatar ? null : onChangePhoto,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 22,
                    width: 22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _uploadingAvatar
                        ? const Padding(
                            padding: EdgeInsets.all(4),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.edit_rounded,
                            size: 14,
                            color: Colors.black54,
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${firstName.isEmpty ? 'User' : firstName} ${lastName}'.trim(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  phone.isNotEmpty ? phone : email,
                  style: const TextStyle(color: Colors.black54),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w700,
        color: Colors.black54,
      ),
    );
  }

  Widget _animatedEntry(int index, Widget child) {
    final duration = Duration(milliseconds: 280 + (index * 70));
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, widget) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: widget,
          ),
        );
      },
      child: child,
    );
  }

  Widget _accentRow(Color mint, Color peach) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: mint,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: peach,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }

  // Field for regular text
  Widget _field(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: _inputDecoration(label, icon),
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
    );
  }

  // Specific field for Date (Read Only + Tap)
  Widget _dateField(String label, TextEditingController ctrl, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        readOnly: true, // Prevents typing
        onTap: _selectDate, // Opens calendar
        decoration: _inputDecoration(label, icon),
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _readOnly(String label, String? value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: value ?? '',
        enabled: false,
        decoration: _inputDecoration(label, icon),
      ),
    );
  }

  Widget _genderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _gender,
        decoration: _inputDecoration('Gender', Icons.wc_outlined),
        items: const [
          DropdownMenuItem(value: 'male', child: Text('Male')),
          DropdownMenuItem(value: 'female', child: Text('Female')),
          DropdownMenuItem(value: 'other', child: Text('Other')),
        ],
        onChanged: (v) => setState(() => _gender = v),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF1E5EFF), width: 1.4),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final error = await ApiService.updateProfile(
        firstName: _firstNameCtrl.text,
        lastName: _lastNameCtrl.text,
        email: _emailCtrl.text,
        birth: _birthCtrl.text, // Use .text to send the string to your API
        gender: _gender ?? '',
        avatarPath: null,
      );

      if (!mounted) return;
      if (error != null) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
        return;
      }
      Navigator.pop(context);
    } catch (e) {
      setState(() => _saving = false);
      // Optional: Show error message to user
    }
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
        firstName: _firstNameCtrl.text,
        lastName: _lastNameCtrl.text,
        email: _emailCtrl.text,
        birth: _birthCtrl.text,
        gender: _gender ?? '',
        avatarPath: file.path,
      );
      if (!mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
        return;
      }

      final updated = await ApiService.getUserProfile();
      if (!mounted) return;
      setState(() => _avatarUrl = updated?.avatarUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo updated')),
      );
    } finally {
      if (mounted) {
        setState(() => _uploadingAvatar = false);
      }
    }
  }
}
