import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final AuthController _auth = Get.find<AuthController>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  // Controls whether password is hidden or shown
  final _hidePassword = true.obs;

  static const _purple = Color(0xFF4A3AFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // App icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _purple,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.check_circle_outline,
                    color: Colors.white, size: 30),
              ),

              const SizedBox(height: 32),
              const Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sign in to continue to your dashboard',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),

              const SizedBox(height: 36),

              // Email field
              _fieldLabel('Email'),
              const SizedBox(height: 8),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration(
                  hint: 'sara.ahmed@school.edu',
                  prefix: Icons.email_outlined,
                ),
              ),

              const SizedBox(height: 20),

              // Password field
              _fieldLabel('Password'),
              const SizedBox(height: 8),
              Obx(() => TextField(
                    controller: _passwordCtrl,
                    obscureText: _hidePassword.value,
                    decoration: _inputDecoration(
                      hint: '••••••••',
                      prefix: Icons.lock_outline,
                      suffix: IconButton(
                        icon: Icon(
                          _hidePassword.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () => _hidePassword.toggle(),
                      ),
                    ),
                  )),

              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Forgot password?',
                  style: const TextStyle(color: _purple, fontSize: 14),
                ),
              ),

              const SizedBox(height: 20),

              // Error message
              Obx(() {
                if (_auth.errorMessage.value.isEmpty) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _auth.errorMessage.value,
                    style:
                        const TextStyle(color: Colors.redAccent, fontSize: 14),
                  ),
                );
              }),

              // Sign in button
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _auth.isLoading.value
                          ? null
                          : () => _auth.login(
                                _emailCtrl.text.trim(),
                                _passwordCtrl.text,
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _auth.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Sign in',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  )),

              const SizedBox(height: 28),

              // Divider with OR
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child:
                        Text('OR', style: TextStyle(color: Colors.grey[500])),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 24),

              // Google Sign In button
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _auth.isLoading.value
                          ? null
                          : () => _auth.loginWithGoogle(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1024px-Google_%22G%22_logo.svg.png',
                            height: 24,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.g_mobiledata,
                                    color: Colors.blueAccent, size: 28),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Sign in with Google',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),

              const SizedBox(height: 28),

              // Sign up link (only students can self-register)
              Center(
                child: GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.signup),
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      children: const [
                        TextSpan(
                          text: 'Sign up',
                          style: TextStyle(
                            color: _purple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────

  Widget _fieldLabel(String text) => Text(
        text,
        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
      );

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefix,
    Widget? suffix,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    );
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(prefix, color: Colors.grey),
      suffixIcon: suffix,
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4A3AFF)),
      ),
    );
  }
}
