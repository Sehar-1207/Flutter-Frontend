import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../controllers/teacher_profile_controller.dart';

class TeacherProfileScreen extends StatelessWidget {
  TeacherProfileScreen({super.key});

  static const _purple = Color(0xFF4A3AFF);
  static const _bg = Color(0xFFF5F6FA);

  final TeacherProfileController controller = () {
    if (Get.isRegistered<TeacherProfileController>()) {
      Get.delete<TeacherProfileController>(force: true);
    }
    return Get.put(TeacherProfileController());
  }();

  @override
  Widget build(BuildContext context) {
    final bool isGoogleUser = GetStorage().read('isGoogleUser') ?? false;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        // Refresh button to manually re-fetch
        actions: [
          Obx(() => controller.isFetchingProfile.value
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _purple,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh, color: _purple),
                  onPressed: controller.fetchProfile,
                )),
        ],
      ),
      body: Obx(() {
        // Show full-screen loader only on very first fetch (no cached name yet)
        if (controller.isFetchingProfile.value &&
            controller.currentName.value.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: _purple),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Avatar + name ──────────────────────────────────
              Center(
                child: Obx(() {
                  final name = controller.currentName.value;
                  final email = controller.currentEmail.value;
                  final initial =
                      name.isNotEmpty ? name[0].toUpperCase() : '?';

                  return Column(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: _purple,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _purple.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 34,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name.isNotEmpty ? name : 'Your Name',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      if (email.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Teacher',
                          style: TextStyle(
                            color: _purple,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),

              const SizedBox(height: 40),

              // ── Section label ──────────────────────────────────
              const Text(
                'Update Profile',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Changes are reflected everywhere immediately.',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),

              const SizedBox(height: 24),

              // ── Name field ─────────────────────────────────────
              _buildLabel('Full Name'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: controller.nameController,
                hint: 'Enter your name',
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 20),

              // ── Password field ─────────────────────────────────
              _buildLabel(
                isGoogleUser
                    ? 'Set Password (Optional)'
                    : 'New Password (Optional)',
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: controller.passwordController,
                hint: isGoogleUser
                    ? 'Create a password for email login'
                    : 'Leave blank to keep current password',
                icon: Icons.lock_outline,
                obscure: true,
              ),

              // Google user hint
              if (isGoogleUser) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'You signed in with Google. Setting a password '
                        'lets you also log in with email.',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[500]),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 40),

              // ── Save button ────────────────────────────────────
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _purple,
                        disabledBackgroundColor:
                            _purple.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  )),
            ],
          ),
        );
      }),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A2E),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF1A1A2E),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}