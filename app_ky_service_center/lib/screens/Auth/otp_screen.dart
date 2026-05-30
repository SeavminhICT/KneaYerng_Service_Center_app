import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  });

  final String destination;
  final String type;
  final String purpose;
  final bool autoRequest;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength = 6;
  static const Color _brandBlue = Color(0xFF5A67F8);
  static const Color _brandBlueDark = Color(0xFF4C5EF1);
  static const Color _surface = Colors.white;
  static const Color _textPrimary = Color(0xFF1B1738);
  static const Color _hint = Color(0xFFD8D6D8);
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
      // Start a 2-minute countdown automatically on entry
      _startResendCountdown(120);
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

    if (result.resendInSec != null && result.resendInSec! > 0) {
      _startResendCountdown(result.resendInSec!);
    } else {
      _startResendCountdown(120);
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
    final viewportHeight =
        mediaQuery.size.height - mediaQuery.padding.vertical - bottomInset - 36;
    final masked = _maskDestination(widget.destination, widget.type);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
              ),
            ),
            Positioned(
              top: -80,
              right: -30,
              child: IgnorePointer(
                child: _buildGlow(
                  size: 230,
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
                  size: 260,
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
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                    Icons.security_rounded,
                                    size: 28,
                                    color: _brandBlue,
                                  ),
                                ),
                              ),
                              SizedBox(height: isCompact ? 16 : 24),
                              Text(
                                l.otpVerification,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: _textPrimary,
                                  letterSpacing: -0.8,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'We\'ve sent you the verification\ncode on $masked',
                                style: const TextStyle(
                                  color: _textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: isCompact ? 30 : 40),
                              _buildOtpFields(),
                              SizedBox(height: isCompact ? 34 : 44),
                              _buildContinueButton(l),
                              const SizedBox(height: 28),
                              _buildResendSection(l),
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
        onPressed: () => Navigator.maybePop(context),
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
        constraints: const BoxConstraints.tightFor(width: 44, height: 44),
        splashRadius: 22,
        icon: const Icon(
          Icons.chevron_left_rounded,
          color: _textPrimary,
          size: 34,
        ),
      ),
    );
  }

  Widget _buildOtpFields() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final boxWidth = ((constraints.maxWidth - (spacing * (_otpLength - 1))) /
                _otpLength)
            .clamp(40.0, 56.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_otpLength, (index) {
            final hasValue = _controllers[index].text.isNotEmpty;
            final isFocused = _focusNodes[index].hasFocus;
            final borderColor = _hasError
                ? _error
                : (isFocused
                    ? _brandBlue
                    : (hasValue ? _brandBlue : const Color(0xFF5D6CFF)));

            return SizedBox(
              width: boxWidth,
              height: 72,
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
                ],
                maxLength: 1,
                textAlign: TextAlign.center,
                cursorColor: _brandBlue,
                style: TextStyle(
                  color: _hasError ? _error : _textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '-',
                  hintStyle: const TextStyle(
                    color: _hint,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                  filled: true,
                  fillColor: _surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: borderColor, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: _hasError ? _error : _brandBlue,
                      width: 1.7,
                    ),
                  ),
                ),
                onChanged: (value) => _handleOtpChange(index, value),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildContinueButton(AppLocalizations l) {
    return SizedBox(
      height: 64,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_brandBlue, _brandBlueDark],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x285A67F8),
              blurRadius: 22,
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
              borderRadius: BorderRadius.circular(24),
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
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.7,
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

  Widget _buildResendSection(AppLocalizations l) {
    if (_isResending) {
      return Center(
        child: Text(
          'Sending...',
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
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
                color: _textPrimary,
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
          l.resend,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
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
