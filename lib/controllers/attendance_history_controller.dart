import 'dart:convert';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class AttendanceHistoryController extends GetxController {
  var isLoadingSummary = true.obs;
  var isLoadingDaily = false.obs;

  var summaryData = {}.obs;
  var dailyRecords = [].obs;
  var dailyMessage = ''.obs;
  var selectedDate = DateTime.now().obs;

  var classId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments['classId'] != null) {
      classId.value = Get.arguments['classId'];
      fetchSummary();
      fetchDailyAttendance();
    }
  }

  void onDatePicked(DateTime date) {
    selectedDate.value = date;
    fetchDailyAttendance();
  }

  Future<void> fetchSummary() async {
    try {
      isLoadingSummary(true);
      String? token = GetStorage().read('token');
      var response = await http.get(
        Uri.parse(
            '${ApiService.baseUrl}/teacher/classes/${classId.value}/attendance-summary'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        summaryData.value = jsonData['data'] ?? {};
      }
    } catch (e) {
      Get.snackbar("Error", "Network error fetching summary.");
    } finally {
      isLoadingSummary(false);
    }
  }

  Future<void> fetchDailyAttendance() async {
    try {
      isLoadingDaily(true);
      dailyRecords.clear();
      dailyMessage.value = '';

      String formattedDate =
          DateFormat('yyyy-MM-dd').format(selectedDate.value);
      String? token = GetStorage().read('token');

      var response = await http.get(
        Uri.parse(
            '${ApiService.baseUrl}/teacher/classes/${classId.value}/attendance?date=$formattedDate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var jsonData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (jsonData['data'] != null && jsonData['data']['records'] != null) {
          dailyRecords.value = jsonData['data']['records'];
        } else {
          dailyMessage.value = jsonData['message'] ?? 'No attendance marked.';
        }
      } else {
        dailyMessage.value = jsonData['message'] ?? 'Failed to load records.';
      }
    } catch (e) {
      dailyMessage.value = "Network Error.";
    } finally {
      isLoadingDaily(false);
    }
  }

  Future<void> exportCSV() async {
  try {
    Get.defaultDialog(
      title: "Exporting...",
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );

    String formattedDate =
        DateFormat('yyyy-MM-dd').format(selectedDate.value);

    String? token = GetStorage().read('token');

    var response = await http.get(
      Uri.parse(
        '${ApiService.baseUrl}/teacher/classes/${classId.value}/attendance/download?date=$formattedDate',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    Get.back();

    if (response.statusCode == 200) {

      // APP STORAGE DIRECTORY
      await Permission.storage.request();

      // DOWNLOAD FOLDER
        Directory dir = Directory('/storage/emulated/0/Download');
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }

        // CREATE FILE
        final file = File(
          '${dir.path}/attendance_$formattedDate.csv',
        );

      // SAVE CSV
      await file.writeAsBytes(response.bodyBytes);

      print("CSV Saved At:");
      print(file.path);

      Get.snackbar(
        "Success",
        "CSV saved successfully!\n${file.path}",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );

    } else {
      var jsonData = json.decode(response.body);

      Get.snackbar(
        "Error",
        jsonData['message'] ?? "Failed to download",
        snackPosition: SnackPosition.TOP,
      );
    }

  } catch (e) {

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    Get.snackbar(
      "Error",
      "Network Error.",
      snackPosition: SnackPosition.TOP,
    );

    print(e);
  }
}
}
