import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../main_navigation_screen.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agree = false;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // 🔙 Back button
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),

                const SizedBox(height: 12),

                // Title
                const Text(
                  "Create an account.",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFA552),
                  ),
                ),

                const SizedBox(height: 28),

                _label("Full Name"),
                _input(
                  controller: _nameCtrl,
                  hint: "Full Name",
                  icon: Icons.person_outline,
                  validator: (v) =>
                  v!.isEmpty ? "Full name is required" : null,
                ),

                const SizedBox(height: 20),

                _label("Email"),
                _input(
                  controller: _emailCtrl,
                  hint: "Email",
                  icon: Icons.email_outlined,
                  keyboard: TextInputType.emailAddress,
                  validator: (v) {
                    if (v!.isEmpty) return "Email is required";
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(v)) {
                      return "Invalid email format";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                _label("Password"),
                _passwordInput(
                  controller: _passwordCtrl,
                  hint: "Password",
                  obscure: _obscurePassword,
                  toggle: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  validator: (v) {
                    if (v!.isEmpty) return "Password is required";
                    if (v.length < 6) {
                      return "Password must contain at least 6 digits";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 6),
                const Text(
                  "Password must contain at least 6 digits",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),

                const SizedBox(height: 20),

                _label("Confirm Password"),
                _passwordInput(
                  controller: _confirmCtrl,
                  hint: "Confirm Password",
                  obscure: _obscureConfirm,
                  toggle: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (v) {
                    if (v!.isEmpty) return "Confirm password required";
                    if (v != _passwordCtrl.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Terms
                Row(
                  children: [
                    Checkbox(
                      value: _agree,
                      onChanged: (v) => setState(() => _agree = v!),
                    ),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          text: "By signing up you agree to our ",
                          style: TextStyle(color: Colors.grey),
                          children: [
                            TextSpan(
                              text: "terms and conditions",
                              style: TextStyle(
                                color: Color(0xFFFFA552),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Create Account button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA552),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: !_agree || _loading
                        ? null
                        : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _loading = true);
                        await Future.delayed(
                            const Duration(seconds: 2));
                        if (!mounted) return;
                        setState(() => _loading = false);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OtpScreen(email: "example@email.com"),
                          ),
                        );
                      }
                    },
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Create Account",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Or Join With
                const Center(
                  child: Text(
                    "Or Join With",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _social(Icons.facebook, Colors.blue),
                    const SizedBox(width: 24),
                    _social(Icons.g_mobiledata, Colors.red),
                  ],
                ),

                const SizedBox(height: 30),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Log In",
                        style: TextStyle(
                          color: Color(0xFFFFA552),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- helpers ----------
  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _passwordInput({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback toggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon:
          Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _social(IconData icon, Color color) {
    return CircleAvatar(
      radius: 26,
      backgroundColor: color,
      child: Icon(icon, color: Colors.white),
    );
  }
}
