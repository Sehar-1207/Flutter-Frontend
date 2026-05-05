import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'routes/app_routes.dart';

void main() async {
  // Initialize local storage before running app
  await GetStorage.init();
  runApp(const AttendApp());
}

class AttendApp extends StatelessWidget {
  const AttendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Attend',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A3AFF)),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      // Start from splash screen
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
    );
  }
}
