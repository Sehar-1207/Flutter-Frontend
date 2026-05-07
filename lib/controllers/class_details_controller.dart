import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class ClassDetailsController extends GetxController {
  var isLoading = true.obs;
  var students = [].obs;
  var classData = {}.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      classData.value = Get.arguments;
      fetchStudents(classData['id']);
    }
  }

  Future<void> fetchStudents(String classId) async {
    try {
      isLoading(true);
      String? token = GetStorage().read('token');
      var response = await http.get(
        Uri.parse('${ApiService.baseUrl}/teacher/classes/$classId/students'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        students.value = jsonData['data'] ?? [];
      } else {
        Get.snackbar("Error", "Failed to load students");
      }
    } catch (e) {
      Get.snackbar("Error", "Network error while fetching students.");
    } finally {
      isLoading(false);
    }
  }

  Future<void> addStudent(String classId, String email, String name,
      String rollNo, String section) async {
    try {
      Get.defaultDialog(
        title: "Adding Student",
        content: const CircularProgressIndicator(),
        barrierDismissible: false,
      );

      String? token = GetStorage().read('token');
      var response = await http.post(
        Uri.parse('${ApiService.baseUrl}/teacher/classes/$classId/students'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "studentEmail": email,
          "studentName": name,
          "rollNo": rollNo,
          "section": section,
        }),
      );

      Get.back(); // close loading
      var data = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.back(); // close bottom sheet
        Get.snackbar("Success", "Student added successfully!",
            snackPosition: SnackPosition.TOP);
        fetchStudents(classId); // refresh
      } else {
        Get.snackbar("Error", data['message'] ?? "Failed to add student",
            snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar("Error", "Network error.",
          snackPosition: SnackPosition.TOP);
    }
  }

  Future<void> removeStudent(String classId, String studentId) async {
    try {
      Get.defaultDialog(
        title: "Removing...",
        content: const CircularProgressIndicator(),
        barrierDismissible: false,
      );

      String? token = GetStorage().read('token');
      var response = await http.delete(
        Uri.parse(
            '${ApiService.baseUrl}/teacher/classes/$classId/students/$studentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      Get.back(); // close dialog
      if (response.statusCode == 200) {
        Get.snackbar("Success", "Student removed",
            snackPosition: SnackPosition.TOP);
        fetchStudents(classId);
      } else {
        Get.snackbar("Error", "Failed to remove student",
            snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar("Error", "Network error.",
          snackPosition: SnackPosition.TOP);
    }
  }
}
