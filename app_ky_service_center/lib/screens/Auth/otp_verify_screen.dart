import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../theme/app_palette.dart';
import 'login_screen.dart';

// ─── Design tokens ───────────────────────────────────────────────────────────
const _primary = Color(0xFF5198F5);
const _primaryDk = Color(0xFF3A7DE0);
const _bg = Color(0xFFF8F9FC);
const _surface = Color(0xFFFFFFFF);
const _border = Color(0xFFE5E7EB);
const _textHead = Color(0xFF111827);
const _textSub = Color(0xFF6B7280);
const _iconMuted = Color(0xFF9CA3AF);

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();

  late final TabController _tab;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _tab.dispose();
    super.dispose();
  }

  bool get _isPhone => _tab.index == 0;

  String? _validatePhone(String? v) {
    final l = AppLocalizations.of(context);
    final t = v?.trim() ?? '';
    if (t.isEmpty) return l.requiredField;
    final digits = t.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 8 || digits.length > 15) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  String? _validateEmail(String? v) {
    final l = AppLocalizations.of(context);
    final t = v?.trim() ?? '';
    if (t.isEmpty) return l.requiredField;
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(t)) {
      return l.invalidEmail;
    }
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_loading || !_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final dest = _isPhone ? _phoneCtrl.text.trim() : _emailCtrl.text.trim();
    final type = _isPhone ? 'phone' : 'email';

    final req = await ApiService.sendForgotPasswordOtp(identifier: dest);

    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(req.message)));

    if (!req.ok) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpVerifyScreen(
          destination: dest,
          type: type,
          purpose: 'reset_password',
          initialResendInSec: req.resendInSec,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: _bg,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              24,
              16,
              24,
              MediaQuery.of(context).viewInsets.bottom + 28,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.vertical -
                    60,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    _BackBtn(),
                    const SizedBox(height: 20),

                    // Step indicator
                    _StepIndicator(current: 0),
                    const SizedBox(height: 28),

                    // Icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        color: _primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      l.forgotPassword,
                      style: kFont(context, 
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: _textHead,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your phone or email to receive\na verification code.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: _textSub,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Tab selector
                    _MethodSelector(tab: _tab),
                    const SizedBox(height: 22),

                    // Input field
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: _isPhone
                          ? _InputField(
                              key: const ValueKey('phone'),
                              controller: _phoneCtrl,
                              focusNode: _phoneFocus,
                              hint: '+855 xx xxx xxx',
                              icon: Icons.phone_outlined,
                              keyboard: TextInputType.phone,
                              validator: _validatePhone,
                              onSubmit: _submit,
                            )
                          : _InputField(
                              key: const ValueKey('email'),
                              controller: _emailCtrl,
                              focusNode: _emailFocus,
                              hint: 'your@email.com',
                              icon: Icons.mail_outline_rounded,
                              keyboard: TextInputType.emailAddress,
                              validator: _validateEmail,
                              onSubmit: _submit,
                            ),
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    _PrimaryBtn(
                      label: l.sendResetLink.toUpperCase(),
                      loading: _loading,
                      onTap: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  OTP Verify Screen
// ─────────────────────────────────────────────────────────────────────────────
class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({
    super.key,
    required this.destination,
    required this.type,
    required this.purpose,
    this.initialResendInSec,
  });

  final String destination;
  final String type;
  final String purpose;
  final int? initialResendInSec;

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  static const int _len = 6;

  final List<TextEditingController> _ctrs = List.generate(
    _len,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _nodes = List.generate(_len, (_) => FocusNode());

  bool _loading = false;
  bool _hasError = false;
  bool _resending = false;
  int _countdown = 120;
  bool _allFilled = false;
  String _errorMessage = 'Invalid OTP. Please try again.';

  @override
  void initState() {
    super.initState();
    for (final n in _nodes) {
      n.addListener(_onFocusChange);
    }
    _startCountdown(widget.initialResendInSec ?? 120);
  }

  @override
  void dispose() {
    for (final c in _ctrs) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.removeListener(_onFocusChange);
      n.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() => setState(() {});

  void _startCountdown([int seconds = 120]) {
    _countdown = seconds;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _countdown--);
      return _countdown > 0;
    });
  }

  Future<void> _resend() async {
    if (_resending || _countdown > 0) return;
    setState(() => _resending = true);
    final r = widget.purpose == 'reset_password'
        ? await ApiService.sendForgotPasswordOtp(identifier: widget.destination)
        : await ApiService.requestOtp(
            destination: widget.destination,
            type: widget.type,
            purpose: widget.purpose,
          );
    if (!mounted) return;
    setState(() => _resending = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(r.message)));
    if (r.ok) _startCountdown(r.resendInSec ?? 120);
  }

  void _onChanged(int index, String value) {
    if (_hasError) setState(() => _hasError = false);

    final digits = value.replaceAll(RegExp(r'\D'), '');

    // Paste full OTP
    if (digits.length >= _len) {
      for (var i = 0; i < _len; i++) {
        _ctrs[i].text = digits[i];
      }
      FocusScope.of(context).unfocus();
      _checkAndVerify();
      return;
    }

    if (digits.isEmpty) {
      _ctrs[index].clear();
      if (index > 0) _nodes[index - 1].requestFocus();
      _updateFilled();
      return;
    }

    _ctrs[index].text = digits[0];
    _ctrs[index].selection = const TextSelection.collapsed(offset: 1);

    if (index < _len - 1) {
      _nodes[index + 1].requestFocus();
    } else {
      FocusScope.of(context).unfocus();
    }
    _checkAndVerify();
  }

  void _updateFilled() {
    final filled = _ctrs.every((c) => c.text.isNotEmpty);
    if (filled != _allFilled) setState(() => _allFilled = filled);
  }

  void _checkAndVerify() {
    final otp = _ctrs.map((c) => c.text).join();
    setState(() => _allFilled = otp.length == _len);
    if (otp.length == _len && !_loading) _verify();
  }

  Future<void> _verify() async {
    if (_loading) return;
    final otp = _ctrs.map((c) => c.text).join();
    if (otp.length < _len) return;

    setState(() {
      _loading = true;
      _hasError = false;
    });

    final result = widget.purpose == 'reset_password'
        ? await ApiService.verifyForgotPasswordOtp(
            identifier: widget.destination,
            otp: otp,
          )
        : await ApiService.verifyOtp(
            destination: widget.destination,
            type: widget.type,
            purpose: widget.purpose,
            otp: otp,
          );

    if (!mounted) return;
    setState(() => _loading = false);

    if (!result.ok) {
      setState(() {
        _hasError = true;
        _errorMessage = result.message;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
      return;
    }

    if (widget.purpose == 'reset_password') {
      final resetToken = result.resetToken;
      if (resetToken == null || resetToken.isEmpty) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Unable to start password reset. Please try again.';
        });
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordNewScreen(resetToken: resetToken),
        ),
      );
      return;
    }

    Navigator.of(context).pop(result.resetToken);
  }

  String _mask() {
    final t = widget.destination.trim();
    if (widget.type == 'phone') {
      if (t.length <= 4) return t;
      return '*** *** ${t.substring(t.length - 3)}';
    }
    final parts = t.split('@');
    if (parts.length != 2) return t;
    final h = parts[0];
    final mh = h.length <= 2
        ? '${h[0]}*'
        : '${h.substring(0, 2)}${'*' * (h.length - 2)}';
    return '$mh@${parts[1]}';
  }

  String _fmt(int s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              24,
              16,
              24,
              MediaQuery.of(context).viewInsets.bottom + 28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BackBtn(),
                const SizedBox(height: 20),
                _StepIndicator(current: 1),
                const SizedBox(height: 28),

                // Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: _primary,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Verification',
                  style: kFont(context, 
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: _textHead,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: _textSub,
                      height: 1.6,
                    ),
                    children: [
                      const TextSpan(text: 'We sent a 6-digit code to\n'),
                      TextSpan(
                        text: _mask(),
                        style: const TextStyle(
                          color: _primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // OTP boxes
                _buildOtpRow(),
                const SizedBox(height: 12),

                // Error hint
                AnimatedOpacity(
                  opacity: _hasError ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: AppPalette.error,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppPalette.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Verify button
                _PrimaryBtn(
                  label: 'VERIFY CODE',
                  loading: _loading,
                  enabled: _allFilled,
                  onTap: _verify,
                ),
                const SizedBox(height: 28),

                // Resend
                Center(
                  child: _countdown > 0
                      ? RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: _textSub,
                            ),
                            children: [
                              const TextSpan(text: 'Resend code in '),
                              TextSpan(
                                text: _fmt(_countdown),
                                style: const TextStyle(
                                  color: _primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _resending
                      ? Text(
                          'Sending...',
                          style: GoogleFonts.inter(color: _textSub),
                        )
                      : GestureDetector(
                          onTap: _resend,
                          child: Text(
                            'Resend code',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: _primary,
                              fontWeight: FontWeight.w700,
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

  Widget _buildOtpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_len, (i) {
        final hasVal = _ctrs[i].text.isNotEmpty;
        final focused = _nodes[i].hasFocus;
        final isError = _hasError;

        Color borderColor;
        Color bgColor;
        if (isError) {
          borderColor = AppPalette.error;
          bgColor = AppPalette.error.withValues(alpha: 0.05);
        } else if (hasVal) {
          borderColor = _primary;
          bgColor = _primary.withValues(alpha: 0.06);
        } else if (focused) {
          borderColor = _primary;
          bgColor = _surface;
        } else {
          borderColor = _border;
          bgColor = _surface;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 46,
          height: 58,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
              width: hasVal || focused ? 2.0 : 1.5,
            ),
            boxShadow: (hasVal && !isError)
                ? [
                    BoxShadow(
                      color: _primary.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: _ctrs[i],
            focusNode: _nodes[i],
            autofocus: i == 0,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 6,
            textAlign: TextAlign.center,
            cursorColor: _primary,
            style: kFont(context, 
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isError ? AppPalette.error : _textHead,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: '-',
              hintStyle: TextStyle(
                fontSize: 28,
                color: Color(0xFFD1D5DB),
                fontWeight: FontWeight.w400,
              ),
            ),
            onChanged: (v) => _onChanged(i, v),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Reset Password New Screen
// ─────────────────────────────────────────────────────────────────────────────
class ResetPasswordNewScreen extends StatefulWidget {
  const ResetPasswordNewScreen({super.key, required this.resetToken});
  final String resetToken;

  @override
  State<ResetPasswordNewScreen> createState() => _ResetPasswordNewScreenState();
}

class _ResetPasswordNewScreenState extends State<ResetPasswordNewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pwCtrl = TextEditingController();
  final _cfCtrl = TextEditingController();
  final _pwFocus = FocusNode();
  final _cfFocus = FocusNode();

  bool _obscurePw = true;
  bool _obscureCf = true;
  bool _loading = false;

  int _strength = 0; // 0-4

  @override
  void initState() {
    super.initState();
    _pwCtrl.addListener(_calcStrength);
  }

  @override
  void dispose() {
    _pwCtrl.removeListener(_calcStrength);
    _pwCtrl.dispose();
    _cfCtrl.dispose();
    _pwFocus.dispose();
    _cfFocus.dispose();
    super.dispose();
  }

  void _calcStrength() {
    final p = _pwCtrl.text;
    int s = 0;
    if (p.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(p)) s++;
    if (RegExp(r'[0-9]').hasMatch(p)) s++;
    if (RegExp(r'[!@#\$&*~%^()_+=\-\[\]{}|;:,.<>?]').hasMatch(p)) s++;
    setState(() => _strength = s);
  }

  String? _validatePw(String? v) {
    final l = AppLocalizations.of(context);
    final p = v ?? '';
    if (p.isEmpty) return l.requiredField;
    if (p.length < 8) return 'Minimum 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(p)) {
      return 'Add at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(p)) return 'Add at least one number';
    return null;
  }

  String? _validateCf(String? v) {
    final l = AppLocalizations.of(context);
    if (v == null || v.isEmpty) return l.requiredField;
    if (v != _pwCtrl.text) return l.passwordsDoNotMatch;
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_loading || !_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final error = await ApiService.resetForgotPassword(
      resetPasswordToken: widget.resetToken,
      newPassword: _pwCtrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    // Show the success sheet, then return to login.
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => _SuccessSheet(),
    );

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
    final strengthLabels = ['Weak', 'Fair', 'Good', 'Strong'];
    final strengthColors = [
      const Color(0xFFEF4444),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFF059669),
    ];

    return Scaffold(
      backgroundColor: _bg,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              24,
              16,
              24,
              MediaQuery.of(context).viewInsets.bottom + 28,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BackBtn(),
                  const SizedBox(height: 20),
                  _StepIndicator(current: 2),
                  const SizedBox(height: 28),

                  // Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.vpn_key_rounded,
                      color: _primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    l.newPassword,
                    style: kFont(context, 
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: _textHead,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a strong password that you\nhaven\'t used before.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: _textSub,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // New password
                  _PasswordField(
                    controller: _pwCtrl,
                    focusNode: _pwFocus,
                    nextFocus: _cfFocus,
                    hint: l.newPassword,
                    obscure: _obscurePw,
                    onToggle: () => setState(() => _obscurePw = !_obscurePw),
                    validator: _validatePw,
                  ),

                  // Strength bar
                  if (_pwCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: List.generate(4, (i) {
                        final filled = i < _strength;
                        return Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: 4,
                            margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                            decoration: BoxDecoration(
                              color: filled
                                  ? strengthColors[(_strength - 1).clamp(0, 3)]
                                  : const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    if (_strength > 0)
                      Text(
                        strengthLabels[(_strength - 1).clamp(0, 3)],
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: strengthColors[(_strength - 1).clamp(0, 3)],
                        ),
                      ),
                  ],
                  const SizedBox(height: 14),

                  // Confirm password
                  _PasswordField(
                    controller: _cfCtrl,
                    focusNode: _cfFocus,
                    hint: l.confirmPassword,
                    obscure: _obscureCf,
                    onToggle: () => setState(() => _obscureCf = !_obscureCf),
                    validator: _validateCf,
                    textInputAction: TextInputAction.done,
                    onSubmit: _submit,
                  ),
                  const SizedBox(height: 10),

                  // Requirements list
                  _ReqRow(
                    label: 'At least 8 characters',
                    met: _pwCtrl.text.length >= 8,
                  ),
                  _ReqRow(
                    label: 'One uppercase letter (A-Z)',
                    met: RegExp(r'[A-Z]').hasMatch(_pwCtrl.text),
                  ),
                  _ReqRow(
                    label: 'One number (0-9)',
                    met: RegExp(r'[0-9]').hasMatch(_pwCtrl.text),
                  ),

                  const SizedBox(height: 32),

                  _PrimaryBtn(
                    label: l.resetPassword.toUpperCase(),
                    loading: _loading,
                    onTap: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Success sheet
// ─────────────────────────────────────────────────────────────────────────────
class _SuccessSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF10B981),
              size: 42,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Password Reset!',
            style: kFont(context, 
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _textHead,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Password reset successfully. Please login.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _textSub,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                l.back,
                style: kFont(context, 
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shared widgets
// ─────────────────────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current});
  final int current; // 0 = method, 1 = otp, 2 = new pw

  static const _labels = ['Method', 'Verify', 'Reset'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        final done = i < current;
        final active = i == current;
        return Expanded(
          child: Row(
            children: [
              // Circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? _primary
                      : active
                      ? _primary.withValues(alpha: 0.12)
                      : const Color(0xFFF3F4F6),
                  border: Border.all(
                    color: done || active ? _primary : _border,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: done
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        )
                      : Text(
                          '${i + 1}',
                          style: kFont(context, 
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: active ? _primary : _iconMuted,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _labels[i],
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: active || done
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: active || done ? _primary : _textSub,
                      ),
                    ),
                    if (i < 2)
                      Container(
                        height: 2,
                        margin: const EdgeInsets.only(top: 4, right: 8),
                        decoration: BoxDecoration(
                          color: done ? _primary : _border,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _MethodSelector extends StatelessWidget {
  const _MethodSelector({required this.tab});
  final TabController tab;

  @override
  Widget build(BuildContext context) {
    final isPhone = tab.index == 0;
    return Container(
      height: 54,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _Tab(
            icon: Icons.phone_outlined,
            label: 'Phone',
            active: isPhone,
            onTap: () => tab.animateTo(0),
          ),
          _Tab(
            icon: Icons.mail_outline_rounded,
            label: 'Email',
            active: !isPhone,
            onTap: () => tab.animateTo(1),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: active ? _surface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: active ? _primary : _iconMuted),
              const SizedBox(width: 6),
              Text(
                label,
                style: kFont(context, 
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: active ? _primary : _iconMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.icon,
    required this.keyboard,
    required this.validator,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final IconData icon;
  final TextInputType keyboard;
  final String? Function(String?)? validator;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboard,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => onSubmit(),
      cursorColor: _primary,
      validator: validator,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: _textHead,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 15, color: _iconMuted),
        prefixIcon: Icon(icon, color: _iconMuted, size: 20),
        prefixIconConstraints: const BoxConstraints(minWidth: 52),
        filled: true,
        fillColor: _surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        errorStyle: GoogleFonts.inter(fontSize: 12, color: AppPalette.error),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppPalette.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppPalette.error, width: 1.5),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.focusNode,
    this.nextFocus,
    required this.hint,
    required this.obscure,
    required this.onToggle,
    required this.validator,
    this.textInputAction = TextInputAction.next,
    this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocus;
  final String hint;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      textInputAction: textInputAction,
      enableSuggestions: false,
      autocorrect: false,
      cursorColor: _primary,
      onFieldSubmitted: (_) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        } else {
          onSubmit?.call();
        }
      },
      validator: validator,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: _textHead,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 15, color: _iconMuted),
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          color: _iconMuted,
          size: 20,
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 52),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20,
            color: _iconMuted,
          ),
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 52),
        filled: true,
        fillColor: _surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        errorStyle: GoogleFonts.inter(fontSize: 12, color: AppPalette.error),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppPalette.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppPalette.error, width: 1.5),
        ),
      ),
    );
  }
}

class _ReqRow extends StatelessWidget {
  const _ReqRow({required this.label, required this.met});
  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: met ? const Color(0xFF10B981) : _border,
            ),
            child: met
                ? const Icon(Icons.check_rounded, size: 10, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: met ? const Color(0xFF10B981) : _textSub,
              fontWeight: met ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  const _PrimaryBtn({
    required this.label,
    required this.loading,
    required this.onTap,
    this.enabled = true,
  });
  final String label;
  final bool loading;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: enabled
                ? [_primary, _primaryDk]
                : [
                    _primary.withValues(alpha: 0.4),
                    _primaryDk.withValues(alpha: 0.4),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: _primary.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: ElevatedButton(
          onPressed: (loading || !enabled) ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: loading
                ? const SizedBox(
                    key: ValueKey('spin'),
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    key: const ValueKey('label'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: kFont(context, 
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _BackBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.maybePop(context),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: _textHead,
          size: 18,
        ),
      ),
    );
  }
}

// NOTE: LoginScreen is imported from login_screen.dart
