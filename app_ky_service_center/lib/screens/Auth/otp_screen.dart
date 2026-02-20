import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../theme/app_palette.dart';
import '../main_navigation_screen.dart';
import 'registration_success_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.destination,
    this.type = 'email',
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
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  Timer? _resendTimer;
  bool _isLoading = false;
  bool _isResending = false;
  int _resendInSec = 0;

  @override
  void initState() {
    super.initState();
    if (widget.autoRequest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestOtp();
      });
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
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
    setState(() {
      _isResending = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));

    if (result.resendInSec != null && result.resendInSec! > 0) {
      _startResendCountdown(result.resendInSec!);
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
    final otp = _controllers.map((e) => e.text).join();

    if (otp.length < 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter full OTP')));
      return;
    }

    setState(() => _isLoading = true);
    final result = await ApiService.verifyOtp(
      destination: widget.destination,
      type: widget.type,
      purpose: widget.purpose,
      otp: otp,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!result.ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
      return;
    }

    if (widget.purpose == 'signup') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const RegistrationSuccessScreen()),
        (_) => false,
      );
      return;
    }

    if (widget.purpose == 'login') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (_) => false,
      );
      return;
    }

    Navigator.of(context).pop(result.resetToken);
  }

  @override
  Widget build(BuildContext context) {
    final masked = _maskDestination(widget.destination, widget.type);

    return Scaffold(
      backgroundColor: AppPalette.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppPalette.primarySoft,
                      AppPalette.background,
                      AppPalette.background,
                    ],
                    stops: const [0, 0.45, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -90,
              right: -70,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppPalette.primary.withAlpha((0.08 * 255).round()),
                ),
              ),
            ),
            Positioned(
              bottom: -120,
              left: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppPalette.primary.withAlpha((0.06 * 255).round()),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
                      decoration: BoxDecoration(
                        color: AppPalette.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppPalette.border),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withAlpha((0.05 * 255).round()),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppPalette.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppPalette.border),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back),
                                tooltip: 'Back',
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 64,
                            width: 64,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppPalette.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppPalette.border),
                            ),
                            child: Image.asset(
                              'assets/images/Logo_KYSC.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'KNEAYERNG MOBILE APP',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppPalette.textPrimary,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Verify your account',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppPalette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Enter the 6-digit code sent to\n$masked',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppPalette.textMuted,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              return SizedBox(
                                width: 44,
                                child: TextField(
                                  controller: _controllers[index],
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    filled: true,
                                    fillColor: AppPalette.surface,
                                    contentPadding:
                                        const EdgeInsets.symmetric(vertical: 12),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppPalette.border,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppPalette.primary,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (value.isNotEmpty && index < 5) {
                                      FocusScope.of(context).nextFocus();
                                    }
                                  },
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 26),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _verifyOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppPalette.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Verify',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextButton(
                            onPressed: (_isResending || _resendInSec > 0)
                                ? null
                                : _requestOtp,
                            child: Text(
                              _resendInSec > 0
                                  ? 'Resend OTP in ${_resendInSec}s'
                                  : (_isResending
                                      ? 'Sending...'
                                      : 'Resend OTP'),
                              style: const TextStyle(
                                color: AppPalette.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
