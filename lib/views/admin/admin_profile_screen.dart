import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final AdminController _admin = Get.find<AdminController>();
  bool _isEditing = false;

  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load existing name into controller once profile data is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_admin.adminProfile.isNotEmpty) {
        _nameController.text = _admin.adminProfile['name'] ?? '';
      }
    });
  }

  void _saveProfile() {
    FocusScope.of(context).unfocus();
    _admin.updateAdminProfile(
        _nameController.text.trim(), _passwordController.text.trim());
    setState(() {
      _isEditing = false;
      _passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  // Reset if discarded
                  _nameController.text = _admin.adminProfile['name'] ?? '';
                  _passwordController.clear();
                }
              });
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: Obx(() {
        if (_admin.isProfileLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = _admin.adminProfile;
        if (profile.isEmpty) {
          return const Center(child: Text('Could not load profile.'));
        }

        final email = profile['email'] ?? 'No email available';
        final role = profile['role'] ?? 'admin';
        final name = profile['name'] ?? 'Admin';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF4A3AFF).withValues(alpha:0.1),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'A',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A3AFF),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Basic details in view mode
              if (!_isEditing) ...[
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C9A7).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    role.toString().toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF00C9A7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Readonly Details Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      _infoRow(Icons.email_outlined, 'Email', email),
                      const Divider(height: 30),
                      _infoRow(Icons.lock_outline, 'Password', '••••••••'),
                    ],
                  ),
                ),
              ],

              // Edit Form Mode
              if (_isEditing) ...[
                const SizedBox(height: 20),
                // Readonly email display
                TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Email Address (Cannot be changed)',
                    hintText: email,
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Name editing
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Password editing
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    hintText: 'Leave blank to keep current password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A3AFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Save Changes',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4A3AFF), size: 24),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            const SizedBox(height: 2),
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ],
    );
  }
}
