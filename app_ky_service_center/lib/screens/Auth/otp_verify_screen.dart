import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../theme/app_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../theme/app_palette.dart';
import 'login_screen.dart';
import 'widgets/otp_back_button.dart';
import 'widgets/otp_code_row.dart';
import 'widgets/otp_design_tokens.dart';
import 'widgets/otp_input_field.dart';
import 'widgets/otp_method_selector.dart';
import 'widgets/otp_password_field.dart';
import 'widgets/otp_primary_button.dart';
import 'widgets/otp_progress_header.dart';
import 'widgets/otp_requirement_row.dart';
import 'widgets/otp_success_sheet.dart';

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
      backgroundColor: otpSurface,
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
                    const OtpBackBtn(),
                    const SizedBox(height: 24),

                    // Progress
                    const OtpProgressHeader(current: 0),
                    const SizedBox(height: 28),

                    Text(
                      l.forgotPassword,
                      style: kFont(context,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: otpTextHead,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your phone or email to receive a verification code.',
                      style: kmFont(context, GoogleFonts.inter(
                        fontSize: 14,
                        color: otpTextSub,
                        height: 1.6,
                      )),
                    ),
                    const SizedBox(height: 28),

                    // Tab selector
                    OtpMethodSelector(tab: _tab),
                    const SizedBox(height: 22),

                    // Input field
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: _isPhone
                          ? OtpInputField(
                              key: const ValueKey('phone'),
                              controller: _phoneCtrl,
                              focusNode: _phoneFocus,
                              hint: '+855 xx xxx xxx',
                              icon: HugeIcons.strokeRoundedSmartPhone01,
                              keyboard: TextInputType.phone,
                              validator: _validatePhone,
                              onSubmit: _submit,
                            )
                          : OtpInputField(
                              key: const ValueKey('email'),
                              controller: _emailCtrl,
                              focusNode: _emailFocus,
                              hint: 'your@email.com',
                              icon: HugeIcons.strokeRoundedMail01,
                              keyboard: TextInputType.emailAddress,
                              validator: _validateEmail,
                              onSubmit: _submit,
                            ),
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    OtpPrimaryBtn(
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
      backgroundColor: otpSurface,
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
                const OtpBackBtn(),
                const SizedBox(height: 24),
                const OtpProgressHeader(current: 1),
                const SizedBox(height: 28),

                Text(
                  'Verification',
                  style: kFont(context,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: otpTextHead,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: kmFont(context, GoogleFonts.inter(
                      fontSize: 14,
                      color: otpTextSub,
                      height: 1.6,
                    )),
                    children: [
                      const TextSpan(text: 'We sent a 6-digit code to '),
                      TextSpan(
                        text: _mask(),
                        style: const TextStyle(
                          color: otpPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // OTP boxes
                OtpCodeRow(
                  length: _len,
                  controllers: _ctrs,
                  focusNodes: _nodes,
                  hasError: _hasError,
                  onChanged: _onChanged,
                ),
                const SizedBox(height: 12),

                // Error hint
                AnimatedOpacity(
                  opacity: _hasError ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Row(
                    children: [
                      const Icon(
                        HugeIcons.strokeRoundedInformationCircle,
                        size: 14,
                        color: AppPalette.error,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: kmFont(context, GoogleFonts.inter(
                            fontSize: 12,
                            color: AppPalette.error,
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Verify button
                OtpPrimaryBtn(
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
                            style: kmFont(context, GoogleFonts.inter(
                              fontSize: 14,
                              color: otpTextSub,
                            )),
                            children: [
                              const TextSpan(text: 'Resend code in '),
                              TextSpan(
                                text: _fmt(_countdown),
                                style: const TextStyle(
                                  color: otpPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _resending
                      ? Text(
                          'Sending...',
                          style: kmFont(context, GoogleFonts.inter(color: otpTextSub)),
                        )
                      : GestureDetector(
                          onTap: _resend,
                          child: Text(
                            'Resend code',
                            style: kmFont(context, GoogleFonts.inter(
                              fontSize: 14,
                              color: otpPrimary,
                              fontWeight: FontWeight.w700,
                            )),
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
      builder: (_) => const OtpSuccessSheet(),
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
      backgroundColor: otpSurface,
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
                  const OtpBackBtn(),
                  const SizedBox(height: 24),
                  const OtpProgressHeader(current: 2),
                  const SizedBox(height: 28),

                  Text(
                    l.newPassword,
                    style: kFont(context,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: otpTextHead,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a strong password that you haven\'t used before.',
                    style: kmFont(context, GoogleFonts.inter(
                      fontSize: 14,
                      color: otpTextSub,
                      height: 1.6,
                    )),
                  ),
                  const SizedBox(height: 28),

                  // New password
                  OtpPasswordField(
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
                        style: kmFont(context, GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: strengthColors[(_strength - 1).clamp(0, 3)],
                        )),
                      ),
                  ],
                  const SizedBox(height: 14),

                  // Confirm password
                  OtpPasswordField(
                    controller: _cfCtrl,
                    focusNode: _cfFocus,
                    hint: l.confirmPassword,
                    obscure: _obscureCf,
                    onToggle: () => setState(() => _obscureCf = !_obscureCf),
                    validator: _validateCf,
                    textInputAction: TextInputAction.done,
                    onSubmit: _submit,
                  ),
                  const SizedBox(height: 14),

                  // Requirements list
                  OtpReqRow(
                    label: 'At least 8 characters',
                    met: _pwCtrl.text.length >= 8,
                  ),
                  OtpReqRow(
                    label: 'One uppercase letter (A-Z)',
                    met: RegExp(r'[A-Z]').hasMatch(_pwCtrl.text),
                  ),
                  OtpReqRow(
                    label: 'One number (0-9)',
                    met: RegExp(r'[0-9]').hasMatch(_pwCtrl.text),
                  ),

                  const SizedBox(height: 32),

                  OtpPrimaryBtn(
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

// NOTE: LoginScreen is imported from login_screen.dart
