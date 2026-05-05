import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/api_service.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final ApiService _api = ApiService();
  final _storage = GetStorage();

  // Reactive variables – UI rebuilds when these change
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // ─── LOGIN ───────────────────────────────────────────────

  Future<void> login(String email, String password) async {
    // Basic validation
    if (!_isValidEmail(email)) {
      errorMessage.value = 'Please enter a valid email address';
      return;
    }
    if (password.isEmpty) {
      errorMessage.value = 'Password cannot be empty';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _api.login(email, password);

      if (result['success']) {
        final data = result['data'];
        // Save token and role to local storage
        _storage.write('token', data['token']);
        _storage.write('role', data['role']);
        // Go to the right dashboard based on role
        _navigateByRole(data['role']);
      } else {
        errorMessage.value = result['message'] ?? 'Login failed';
      }
    } catch (e) {
      errorMessage.value = 'Network error. Please check your connection.';
    } finally {
      isLoading.value = false;
    }
  }

  // ─── REGISTER (students only) ────────────────────────────

  Future<void> register(String name, String email, String password) async {
    // Basic validation
    if (name.trim().isEmpty) {
      errorMessage.value = 'Please enter your full name';
      return;
    }
    if (!_isValidEmail(email)) {
      errorMessage.value = 'Please enter a valid email address';
      return;
    }
    if (password.isEmpty) {
      errorMessage.value = 'Password cannot be empty';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _api.register(name, email, password);

      if (result['success']) {
        Get.snackbar(
          'Account Created!',
          'Please login with your new account.',
          snackPosition: SnackPosition.BOTTOM,
        );
        // Go back to login
        Get.offNamed(AppRoutes.login);
      } else {
        errorMessage.value = result['message'] ?? 'Registration failed';
      }
    } catch (e) {
      errorMessage.value = 'Network error. Please check your connection.';
    } finally {
      isLoading.value = false;
    }
  }

  // ─── LOGOUT ──────────────────────────────────────────────

  void logout() {
    _storage.erase(); // Clear token + role
    Get.offAllNamed(AppRoutes.login);
  }

  // ─── HELPERS ─────────────────────────────────────────────

  void _navigateByRole(String role) {
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
        errorMessage.value = 'Unknown role: $role';
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email);
  }
}
