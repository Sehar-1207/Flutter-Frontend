import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import 'package:flutter/material.dart';

class StudentController extends GetxController {
  // -----------------------------
  // LOADING STATES
  // -----------------------------
  var isProfileLoading = false.obs;
  var isClassesLoading = false.obs;
  var isAttendanceLoading = false.obs;
  var isLoading = false.obs; // Unified loading for profile update

  // -----------------------------
  // DATA VARIABLES
  // -----------------------------
  var profile = {}.obs;

  // My Classes
  var myClasses = [].obs;

  // Single Class Attendance
  var classAttendance = {}.obs;

  // All Attendance
  var allAttendance = [].obs;

  // -----------------------------
  // TOKEN
  // -----------------------------
  String? get token => GetStorage().read('token');

  // =========================================================
  // GET PROFILE
  // =========================================================
  Future<void> getProfile() async {
    try {
      isProfileLoading(true);

      var response = await http.get(
        Uri.parse('${ApiService.baseUrl}/student/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        profile.value = data['data'];
      } else {
        Get.snackbar("Error", data['message'] ?? "Failed to load profile");
      }
    } catch (e) {
      Get.snackbar("Error", "Network error while loading profile");
    } finally {
      isProfileLoading(false);
    }
  }

  // =========================================================
  // UPDATE PROFILE (Name and/or Password)
  // =========================================================
  Future<void> updateFullProfile({required String name, String? password}) async {
    try {
      isLoading(true);
      Get.defaultDialog(
        title: "Saving Changes",
        content: const CircularProgressIndicator(),
        barrierDismissible: false,
      );
      final Map<String, dynamic> body = {"name": name};
      if (password != null && password.isNotEmpty) {
        body["password"] = password;
      }
      var response = await http.put(
        Uri.parse('${ApiService.baseUrl}/student/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );
      Get.back();
      var data = json.decode(response.body);
      if (response.statusCode == 200) {
        profile.value = {...profile.value, 'name': name};
        Get.snackbar(
          "Success",
          data['message'] ?? "Profile updated successfully",
          snackPosition: SnackPosition.TOP,
        );
      } else {
        Get.snackbar(
          "Error",
          data['message'] ?? "Failed to update profile",
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        "Error",
        "Network error",
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading(false);
    }
  }

  // =========================================================
  // GET MY CLASSES
  // =========================================================
  Future<void> getMyClasses() async {
    try {
      isClassesLoading(true);

      var response = await http.get(
        Uri.parse('${ApiService.baseUrl}/student/classes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        myClasses.value = data['data'] ?? [];
      } else {
        Get.snackbar(
          "Error",
          data['message'] ?? "Failed to load classes",
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Network error while fetching classes",
      );
    } finally {
      isClassesLoading(false);
    }
  }

  // =========================================================
  // GET SINGLE CLASS ATTENDANCE
  // =========================================================
  Future<void> getClassAttendance(String classId) async {
    try {
      isAttendanceLoading(true);

      var response = await http.get(
        Uri.parse(
            '${ApiService.baseUrl}/student/classes/$classId/attendance'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        classAttendance.value = data['data'];
      } else {
        Get.snackbar(
          "Error",
          data['message'] ?? "Failed to load attendance",
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Network error while fetching attendance",
      );
    } finally {
      isAttendanceLoading(false);
    }
  }

  // =========================================================
  // GET ALL ATTENDANCE
  // =========================================================
  Future<void> getAllAttendance() async {
    try {
      isAttendanceLoading(true);

      var response = await http.get(
        Uri.parse('${ApiService.baseUrl}/student/attendance'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        allAttendance.value = data['data'] ?? [];
      } else {
        Get.snackbar(
          "Error",
          data['message'] ?? "Failed to load attendance",
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Network error while loading attendance",
      );
    } finally {
      isAttendanceLoading(false);
    }
  }
}