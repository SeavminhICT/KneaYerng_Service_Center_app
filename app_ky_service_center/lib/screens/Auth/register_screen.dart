import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../services/app_notification_service.dart';
import '../../services/cart_service.dart';
import '../../theme/app_palette.dart';
import '../../widgets/circle_back_button.dart';
import '../main_navigation_screen.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const double _fieldRadius = 14;
  static const double _buttonRadius = 24;
  static const double _fieldSpacing = 14;

  static const Color _brandBlue = Color(0xFF5A67F8);
  static const Color _brandBlueDark = Color(0xFF4C5EF1);
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
    final l = AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            // ── Gradient Header ──
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF3B63FF), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(36),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      CircleBackButton(
                        onPressed: () {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Image.asset(
                              'assets/images/Logo_KYSC.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.createAccount,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'Join KY Service Center today',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Form ──
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(20, 24, 20, bottomInset + 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextField(
                        controller: _fullNameCtrl,
                        focusNode: _fullNameFocus,
                        nextFocus: _emailFocus,
                        hint: l.fullName,
                        keyboard: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        prefixIcon: const Icon(
                          HugeIcons.strokeRoundedUser,
                          size: 22,
                          color: _iconMuted,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l.requiredField;
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
                          HugeIcons.strokeRoundedMail01,
                          size: 22,
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
                          HugeIcons.strokeRoundedSmartPhone01,
                          size: 22,
                          color: _iconMuted,
                        ),
                        validator: _validatePhone,
                      ),
                      const SizedBox(height: _fieldSpacing),
                      _buildTextField(
                        controller: _passwordCtrl,
                        focusNode: _passwordFocus,
                        nextFocus: _confirmPasswordFocus,
                        hint: l.password,
                        obscure: _obscurePassword,
                        enableSuggestions: false,
                        autoCorrect: false,
                        prefixIcon: const Icon(
                          HugeIcons.strokeRoundedSquareLock01,
                          size: 22,
                          color: _iconMuted,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? HugeIcons.strokeRoundedViewOffSlash
                                : HugeIcons.strokeRoundedView,
                            size: 22,
                            color: _iconMuted,
                          ),
                        ),
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: _fieldSpacing),
                      _buildTextField(
                        controller: _confirmPasswordCtrl,
                        focusNode: _confirmPasswordFocus,
                        hint: l.confirmPassword,
                        obscure: _obscureConfirm,
                        enableSuggestions: false,
                        autoCorrect: false,
                        textInputAction: TextInputAction.done,
                        onSubmitted: _submit,
                        prefixIcon: const Icon(
                          HugeIcons.strokeRoundedSquareLock01,
                          size: 22,
                          color: _iconMuted,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                          icon: Icon(
                            _obscureConfirm
                                ? HugeIcons.strokeRoundedViewOffSlash
                                : HugeIcons.strokeRoundedView,
                            size: 22,
                            color: _iconMuted,
                          ),
                        ),
                        validator: _validateConfirmPassword,
                      ),
                      const SizedBox(height: 28),
                      _buildSignUpButton(l),
                      const SizedBox(height: 22),
                      _buildOrDivider(),
                      const SizedBox(height: 18),
                      _buildGoogleButton(),
                      const SizedBox(height: 24),
                      _buildLoginPrompt(l),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpButton(AppLocalizations l) {
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
                      Center(
                        child: Text(
                          l.signUp.toUpperCase(),
                          style: const TextStyle(
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
                            HugeIcons.strokeRoundedArrowRight01,
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

  Widget _buildLoginPrompt(AppLocalizations l) {
    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '${l.alreadyHaveAccount} ',
            style: const TextStyle(
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
            child: Text(
              l.signIn,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: _textMuted,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        errorStyle: const TextStyle(color: AppPalette.error, fontSize: 12),
        prefixIcon: prefixIcon,
        prefixIconConstraints: const BoxConstraints(minWidth: 48),
        suffixIcon: suffixIcon,
        suffixIconConstraints: const BoxConstraints(minWidth: 48),
        filled: true,
        fillColor: _surfaceAlt,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
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
      return AppLocalizations.of(context).invalidEmail;
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return AppLocalizations.of(context).requiredField;
    final digits = text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 7) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return AppLocalizations.of(context).requiredField;
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
    if (confirm.isEmpty) return AppLocalizations.of(context).requiredField;
    if (confirm != _passwordCtrl.text) {
      return AppLocalizations.of(context).passwordsDoNotMatch;
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

    Navigator.push(
      context,
      _buildOtpRoute(phone, otpType, initialResendInSec: request.resendInSec),
    );
  }

  Future<void> _loginWithGoogle() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
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
        // Google accounts are already verified by the backend; no OTP needed.
        await AppNotificationService.instance.syncTokenWithBackend(force: true);
        unawaited(CartService.instance.loadFromApi());
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
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
    int? initialResendInSec,
  }) {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 380),
      pageBuilder: (context, animation, secondaryAnimation) => OtpScreen(
        destination: destination,
        type: type,
        purpose: 'signup',
        autoRequest: autoRequest,
        initialResendInSec: initialResendInSec,
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
