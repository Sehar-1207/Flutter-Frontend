import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/class_details_controller.dart';
import '../../routes/app_routes.dart';

class ClassDetailsScreen extends StatelessWidget {
  ClassDetailsScreen({super.key});

  final ClassDetailsController controller = Get.put(ClassDetailsController());
  static const _purple = Color(0xFF4A3AFF);
  static const _bg = Color(0xFFF5F6FA);

  void _showAddStudentDialog(BuildContext context, String classId) {
    final emailCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final rollNoCtrl = TextEditingController();
    final sectionCtrl = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Add Student",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: "Student Email", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                    labelText: "Student Name", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: rollNoCtrl,
                decoration: const InputDecoration(
                    labelText: "Roll No", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: sectionCtrl,
                decoration: const InputDecoration(
                    labelText: "Section", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (emailCtrl.text.isNotEmpty &&
                        nameCtrl.text.isNotEmpty &&
                        rollNoCtrl.text.isNotEmpty &&
                        sectionCtrl.text.isNotEmpty) {
                      controller.addStudent(
                        classId,
                        emailCtrl.text.trim(),
                        nameCtrl.text.trim(),
                        rollNoCtrl.text.trim(),
                        sectionCtrl.text.trim(),
                      );
                    } else {
                      Get.snackbar("Validation", "Please fill all fields.");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Add",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Text(
              controller.classData['subjectName'] ?? 'Class Details',
              style: const TextStyle(
                  color: Color(0xFF1A1A2E), fontWeight: FontWeight.w600),
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text(
                        controller.classData['semester'] ?? 'Semester',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E)),
                      )),
                  const SizedBox(height: 8),
                  Obx(() {
                    var c = controller.classData;
                    String sec = (c['sections'] is List)
                        ? (c['sections'] as List).join(", ")
                        : (c['sections']?.toString() ?? "A");
                    return Text(
                      "Sem ${c['semesterNumber']} \u2022 Section $sec",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    );
                  }),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (controller.students.isEmpty) {
                              Get.snackbar("Notice",
                                  "Please add students first to mark attendance.");
                              return;
                            }
                            Get.toNamed(AppRoutes.markAttendance, arguments: {
                              'classId': controller.classData['id'],
                              'students': controller.students,
                            });
                          },
                          icon: const Icon(Icons.check_circle_outline,
                              color: Colors.white, size: 20),
                          label: const Text("Mark today"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddStudentDialog(
                              context, controller.classData['id']),
                          icon: const Icon(Icons.add, color: _purple, size: 20),
                          label: const Text("Add students"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _purple.withOpacity(0.1),
                            foregroundColor: _purple,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text(
                        "STUDENTS (${controller.students.length})",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                            letterSpacing: 1.2),
                      )),
                  TextButton.icon(
                    onPressed: () {
                      Get.toNamed(AppRoutes.attendanceHistory,
                          arguments: {'classId': controller.classData['id']});
                    },
                    icon:
                        Icon(Icons.history, size: 16, color: Colors.grey[600]),
                    label: Text("History",
                        style: TextStyle(color: Colors.grey[600])),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.students.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text("No students added yet.",
                            style: TextStyle(color: Colors.grey[500])),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => _showAddStudentDialog(
                              context, controller.classData['id']),
                          child: const Text("Add Student",
                              style: TextStyle(color: _purple)),
                        )
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: controller.students.length,
                  itemBuilder: (context, index) {
                    var st = controller.students[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: _purple.withOpacity(0.1),
                          child: Text(
                            (st['studentName']?.toString().isNotEmpty == true)
                                ? st['studentName']
                                    .toString()
                                    .substring(0, 1)
                                    .toUpperCase()
                                : 'S',
                            style: const TextStyle(
                                color: _purple, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(st['studentName'] ?? 'No Name',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(st['studentEmail'] ?? '',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600])),
                            const SizedBox(height: 2),
                            Text("Roll No: ${st['rollNo']}",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () {
                            Get.defaultDialog(
                                title: "Remove Student",
                                middleText:
                                    "Are you sure you want to remove ${st['studentName']}?",
                                textCancel: "Cancel",
                                textConfirm: "Remove",
                                confirmTextColor: Colors.white,
                                buttonColor: Colors.red,
                                onConfirm: () {
                                  Get.back();
                                  controller.removeStudent(
                                      controller.classData['id'],
                                      st['studentId']);
                                });
                          },
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
