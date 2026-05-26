import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../services/api_service.dart';
import '../../services/app_notification_service.dart';
import '../../theme/app_palette.dart';
import '../main_navigation_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const double _radius = 18;
  static const double _panelRadius = 30;
  static const double _fieldSpacing = 16;
  static const Color _brandBlue = Color(0xFF4A88F7);
  static const Color _brandBlueSoft = Color(0xFF96B5F2);
  static const Color _background = Color(0xFFF5F7FB);
  static const Color _surface = Colors.white;
  static const Color _surfaceAlt = Color(0xFFF9FBFF);
  static const Color _border = Color(0xFFE6ECF5);
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _iconMuted = Color(0xFF97A2B5);

  bool rememberMe = false;
  bool obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading = false;
  final TextEditingController _otpDestinationCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _otpDestinationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);

    final error = await ApiService.login(
      identifier: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
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
        await AppNotificationService.instance.syncTokenWithBackend(force: true);
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

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final viewportHeight =
        mediaQuery.size.height - mediaQuery.padding.vertical - bottomInset - 48;

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
              top: -120,
              right: -90,
              child: IgnorePointer(
                child: _buildGlow(
                  size: 250,
                  colors: const [
                    Color(0x284A88F7),
                    Color(0x1496B5F2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              left: -110,
              bottom: 110,
              child: IgnorePointer(
                child: _buildGlow(
                  size: 290,
                  colors: const [
                    Color(0x1A4A88F7),
                    Color(0x12EAF1FF),
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
                    padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset + 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: viewportHeight.clamp(0.0, double.infinity),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 380),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: isCompact ? 8 : 24),
                                _buildLogoBadge(),
                                SizedBox(height: isCompact ? 28 : 38),
                                const Text(
                                  'Sign in',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    color: _textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Continue to your service account.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _textMuted,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildAuthPanel(),
                                SizedBox(height: isCompact ? 22 : 28),
                                _buildOrDivider(),
                                const SizedBox(height: 18),
                                _buildGoogleButton(),
                                const SizedBox(height: 18),
                                _buildSignUpPrompt(),
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
            if (_loading)
              Positioned.fill(
                child: ColoredBox(
                  color: const Color(0x66FFFFFF),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: _brandBlue,
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

  Widget _buildGlow({required double size, required List<Color> colors}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: RadialGradient(radius: 0.7, colors: colors),
      ),
    );
  }

  Widget _buildLogoBadge() {
    return Center(
      child: GestureDetector(
        onLongPress: _showServerSettingsDialog,
        child: Container(
          width: 112,
          height: 112,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFDFEFF),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x144A88F7),
                blurRadius: 28,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/Logo_KYSC.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildAuthPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_panelRadius),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 32,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            controller: _emailCtrl,
            hint: 'Email or phone number',
            keyboard: TextInputType.text,
            prefixIcon: const Icon(
              Icons.mail_outline_rounded,
              size: 20,
              color: _iconMuted,
            ),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              FocusScope.of(context).nextFocus();
            },
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Email or phone required';
              }
              return null;
            },
          ),
          const SizedBox(height: _fieldSpacing),
          _buildTextField(
            controller: _passwordCtrl,
            hint: 'Your password',
            obscure: obscurePassword,
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              size: 20,
              color: _iconMuted,
            ),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submitLogin(),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Password required';
              }
              if (v.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: _iconMuted,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Transform.scale(
                scale: 0.82,
                alignment: Alignment.centerLeft,
                child: CupertinoSwitch(
                  value: rememberMe,
                  activeTrackColor: _brandBlue,
                  inactiveTrackColor: const Color(0xFFD5DDEA),
                  thumbColor: Colors.white,
                  onChanged: (value) {
                    setState(() => rememberMe = value);
                  },
                ),
              ),
              const SizedBox(width: 4),
              const Expanded(
                child: Text(
                  'Remember Me',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _textMuted,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: _brandBlue,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildSignInButton(),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: _brandBlue,
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Go to Home'),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_brandBlue, _brandBlueSoft],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x224A88F7),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _loading ? null : _submitLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white70,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: _loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Sign in',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
        ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: const [
        Expanded(child: Divider(color: _border, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9AA6B8),
            ),
          ),
        ),
        Expanded(child: Divider(color: _border, thickness: 1)),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      height: 54,
      child: OutlinedButton(
        onPressed: _loading ? null : _loginWithGoogle,
        style: OutlinedButton.styleFrom(
          backgroundColor: _surface,
          side: const BorderSide(color: _border),
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/google-color.png',
              width: 22,
              height: 22,
            ),
            const SizedBox(width: 14),
            const Text(
              'Login with Google',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpPrompt() {
    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            "Don't have an account? ",
            style: TextStyle(fontSize: 13, color: _textMuted),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: _brandBlue,
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Sign up',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
    String? Function(String?)? validator,
    Widget? prefixIcon,
    Widget? suffixIcon,
    TextInputAction? textInputAction,
    ValueChanged<String>? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: obscure,
      validator: validator,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(
        color: _textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: _iconMuted,
          fontSize: 13,
          fontWeight: FontWeight.w500,
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
          horizontal: 16,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: _brandBlue, width: 1.35),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppPalette.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppPalette.error, width: 1.2),
        ),
      ),
    );
  }

  Future<void> _showServerSettingsDialog() async {
    final controller = TextEditingController(text: ApiService.serverOrigin);
    String? feedback;
    bool feedbackIsError = false;
    bool loading = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            Future<void> testConnection() async {
              setDialogState(() {
                loading = true;
                feedback = null;
              });

              final error = await ApiService.testBaseUrl(controller.text);
              if (!dialogContext.mounted) return;

              setDialogState(() {
                loading = false;
                feedbackIsError = error != null;
                feedback = error ?? 'Connection successful.';
              });
            }

            Future<void> saveServer() async {
              setDialogState(() {
                loading = true;
                feedback = null;
              });

              final error = await ApiService.configureBaseUrl(controller.text);
              if (!mounted || !dialogContext.mounted) return;

              setDialogState(() {
                loading = false;
                feedbackIsError = error != null;
                feedback = error;
              });

              if (error != null) {
                return;
              }

              setState(() {});
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Server updated to ${ApiService.serverOrigin}'),
                ),
              );
            }

            Future<void> useDefaultServer() async {
              setDialogState(() {
                loading = true;
                feedback = null;
              });

              await ApiService.clearConfiguredBaseUrl();
              if (!mounted || !dialogContext.mounted) return;

              setState(() {});
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Server reset to ${ApiService.serverOrigin}'),
                ),
              );
            }

            return AlertDialog(
              title: const Text('Server Settings'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter your backend host or domain. The app adds /api automatically. '
                    'For a real phone, run Laravel with --host=0.0.0.0 and use your computer LAN IP.',
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: 'Server URL',
                      hintText: '192.168.1.10:8000 or api.yourdomain.com',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current API: ${ApiService.baseUrl}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppPalette.textMuted,
                    ),
                  ),
                  if (feedback != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      feedback!,
                      style: TextStyle(
                        fontSize: 12,
                        color: feedbackIsError
                            ? AppPalette.error
                            : Colors.green,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: loading
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Close'),
                ),
                TextButton(
                  onPressed: loading ? null : useDefaultServer,
                  child: const Text('Use Default'),
                ),
                TextButton(
                  onPressed: loading ? null : testConnection,
                  child: const Text('Test'),
                ),
                ElevatedButton(
                  onPressed: loading ? null : saveServer,
                  child: loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
  }
}
