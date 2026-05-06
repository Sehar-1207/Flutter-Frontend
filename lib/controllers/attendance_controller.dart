import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class AttendanceController extends GetxController {
  var isLoading = false.obs;
  var classId = ''.obs;
  var students = [].obs;

  // Map to hold attendance status: studentId -> 'Present' / 'Absent'
  var attendanceStatus = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      classId.value = Get.arguments['classId'];
      students.value = Get.arguments['students'] ?? [];

      // By default, mark everyone as Present
      for (var i = 0; i < students.length; i++) {
        var s = students[i];
        String sid = s['studentId'] ?? s['id'] ?? i.toString();
        attendanceStatus[sid] = 'Present';
      }

      attendanceStatus.refresh();
    }
  }

  int get totalPresent =>
      attendanceStatus.values.where((s) => s == 'Present').length;
  int get totalAbsent =>
      attendanceStatus.values.where((s) => s == 'Absent').length;

  
  void toggleStatus(String studentId, String status) {
    attendanceStatus[studentId] = status;
    attendanceStatus.refresh();
  }

  void markAllLocal(String status) {
    for (var i = 0; i < students.length; i++) {
      var s = students[i];
      String sid = s['studentId'] ?? s['id'] ?? i.toString();
      attendanceStatus[sid] = status;
    }
  }

  String get todayDate {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  Future<void> submitAttendance() async {
    try {
      isLoading(true);
      Get.defaultDialog(
          title: "Submitting Attendance",
          content: const CircularProgressIndicator(),
          barrierDismissible: false);

      final records = students.map((s) {
        String sid = s['studentId'] ?? s['id'] ?? '';
        return {"studentId": sid, "status": attendanceStatus[sid] ?? 'Present'};
      }).toList();

      String? token = GetStorage().read('token');
      var response = await http.post(
          Uri.parse(
              '${ApiService.baseUrl}/teacher/classes/${classId.value}/attendance'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({"date": todayDate, "records": records}));

      Get.back(); // close dialog
      var data = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.back(); 
        Get.snackbar("Success", "Attendance saved successfully!",
            snackPosition: SnackPosition.TOP);
      } else {
        Get.snackbar("Error", data['message'] ?? "Failed to save attendance",
            snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar("Error", "Network error.",
          snackPosition: SnackPosition.TOP);
    } finally {
      isLoading(false);
    }
  }

  Future<void> submitMarkAll(String status) async {
    
    try {
      isLoading(true);
      Get.defaultDialog(
          title: "Submitting $status",
          content: const CircularProgressIndicator(),
          barrierDismissible: false);

      String? token = GetStorage().read('token');
      var response = await http.post(
          Uri.parse(
              '${ApiService.baseUrl}/teacher/classes/${classId.value}/attendance/mark-all'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({"date": todayDate, "status": status}));

      Get.back();
      var data = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.back();
        Get.snackbar("Success", data['message'] ?? "Marked all as $status",
            snackPosition: SnackPosition.TOP);
      } else {
        Get.snackbar("Error", data['message'] ?? "Failed to mark all",
            snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar("Error", "Network error.",
          snackPosition: SnackPosition.TOP);
    } finally {
      isLoading(false);
    }
  }
}
