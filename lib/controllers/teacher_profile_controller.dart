import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';

class TeacherProfileController extends GetxController {
  var isLoading = false.obs;
  var currentName = "Teacher".obs;
  var nameController = TextEditingController();
  var passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    currentName.value = GetStorage().read('name') ?? 'Teacher';
    nameController.text = currentName.value;

    // Update the observable when text changes
    nameController.addListener(() {
      currentName.value = nameController.text;
    });
  }

  Future<void> updateProfile() async {
    if (nameController.text.isEmpty) {
      Get.snackbar("Validation", "Name cannot be empty",
          snackPosition: SnackPosition.TOP);
      return;
    }

    try {
      isLoading(true);
      String? token = GetStorage().read('token');

      Map<String, dynamic> body = {};
      if (nameController.text.isNotEmpty)
        body['name'] = nameController.text.trim();
      if (passwordController.text.isNotEmpty)
        body['password'] = passwordController.text.trim();

      var response = await http.put(
        Uri.parse('${ApiService.baseUrl}/teacher/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Profile updated successfully",
            snackPosition: SnackPosition.TOP);
        GetStorage().write('name', nameController.text.trim());
        Get.back(result: true); // Optionally go back
      } else {
        var errorData = json.decode(response.body);
        Get.snackbar(
            "Error", errorData['message'] ?? "Failed to update profile",
            snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      Get.snackbar("Error", "Network error.", snackPosition: SnackPosition.TOP);
    } finally {
      isLoading(false);
    }
  }
}
