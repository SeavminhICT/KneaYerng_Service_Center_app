import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../services/api_service.dart';
import '../../services/app_notification_service.dart';
import '../../theme/app_palette.dart';
import '../main_navigation_screen.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const double _fieldRadius = 22;
  static const double _buttonRadius = 24;
  static const double _fieldSpacing = 14;

  static const Color _brandBlue = Color(0xFF5A67F8);
  static const Color _brandBlueDark = Color(0xFF4C5EF1);
  static const Color _background = Color(0xFFFAFBFF);
  static const Color _surface = Colors.white;
  static const Color _surfaceAlt = Color(0xFFFDFDFF);
  static const Color _border = Color(0xFFE4E0E4);
  static const Color _textPrimary = Color(0xFF1B1738);
  static const Color _textMuted = Color(0xFF8B91A6);
  static const Color _iconMuted = Color(0xFF8B8588);

  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  late final FocusNode _fullNameFocus;
  late final FocusNode _emailFocus;
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
    _emailFocus = FocusNode();
    _phoneFocus = FocusNode();
    _passwordFocus = FocusNode();
    _confirmPasswordFocus = FocusNode();
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();

    _fullNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final viewportHeight =
        mediaQuery.size.height - mediaQuery.padding.vertical - bottomInset - 28;

    return Scaffold(
      backgroundColor: _background,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(color: _background),
              ),
            ),
            Positioned(
              top: -80,
              right: -30,
              child: IgnorePointer(
                child: _buildGlow(
                  size: 220,
                  colors: const [
                    Color(0x16FFD9CF),
                    Color(0x0CFFFFFF),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              left: -70,
              bottom: 20,
              child: IgnorePointer(
                child: _buildGlow(
                  size: 250,
                  colors: const [
                    Color(0x185A67F8),
                    Color(0x0CF3F6FF),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxHeight < 760;

                  final isKeyboardOpen = bottomInset > 0;
                  return SingleChildScrollView(
                    physics: isKeyboardOpen
                        ? const ClampingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(20, 8, 20, bottomInset + 20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: viewportHeight.clamp(0.0, double.infinity),
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 390),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _buildBackButton(),
                              SizedBox(height: isCompact ? 14 : 24),
                              const Text(
                                'Sign up',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  color: _textPrimary,
                                  letterSpacing: -0.8,
                                ),
                              ),
                              SizedBox(height: isCompact ? 22 : 28),
                              _buildTextField(
                                controller: _fullNameCtrl,
                                focusNode: _fullNameFocus,
                                nextFocus: _emailFocus,
                                hint: 'Full name',
                                keyboard: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                                prefixIcon: const Icon(
                                  Icons.person_outline_rounded,
                                  size: 24,
                                  color: _iconMuted,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Full name is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: _fieldSpacing),
                              _buildTextField(
                                controller: _emailCtrl,
                                focusNode: _emailFocus,
                                nextFocus: _phoneFocus,
                                hint: 'Email (Optional)',
                                keyboard: TextInputType.emailAddress,
                                prefixIcon: const Icon(
                                  Icons.mail_outline_rounded,
                                  size: 24,
                                  color: _iconMuted,
                                ),
                                validator: _validateEmail,
                              ),
                              const SizedBox(height: _fieldSpacing),
                              _buildTextField(
                                controller: _phoneCtrl,
                                focusNode: _phoneFocus,
                                nextFocus: _passwordFocus,
                                hint: '+855 xx xxx xxx',
                                keyboard: TextInputType.phone,
                                prefixIcon: const Icon(
                                  Icons.phone_outlined,
                                  size: 24,
                                  color: _iconMuted,
                                ),
                                validator: _validatePhone,
                              ),
                              const SizedBox(height: _fieldSpacing),
                              _buildTextField(
                                controller: _passwordCtrl,
                                focusNode: _passwordFocus,
                                nextFocus: _confirmPasswordFocus,
                                hint: 'Your password',
                                obscure: _obscurePassword,
                                enableSuggestions: false,
                                autoCorrect: false,
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                  size: 24,
                                  color: _iconMuted,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 24,
                                    color: const Color(0xFFD4D0D1),
                                  ),
                                ),
                                validator: _validatePassword,
                              ),
                              const SizedBox(height: _fieldSpacing),
                              _buildTextField(
                                controller: _confirmPasswordCtrl,
                                focusNode: _confirmPasswordFocus,
                                hint: 'Confirm password',
                                obscure: _obscureConfirm,
                                enableSuggestions: false,
                                autoCorrect: false,
                                textInputAction: TextInputAction.done,
                                onSubmitted: _submit,
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                  size: 24,
                                  color: _iconMuted,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirm = !_obscureConfirm;
                                    });
                                  },
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 24,
                                    color: const Color(0xFFD4D0D1),
                                  ),
                                ),
                                validator: _validateConfirmPassword,
                              ),
                              SizedBox(height: isCompact ? 24 : 32),
                              _buildSignUpButton(),
                              SizedBox(height: isCompact ? 20 : 24),
                              _buildOrDivider(),
                              const SizedBox(height: 18),
                              _buildGoogleButton(),
                              const SizedBox(height: 22),
                              _buildLoginPrompt(),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlow({required double size, required List<Color> colors}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: RadialGradient(radius: 0.72, colors: colors),
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        splashRadius: 24,
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: _textPrimary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      height: 64,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_brandBlue, _brandBlueDark],
          ),
          borderRadius: BorderRadius.circular(_buttonRadius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x285A67F8),
              blurRadius: 22,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _loading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white70,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_buttonRadius),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
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
                : Stack(
                    key: const ValueKey('ready'),
                    alignment: Alignment.center,
                    children: [
                      const Center(
                        child: Text(
                          'SIGN UP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withAlpha(22),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 24,
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

  Widget _buildOrDivider() {
    return const Center(
      child: Text(
        'OR',
        style: TextStyle(
          color: Color(0xFF9F9FA9),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      height: 62,
      child: OutlinedButton(
        onPressed: _loading ? null : _loginWithGoogle,
        style: OutlinedButton.styleFrom(
          backgroundColor: _surface,
          side: const BorderSide(color: Colors.transparent),
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F1B1738),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/google-color.png',
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 14),
              const Text(
                'Continue with Google',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'Already have an account? ',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: _brandBlue,
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Sign in',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
      cursorColor: _brandBlue,
      onFieldSubmitted: (_) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
          return;
        }
        onSubmitted?.call();
      },
      validator: validator,
      style: const TextStyle(
        color: _textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: _textMuted,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        errorStyle: const TextStyle(color: AppPalette.error, fontSize: 12),
        prefixIcon: prefixIcon,
        prefixIconConstraints: const BoxConstraints(minWidth: 56),
        suffixIcon: suffixIcon,
        suffixIconConstraints: const BoxConstraints(minWidth: 56),
        filled: true,
        fillColor: _surfaceAlt,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          borderSide: const BorderSide(color: _border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          borderSide: const BorderSide(color: _brandBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          borderSide: const BorderSide(color: AppPalette.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          borderSide: const BorderSide(color: AppPalette.error, width: 1.2),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;

    final isEmail = RegExp(
      r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
    ).hasMatch(text);

    if (!isEmail) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Phone number is required';
    final digits = text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 7) {
      return 'Enter a valid phone number';
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

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (_loading || !_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final fullName = _fullNameCtrl.text.trim();
    final nameParts = fullName.split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    final firstName = nameParts.isNotEmpty ? nameParts.first : 'User';
    final lastName = nameParts.length > 1
        ? nameParts.skip(1).join(' ')
        : 'Customer';

    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final error = await ApiService.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
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

    // Send OTP to phone for signup verification
    const otpType = 'phone';
    final request = await ApiService.requestOtp(
      destination: phone,
      type: otpType,
      purpose: 'signup',
    );

    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(request.message)));

    if (!request.ok) return;

    Navigator.push(context, _buildOtpRoute(phone, otpType));
  }

  Future<void> _loginWithGoogle() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      final account = await googleSignIn.signIn();
      if (account == null) {
        setState(() => _loading = false);
        return;
      }

      final email = account.email;
      final displayName = account.displayName ?? '';
      final photoUrl = account.photoUrl;

      String firstName = '';
      String lastName = '';
      if (displayName.trim().isNotEmpty) {
        final parts = displayName.trim().split(' ');
        if (parts.length > 1) {
          firstName = parts.first;
          lastName = parts.sublist(1).join(' ');
        } else {
          firstName = displayName;
          lastName = '';
        }
      } else {
        firstName = email.split('@').first;
        lastName = '';
      }

      final error = await ApiService.loginWithGoogle(
        email: email,
        firstName: firstName,
        lastName: lastName,
        avatar: photoUrl,
      );

      if (!mounted) return;
      setState(() => _loading = false);

      if (error == null) {
        await AppNotificationService.instance.syncTokenWithBackend(force: true);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } catch (error) {
      debugPrint('Google Sign-In Error: $error');
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In failed: $error')),
        );
      }
    }
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
