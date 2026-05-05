import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../controllers/admin_controller.dart';
import '../../routes/app_routes.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AdminController _admin = Get.find<AdminController>();

  int _currentIndex = 0;
  static const _purple = Color(0xFF4A3AFF);
  static const _bg = Color(0xFFF5F6FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          Obx(() {
            final name = _admin.adminProfile['name']?.toString() ?? 'A';
            final initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';
            return Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.adminProfile),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF4A3AFF).withValues(alpha: 0.1),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Color(0xFF4A3AFF),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),

      // Drawer with logout option
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: _purple),
                child: Center(
                  child: Text(
                    'Attend Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person_outline, color: _purple),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context); // Close drawer safely
                  Get.toNamed(AppRoutes.adminProfile);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  GetStorage().erase();
                  Get.offAllNamed(AppRoutes.login);
                },
              ),
            ],
          ),
        ),
      ),

      body: Obx(() {
        if (_admin.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: _admin.fetchDashboardStats,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.3,
                  children: [
                    _statCard(
                      label: 'Students',
                      value: _admin.totalStudents.value.toString(),
                      icon: Icons.people_outline,
                      iconBg: const Color(0xFFEEEBFF),
                    ),
                    _statCard(
                      label: 'Teachers',
                      value: _admin.totalTeachers.value.toString(),
                      icon: Icons.person_outline,
                      iconBg: const Color(0xFFE8F8F5),
                    ),
                    _statCard(
                      label: 'Admins',
                      value: _admin.totalAdmins.value.toString(),
                      icon: Icons.shield_outlined,
                      iconBg: const Color(0xFFEAF6FF),
                    ),
                    _statCard(
                      label: 'Total Users',
                      value: _admin.totalUsers.value.toString(),
                      icon: Icons.group_outlined,
                      iconBg: const Color(0xFFFFF8E7),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                
                Text(
                  'QUICK ACTIONS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[500],
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),

                _actionTile(
                  title: 'Manage Users',
                  subtitle: 'Add, edit, remove accounts',
                  icon: Icons.people_outline,
                  onTap: () => Get.toNamed(AppRoutes.manageUsers),
                ),
                _actionTile(
                  title: 'Classes Overview',
                  subtitle: 'View classes overview',
                  icon: Icons.menu_book_outlined,
                  onTap: () => Get.toNamed(AppRoutes.manageClasses),
                ),
                _actionTile(
                  title: 'Recent Registrations',
                  subtitle: 'View recent signups',
                  icon: Icons.list_alt_outlined,
                  onTap: () => Get.toNamed(AppRoutes.recentRegistrations),
                ),
                // _actionTile(
                //   title: 'Settings',
                //   subtitle: 'System preferences',
                //   icon: Icons.settings_outlined,
                //   onTap: () {},
                // ),
              ],
            ),
          ),
        );
      }),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _purple,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _currentIndex,
        onTap: (index) {
          if (_currentIndex == index) return;

          setState(() {
            _currentIndex = index;
          });

          switch (index) {
            case 0:
              Get.toNamed(AppRoutes.adminDashboard);
              break;

            case 1:
              // 👥 Manage Users
              Get.toNamed(AppRoutes.manageUsers);
              break;

            case 2:
              // 📊 Classes Overview
              Get.toNamed(AppRoutes.manageClasses);
              break;

            case 3:
              // ⚙️ Settings (optional)
              Get.toNamed(AppRoutes.adminProfile);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined), label: ''),
        ],
      ),
    );
  }

  // ── Stat card widget ──────────────────────────────────────

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon in colored box
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _purple, size: 20),
          ),
          const Spacer(),
          Text(
            label,
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }

  // ── Action tile widget ────────────────────────────────────

  Widget _actionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEEEBFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _purple, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
