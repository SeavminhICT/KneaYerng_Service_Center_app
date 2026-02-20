import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_palette.dart';
import 'login_screen.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

enum _PasswordStrength { weak, medium, strong }

class _RegisterScreenState extends State<RegisterScreen> {
  static const double _radius = 16;
  static const double _cardRadius = 24;
  static const double _fieldSpacing = 12;

  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  late final FocusNode _fullNameFocus;
  late final FocusNode _contactFocus;
  late final FocusNode _passwordFocus;
  late final FocusNode _confirmFocus;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fullNameFocus = FocusNode();
    _contactFocus = FocusNode();
    _passwordFocus = FocusNode();
    _confirmFocus = FocusNode();
    _passwordCtrl.addListener(_onInputChanged);
    _fullNameCtrl.addListener(_onInputChanged);
    _contactCtrl.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _contactCtrl.dispose();
    _passwordCtrl.removeListener(_onInputChanged);
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();

    _fullNameFocus.dispose();
    _contactFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strength = _passwordStrength(_passwordCtrl.text.trim());
    final strengthLabel = _strengthLabel(strength);
    final strengthValue = _strengthValue(strength);
    final strengthColor = _strengthColor(strength);

    return Scaffold(
      backgroundColor: AppPalette.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  Container(
                    height: 220,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF4F46E5),
                          Color(0xFF6D28D9),
                          Color(0xFF7C3AED),
                        ],
                      ),
                    ),
                  ),
                  Expanded(child: Container(color: AppPalette.background)),
                ],
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    
                  ),
                  const SizedBox(height: 18),
                  const Center(
                    child: Text(
                      'KNEAYERNG MOBILE APP',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white, 
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(_cardRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.08 * 255).round()),
                          blurRadius: 20,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Get started free.',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppPalette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Free forever. No credit card needed.',
                            style: TextStyle(
                              color: AppPalette.textMuted,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _buildTextField(
                            controller: _contactCtrl,
                            focusNode: _contactFocus,
                            nextFocus: _fullNameFocus,
                            label: 'Email or phone number',
                            hint: 'name@email.com or 0123456789',
                            icon: Icons.alternate_email,
                            keyboard: TextInputType.emailAddress,
                            validator: _validateContact,
                          ),
                          const SizedBox(height: _fieldSpacing),
                          _buildTextField(
                            controller: _fullNameCtrl,
                            focusNode: _fullNameFocus,
                            nextFocus: _passwordFocus,
                            label: 'Full name',
                            hint: 'Your full name',
                            icon: Icons.person_outline,
                            keyboard: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Full name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: _fieldSpacing),
                          _buildTextField(
                            controller: _passwordCtrl,
                            focusNode: _passwordFocus,
                            nextFocus: _confirmFocus,
                            label: 'Password',
                            hint: 'Create a password',
                            icon: Icons.lock_outline,
                            obscure: _obscurePassword,
                            enableSuggestions: false,
                            autoCorrect: false,
                            validator: _validatePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: strengthValue,
                                    minHeight: 6,
                                    backgroundColor: AppPalette.border,
                                    color: strengthColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                strengthLabel,
                                style: TextStyle(
                                  color: strengthColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: _fieldSpacing),
                          _buildTextField(
                            controller: _confirmCtrl,
                            focusNode: _confirmFocus,
                            label: 'Confirm password',
                            hint: 'Re-enter your password',
                            icon: Icons.lock_outline,
                            obscure: _obscureConfirm,
                            enableSuggestions: false,
                            autoCorrect: false,
                            textInputAction: TextInputAction.done,
                            onSubmitted: _submit,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (v != _passwordCtrl.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildPasswordGuidelines(
                            password: _passwordCtrl.text,
                            fullName: _fullNameCtrl.text,
                            contact: _contactCtrl.text,
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4F46E5),
                                    Color(0xFF7C3AED),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(_radius),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(_radius),
                                  ),
                                ),
                                onPressed: _loading ? null : _submit,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: _loading
                                      ? const SizedBox(
                                          key: ValueKey('loading'),
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.4,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Sign up',
                                          key: ValueKey('text'),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(color: AppPalette.border),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'Or sign up with',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppPalette.textMuted),
                                ),
                              ),
                              const Expanded(
                                child: Divider(color: AppPalette.border),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(_radius),
                                    ),
                                    side: const BorderSide(
                                      color: AppPalette.border,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.g_mobiledata,
                                    color: AppPalette.textMuted,
                                  ),
                                  label: const Text(
                                    'Google',
                                    style: TextStyle(
                                      color: AppPalette.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(_radius),
                                    ),
                                    side: const BorderSide(
                                      color: AppPalette.border,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.facebook,
                                    color: AppPalette.textMuted,
                                  ),
                                  label: const Text(
                                    'Facebook',
                                    style: TextStyle(
                                      color: AppPalette.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscure = false,
    TextInputAction textInputAction = TextInputAction.next,
    VoidCallback? onSubmitted,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    bool enableSuggestions = true,
    bool autoCorrect = true,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboard,
      obscureText: obscure,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      enableSuggestions: enableSuggestions,
      autocorrect: autoCorrect,
      onFieldSubmitted: (_) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        } else {
          onSubmitted?.call();
        }
      },
      validator: validator,
      style: const TextStyle(color: AppPalette.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: AppPalette.textMuted),
        floatingLabelStyle: const TextStyle(
          color: AppPalette.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          color: AppPalette.textMuted.withAlpha((0.7 * 255).round()),
        ),
        errorStyle: const TextStyle(color: AppPalette.error, fontSize: 12),
        prefixIcon: Icon(icon, color: AppPalette.textMuted),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppPalette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: Color(0xFF6D28D9), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppPalette.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppPalette.error, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPasswordGuidelines({
    required String password,
    required String fullName,
    required String contact,
  }) {
    final requirements = _passwordRequirements(password, fullName, contact);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPalette.border),
      ),
      // child: Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //     const Text(
      //       'Password requirements',
      //       style: TextStyle(
      //         fontWeight: FontWeight.w600,
      //         color: AppPalette.textPrimary,
      //       ),
      //     ),
      //     const SizedBox(height: 8),
      //     for (final item in requirements) ...[
      //       _RequirementRow(label: item.label, met: item.met),
      //       const SizedBox(height: 4),
      //     ],
      //     const SizedBox(height: 6),
      //     const Text(
      //       'Example: MySecurePass123!',
      //       style: TextStyle(
      //         color: AppPalette.textPrimary,
      //         fontWeight: FontWeight.w600,
      //         fontSize: 12,
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  List<_RequirementItem> _passwordRequirements(
    String password,
    String fullName,
    String contact,
  ) {
    final lengthOk = password.length >= 8;
    final uppercaseOk = RegExp(r'[A-Z]').hasMatch(password);
    final lowercaseOk = RegExp(r'[a-z]').hasMatch(password);
    final numberOk = RegExp(r'[0-9]').hasMatch(password);
    final specialOk = RegExp(r'[!@#$%^&*]').hasMatch(password);
    final commonOk = !_isCommonPassword(password);
    final personalOk = !_containsPersonalInfo(password, fullName, contact);

    return [
      _RequirementItem(
        label: 'Minimum length 8 characters (better: 12+)',
        met: lengthOk,
      ),
      _RequirementItem(label: 'Uppercase letters (A-Z)', met: uppercaseOk),
      _RequirementItem(label: 'Lowercase letters (a-z)', met: lowercaseOk),
      _RequirementItem(label: 'Numbers (0-9)', met: numberOk),
      _RequirementItem(label: 'Special characters (!@#\$%^&*)', met: specialOk),
      _RequirementItem(
        label: 'No common passwords (123456, password, admin123)',
        met: commonOk,
      ),
      _RequirementItem(
        label: 'No personal information (name, phone, date of birth)',
        met: personalOk,
      ),
    ];
  }

  Widget _RequirementRow({required String label, required bool met}) {
    final color = met ? const Color(0xFF16A34A) : AppPalette.textMuted;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          met ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }



  String? _validateContact(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email or phone number is required';

    final isEmail = RegExp(
      r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
    ).hasMatch(text);
    final phoneDigits = text.replaceAll(RegExp(r'\D'), '');
    final isPhone = phoneDigits.length >= 8 && phoneDigits.length <= 15;

    if (!isEmail && !isPhone) {
      return 'Enter a valid email or phone number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Password is required';
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Add at least one uppercase letter (A-Z)';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Add at least one lowercase letter (a-z)';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Add at least one number (0-9)';
    }
    if (!RegExp(r'[!@#$%^&*]').hasMatch(password)) {
      return 'Add at least one special character (!@#\$%^&*)';
    }
    if (_isCommonPassword(password)) {
      return 'This password is too common';
    }
    if (_containsPersonalInfo(
      password,
      _fullNameCtrl.text,
      _contactCtrl.text,
    )) {
      return 'Do not use personal information in the password';
    }
    return null;
  }

  bool _containsPersonalInfo(
    String password,
    String fullName,
    String contact,
  ) {
    final lower = password.toLowerCase();
    final nameParts = fullName
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((part) => part.length >= 3);
    for (final part in nameParts) {
      if (lower.contains(part)) return true;
    }

    final digits = contact.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 3 && lower.contains(digits)) return true;
    if (digits.length >= 4 &&
        lower.contains(digits.substring(digits.length - 4))) {
      return true;
    }

    return false;
  }

  bool _isCommonPassword(String password) {
    const common = [
      '123456',
      'password',
      'admin123',
      'qwerty',
      'letmein',
      'welcome',
      'iloveyou',
    ];
    return common.contains(password.toLowerCase());
  }

  _PasswordStrength _passwordStrength(String password) {
    if (password.isEmpty) return _PasswordStrength.weak;
    if (_isCommonPassword(password)) return _PasswordStrength.weak;

    var score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*]').hasMatch(password)) score++;

    if (score >= 6) return _PasswordStrength.strong;
    if (score >= 4) return _PasswordStrength.medium;
    return _PasswordStrength.weak;
  }

  String _strengthLabel(_PasswordStrength strength) {
    switch (strength) {
      case _PasswordStrength.strong:
        return 'Strong';
      case _PasswordStrength.medium:
        return 'Medium';
      case _PasswordStrength.weak:
      default:
        return 'Weak';
    }
  }

  double _strengthValue(_PasswordStrength strength) {
    switch (strength) {
      case _PasswordStrength.strong:
        return 1.0;
      case _PasswordStrength.medium:
        return 0.66;
      case _PasswordStrength.weak:
      default:
        return 0.33;
    }
  }

  Color _strengthColor(_PasswordStrength strength) {
    switch (strength) {
      case _PasswordStrength.strong:
        return const Color(0xFF16A34A);
      case _PasswordStrength.medium:
        return const Color(0xFFF59E0B);
      case _PasswordStrength.weak:
      default:
        return const Color(0xFFEF4444);
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final fullName = _fullNameCtrl.text.trim();
    final nameParts = fullName.split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    final firstName = nameParts.isNotEmpty ? nameParts.first : 'User';
    final lastName = nameParts.length > 1
        ? nameParts.skip(1).join(' ')
        : 'Customer';

    final contact = _contactCtrl.text.trim();
    final error = await ApiService.register(
      firstName: firstName,
      lastName: lastName,
      email: contact,
      password: _passwordCtrl.text,
      confirmPassword: _confirmCtrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (error == null) {
      final type = _isPhone(contact) ? 'phone' : 'email';
      Navigator.push(context, _buildOtpRoute(contact, type));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  bool _isPhone(String text) {
    final digits = text.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 8 && digits.length <= 15;
  }

  Route<void> _buildOtpRoute(String destination, String type) {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 380),
      pageBuilder: (context, animation, secondaryAnimation) => OtpScreen(
        destination: destination,
        type: type,
        purpose: 'signup',
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
          reverseCurve: Curves.easeInOut,
        );
        final slideTween = Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: slideTween.animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class _RequirementItem {
  const _RequirementItem({required this.label, required this.met});

  final String label;
  final bool met;
}
