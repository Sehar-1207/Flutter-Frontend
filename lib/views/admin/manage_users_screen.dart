import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../routes/app_routes.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final AdminController _admin = Get.find<AdminController>();
  String _selectedFilter = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _admin.fetchAllUsers();
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    if (_searchQuery.isEmpty) {
      _admin.fetchAllUsers(role: _selectedFilter);
    } else {
      _admin.searchUsers(_searchQuery, role: _selectedFilter);
    }
  }

  void _showEditDialog(Map<String, dynamic> user) {
    final nameController = TextEditingController(text: user['name'] ?? '');
    final emailController = TextEditingController(text: user['email'] ?? '');
    String role = user['role'] ?? 'Student';

    Get.dialog(
      AlertDialog(
        title: const Text('Edit User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              DropdownButtonFormField<String>(
                initialValue: ['Student', 'Teacher', 'Admin'].contains(role)
                    ? role
                    : 'Student',
                items: ['Student', 'Teacher', 'Admin']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) role = val;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedData = {
                'name': nameController.text.trim(),
                'email': emailController.text.trim(),
                'role': role,
              };
              _admin.updateUser(user['_id'] ?? user['id'], updatedData);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          // Search & Filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        ['All', 'Student', 'Teacher', 'Admin'].map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (val) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                            // Trigger search or fetch all based on current query
                            if (_searchQuery.isEmpty) {
                              _admin.fetchAllUsers(role: filter);
                            } else {
                              _admin.searchUsers(_searchQuery, role: filter);
                            }
                          },
                          selectedColor:
                              const Color(0xFF4A3AFF).withValues(alpha: 0.1),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? const Color(0xFF4A3AFF)
                                : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Obx(() {
              if (_admin.isUsersLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              // Display users directly from the controller (API handled the filtering)
              final displayUsers = _admin.usersList;

              if (displayUsers.isEmpty) {
                return const Center(child: Text('No users found.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: displayUsers.length,
                itemBuilder: (context, index) {
                  final user = displayUsers[index];
                  final name = user['name'] ?? 'No Name';
                  final email = user['email'] ?? 'No Email';
                  final role = user['role'] ?? 'No Role';

                  // Role Badge Color
                  Color roleColor = Colors.grey;
                  Color roleBg = Colors.grey.withValues(alpha: 0.1);
                  if (role.toString().toLowerCase() == 'student') {
                    roleColor = const Color(0xFF4A3AFF);
                    roleBg = const Color(0xFF4A3AFF).withValues(alpha: 0.1);
                  } else if (role.toString().toLowerCase() == 'teacher') {
                    roleColor = const Color(0xFF00B4D8);
                    roleBg = const Color(0xFF00B4D8).withValues(alpha: 0.1);
                  } else if (role.toString().toLowerCase() == 'admin') {
                    roleColor = const Color(0xFF00C9A7);
                    roleBg = const Color(0xFF00C9A7).withValues(alpha: 0.1);
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text(email,
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 13)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
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
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditDialog(user);
                            } else if (value == 'delete') {
                              _admin.deleteUser(user['_id'] ?? user['id']);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                                value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete',
                                    style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24, right: 8),
        child: FloatingActionButton(
          onPressed: () => Get.toNamed(AppRoutes.addUser)
              ?.then((_) => _admin.fetchAllUsers(role: _selectedFilter)),
          backgroundColor: const Color(0xFF4A3AFF),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
