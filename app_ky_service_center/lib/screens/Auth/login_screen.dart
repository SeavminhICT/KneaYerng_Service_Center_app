import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_palette.dart';
import '../main_navigation_screen.dart';
import 'register_screen.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const double _radius = 16;
  static const double _fieldSpacing = 14;

  bool rememberMe = false;
  bool obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading = false;
  final TextEditingController _otpDestinationCtrl = TextEditingController();
  String _otpType = 'email';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _otpDestinationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Form(
                      key: _formKey,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
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
                            const SizedBox(height: 16),
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    height: 64,
                                    width: 64,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppPalette.surface,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: AppPalette.border,
                                      ),
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
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Welcome back. Sign in to continue.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppPalette.textMuted,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildTextField(
                              controller: _emailCtrl,
                              label: 'Email address',
                              hint: 'name@email.com',
                              icon: Icons.email_outlined,
                              keyboard: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Email required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: _fieldSpacing),
                            _buildTextField(
                              controller: _passwordCtrl,
                              label: 'Password',
                              hint: 'Your password',
                              icon: Icons.lock_outline,
                              obscure: obscurePassword,
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
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Checkbox(
                                  value: rememberMe,
                                  activeColor: AppPalette.primary,
                                  onChanged: (value) {
                                    setState(
                                      () => rememberMe = value ?? false,
                                    );
                                  },
                                ),
                                const Text(
                                  'Remember me',
                                  style: TextStyle(
                                    color: AppPalette.textMuted,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    _startOtpFlow(purpose: 'reset_password');
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppPalette.primary,
                                  ),
                                  child: const Text('Forgot password?'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppPalette.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shadowColor: AppPalette.primary.withAlpha(
                                    (0.25 * 255).round(),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(_radius),
                                  ),
                                ),
                                onPressed: () async {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }

                                  setState(() => _loading = true);

                                  final error = await ApiService.login(
                                    email: _emailCtrl.text.trim(),
                                    password: _passwordCtrl.text,
                                  );

                                  if (!context.mounted) return;
                                  setState(() => _loading = false);

                                  if (error == null) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const MainNavigationScreen(),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(error)),
                                    );
                                  }
                                },
                                child: _loading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton(
                                onPressed: _loading
                                    ? null
                                    : () => _startOtpFlow(purpose: 'login'),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(_radius),
                                  ),
                                  side:
                                      const BorderSide(color: AppPalette.border),
                                ),
                                child: const Text('Login with OTP'),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const Expanded(
                                  child: Divider(color: AppPalette.border),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    'Or continue with',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppPalette.textMuted,
                                        ),
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(color: AppPalette.border),
                                ),
                              ],
                            ),
                            const SizedBox(height: _fieldSpacing),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(_radius),
                                      ),
                                      side: const BorderSide(
                                        color: AppPalette.border,
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.g_mobiledata,
                                      color: AppPalette.textMuted,
                                    ),
                                    label: const Text(
                                      'Google',
                                      style: TextStyle(
                                        color: AppPalette.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(_radius),
                                      ),
                                      side: const BorderSide(
                                        color: AppPalette.border,
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.facebook,
                                      color: AppPalette.textMuted,
                                    ),
                                    label: const Text(
                                      'Facebook',
                                      style: TextStyle(
                                        color: AppPalette.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Don\'t have an account? ',
                                  style: TextStyle(
                                    color: AppPalette.textMuted,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterScreen(),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppPalette.primary,
                                  ),
                                  child: const Text(
                                    'Register',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(color: AppPalette.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: AppPalette.textMuted),
        floatingLabelStyle: const TextStyle(
          color: AppPalette.primary,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          color: AppPalette.textMuted.withAlpha((0.75 * 255).round()),
        ),
        errorStyle: const TextStyle(color: AppPalette.error, fontSize: 12),
        prefixIcon: Icon(icon, color: AppPalette.textMuted),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppPalette.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppPalette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppPalette.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppPalette.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppPalette.error, width: 1.5),
        ),
      ),
    );
  }

  Future<void> _startOtpFlow({required String purpose}) async {
    _otpDestinationCtrl.clear();
    _otpType = 'email';

    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                purpose == 'login' ? 'Login with OTP' : 'Reset Password',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _otpType,
                    items: const [
                      DropdownMenuItem(value: 'email', child: Text('Email')),
                      DropdownMenuItem(value: 'phone', child: Text('Phone')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() => _otpType = value);
                    },
                    decoration: const InputDecoration(labelText: 'Type'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _otpDestinationCtrl,
                    keyboardType: _otpType == 'phone'
                        ? TextInputType.phone
                        : TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: _otpType == 'phone'
                          ? 'Phone number'
                          : 'Email address',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Send OTP'),
                ),
              ],
            );
          },
        );
      },
    );

    if (proceed != true) return;

    final destination = _otpDestinationCtrl.text.trim();
    if (destination.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter destination.')),
      );
      return;
    }

    final request = await ApiService.requestOtp(
      destination: destination,
      type: _otpType,
      purpose: purpose,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(request.message)));
    if (!request.ok) return;

    final resetToken = await Navigator.push<String?>(
      context,
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          destination: destination,
          type: _otpType,
          purpose: purpose,
        ),
      ),
    );

    if (!mounted || purpose != 'reset_password' || resetToken == null) return;
    await _showResetPasswordDialog(resetToken);
  }

  Future<void> _showResetPasswordDialog(String resetToken) async {
    final parentContext = context;
    final passwordCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool submitting = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Set New Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: passwordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New password',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: confirmCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm password',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      submitting ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          final password = passwordCtrl.text;
                          final confirm = confirmCtrl.text;
                          if (password.length < 8 || password != confirm) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Password must be 8+ chars and match confirmation.',
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() => submitting = true);
                          final error = await ApiService.resetPasswordWithOtp(
                            resetToken: resetToken,
                            password: password,
                            confirmPassword: confirm,
                          );
                          if (!mounted || !parentContext.mounted) return;
                          setDialogState(() => submitting = false);
                          final messenger = ScaffoldMessenger.of(parentContext);
                          final navigator = Navigator.of(
                            parentContext,
                            rootNavigator: true,
                          );
                          if (error == null) {
                            navigator.pop();
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Password reset successfully.'),
                              ),
                            );
                          } else {
                            messenger.showSnackBar(
                              SnackBar(content: Text(error)),
                            );
                          }
                        },
                  child: submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );

    passwordCtrl.dispose();
    confirmCtrl.dispose();
  }
}
