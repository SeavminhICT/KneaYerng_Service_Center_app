import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../theme/app_palette.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.resetToken});

  final String resetToken;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  static const double _fieldRadius = 22;
  static const double _buttonRadius = 24;

  static const Color _brandBlue = Color(0xFF5A67F8);
  static const Color _brandBlueDark = Color(0xFF4C5EF1);
  static const Color _surfaceAlt = Color(0xFFFDFDFF);
  static const Color _border = Color(0xFFE4E0E4);
  static const Color _textPrimary = Color(0xFF1B1738);
  static const Color _textMuted = Color(0xFF8B91A6);
  static const Color _iconMuted = Color(0xFF8B8588);

  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  late final FocusNode _passwordFocus;
  late final FocusNode _confirmPasswordFocus;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _passwordFocus = FocusNode();
    _confirmPasswordFocus = FocusNode();
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    final l = AppLocalizations.of(context);
    final password = value ?? '';
    if (password.isEmpty) return l.requiredField;
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
    final l = AppLocalizations.of(context);
    final confirm = value ?? '';
    if (confirm.isEmpty) return l.requiredField;
    if (confirm != _passwordCtrl.text) {
      return l.passwordsDoNotMatch;
    }
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (_loading || !_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final error = await ApiService.resetPasswordWithOtp(
      resetToken: widget.resetToken,
      password: _passwordCtrl.text,
      confirmPassword: _confirmPasswordCtrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password reset successfully. Please login.'),
      ),
    );

    // Navigate back to the login screen (clearing navigation history)
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final viewportHeight =
        mediaQuery.size.height - mediaQuery.padding.vertical - bottomInset - 36;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
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
                    padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: viewportHeight.clamp(0.0, double.infinity),
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 390),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                _buildBackButton(),
                                SizedBox(height: isCompact ? 12 : 20),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: _brandBlue.withAlpha(20),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.vpn_key_outlined,
                                      size: 28,
                                      color: _brandBlue,
                                    ),
                                  ),
                                ),
                                SizedBox(height: isCompact ? 16 : 24),
                                Text(
                                  l.resetPassword,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    color: _textPrimary,
                                    letterSpacing: -0.8,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Please create a strong new password.',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: _textMuted,
                                  ),
                                ),
                                SizedBox(height: isCompact ? 26 : 36),
                                _buildTextField(
                                  controller: _passwordCtrl,
                                  focusNode: _passwordFocus,
                                  nextFocus: _confirmPasswordFocus,
                                  hint: l.newPassword,
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
                                const SizedBox(height: 14),
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
                                SizedBox(height: isCompact ? 32 : 40),
                                _buildSubmitButton(l),
                                const SizedBox(height: 8),
                              ],
                            ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    required String hint,
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
      obscureText: obscure,
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

  Widget _buildSubmitButton(AppLocalizations l) {
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
                          l.resetPassword.toUpperCase(),
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
}
