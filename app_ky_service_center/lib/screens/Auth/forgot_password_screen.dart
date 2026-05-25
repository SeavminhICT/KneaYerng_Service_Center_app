import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../theme/app_palette.dart';
import 'otp_screen.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  static const double _fieldRadius = 22;
  static const double _buttonRadius = 24;
  static const double _cardRadius = 20;

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
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  late final FocusNode _phoneFocus;
  late final FocusNode _emailFocus;

  late TabController _tabController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _phoneFocus = FocusNode();
    _emailFocus = FocusNode();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _tabController.dispose();
    super.dispose();
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

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email address is required';

    final isEmail = RegExp(
      r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
    ).hasMatch(text);

    if (!isEmail) {
      return 'Enter a valid email address';
    }
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (_loading || !_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final isPhone = _tabController.index == 0;
    final destination = isPhone ? _phoneCtrl.text.trim() : _emailCtrl.text.trim();
    final type = isPhone ? 'phone' : 'email';

    final request = await ApiService.requestOtp(
      destination: destination,
      type: type,
      purpose: 'reset_password',
    );

    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(request.message)));

    if (!request.ok) return;

    final resetToken = await Navigator.push<String?>(
      context,
      _buildOtpRoute(destination, type),
    );

    if (!mounted || resetToken == null) return;

    // Navigate to reset password screen with the reset token
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(resetToken: resetToken),
      ),
    );
  }

  Route<String?> _buildOtpRoute(String destination, String type) {
    return PageRouteBuilder<String?>(
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 380),
      pageBuilder: (context, animation, secondaryAnimation) => OtpScreen(
        destination: destination,
        type: type,
        purpose: 'reset_password',
        autoRequest: false,
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

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final viewportHeight =
        mediaQuery.size.height - mediaQuery.padding.vertical - bottomInset - 36;

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
                                      Icons.lock_outline_rounded,
                                      size: 28,
                                      color: _brandBlue,
                                    ),
                                  ),
                                ),
                                SizedBox(height: isCompact ? 16 : 24),
                                const Text(
                                  'Forgot Password',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    color: _textPrimary,
                                    letterSpacing: -0.8,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Select verification method to request code.',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: _textMuted,
                                  ),
                                ),
                                SizedBox(height: isCompact ? 22 : 28),
                                _buildSelectorTabs(),
                                SizedBox(height: isCompact ? 24 : 32),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: _tabController.index == 0
                                      ? _buildTextField(
                                          key: const ValueKey('phoneField'),
                                          controller: _phoneCtrl,
                                          focusNode: _phoneFocus,
                                          hint: '+855 xx xxx xxx',
                                          keyboard: TextInputType.phone,
                                          prefixIcon: const Icon(
                                            Icons.phone_outlined,
                                            size: 24,
                                            color: _iconMuted,
                                          ),
                                          validator: _validatePhone,
                                        )
                                      : _buildTextField(
                                          key: const ValueKey('emailField'),
                                          controller: _emailCtrl,
                                          focusNode: _emailFocus,
                                          hint: 'abc@email.com',
                                          keyboard: TextInputType.emailAddress,
                                          prefixIcon: const Icon(
                                            Icons.mail_outline_rounded,
                                            size: 24,
                                            color: _iconMuted,
                                          ),
                                          validator: _validateEmail,
                                        ),
                                ),
                                SizedBox(height: isCompact ? 32 : 40),
                                _buildSubmitButton(),
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

  Widget _buildSelectorTabs() {
    final isPhone = _tabController.index == 0;
    return Container(
      height: 60,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EFF4),
        borderRadius: BorderRadius.circular(_cardRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(0);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isPhone ? _surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(_cardRadius - 4),
                  boxShadow: isPhone
                      ? const [
                          BoxShadow(
                            color: Color(0x0C5A67F8),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 20,
                      color: isPhone ? _brandBlue : _textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Phone',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isPhone ? _brandBlue : _textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(1);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: !isPhone ? _surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(_cardRadius - 4),
                  boxShadow: !isPhone
                      ? const [
                          BoxShadow(
                            color: Color(0x0C5A67F8),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.mail_outline_rounded,
                      size: 20,
                      color: !isPhone ? _brandBlue : _textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: !isPhone ? _brandBlue : _textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required Key key,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
    Widget? prefixIcon,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboard,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _submit(),
      cursorColor: _brandBlue,
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

  Widget _buildSubmitButton() {
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
                          'SEND CODE',
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
}
