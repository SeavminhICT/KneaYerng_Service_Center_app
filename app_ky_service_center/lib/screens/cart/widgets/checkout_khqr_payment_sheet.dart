import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:khqr_sdk/khqr_sdk.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/pickup_ticket.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_fonts.dart';
import '../../main_navigation_screen.dart';
import 'checkout_colors.dart';

/// Bottom sheet shown after placing a Bakong-QR order: renders the KHQR
/// code, polls the backend for payment status, and surfaces success /
/// failure / pickup-ticket actions. Self-contained: it only talks to
/// [ApiService] and pops the sheet with a bool result (paid or not) —
/// it has no knowledge of [CheckoutFlowScreen]'s state.
class CheckoutKhqrPaymentSheet extends StatefulWidget {
  const CheckoutKhqrPaymentSheet({
    super.key,
    required this.amount,
    required this.orderId,
    required this.orderType,
    required this.transactionId,
    required this.qrString,
    this.orderNumber,
    this.expiresAtIso,
  });

  final double amount;
  final int orderId;
  final String orderType;
  final String transactionId;
  final String qrString;
  final String? orderNumber;
  final String? expiresAtIso;

  @override
  State<CheckoutKhqrPaymentSheet> createState() =>
      _CheckoutKhqrPaymentSheetState();
}

