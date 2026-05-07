// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../controllers/student_controller.dart';
import '../../routes/app_routes.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final StudentController controller = Get.put(StudentController());
  static const _purple = Color(0xFF4A3AFF);

  @override
  void initState() {
    super.initState();
    controller.getProfile();
    controller.getMyClasses();
    controller.getAllAttendance();
  }

  void _openDrawer() {
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Obx(() {
                final p = controller.profile;
                final name = p['name'] ?? p['studentName'] ?? 'Student';
                final initial = name.toString().isNotEmpty
                    ? name.toString().substring(0, 1).toUpperCase()
                    : 'S';
                return UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color(0xFF4A3AFF),
                  ),
                  accountName:
                      Text(name, style: const TextStyle(color: Colors.white)),
                  accountEmail: Text(p['email'] ?? p['studentEmail'] ?? '',
                      style: const TextStyle(color: Colors.white)),
                  currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(initial,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold))),
                );
              }),
              ListTile(
                leading: const Icon(
                  Icons.person,
                  color: Color.fromARGB(255, 37, 151, 136),
                ),
                title: const Text(
                  'Profile',
                  style: TextStyle(color: Color.fromARGB(255, 33, 142, 127)),
                ),
                onTap: () => Get.toNamed(AppRoutes.studentProfile),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title:
                    const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () {
                  GetStorage().erase();
                  Get.offAllNamed(AppRoutes.login);
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
            builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () => Scaffold.of(context).openDrawer())),
        title: const Text('My Classes',
            style: TextStyle(
                color: Color(0xFF1A1A2E), fontWeight: FontWeight.w600)),
        actions: [
          Obx(() {
            final p = controller.profile;
            final name = p['name'] ?? p['studentName'] ?? 'S';
            final initial = name.toString().isNotEmpty
                ? name.toString().substring(0, 1).toUpperCase()
                : 'S';
            return GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.studentProfile),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                    backgroundColor: const Color(0xFFECEBFF),
                    child: Text(initial,
                        style: const TextStyle(
                            color: _purple, fontWeight: FontWeight.bold))),
              ),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          // compute overall attendance percent across allAttendance
          // allAttendance is an array of class objects (backend)
          int total = 0;
          int attended = 0;
          if (controller.allAttendance is List) {
            for (final c in controller.allAttendance) {
              final t = (c['totalLectures'] is int)
                  ? c['totalLectures'] as int
                  : (c['total'] is int)
                      ? c['total'] as int
                      : (c['history'] is List)
                          ? (c['history'] as List).length
                          : 0;
              final p = (c['presentCount'] is int)
                  ? c['presentCount'] as int
                  : (c['present'] is int)
                      ? c['present'] as int
                      : (c['history'] is List)
                          ? (c['history'] as List).where((r) {
                              final s =
                                  (r['status'] ?? '').toString().toLowerCase();
                              return s.contains('present') ||
                                  s == '1' ||
                                  s == 'true';
                            }).length
                          : 0;
              total += t;
              attended += p;
            }
          }
          final overallPercent =
              (total > 0) ? ((attended * 100 / total).round()) : 0;

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 67, 175, 160),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('OVERALL ATTENDANCE',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12)),
                          const SizedBox(height: 8),
                          Text('$overallPercent%',
                              style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                              value: overallPercent / 100,
                              color: Colors.white,
                              backgroundColor: Colors.grey[200]),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${controller.myClasses.length} classes',
                            style: const TextStyle(color: Colors.white)),
                      ],
                    )
                  ],
                ),
              ),
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('My Classes -',
                          style: TextStyle(fontWeight: FontWeight.bold)))),
              const SizedBox(height: 8),
              Expanded(
                child: controller.isClassesLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: controller.myClasses.length,
                        itemBuilder: (context, index) {
                          final c = controller.myClasses[index];
                          final subject =
                              c['subjectName'] ?? c['name'] ?? 'Class';
                          final teacher = c['teacherName'] ??
                              c['teacher'] ??
                              c['faculty'] ??
                              '';
                          final code =
                              c['code'] ?? c['classCode'] ?? c['classId'] ?? '';
                          // try to compute attendance percent per class from allAttendance
                          int classTotal = 0;
                          int classAtt = 0;
                          if (controller.allAttendance is List) {
                            final list = controller.allAttendance
                                .where((r) =>
                                    r['classId']?.toString() ==
                                        (c['classId']?.toString() ??
                                            c['classId']) ||
                                    r['classId']?.toString() ==
                                        (c['id']?.toString() ??
                                            c['classId']?.toString()))
                                .toList();
                            if (list.isNotEmpty) {
                              final first = list.first;
                              classTotal = (first['totalLectures'] is int)
                                  ? first['totalLectures'] as int
                                  : (first['total'] is int)
                                      ? first['total'] as int
                                      : (first['history'] is List)
                                          ? (first['history'] as List).length
                                          : 0;
                              classAtt = (first['presentCount'] is int)
                                  ? first['presentCount'] as int
                                  : (first['present'] is int)
                                      ? first['present'] as int
                                      : 0;
                            }
                          }
                          final classPercent = (classTotal > 0)
                              ? ((classAtt * 100 / classTotal).round())
                              : (c['percentage'] ??
                                  c['attendancePercent'] ??
                                  '--');

                          String _subjectInitials(String subject) {
                            if (subject.trim().isEmpty) return '';
                            final parts = subject.trim().split(RegExp(r'\s+'));
                            if (parts.length == 1) {
                              final p = parts.first;
                              return p.length >= 2
                                  ? p.substring(0, 2).toUpperCase()
                                  : p.substring(0, 1).toUpperCase();
                            }
                            final a = parts[0][0];
                            final b = parts[1][0];
                            return (a + b).toUpperCase();
                          }

                          return GestureDetector(
                            onTap: () {
                              Get.toNamed(AppRoutes.studentClassDetails,
                                  arguments: {
                                    'classId': c['classId'] ?? c['id'],
                                    'subjectName': subject
                                  });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!)),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Center(
                                        child: Text(_subjectInitials(subject),
                                            style: const TextStyle(
                                                color: _purple,
                                                fontWeight: FontWeight.bold))),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(subject,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 4),
                                          Text(teacher,
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12)),
                                        ]),
                                  ),
                                  Column(children: [
                                    Text('$classPercent%',
                                        style: const TextStyle(
                                            color: Color.fromARGB(
                                                255, 67, 175, 160),
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    const Text('attendance',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                  ])
                                ],
                              ),
                            ),
                          );
                        }),
              ),
            ],
          );
        }),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _purple,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: 0,
        onTap: (index) {
          if (index == 3) {
            // Person icon → navigate to student profile
            Get.toNamed(AppRoutes.studentProfile);
          }
          // Add other tab navigation here if needed
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
    );
  }
}
