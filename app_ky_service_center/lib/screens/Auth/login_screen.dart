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
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2F6BFF), Color(0xFF18C7CC)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compactHeight = constraints.maxHeight < 760;
                  final minContentHeight =
                      (constraints.maxHeight -
                              bottomInset -
                              (compactHeight ? 48 : 72))
                          .clamp(0.0, double.infinity)
                          .toDouble();

                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      20,
                      compactHeight ? 24 : 48,
                      20,
                      bottomInset + 24,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: minContentHeight,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(
                                          (0.2 * 255).round(),
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.shield_outlined,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Text(
                                      'KneaYerng Seervice Center',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 26),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    22,
                                    20,
                                    22,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppPalette.surface,
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(
                                          (0.08 * 255).round(),
                                        ),
                                        blurRadius: 22,
                                        offset: const Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Center(
                                        child: Text(
                                          'Login',
                                          style: TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w700,
                                            color: AppPalette.textPrimary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Center(
                                        child: Wrap(
                                          alignment: WrapAlignment.center,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            const Text(
                                              "Don't have an account? ",
                                              style: TextStyle(
                                                color: AppPalette.textMuted,
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        const RegisterScreen(),
                                                  ),
                                                );
                                              },
                                              style: TextButton.styleFrom(
                                                foregroundColor: const Color(
                                                  0xFF2F6BFF,
                                                ),
                                                padding: EdgeInsets.zero,
                                                minimumSize: const Size(0, 0),
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              child: const Text(
                                                'Sign Up',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border: Border.all(
                                            color: AppPalette.border,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.dns_outlined,
                                              size: 18,
                                              color: AppPalette.textMuted,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    ApiService
                                                            .hasConfiguredBaseUrl
                                                        ? 'Custom server'
                                                        : 'Default server',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          AppPalette.textMuted,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    ApiService.serverOrigin,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: AppPalette
                                                          .textPrimary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            TextButton(
                                              onPressed:
                                                  _showServerSettingsDialog,
                                              style: TextButton.styleFrom(
                                                foregroundColor: const Color(
                                                  0xFF2F6BFF,
                                                ),
                                              ),
                                              child: const Text('Change'),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      _buildTextField(
                                        controller: _emailCtrl,
                                        label: 'Email or Phone',
                                        hint: 'phone number or email',
                                        keyboard: TextInputType.text,
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
                                        label: 'Password',
                                        hint: '********',
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
                                            color: AppPalette.textMuted,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              obscurePassword =
                                                  !obscurePassword;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      LayoutBuilder(
                                        builder: (context, rowConstraints) {
                                          final compactRow =
                                              rowConstraints.maxWidth < 360;

                                          if (compactRow) {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Checkbox(
                                                      value: rememberMe,
                                                      activeColor: const Color(
                                                        0xFF2F6BFF,
                                                      ),
                                                      materialTapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                      onChanged: (value) {
                                                        setState(
                                                          () => rememberMe =
                                                              value ?? false,
                                                        );
                                                      },
                                                    ),
                                                    const Text(
                                                      'Remember me',
                                                      style: TextStyle(
                                                        color: AppPalette
                                                            .textMuted,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: TextButton(
                                                    onPressed: () {
                                                      _startOtpFlow(
                                                        purpose:
                                                            'reset_password',
                                                      );
                                                    },
                                                    style:
                                                        TextButton.styleFrom(
                                                      foregroundColor:
                                                          const Color(
                                                        0xFF2F6BFF,
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      'Forgot Password ?',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }

                                          return Row(
                                            children: [
                                              Checkbox(
                                                value: rememberMe,
                                                activeColor: const Color(
                                                  0xFF2F6BFF,
                                                ),
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                onChanged: (value) {
                                                  setState(
                                                    () => rememberMe =
                                                        value ?? false,
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
                                                  _startOtpFlow(
                                                    purpose: 'reset_password',
                                                  );
                                                },
                                                style: TextButton.styleFrom(
                                                  foregroundColor: const Color(
                                                    0xFF2F6BFF,
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Forgot Password ?',
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 52,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF2F6BFF,
                                            ),
                                            foregroundColor: Colors.white,
                                            elevation: 3,
                                            shadowColor: const Color(
                                              0xFF2F6BFF,
                                            ).withAlpha((0.3 * 255).round()),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                _radius,
                                              ),
                                            ),
                                          ),
                                          onPressed: () async {
                                            if (!_formKey.currentState!
                                                .validate()) {
                                              return;
                                            }

                                            setState(() => _loading = true);

                                            final error =
                                                await ApiService.login(
                                              identifier:
                                                  _emailCtrl.text.trim(),
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
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(error),
                                                ),
                                              );
                                            }
                                          },
                                          child: _loading
                                              ? const SizedBox(
                                                  width: 22,
                                                  height: 22,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.4,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : const Text(
                                                  'Log In',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      Row(
                                        children: [
                                          const Expanded(
                                            child: Divider(
                                              color: AppPalette.border,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            child: Text(
                                              'Or',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color:
                                                        AppPalette.textMuted,
                                                  ),
                                            ),
                                          ),
                                          const Expanded(
                                            child: Divider(
                                              color: AppPalette.border,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 48,
                                        child: OutlinedButton.icon(
                                          onPressed: () {},
                                          style: OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                _radius,
                                              ),
                                            ),
                                            side: const BorderSide(
                                              color: AppPalette.border,
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.facebook,
                                            color: Color(0xFF1877F2),
                                          ),
                                          label: const Text(
                                            'Continue with Facebook',
                                            style: TextStyle(
                                              color: AppPalette.textPrimary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppPalette.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          obscureText: obscure,
          validator: validator,
          style: const TextStyle(color: AppPalette.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppPalette.textMuted.withAlpha((0.75 * 255).round()),
            ),
            errorStyle: const TextStyle(color: AppPalette.error, fontSize: 12),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
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
              borderSide: const BorderSide(
                color: Color(0xFF2F6BFF),
                width: 1.5,
              ),
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
        ),
      ],
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
                    'Enter your backend host or domain. The app adds /api automatically. On desktop, the default server now uses your local LAN IP when available.',
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
                  TextField(
                    controller: _otpDestinationCtrl,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: 'Email or phone number',
                      hintText: 'name@email.com or +85512345678',
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
    _otpType = _inferOtpType(destination);
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(request.message)));
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

  String _inferOtpType(String destination) {
    final value = destination.trim();
    return value.contains('@') ? 'email' : 'phone';
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
                  onPressed: submitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          final password = passwordCtrl.text;
                          final confirm = confirmCtrl.text;
                          final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
                          final hasNumber = RegExp(r'[0-9]').hasMatch(password);
                          if (password.length < 8 ||
                              !hasUpper ||
                              !hasNumber ||
                              password != confirm) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Password must be at least 8 characters, include 1 uppercase letter and 1 number, and match confirmation.',
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
