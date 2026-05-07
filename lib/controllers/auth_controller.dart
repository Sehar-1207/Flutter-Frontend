import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
      _storage.write('token', data['token']);
      _storage.write('role', data['role']);
      _storage.write('name', data['name']);        // ← ADD THIS LINE
      _storage.write('isGoogleUser', false);        // ← ADD THIS LINE
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

  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        isLoading.value = false;
        return;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final idToken = await userCredential.user!.getIdToken();

      if (idToken == null) {
        errorMessage.value = "Google login failed";
        return;
      }

      //  Backend call
      final result = await _api.googleLogin(idToken!);

      if (result['success']) {
        final data = result['data'];
        // In AuthController.login() — after result['success']
        _storage.write('token', data['token']);
        _storage.write('role', data['role']);
        _storage.write('name', data['name']); // ← ADD THIS
        _storage.write('isGoogleUser', false); // ← ADD THIS

        _navigateByRole(data['role']);
      } else {
        errorMessage.value = result['message'] ?? 'Google login failed';
      }
    } catch (e, stackTrace) {
      print('Google login exception: $e\n$stackTrace');
      errorMessage.value = 'Google login error: $e';
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
          snackPosition: SnackPosition.TOP,
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
