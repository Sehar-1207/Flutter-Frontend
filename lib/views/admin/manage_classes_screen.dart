import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';

class ManageClassesScreen extends StatefulWidget {
  const ManageClassesScreen({super.key});

  @override
  State<ManageClassesScreen> createState() => _ManageClassesScreenState();
}

class _ManageClassesScreenState extends State<ManageClassesScreen> {
  final AdminController _admin = Get.find<AdminController>();

  @override
  void initState() {
    super.initState();
    _admin.fetchClassesOverview();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classes Overview'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: Obx(() {
        if (_admin.isClassesLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final classes = _admin.classesList;
        if (classes.isEmpty) {
          return const Center(child: Text('No classes found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: classes.length,
          itemBuilder: (context, index) {
            final cls = classes[index];
            final className = cls['className'] ?? 'Unknown Class';
            final section = cls['section'] ?? '';
            final instructor = cls['teacherName'] ?? 'Unknown Instructor';
            final studentsCount = cls['studentsCount']?.toString() ?? '0';

            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(className,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A3AFF).withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Section: $section',
                        style: const TextStyle(
                            color: Color(0xFF4A3AFF),
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(instructor,
                          style: const TextStyle(color: Colors.grey)),
                      const Spacer(),
                      const Icon(Icons.group_outlined,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('$studentsCount Students',
                          style: const TextStyle(color: Colors.grey)),
                    ],
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
