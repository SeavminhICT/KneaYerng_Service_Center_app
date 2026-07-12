import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../services/app_notification_service.dart';
import '../main_navigation_screen.dart';
import 'registration_success_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.destination,
    this.type = 'phone',
    this.purpose = 'signup',
    this.autoRequest = false,
    this.initialResendInSec,
  });

  final String destination;
  final String type;
  final String purpose;
  final bool autoRequest;
  final int? initialResendInSec;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength = 6;
  static const Color _brandBlue = Color(0xFF5865F2);
  static const Color _brandBlueDark = Color(0xFF4654E9);
  static const Color _background = Color(0xFFF1F7FE);
  static const Color _surface = Colors.white;
  static const Color _textPrimary = Color(0xFF171A38);
  static const Color _textSecondary = Color(0xFF626A7D);
  static const Color _hint = Color(0xFFD4D8E2);
  static const Color _error = Color(0xFFEF4444);

  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  late final List<FocusNode> _focusNodes;

  Timer? _resendTimer;
  bool _isLoading = false;
  bool _isResending = false;
  int _resendInSec = 0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
    for (final node in _focusNodes) {
      node.addListener(_handleFocusStateChange);
    }
    if (widget.autoRequest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestOtp();
      });
    } else {
      _startResendCountdown(widget.initialResendInSec ?? 120);
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final node in _focusNodes) {
      node
        ..removeListener(_handleFocusStateChange)
        ..dispose();
    }
    super.dispose();
  }

  void _handleFocusStateChange() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _requestOtp() async {
    if (_isResending || _resendInSec > 0) return;
    setState(() => _isResending = true);

    final result = await ApiService.requestOtp(
      destination: widget.destination,
      type: widget.type,
      purpose: widget.purpose,
    );

    if (!mounted) return;
    setState(() => _isResending = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));

    if (result.ok) {
      _startResendCountdown(
        result.resendInSec != null && result.resendInSec! > 0
            ? result.resendInSec!
            : 120,
      );
    }
  }

  void _startResendCountdown(int seconds) {
    _resendTimer?.cancel();
    setState(() => _resendInSec = seconds);

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendInSec <= 1) {
        timer.cancel();
        setState(() => _resendInSec = 0);
      } else {
        setState(() => _resendInSec--);
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (_isLoading) return;
    final otp = _controllers.map((e) => e.text).join();

    if (otp.length < _otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full OTP code.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    final result = await ApiService.verifyOtp(
      destination: widget.destination,
      type: widget.type,
      purpose: widget.purpose,
      otp: otp,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!result.ok) {
      setState(() {
        _hasError = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
      return;
    }

    if (widget.purpose == 'signup') {
      await AppNotificationService.instance.syncTokenWithBackend(force: true);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const RegistrationSuccessScreen()),
        (_) => false,
      );
      return;
    }

    if (widget.purpose == 'login') {
      await AppNotificationService.instance.syncTokenWithBackend(force: true);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (_) => false,
      );
      return;
    }

    Navigator.of(context).pop(result.resetToken);
  }

  void _handleOtpChange(int index, String value) {
    if (_hasError) {
      setState(() {
        _hasError = false;
      });
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) {
      _controllers[index].clear();
      if (index > 0) {
        FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      }
      return;
    }

    if (digits.length >= _otpLength) {
      for (var i = 0; i < _otpLength; i++) {
        _controllers[i].text = digits[i];
      }
      FocusScope.of(context).unfocus();
      _maybeAutoVerify();
      return;
    }

    if (digits.length > 1) {
      for (var i = 0; i < digits.length && (index + i) < _otpLength; i++) {
        _controllers[index + i].text = digits[i];
      }

      final nextIndex = index + digits.length;
      if (nextIndex < _otpLength) {
        FocusScope.of(context).requestFocus(_focusNodes[nextIndex]);
      } else {
        FocusScope.of(context).unfocus();
      }
      _maybeAutoVerify();
      return;
    }

    if (digits != value) {
      _controllers[index].text = digits;
      _controllers[index].selection = const TextSelection.collapsed(offset: 1);
    }

    if (index < _otpLength - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else {
      FocusScope.of(context).unfocus();
    }

    _maybeAutoVerify();
  }

  void _maybeAutoVerify() {
    if (_isLoading) return;
    final otp = _controllers.map((e) => e.text).join();
    if (otp.length == _otpLength) {
      _verifyOtp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final masked = _maskDestination(widget.destination, widget.type);

    return Scaffold(
      backgroundColor: _background,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -85,
              child: IgnorePointer(
                child: Container(
                  width: 270,
                  height: 270,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0x55FFFFFF), Color(0x00FFFFFF)],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: -100,
              bottom: -110,
              child: IgnorePointer(
                child: Container(
                  width: 310,
                  height: 310,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0x245865F2), Color(0x005865F2)],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxHeight < 700;
                  final isKeyboardOpen = bottomInset > 0;
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      24,
                      isCompact ? 8 : 16,
                      24,
                      bottomInset + 24,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            (constraints.maxHeight -
                                    bottomInset -
                                    (isCompact ? 32 : 48))
                                .clamp(0.0, double.infinity),
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 460),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildBackButton(),
                              SizedBox(height: isCompact ? 10 : 24),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFE8EDFF),
                                        Color(0xFFDCE5FF),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x105865F2),
                                        blurRadius: 18,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    HugeIcons.strokeRoundedSecurityCheck,
                                    size: 30,
                                    color: _brandBlue,
                                  ),
                                ),
                              ),
                              SizedBox(height: isCompact ? 18 : 28),
                              Text(
                                l.otpVerification,
                                style: Theme.of(context).textTheme.headlineLarge
                                    ?.copyWith(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w700,
                                      color: _textPrimary,
                                      letterSpacing: -1.1,
                                      height: 1.1,
                                    ),
                              ),
                              const SizedBox(height: 18),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text:
                                          'We sent a 6-digit verification code to\n',
                                    ),
                                    TextSpan(
                                      text: masked,
                                      style: const TextStyle(
                                        color: _textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: _textSecondary,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                      height: 1.5,
                                    ),
                              ),
                              SizedBox(height: isCompact ? 28 : 44),
                              _buildOtpFields(),
                              SizedBox(height: isCompact ? 28 : 42),
                              _buildContinueButton(l),
                              const SizedBox(height: 26),
                              _buildResendSection(l),
                              if (!isKeyboardOpen)
                                SizedBox(height: isCompact ? 8 : 28),
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

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.maybePop(context),
          borderRadius: BorderRadius.circular(14),
          child: const SizedBox(
            width: 46,
            height: 46,
            child: Icon(
              HugeIcons.strokeRoundedArrowLeft01,
              color: _textPrimary,
              size: 31,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpFields() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 9.0;
        final boxWidth =
            ((constraints.maxWidth - (spacing * (_otpLength - 1))) / _otpLength)
                .clamp(30.0, 61.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_otpLength, (index) {
            final hasValue = _controllers[index].text.isNotEmpty;
            final isFocused = _focusNodes[index].hasFocus;
            final borderColor = _hasError
                ? _error
                : (isFocused
                      ? _brandBlue
                      : (hasValue
                            ? const Color(0xFF7A84F8)
                            : const Color(0xFF9AA4EF)));

            return AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: boxWidth,
              height: 74,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: isFocused
                    ? const [
                        BoxShadow(
                          color: Color(0x205865F2),
                          blurRadius: 14,
                          offset: Offset(0, 7),
                        ),
                      ]
                    : const [],
              ),
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                autofocus: index == 0,
                keyboardType: TextInputType.number,
                textInputAction: index == _otpLength - 1
                    ? TextInputAction.done
                    : TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(_otpLength),
                ],
                maxLength: _otpLength,
                textAlign: TextAlign.center,
                cursorColor: _brandBlue,
                style: TextStyle(
                  color: _hasError ? _error : _textPrimary,
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '–',
                  hintStyle: const TextStyle(
                    color: _hint,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                  filled: true,
                  fillColor: _surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: borderColor, width: 1.45),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: _hasError ? _error : _brandBlue,
                      width: 1.8,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: _error, width: 1.6),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: _error, width: 1.8),
                  ),
                ),
                onChanged: (value) => _handleOtpChange(index, value),
                onSubmitted: (_) {
                  if (index == _otpLength - 1) {
                    _verifyOtp();
                  }
                },
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildContinueButton(AppLocalizations l) {
    return SizedBox(
      height: 62,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_brandBlue, _brandBlueDark],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x385865F2),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _verifyOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white70,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: _isLoading
                ? const SizedBox(
                    key: ValueKey('loading'),
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.3,
                      color: Colors.white,
                    ),
                  )
                : Stack(
                    key: const ValueKey('ready'),
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: Text(
                          l.continueText.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.9,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withAlpha(22),
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

  Widget _buildResendSection(AppLocalizations l) {
    if (_isResending) {
      return const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(color: _brandBlue, strokeWidth: 2.2),
        ),
      );
    }

    if (_resendInSec > 0) {
      return Center(
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              'Re-send code in ',
              style: TextStyle(
                color: _textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _formatCountdown(_resendInSec),
              style: const TextStyle(
                color: _brandBlue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: TextButton(
        onPressed: _requestOtp,
        style: TextButton.styleFrom(
          foregroundColor: _brandBlue,
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          '${l.resend} code',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  String _formatCountdown(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _maskDestination(String destination, String type) {
    final text = destination.trim();
    if (type == 'phone') {
      if (text.length <= 4) return text;
      final suffix = text.substring(text.length - 3);
      return '*** *** $suffix';
    }

    final parts = text.split('@');
    if (parts.length != 2 || parts[0].isEmpty) return text;
    final head = parts[0];
    final maskedHead = head.length <= 2
        ? '${head[0]}*'
        : '${head.substring(0, 2)}${'*' * (head.length - 2)}';
    return '$maskedHead@${parts[1]}';
  }
}
