import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';

class TeacherController extends GetxController {
  var isLoading = true.obs;
  var isSearchLoading = false.obs;
  var classes = [].obs;
  var totalClasses = 0.obs;
  var searchQuery = "".obs;
  var teacherInitial = "".obs;
  var teacherName = "".obs;

  @override
  void onInit() {
    super.onInit();
    _loadNameFromStorage(); // show instantly from cache
    fetchTeacherName(); // then correct from server silently
    fetchDashboardData();
  }

  void _loadNameFromStorage() {
    final String? name = GetStorage().read('name');
    if (name != null && name.isNotEmpty) {
      teacherName.value = name;
      teacherInitial.value = name[0].toUpperCase();
    }
  }

  Future<void> fetchTeacherName() async {
    try {
      final String? token = GetStorage().read('token');
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/teacher/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final String freshName = data['name'] ?? '';
        if (freshName.isNotEmpty) {
          await GetStorage().write('name', freshName);
          teacherName.value = freshName;
          teacherInitial.value = freshName[0].toUpperCase();
        }
      }
    } catch (_) {
      // silently fail — cached value already shown
    }
  }

  Future<void> fetchDashboardData() async {
    isLoading(true);
    await fetchTotalClasses();
    await fetchClasses();
    isLoading(false);
  }

  Future<void> fetchTotalClasses() async {
    try {
      String? token = GetStorage().read('token');
      var response = await http.get(
        Uri.parse('${ApiService.baseUrl}/teacher/dashboard/total-classes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        totalClasses.value = jsonData['data']['totalClasses'] ?? 0;
      }
    } catch (e) {
      debugPrint("Failed to fetch total classes: $e");
    }
  }

  Future<void> fetchClasses() async {
    try {
      isSearchLoading(true);
      String? token = GetStorage().read('token');
      String endpoint = searchQuery.value.isEmpty
          ? '${ApiService.baseUrl}/teacher/classes'
          : '${ApiService.baseUrl}/teacher/classes/search?query=${Uri.encodeComponent(searchQuery.value)}';

      var response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        classes.value = jsonData['data'] ?? [];
      } else {
        Get.snackbar("Error", "Failed to fetch classes",
            snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      Get.snackbar("Error", "Network error while fetching classes.",
          snackPosition: SnackPosition.TOP);
    } finally {
      isSearchLoading(false);
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    fetchClasses();
  }

  void onProfileUpdated() {
    _loadNameFromStorage();
  }

  Future<void> createClass(int semesterNum, String semesterStr,
      String subjectName, String section) async {
    try {
      Get.defaultDialog(
        title: "Creating",
        content: const CircularProgressIndicator(),
        barrierDismissible: false,
      );

      String? token = GetStorage().read('token');
      var response = await http.post(
        Uri.parse('${ApiService.baseUrl}/teacher/classes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "semesterNumber": semesterNum,
          "semester": semesterStr,
          "subjectName": subjectName,
          "sections": [section],
        }),
      );

      Get.back();

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.back();
        Get.snackbar("Success", "Class created successfully!",
            snackPosition: SnackPosition.TOP);
        fetchDashboardData();
      } else {
        var errorData = json.decode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to create class",
            snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar("Error", "Network error.", snackPosition: SnackPosition.TOP);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DASHBOARD VIEW
// ═══════════════════════════════════════════════════════════════════════════════

class TeacherDashboard extends StatelessWidget {
  TeacherDashboard({super.key});

  static const _purple = Color(0xFF4A3AFF);

  final TeacherController controller =
      Get.put(TeacherController(), permanent: false);
  final RxInt _currentIndex = 0.obs;

  void _showCreateClassDialog(BuildContext context) {
    final semesterNumCtrl = TextEditingController();
    final semesterStrCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
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
              const Text("Create New Class",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: semesterNumCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Semester Number (e.g. 1)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: semesterStrCtrl,
                decoration: const InputDecoration(
                  labelText: "Semester (e.g. Fall 2026)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: subjectCtrl,
                decoration: const InputDecoration(
                  labelText: "Subject Name (e.g. Data Structures)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: sectionCtrl,
                decoration: const InputDecoration(
                  labelText: "Section (e.g. A)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final num = int.tryParse(semesterNumCtrl.text.trim()) ?? 0;
                    if (num > 0 &&
                        semesterStrCtrl.text.isNotEmpty &&
                        subjectCtrl.text.isNotEmpty &&
                        sectionCtrl.text.isNotEmpty) {
                      controller.createClass(num, semesterStrCtrl.text.trim(),
                          subjectCtrl.text.trim(), sectionCtrl.text.trim());
                    } else {
                      Get.snackbar(
                          "Validation", "Please fill all fields correctly.");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Create Class",
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

  Future<void> _navigateToProfile() async {
    final bool? updated = await Get.toNamed(
      AppRoutes.teacherProfile,
      arguments: {'name': controller.teacherName.value},
    ) as bool?;
    if (updated == true) {
      controller.onProfileUpdated();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: _purple),
                child: Center(
                  child: Text(
                    'Attend Teacher',
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
                onTap: () async {
                  Navigator.pop(context);
                  await _navigateToProfile();
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pop(context);
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
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text(
          'My Classes',
          style:
              TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: _navigateToProfile,
              child: Obx(() {
                final initial = controller.teacherInitial.value;
                return CircleAvatar(
                  backgroundColor: _purple.withValues(alpha: 0.2),
                  child: initial.isEmpty
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _purple,
                          ),
                        )
                      : Text(
                          initial,
                          style: const TextStyle(
                            color: _purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                );
              }),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Obx(() => Text(
                    controller.teacherName.value.isEmpty
                        ? "Welcome back!"
                        : "Welcome back, ${controller.teacherName.value}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  )),
              const SizedBox(height: 20),
              Obx(() => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _purple,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Total Classes",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${controller.totalClasses.value}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.class_,
                              color: Colors.white, size: 30),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 20),
              TextField(
                onChanged: controller.onSearchChanged,
                decoration: InputDecoration(
                  hintText: "Search classes...",
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value ||
                      controller.isSearchLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.classes.isEmpty) {
                    return const Center(
                        child: Text("No classes found. Create one!"));
                  }
                  return ListView.builder(
                    itemCount: controller.classes.length,
                    itemBuilder: (context, index) {
                      var c = controller.classes[index];
                      String sectionStr = "";
                      if (c['sections'] != null) {
                        if (c['sections'] is List) {
                          sectionStr = (c['sections'] as List).join(", ");
                        } else {
                          sectionStr = c['sections'].toString();
                        }
                      } else {
                        sectionStr = "A";
                      }
                      return GestureDetector(
                        onTap: () =>
                            Get.toNamed(AppRoutes.classDetails, arguments: c),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: _purple.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Text(
                                    "CS",
                                    style: TextStyle(
                                      color: _purple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c['subjectName'] ?? "Subject Name",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A1A2E),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Section $sectionStr \u2022 ${c['semester']} \u2022 Sem ${c['semesterNumber']}",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: Colors.grey),
                            ],
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateClassDialog(context),
        backgroundColor: _purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: _purple,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            currentIndex: _currentIndex.value,
            onTap: (index) {
              if (index == 1) {
                _navigateToProfile();
              } else {
                _currentIndex.value = index;
              }
            },
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book_outlined), label: ''),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline), label: ''),
            ],
          )),
    );
  }
}
