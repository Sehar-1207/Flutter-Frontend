import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/student_controller.dart';

class StudentProfile extends StatefulWidget {
  const StudentProfile({super.key});

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  final StudentController controller = Get.put(StudentController());
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _pwCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.getProfile().then((_) {
      final p = controller.profile;
      _nameCtrl.text = p['name'] ?? p['studentName'] ?? '';
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final name = _nameCtrl.text.trim();
    final pw = _pwCtrl.text.trim();

    if (name.isEmpty) {
      Get.snackbar('Validation', 'Name cannot be empty',
          snackPosition: SnackPosition.TOP);
      return;
    }
    if (pw.isNotEmpty && pw.length < 6) {
      Get.snackbar('Validation', 'Password must be at least 6 characters',
          snackPosition: SnackPosition.TOP);
      return;
    }

    await controller.updateFullProfile(
      name: name,
      password: pw.isNotEmpty ? pw : null,
    );

    // Clear password field after save
    _pwCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
              color: Color(0xFF1A1A2E), fontWeight: FontWeight.w600),
        ),
      ),
      body: Obx(() {
        if (controller.isProfileLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final p = controller.profile;
        final email = p['email'] ?? p['studentEmail'] ?? 'Not set';
        final name = p['name'] ?? p['studentName'] ?? 'S';
        final initial = name.isNotEmpty
            ? name.substring(0, 1).toUpperCase()
            : 'S';

        // Sync name field if profile reloads
        if (_nameCtrl.text.isEmpty) {
          _nameCtrl.text = name;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              // Avatar
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF4A3AFF),
                child: Text(
                  initial,
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),

              // Email Address card
              _InfoCard(
                icon: Icons.email_outlined,
                label: 'Email Address',
                value: email,
              ),
              const SizedBox(height: 16),

              // Full Name editable card
              _EditCard(
                label: 'Full Name',
                icon: Icons.person_outline,
                controller: _nameCtrl,
                hint: 'Enter your full name',
                obscure: false,
              ),
              const SizedBox(height: 16),

              // New Password editable card
              _EditCard(
                label: 'New Password',
                icon: Icons.lock_outline,
                controller: _pwCtrl,
                hint: 'Leave blank to keep current pass...',
                obscure: true,
              ),
              const SizedBox(height: 32),

              // Save Changes button
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A3AFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                    ),
                  )),
            ],
          ),
        );
      }),
    );
  }
}

// ─── Read-only info card (email) ────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFECEBFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF4A3AFF), size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Editable field card ─────────────────────────────────────────────────────
class _EditCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String hint;
  final bool obscure;

  const _EditCard({
    required this.label,
    required this.icon,
    required this.controller,
    required this.hint,
    required this.obscure,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: obscure,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              prefixIcon: Icon(icon,
                  color: const Color(0xFF4A3AFF), size: 20),
              hintText: hint,
              hintStyle:
                  const TextStyle(color: Colors.grey, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF5F6FA),
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 12, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}