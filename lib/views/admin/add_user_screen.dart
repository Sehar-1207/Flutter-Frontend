import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';

class AddUserScreen extends StatelessWidget {
  AddUserScreen({super.key});

  // AdminController is already registered by AdminDashboard
  final AdminController _admin = Get.find<AdminController>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // Dropdown role selection (reactive)
  final _selectedRole = 'student'.obs;
  final List<String> _roles = ['student', 'teacher', 'admin'];

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
        title: const Text(
          'Add User',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full Name
            _fieldLabel('Full Name'),
            const SizedBox(height: 8),
            _textField(controller: _nameCtrl, hint: 'Enter full name'),

            const SizedBox(height: 20),

            // Email
            _fieldLabel('Email'),
            const SizedBox(height: 8),
            _textField(
              controller: _emailCtrl,
              hint: 'Enter email address',
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 20),

            // Password
            _fieldLabel('Password'),
            const SizedBox(height: 8),
            _textField(
              controller: _passwordCtrl,
              hint: 'Enter password',
              obscure: true,
            ),

            const SizedBox(height: 20),

            // Role dropdown
            _fieldLabel('Role'),
            const SizedBox(height: 8),
            Obx(() => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedRole.value,
                      isExpanded: true,
                      items: _roles
                          .map((r) => DropdownMenuItem(
                                value: r,
                                // Capitalize first letter
                                child: Text(
                                    r[0].toUpperCase() + r.substring(1)),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) _selectedRole.value = val;
                      },
                    ),
                  ),
                )),

            const SizedBox(height: 16),

            // Error message
            Obx(() {
              if (_admin.errorMessage.value.isEmpty) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _admin.errorMessage.value,
                  style:
                      const TextStyle(color: Colors.redAccent, fontSize: 14),
                ),
              );
            }),

            // Add User button
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _admin.isAddingUser.value
                        ? null
                        : () => _admin.addUser(
                              _nameCtrl.text.trim(),
                              _emailCtrl.text.trim(),
                              _passwordCtrl.text,
                              _selectedRole.value,
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _admin.isAddingUser.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Add User',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────

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
