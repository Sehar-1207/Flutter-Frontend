import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';


class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final AuthController _auth = Get.find<AuthController>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  static const _purple = Color(0xFF4A3AFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create account',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Start tracking attendance in seconds',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),

            const SizedBox(height: 36),

            // Full name
            _fieldLabel('Full name'),
            const SizedBox(height: 8),
            _textField(
              controller: _nameCtrl,
              hint: 'User',
            ),

            const SizedBox(height: 20),

            // Email
            _fieldLabel('Email'),
            const SizedBox(height: 8),
            _textField(
              controller: _emailCtrl,
              hint: 'user@gmail.com',
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 20),

            // Password
            _fieldLabel('Password'),
            const SizedBox(height: 8),
            _textField(
              controller: _passwordCtrl,
              hint: 'password123',
              obscure: true,
            ),

            const SizedBox(height: 16),

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

            // Create account button
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _auth.isLoading.value
                        ? null
                        : () => _auth.register(
                              _nameCtrl.text.trim(),
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
                            'Create account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                )),

            const SizedBox(height: 24),

            Center(
              child: Text(
                'By signing up you agree to our Terms and Privacy Policy',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  

  Widget _fieldLabel(String text) => Text(
        text,
        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
      );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    );
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A3AFF)),
        ),
      ),
    );
  }
}
