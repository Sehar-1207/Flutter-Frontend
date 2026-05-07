import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';
import '../views/teacher/teacher_dashboard.dart';

class TeacherProfileController extends GetxController {
  var isLoading = false.obs;
  var isFetchingProfile = false.obs;
  var currentName = "".obs;
  var currentEmail = "".obs;
  late TextEditingController nameController;
  late TextEditingController passwordController;

  @override
  void onInit() {
    super.onInit();

    // Show cached value instantly — no flicker
    final String cached = GetStorage().read('name') ?? '';
    currentName.value = cached;
    nameController = TextEditingController(text: cached);
    passwordController = TextEditingController();

    nameController.addListener(() {
      currentName.value = nameController.text;
    });

    // Then silently fetch fresh data from server
    fetchProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // ─── GET PROFILE ────────────────────────────────────────────────────────────

  Future<void> fetchProfile() async {
    try {
      isFetchingProfile(true);
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
        final String freshEmail = data['email'] ?? '';

        // Update storage so next open is instant too
        await GetStorage().write('name', freshName);

        // Update observables
        currentName.value = freshName;
        currentEmail.value = freshEmail;

        // Update text field only if user hasn't started typing
        if (nameController.text == nameController.text) {
          nameController.text = freshName;
          // Move cursor to end
          nameController.selection = TextSelection.fromPosition(
            TextPosition(offset: freshName.length),
          );
        }

        // Sync dashboard controller if alive
        _syncDashboard(freshName);
      }
    } catch (_) {
      // Silently fail — cached value already shown
    } finally {
      isFetchingProfile(false);
    }
  }

  // ─── UPDATE PROFILE ─────────────────────────────────────────────────────────

  Future<void> updateProfile() async {
    final trimmedName = nameController.text.trim();
    final trimmedPassword = passwordController.text.trim();

    if (trimmedName.isEmpty) {
      Get.snackbar(
        "Validation",
        "Name cannot be empty",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      isLoading(true);
      final String? token = GetStorage().read('token');

      final Map<String, dynamic> body = {'name': trimmedName};
      if (trimmedPassword.isNotEmpty) {
        body['password'] = trimmedPassword;
      }

      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/teacher/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 1. Persist to local storage
        await GetStorage().write('name', trimmedName);

        // 2. If password was set, user is no longer purely a Google user
        if (trimmedPassword.isNotEmpty) {
          await GetStorage().write('isGoogleUser', false);
        }

        // 3. Update profile screen's own observables
        currentName.value = trimmedName;

        // 4. Sync dashboard
        _syncDashboard(trimmedName);

        // 5. Clear password field after success
        passwordController.clear();

        Get.snackbar(
          "Success",
          "Profile updated successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.transparent,
          colorText: Colors.black,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        );

        await Future.delayed(const Duration(seconds: 2));
        Get.back(result: true);
      } else {
        final errorData = json.decode(response.body);
        Get.snackbar(
          "Error",
          errorData['message'] ?? "Failed to update profile",
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (_) {
      Get.snackbar(
        "Error",
        "Network error. Please check your connection.",
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading(false);
    }
  }

  // ─── HELPER ─────────────────────────────────────────────────────────────────

  void _syncDashboard(String name) {
    if (Get.isRegistered<TeacherController>()) {
      final dash = Get.find<TeacherController>();
      dash.teacherName.value = name;
      dash.teacherInitial.value =
          name.isNotEmpty ? name[0].toUpperCase() : '?';
    }
  }
}