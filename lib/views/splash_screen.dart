import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  
  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    final storage = GetStorage();
    final token = storage.read('token');
    final role = storage.read('role');

    
    if (token != null && role != null) {
      switch (role) {
        case 'admin':
          Get.offAllNamed(AppRoutes.adminDashboard);
          break;
        case 'teacher':
          Get.offAllNamed(AppRoutes.teacherDashboard);
          break;
        case 'student':
          Get.offAllNamed(AppRoutes.studentDashboard);
          break;
        default:
          Get.offAllNamed(AppRoutes.login);
      }
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A3AFF), 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Attend',
              style: TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Attendance, simplified.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Text(
          'v1.0.0',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
