import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';

class RecentRegistrationsScreen extends StatefulWidget {
  const RecentRegistrationsScreen({super.key});

  @override
  State<RecentRegistrationsScreen> createState() =>
      _RecentRegistrationsScreenState();
}

class _RecentRegistrationsScreenState extends State<RecentRegistrationsScreen> {
  final AdminController _admin = Get.find<AdminController>();

  @override
  void initState() {
    super.initState();
    _admin.fetchRecentRegistrations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Registrations'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: Obx(() {
        if (_admin.isRegistrationsLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final registrations = _admin.registrationsList;
        if (registrations.isEmpty) {
          return const Center(child: Text('No recent registrations found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: registrations.length,
          itemBuilder: (context, index) {
            final reg = registrations[index];
            final name = reg['name'] ?? 'Unknown User';
            final email = reg['email'] ?? 'No email';
            final role = reg['role'] ?? 'Student';

            // Base role color
            Color roleColor = const Color(0xFF4A3AFF);
            Color roleBg = roleColor.withOpacity(0.1);
            if (role.toString().toLowerCase() == 'teacher') {
              roleColor = const Color(0xFF00B4D8);
              roleBg = roleColor.withOpacity(0.1);
            } else if (role.toString().toLowerCase() == 'admin') {
              roleColor = const Color(0xFF00C9A7);
              roleBg = roleColor.withOpacity(0.1);
            }

            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: roleColor,
                  child: Text(
                    name.isNotEmpty
                        ? name[0].toUpperCase() +
                            (name.length > 1
                                ? name.split(' ').last[0].toUpperCase()
                                : '')
                        : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text(email,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: roleBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    role,
                    style: TextStyle(
                        color: roleColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
