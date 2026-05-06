import 'package:get/get.dart';
import '../services/api_service.dart';

class AdminController extends GetxController {
  final ApiService _api = ApiService();

  //DashBoard stats
  var isLoading = false.obs;
  var totalStudents = 0.obs;
  var totalTeachers = 0.obs;
  var totalAdmins = 0.obs;
  var totalUsers = 0.obs;

  // Add-user form state
  var isAddingUser = false.obs;
  var errorMessage = ''.obs;

  // Data lists
  var adminProfile = <String, dynamic>{}.obs;
  var usersList = [].obs;
  var classesList = [].obs;
  var registrationsList = [].obs;
  var isProfileLoading = false.obs;
  var isUsersLoading = false.obs;
  var isClassesLoading = false.obs;
  var isRegistrationsLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load dashboard stats when controller is created
    fetchDashboardStats();
    fetchAdminProfile();
  }

  // ─── ADMIN PROFILE ────────────────────────────────────────

  Future<void> fetchAdminProfile() async {
    isProfileLoading.value = true;
    try {
      final result = await _api.getAdminProfile();
      if (result['success']) {
        final data = result['data'] is Map
            ? result['data']
            : (result['data']['data'] ?? {});
        adminProfile.assignAll(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile');
    } finally {
      isProfileLoading.value = false;
    }
  }

  Future<void> updateAdminProfile(String name, String password) async {
    try {
      final data = <String, dynamic>{};
      if (name.isNotEmpty) data['name'] = name;
      if (password.isNotEmpty) data['password'] = password;

      if (data.isEmpty) {
        Get.snackbar('Error', 'Provide name or password to update');
        return;
      }

      final result = await _api.updateAdminProfile(data);
      if (result['success']) {
        fetchAdminProfile(); // Refresh the profile from backend
        Get.back(); // close screen or dialog
        Get.snackbar('Success', 'Profile updated successfully',
            snackPosition: SnackPosition.TOP);
      } else {
        Get.snackbar('Error', result['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      Get.snackbar('Error', 'Network error while updating profile');
    }
  }

  // ─── DASHBOARD ───────────────────────────────────────────

  Future<void> fetchDashboardStats() async {
    isLoading.value = true;
    try {
      final result = await _api.getAdminStats();
      if (result['success']) {
        
        final stats = result[
            'data']; 
        totalStudents.value =
            stats['totalStudents'] ?? stats['data']?['totalStudents'] ?? 0;
        totalTeachers.value =
            stats['totalTeachers'] ?? stats['data']?['totalTeachers'] ?? 0;
        totalAdmins.value =
            stats['totalAdmins'] ?? stats['data']?['totalAdmins'] ?? 0;
        totalUsers.value =
            stats['totalUsers'] ?? stats['data']?['totalUsers'] ?? 0;
      }
    } catch (e) {
      // Stats failing silently is acceptable – show 0s
    } finally {
      isLoading.value = false;
    }
  }

  // ─── LIST DATA ───────────────────────────────────────────

  Future<void> fetchClassesOverview() async {
    isClassesLoading.value = true;
    try {
      final result = await _api.getClassesOverview();
      if (result['success']) {
        final data = result['data'];
        if (data is List) {
          classesList.assignAll(data);
        } else if (data['classesOverview'] != null) {
          classesList.assignAll(data['classesOverview']);
        } else {
          classesList.assignAll(data['data'] ?? []);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load classes overview');
    } finally {
      isClassesLoading.value = false;
    }
  }

  Future<void> fetchRecentRegistrations() async {
    isRegistrationsLoading.value = true;
    try {
      final result = await _api.getRecentRegistrations();
      if (result['success']) {
        final data = result['data'];
        if (data is List) {
          registrationsList.assignAll(data);
        } else if (data['recentRegistrations'] != null) {
          registrationsList.assignAll(data['recentRegistrations']);
        } else {
          registrationsList.assignAll(data['data'] ?? []);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load recent registrations');
    } finally {
      isRegistrationsLoading.value = false;
    }
  }

  Future<void> fetchAllUsers({String role = 'All'}) async {
    isUsersLoading.value = true;
    try {
      final result = await _api.getAllUsers(role: role);
      if (result['success']) {
        final data = result['data'] is List
            ? result['data']
            : result['data']['data'] ?? [];
        usersList.assignAll(data);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load users');
    } finally {
      isUsersLoading.value = false;
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      final result = await _api.deleteUser(id);
      if (result['success']) {
        usersList.removeWhere((u) => u['_id'] == id || u['id'] == id);
        Get.snackbar('Success', 'User deleted successfully',
            snackPosition: SnackPosition.TOP);
        fetchDashboardStats();
      } else {
        Get.snackbar('Error', result['message'] ?? 'Failed to delete user');
      }
    } catch (e) {
      Get.snackbar('Error', 'Network error while deleting user');
    }
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    try {
      final result = await _api.updateUser(id, data);
      if (result['success']) {
        fetchAllUsers(); // Reload list
        Get.back(); // close dialog or screen
        Get.snackbar('Success', 'User updated successfully',
            snackPosition: SnackPosition.TOP);
      } else {
        Get.snackbar('Error', result['message'] ?? 'Failed to update user');
      }
    } catch (e) {
      Get.snackbar('Error', 'Network error while updating user');
    }
  }

  // ─── ADD USER ────────────────────────────────────────────

  Future<void> addUser(
      String name, String email, String password, String role) async {
    // Validation
    if (name.trim().isEmpty) {
      errorMessage.value = 'Name is required';
      return;
    }
    if (!RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email)) {
      errorMessage.value = 'Please enter a valid email address';
      return;
    }
    if (password.isEmpty) {
      errorMessage.value = 'Password is required';
      return;
    }

    isAddingUser.value = true;
    errorMessage.value = '';

    try {
      final result = await _api.addUser(name, email, password, role);

      if (result['success']) {
        Get.back(); 
        fetchAllUsers(); 
        fetchDashboardStats();
        Get.snackbar(
          'Success',
          'User added successfully',
          snackPosition: SnackPosition.TOP,
        );
      } else {
        errorMessage.value = result['message'] ?? 'Failed to add user';
      }
    } catch (e) {
      errorMessage.value = 'Network error. Please check your connection.';
    } finally {
      isAddingUser.value = false;
    }
  }
}
