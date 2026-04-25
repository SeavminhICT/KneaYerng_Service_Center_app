import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_palette.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const double _radius = 16;
  static const double _cardRadius = 22;
  static const double _fieldSpacing = 10;

  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  late final FocusNode _fullNameFocus;
  late final FocusNode _contactFocus;
  late final FocusNode _phoneFocus;
  late final FocusNode _passwordFocus;
  late final FocusNode _confirmPasswordFocus;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fullNameFocus = FocusNode();
    _contactFocus = FocusNode();
    _phoneFocus = FocusNode();
    _passwordFocus = FocusNode();
    _confirmPasswordFocus = FocusNode();
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _contactCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();

    _fullNameFocus.dispose();
    _contactFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2F6BFF), Color(0xFF18C7CC)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(
                                      (0.2 * 255).round(),
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.shield_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'KneaYerng',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                18,
                                18,
                                18,
                                18,
                              ),
                              decoration: BoxDecoration(
                                color: AppPalette.surface,
                                borderRadius: BorderRadius.circular(
                                  _cardRadius,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(
                                      (0.08 * 255).round(),
                                    ),
                                    blurRadius: 22,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Center(
                                    child: Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        color: AppPalette.textPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Already have an account? ',
                                          style: TextStyle(
                                            color: AppPalette.textMuted,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          style: TextButton.styleFrom(
                                            foregroundColor: const Color(
                                              0xFF2F6BFF,
                                            ),
                                            padding: EdgeInsets.zero,
                                            minimumSize: const Size(0, 0),
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: const Text(
                                            'Login',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  _buildTextField(
                                    controller: _fullNameCtrl,
                                    focusNode: _fullNameFocus,
                                    nextFocus: _contactFocus,
                                    label: 'Full Name',
                                    hint: 'Lois Becket',
                                    keyboard: TextInputType.name,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Full name is required';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: _fieldSpacing),
                                  _buildTextField(
                                    controller: _contactCtrl,
                                    focusNode: _contactFocus,
                                    nextFocus: _phoneFocus,
                                    label: 'Email (optional)',
                                    hint: 'loisbecket@gmail.com',
                                    keyboard: TextInputType.emailAddress,
                                    validator: _validateContact,
                                  ),
                                  const SizedBox(height: _fieldSpacing),
                                  _buildTextField(
                                    controller: _phoneCtrl,
                                    focusNode: _phoneFocus,
                                    nextFocus: _passwordFocus,
                                    label: 'Phone Number (optional)',
                                    hint: '(+855) 726-0592',
                                    keyboard: TextInputType.phone,
                                    prefixIcon: const SizedBox(
                                      width: 48,
                                      child: Center(
                                        child: Text(
                                          '\u{1F1F0}\u{1F1ED}',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ),
                                    validator: _validatePhoneOptional,
                                  ),
                                  const SizedBox(height: _fieldSpacing),
                                  _buildTextField(
                                    controller: _passwordCtrl,
                                    focusNode: _passwordFocus,
                                    nextFocus: _confirmPasswordFocus,
                                    label: 'Password',
                                    hint: '********',
                                    obscure: _obscurePassword,
                                    enableSuggestions: false,
                                    autoCorrect: false,
                                    validator: _validatePassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: AppPalette.textMuted,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: _fieldSpacing),
                                  _buildTextField(
                                    controller: _confirmPasswordCtrl,
                                    focusNode: _confirmPasswordFocus,
                                    label: 'Confirm Password',
                                    hint: '********',
                                    obscure: _obscureConfirm,
                                    enableSuggestions: false,
                                    autoCorrect: false,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: _submit,
                                    validator: _validateConfirmPassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirm
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: AppPalette.textMuted,
                                      ),
                                      onPressed: () => setState(
                                        () =>
                                            _obscureConfirm = !_obscureConfirm,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF2F6BFF,
                                        ),
                                        foregroundColor: Colors.white,
                                        elevation: 3,
                                        shadowColor: const Color(
                                          0xFF2F6BFF,
                                        ).withAlpha((0.3 * 255).round()),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            _radius,
                                          ),
                                        ),
                                      ),
                                      onPressed: _loading ? null : _submit,
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        child: _loading
                                            ? const SizedBox(
                                                key: ValueKey('loading'),
                                                width: 22,
                                                height: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2.4,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : const Text(
                                                'Sign Up',
                                                key: ValueKey('text'),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    required String label,
    required String hint,
    TextInputType keyboard = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscure = false,
    TextInputAction textInputAction = TextInputAction.next,
    VoidCallback? onSubmitted,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    Widget? prefixIcon,
    bool enableSuggestions = true,
    bool autoCorrect = true,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppPalette.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboard,
          obscureText: obscure,
          textCapitalization: textCapitalization,
          textInputAction: textInputAction,
          enableSuggestions: enableSuggestions,
          autocorrect: autoCorrect,
          readOnly: readOnly,
          onTap: onTap,
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
            hintText: hint,
            hintStyle: TextStyle(
              color: AppPalette.textMuted.withAlpha((0.75 * 255).round()),
            ),
            errorStyle: const TextStyle(color: AppPalette.error, fontSize: 12),
            prefixIcon: prefixIcon,
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
              borderSide: const BorderSide(
                color: Color(0xFF2F6BFF),
                width: 1.5,
              ),
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
        ),
      ],
    );
  }

  String? _validateContact(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      if (_phoneCtrl.text.trim().isEmpty) {
        return 'Email or phone is required';
      }
      return null;
    }

    final isEmail = RegExp(
      r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
    ).hasMatch(text);

    if (!isEmail) {
      return 'Enter a valid email address';
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
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Add at least one number (0-9)';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final confirm = value ?? '';
    if (confirm.isEmpty) return 'Confirm your password';
    if (confirm != _passwordCtrl.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validatePhoneOptional(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      if (_contactCtrl.text.trim().isEmpty) {
        return 'Email or phone is required';
      }
      return null;
    }
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  // bool _isCommonPassword(String password) {
  //   const common = [
  //     '123456',
  //     'password',
  //     'admin123',
  //     'qwerty',
  //     'letmein',
  //     'welcome',
  //     'iloveyou',
  //   ];
  //   return common.contains(password.toLowerCase());
  // }

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
    final phone = _phoneCtrl.text.trim();
    final error = await ApiService.register(
      firstName: firstName,
      lastName: lastName,
      email: contact,
      phone: phone,
      password: _passwordCtrl.text,
      confirmPassword: _confirmPasswordCtrl.text,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    final otpDestination = phone.isNotEmpty ? phone : contact;
    final otpType = phone.isNotEmpty ? 'phone' : 'email';
    final request = await ApiService.requestOtp(
      destination: otpDestination,
      type: otpType,
      purpose: 'signup',
    );

    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(request.message)));

    if (!request.ok) return;

    Navigator.push(context, _buildOtpRoute(otpDestination, otpType));
  }

  Route<void> _buildOtpRoute(
    String destination,
    String type, {
    bool autoRequest = false,
  }) {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 380),
      pageBuilder: (context, animation, secondaryAnimation) => OtpScreen(
        destination: destination,
        type: type,
        purpose: 'signup',
        autoRequest: autoRequest,
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