class _CheckoutKhqrPaymentSheetState extends State<CheckoutKhqrPaymentSheet>
    with SingleTickerProviderStateMixin {
  static const Duration _checkInterval = Duration(seconds: 3);

  late AnimationController _entryController;
  late Animation<double> _entryFadeAnimation;
  late Animation<Offset> _entrySlideAnimation;

  bool _isChecking = false;
  bool _isSuccess = false;
  final bool _isScanned = false;
  bool _isTerminalFailure = false;
  bool _autoCheckStopped = false;
  bool _isOpeningTicket = false;
  int _checkAttempts = 0;
  int _maxCheckAttempts = 200;
  String? _lastStatus;
  String? _statusMessage;
  DateTime? _expiresAt;
  Timer? _checkTimer;
  Timer? _countdownTimer;

  bool _isSuccessStatus(String status) {
    switch (status.toUpperCase()) {
      case 'SUCCESS':
      case 'PAID':
      case 'COMPLETED':
      case 'APPROVED':
      case 'OK':
        return true;
      default:
        return false;
    }
  }

  bool _isFailureStatus(String status) {
    switch (status.toUpperCase()) {
      case 'FAILED':
      case 'INVALID_TRANSACTION':
      case 'EXPIRED':
      case 'TIMEOUT':
      case 'UNAUTHORIZED':
      case 'UNAVAILABLE':
      case 'CANCELLED':
      case 'CANCELED':
      case 'REJECTED':
        return true;
      default:
        return false;
    }
  }

  void _logKhqrEvent({
    required String event,
    String? status,
    String? message,
    String? fromBank,
    String? paidAtIso,
    double? amount,
    String? currency,
    String? bankHash,
  }) {
    final payload = <String, dynamic>{
      'event': event,
      'amount': (amount ?? widget.amount).toStringAsFixed(2),
      'currency': currency ?? 'USD',
      'fromBank': fromBank ?? 'unknown',
      'dateTime': paidAtIso ?? DateTime.now().toIso8601String(),
      'status': status,
      'md5': widget.transactionId,
    };
    if (bankHash != null && bankHash.isNotEmpty) {
      payload['bankHash'] = bankHash;
    }
    if (message != null && message.isNotEmpty) {
      payload['message'] = message;
    }
    debugPrint(jsonEncode(payload));
  }

  void _setStatusMessage(String? message) {
    if (!mounted || _statusMessage == message) return;
    setState(() {
      _statusMessage = message;
    });
  }

  @override
  void initState() {
    super.initState();
    _expiresAt = _parseExpiresAt(widget.expiresAtIso);
    _maxCheckAttempts = _deriveMaxAttempts();
    _statusMessage = 'Checking payment automatically...';

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _entryFadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _entrySlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.9, curve: Curves.easeOutBack),
    ));
    _entryController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startChecking();
      }
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _stopChecking();
    _stopCountdown();
    super.dispose();
  }

  DateTime? _parseExpiresAt(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      return DateTime.parse(value).toLocal();
    } catch (_) {
      return null;
    }
  }

  int _deriveMaxAttempts() {
    final expiresAt = _expiresAt;
    if (expiresAt == null) return 200;
    final remaining = expiresAt.difference(DateTime.now()).inSeconds;
    if (remaining <= 0) return 1;
    // Real stop condition is the QR's own expiry (`_isExpired`, checked every
    // tick); this is only a sanity ceiling so polling can't run away forever.
    // There's no manual "check now" button to fall back on, so this must
    // cover the full expiry window rather than cutting auto-check off early.
    final attempts = (remaining / _checkInterval.inSeconds).ceil() + 2;
    if (attempts < 10) return 10;
    if (attempts > 2000) return 2000;
    return attempts;
  }

  bool get _isExpired {
    final expiresAt = _expiresAt;
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt);
  }

  void _startChecking() {
    _stopChecking();
    _startCountdown();
    _autoCheckStopped = false;
    _checkAttempts = 0;
    _maxCheckAttempts = _deriveMaxAttempts();
    _checkStatus(fromTimer: true);
    _checkTimer = Timer.periodic(_checkInterval, (_) {
      if (!mounted || _isSuccess || _isTerminalFailure) {
        _stopChecking();
        return;
      }
      _checkStatus(fromTimer: true);
    });
  }

  void _stopChecking() {
    _checkTimer?.cancel();
    _checkTimer = null;
  }

  void _startCountdown() {
    _stopCountdown();
    if (_expiresAt == null) return;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _isSuccess || _isTerminalFailure) {
        _stopCountdown();
        return;
      }
      if (_isExpired) {
        _stopChecking();
        _stopCountdown();
        setState(() {
          _isTerminalFailure = true;
          _statusMessage = 'QR expired. Please generate a new one.';
          _lastStatus = 'EXPIRED';
        });
        _logKhqrEvent(event: 'expired', status: 'EXPIRED');
      }
      // No setState here for the non-expired tick: the countdown text below
      // repaints itself on its own timer so this screen doesn't rebuild
      // (and visibly "flash") every second.
    });
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  Future<void> _checkStatus({bool fromTimer = false}) async {
    if (_isChecking || _isSuccess || _isTerminalFailure) return;
    if (_checkAttempts >= _maxCheckAttempts) {
      if (fromTimer) {
        _stopChecking();
        _autoCheckStopped = true;
        _setStatusMessage('Payment pending. Automatic check paused.');
      }
      return;
    }
    if (_isExpired) {
      _stopChecking();
      _stopCountdown();
      setState(() {
        _isTerminalFailure = true;
        _statusMessage = 'QR expired. Please generate a new one.';
        _lastStatus = 'EXPIRED';
      });
      _logKhqrEvent(event: 'expired_on_check', status: 'EXPIRED');
      return;
    }

    _isChecking = true;
    _checkAttempts += 1;

    try {
      final result = await ApiService.checkKhqrTransaction(
        transactionId: widget.transactionId,
      );

      if (!mounted) return;
      _isChecking = false;

      final normStatus = result.status.toUpperCase();
      _lastStatus = normStatus;

      if (_isSuccessStatus(normStatus)) {
        _stopChecking();
        _stopCountdown();
        setState(() {
          _isSuccess = true;
          _statusMessage = 'Payment successful!';
        });
        _logKhqrEvent(
          event: 'paid',
          status: normStatus,
          message: result.message,
          fromBank: result.fromAccountId,
          paidAtIso: result.paidAtIso,
          amount: result.amount,
          currency: result.currency,
          bankHash: result.bakongHash,
        );
        return;
      }

      if (_isFailureStatus(normStatus)) {
        _stopChecking();
        _stopCountdown();
        setState(() {
          _isTerminalFailure = true;
          _statusMessage = _failureMessageForStatus(normStatus, result.message);
        });
        _logKhqrEvent(
          event: 'payment_failed',
          status: normStatus,
          message: result.message,
        );
        return;
      }

      if (normStatus == 'NOT_FOUND') {
        if (_isExpired) {
          _stopChecking();
          _stopCountdown();
          setState(() {
            _isTerminalFailure = true;
            _statusMessage = AppLocalizations.of(context).khqrQrExpired;
            _lastStatus = 'EXPIRED';
          });
          _logKhqrEvent(event: 'expired_not_found', status: 'EXPIRED');
        } else if (fromTimer) {
          if (_autoCheckStopped) {
            _setStatusMessage(AppLocalizations.of(context).khqrPendingPaused);
          } else {
            _setStatusMessage(AppLocalizations.of(context).khqrCheckingAuto);
          }
        } else {
          _setStatusMessage(result.message ?? AppLocalizations.of(context).khqrNoPaymentYet);
        }
        return;
      }

      _setStatusMessage(result.message ?? 'Status: ${result.status}');
    } catch (e) {
      if (!mounted) return;
      _isChecking = false;
      if (!fromTimer) {
        _setStatusMessage(AppLocalizations.of(context).khqrCheckFailed);
      }
    }
  }

  String _failureMessageForStatus(String status, String? serverMsg) {
    if (serverMsg != null && serverMsg.trim().isNotEmpty) {
      return serverMsg.trim();
    }
    final l = AppLocalizations.of(context);
    switch (status) {
      case 'EXPIRED':
      case 'TIMEOUT':
        return l.khqrQrExpired;
      case 'UNAUTHORIZED':
        return l.khqrSandboxUnauth;
      case 'UNAVAILABLE':
        return l.khqrSandboxUnavail;
      default:
        return l.khqrFailedDefault;
    }
  }

  bool get _shouldOfferPickupTicket =>
      _isSuccess && widget.orderType == 'pickup';

  Future<void> _openTicketDetail() async {
    if (_isOpeningTicket || widget.orderType != 'pickup') return;
    setState(() {
      _isOpeningTicket = true;
    });

    try {
      final ticket = await _findMatchingTicket();
      if (!mounted) return;
      setState(() {
        _isOpeningTicket = false;
      });

      if (ticket == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).khqrTicketNotReady),
          ),
        );
        return;
      }

      await Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => MainNavigationScreen(
            initialIndex: 0,
            initialPickupTicket: ticket,
          ),
        ),
        (_) => false,
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _isOpeningTicket = false;
        });
      }
    }
  }

  Future<PickupTicket?> _findMatchingTicket() async {
    for (int attempt = 0; attempt < 5; attempt++) {
      final tickets = await ApiService.fetchPickupTickets();
      for (final t in tickets) {
        if (t.orderId == widget.orderId) {
          return t;
        }
        if (widget.orderNumber != null &&
            widget.orderNumber!.isNotEmpty &&
            t.orderNumber == widget.orderNumber) {
          return t;
        }
      }
      await Future<void>.delayed(const Duration(milliseconds: 900));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bottomInset = 16 + MediaQuery.of(context).padding.bottom;
    final showFailure = _isTerminalFailure;
    final showQr = !_isSuccess && !_isScanned && !showFailure;
    final showScanned = !_isSuccess && _isScanned;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: checkoutSurface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: checkoutShadow(context),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(18, 10, 18, bottomInset),
        child: FadeTransition(
          opacity: _entryFadeAnimation,
          child: SlideTransition(
            position: _entrySlideAnimation,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4.5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isCheckoutDark(context)
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _isChecking
                            ? null
                            : () {
                                _stopChecking();
                                Navigator.of(context).pop(false);
                              },
                        icon: const Icon(
                          HugeIcons.strokeRoundedArrowLeft01,
                          size: 20,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: checkoutSurfaceAlt(context),
                          foregroundColor: checkoutInk(context),
                          minimumSize: const Size(38, 38),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: checkoutBorder(context),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Bakong KHQR',
                          style: kFont(
                            context,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: checkoutInk(context),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeInOutCubic,
                    switchOutCurve: Curves.easeInOutCubic,
                    child: showFailure
                        ? _buildFailedStep()
                        : showQr
                        ? _buildQrStep()
                        : showScanned
                        ? _buildScannedStep()
                        : _buildPaidStep(),
                  ),
                  if (_isSuccess || _isTerminalFailure) ...[
                    const SizedBox(height: 18),
                    _buildActionButtons(l),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQrStep() {
    final l = AppLocalizations.of(context);
    final expiresAt = _expiresAt;
    return Container(
      key: const ValueKey('qr-step'),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      l.khqrPayment,
                      style: kFont(
                        context,
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _qrMetaRow(l.khqrMerchant, 'KNEA YERNG SERVICE CENTER'),
                        const SizedBox(height: 8),
                        _qrMetaRow(
                          l.khqrAmount,
                          '\$${widget.amount.toStringAsFixed(2)} USD',
                        ),
                        const SizedBox(height: 8),
                        _qrMetaRow(
                          l.khqrReference,
                          '#${widget.transactionId.substring(0, 8).toUpperCase()}',
                        ),
                        const SizedBox(height: 8),
                        _qrMetaRow(l.khqrNetwork, 'Bakong KHQR'),
                        if (expiresAt != null) ...[
                          const SizedBox(height: 8),
                          _qrMetaTimerRow(l.khqrExpiresIn, expiresAt),
                        ],
                      ],
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: [
                      KhqrCardWidget(
                        width: 240,
                        qr: widget.qrString,
                        receiverName: 'KneaYerng Service Center',
                        amount: widget.amount,
                        currency: KhqrCurrency.usd,
                        duration: null,
                        isLoading: false,
                        isError: false,
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Align(
                            alignment: const Alignment(0, 0.42),
                            child: Container(
                              width: 46,
                              height: 46,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1.5,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x14000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/images/logo_bakong.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Positioned.fill(
                        child: IgnorePointer(
                          child: QrScannerOverlay(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l.khqrScanInstruction,
            textAlign: TextAlign.center,
            style: kFont(
              context,
              fontSize: 14,
              color: checkoutMuted(context),
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          if (_statusMessage != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _isTerminalFailure
                    ? const Color(0xFFFEF2F2)
                    : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: _isTerminalFailure
                      ? const Color(0xFFFECACA)
                      : const Color(0xFFBFDBFE),
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isTerminalFailure
                        ? const Color(0x0DDC2626)
                        : const Color(0x0D3B82F6),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_isTerminalFailure) ...[
                    const PulsingStatusDot(color: Color(0xFF3B82F6)),
                    const SizedBox(width: 10),
                  ] else ...[
                    const Icon(
                      HugeIcons.strokeRoundedAlertCircle,
                      color: Color(0xFFDC2626),
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      _statusMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: _isTerminalFailure
                            ? const Color(0xFFB91C1C)
                            : const Color(0xFF1E40AF),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _qrMetaRow(String label, String value, {bool isTimer = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: kFont(
              context,
              fontSize: 12,
              color: checkoutMuted(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: kFont(
            context,
            fontSize: 12,
            color: isTimer ? const Color(0xFFE11D48) : checkoutInk(context),
            fontWeight: FontWeight.w800,
            forceColor: isTimer,   // red countdown must show even in Khmer
          ),
        ),
      ],
    );
  }

  Widget _qrMetaTimerRow(String label, DateTime expiresAt) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: kFont(
              context,
              fontSize: 12,
              color: checkoutMuted(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _KhqrCountdownText(
          expiresAt: expiresAt,
          style: kFont(
            context,
            fontSize: 12,
            color: const Color(0xFFE11D48),
            fontWeight: FontWeight.w800,
            forceColor: true, // red countdown must show even in Khmer
          ),
        ),
      ],
    );
  }

  Widget _buildScannedStep() {
    return Container(
      key: const ValueKey('scanned-step'),
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            builder: (context, val, child) {
              return Transform.scale(
                scale: val,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 94,
                      height: 94,
                      decoration: BoxDecoration(
                        color: checkoutSurfaceAlt(context),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: checkoutBorder(context)),
                      ),
                      child: Icon(
                        HugeIcons.strokeRoundedQrCode01,
                        color: checkoutMuted(context),
                        size: 60,
                      ),
                    ),
                    const Positioned(
                      right: -4,
                      bottom: -4,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Color(0xFF0EA5E9),
                        child: Icon(
                          HugeIcons.strokeRoundedTick01,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context).khqrQrScanned,
            style: kFont(
              context,
              fontSize: 28,
              color: checkoutInk(context),
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).khqrCompleteInApp,
            style: kFont(
              context,
              fontSize: 14,
              color: checkoutMuted(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_statusMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const PulsingStatusDot(color: Color(0xFF0284C7)),
                  const SizedBox(width: 8),
                  Text(
                    _statusMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0369A1),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFailedStep() {
    final l = AppLocalizations.of(context);
    final message = _statusMessage ?? l.khqrFailedDefault;
    final isExpired =
        message.toLowerCase().contains('expired') ||
        _lastStatus == 'EXPIRED' ||
        _lastStatus == 'TIMEOUT';
    final isCheckError =
        _lastStatus == 'UNAUTHORIZED' || _lastStatus == 'UNAVAILABLE';

    return Container(
      key: const ValueKey('failed-step'),
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            builder: (context, val, child) {
              return Transform.scale(
                scale: val,
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFEF2F2),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x1ADB2777),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    HugeIcons.strokeRoundedAlertCircle,
                    color: Color(0xFFDC2626),
                    size: 44,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            isCheckError
                ? l.khqrBakongError
                : (isExpired ? l.khqrPaymentExpired : l.khqrPaymentFailed),
            style: kFont(
              context,
              fontSize: 28,
              color: checkoutInk(context),
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: kFont(
                context,
                fontSize: 14,
                color: const Color(0xFFDC2626),
                fontWeight: FontWeight.w700,
                forceColor: true,   // error red must show even in Khmer
              ),
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: checkoutSurfaceAlt(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: checkoutBorder(context)),
            ),
            child: Column(
              children: [
                _qrMetaRow(
                  l.khqrAmountDue,
                  '\$${widget.amount.toStringAsFixed(2)} USD',
                ),
                const SizedBox(height: 8),
                _qrMetaRow(
                  l.khqrReferenceCode,
                  '#${widget.transactionId.substring(0, 8).toUpperCase()}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaidStep() {
    return Container(
      key: const ValueKey('paid-step'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: checkoutSurface(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: checkoutBorder(context), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: checkoutShadow(context),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          const AnimatedSuccessCheck(size: 92),
          const SizedBox(height: 22),
          Text(
            AppLocalizations.of(context).khqrPaymentSuccessful,
            style: kFont(
              context,
              fontSize: 28,
              color: checkoutInk(context),
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).khqrPaymentProcessed,
            style: kFont(
              context,
              fontSize: 14,
              color: checkoutMuted(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.amount.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 46,
                  color: checkoutInk(context),
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'USD',
                  style: TextStyle(
                    fontSize: 16,
                    color: checkoutMuted(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          DashedDivider(color: checkoutBorder(context), height: 1.5),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: checkoutSurfaceAlt(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: checkoutBorder(context)),
            ),
            child: Column(
              children: [
                _SuccessReceiptRow(
                  label: AppLocalizations.of(context).khqrOrderId,
                  value: widget.orderNumber ?? '#${widget.orderId}',
                ),
                const SizedBox(height: 12),
                _SuccessReceiptRow(label: AppLocalizations.of(context).khqrPaymentMethod, value: 'Bakong KHQR'),
                const SizedBox(height: 12),
                _SuccessReceiptRow(
                  label: AppLocalizations.of(context).khqrReferenceCode,
                  value: '#${widget.transactionId.substring(0, 8).toUpperCase()}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(HugeIcons.strokeRoundedPdf01, size: 18),
            label: Text(AppLocalizations.of(context).khqrPdfComingSoon),
            style: OutlinedButton.styleFrom(
              disabledForegroundColor: checkoutMuted(context),
              side: BorderSide(color: checkoutBorder(context)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: kFont(context, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations l) {
    if (_isSuccess) {
      return Column(
        children: [
          if (_shouldOfferPickupTicket) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isOpeningTicket ? null : _openTicketDetail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _isOpeningTicket
                      ? l.khqrOpeningTicket
                      : l.khqrViewPickupTicket,
                  style: kFont(context, fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: isCheckoutDark(context) ? Colors.white : const Color(0xFF0F172A),
                foregroundColor: isCheckoutDark(context) ? const Color(0xFF0F172A) : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                l.done,
                style: kFont(context, fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
        ],
      );
    }

    if (_isTerminalFailure) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            side: BorderSide(color: checkoutBorder(context), width: 1.5),
            foregroundColor: checkoutInk(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            l.close,
            style: kFont(context, fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ),
      );
    }

    // Payment status is already checked automatically in the background and
    // surfaced via the pending pill above the QR — no manual "Checking
    // Payment..." button needed here.
    return const SizedBox.shrink();
  }
}

class _SuccessReceiptRow extends StatelessWidget {
  const _SuccessReceiptRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: kFont(
            context,
            fontSize: 12,
            color: checkoutMuted(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: kFont(
              context,
              fontSize: 12,
              color: checkoutInk(context),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// Custom Animation Widgets
// ==========================================

/// Ticks its own mm:ss display once a second without rebuilding the parent
/// sheet, so the rest of the payment screen stays static instead of
/// flashing on every countdown tick.
class _KhqrCountdownText extends StatefulWidget {
  const _KhqrCountdownText({required this.expiresAt, required this.style});

  final DateTime expiresAt;
  final TextStyle style;

  @override
  State<_KhqrCountdownText> createState() => _KhqrCountdownTextState();
}

class _KhqrCountdownTextState extends State<_KhqrCountdownText> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _text {
    final remaining = widget.expiresAt.difference(DateTime.now());
    if (remaining.isNegative) return '00:00';
    final minutes = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Text(_text, style: widget.style);
  }
}

class PulsingStatusDot extends StatefulWidget {
  const PulsingStatusDot({super.key, this.color = const Color(0xFF0F6BFF)});

  final Color color;

  @override
  State<PulsingStatusDot> createState() => _PulsingStatusDotState();
}

class _PulsingStatusDotState extends State<PulsingStatusDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 18 * (1.0 + _controller.value * 1.2),
              height: 18 * (1.0 + _controller.value * 1.2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: (1.0 - _controller.value) * 0.4),
              ),
            ),
            Container(
              width: 14 * (1.0 + _controller.value * 0.6),
              height: 14 * (1.0 + _controller.value * 0.6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: (1.0 - _controller.value) * 0.6),
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class QrScannerOverlay extends StatefulWidget {
  const QrScannerOverlay({super.key});

  @override
  State<QrScannerOverlay> createState() => _QrScannerOverlayState();
}

class _QrScannerOverlayState extends State<QrScannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final startY = height * 0.38;
        final endY = height * 0.92;
        final sweepHeight = endY - startY;

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final position = startY + (_controller.value * sweepHeight);
            return Stack(
              children: [
                Positioned(
                  top: position,
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFDC2626).withValues(alpha: 0.0),
                          const Color(0xFFDC2626).withValues(alpha: 0.8),
                          const Color(0xFFDC2626).withValues(alpha: 0.0),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFDC2626).withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class AnimatedSuccessCheck extends StatefulWidget {
  const AnimatedSuccessCheck({
    super.key,
    this.size = 88.0,
    this.color = const Color(0xFF10B981),
    this.onComplete,
  });

  final double size;
  final Color color;
  final VoidCallback? onComplete;

  @override
  State<AnimatedSuccessCheck> createState() => _AnimatedSuccessCheckState();
}

class _AnimatedSuccessCheckState extends State<AnimatedSuccessCheck>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _checkAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutQuad),
    );

    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _checkAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: _CheckmarkPainter(
                progress: _checkAnimation.value,
                color: Colors.white,
                strokeWidth: widget.size * 0.08,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  _CheckmarkPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final startX = size.width * 0.28;
    final startY = size.height * 0.5;
    final pivotX = size.width * 0.44;
    final pivotY = size.height * 0.66;
    final endX = size.width * 0.72;
    final endY = size.height * 0.36;

    path.moveTo(startX, startY);

    if (progress < 0.4) {
      final t = progress / 0.4;
      final currentX = startX + (pivotX - startX) * t;
      final currentY = startY + (pivotY - startY) * t;
      path.lineTo(currentX, currentY);
    } else {
      path.lineTo(pivotX, pivotY);
      final t = (progress - 0.4) / 0.6;
      final currentX = pivotX + (endX - pivotX) * t;
      final currentY = pivotY + (endY - pivotY) * t;
      path.lineTo(currentX, currentY);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key, this.height = 1, this.color = const Color(0xFFE2E8F0)});

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
