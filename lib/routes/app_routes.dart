import 'package:get/get.dart';
import '../views/splash_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/signup_screen.dart';
import '../views/admin/admin_dashboard.dart';
import '../views/admin/add_user_screen.dart';
import '../views/admin/manage_users_screen.dart';
import '../views/admin/manage_classes_screen.dart';
import '../views/admin/recent_registrations_screen.dart';
import '../views/admin/admin_profile_screen.dart';
import '../views/teacher/teacher_dashboard.dart';
import '../views/student/student_dashboard.dart';
import '../controllers/auth_controller.dart';
import '../controllers/admin_controller.dart';

class AppRoutes {
  // Route name constants
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const adminDashboard = '/admin-dashboard';
  static const teacherDashboard = '/teacher-dashboard';
  static const studentDashboard = '/student-dashboard';
  static const addUser = '/add-user';
  static const manageUsers = '/manage-users';
  static const manageClasses = '/manage-classes';
  static const recentRegistrations = '/recent-registrations';
  static const adminProfile = '/admin-profile';

  // All app pages/routes
  static final pages = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: login,
      page: () => LoginScreen(),
      // Register AuthController when entering login
      binding: BindingsBuilder(() {
        Get.put(AuthController());
      }),
    ),
    GetPage(
      name: signup,
      page: () => SignupScreen(),
    ),
    GetPage(
      name: adminDashboard,
      page: () => const AdminDashboard(),
      // Register AdminController when entering admin dashboard
      binding: BindingsBuilder(() {
        Get.put(AdminController());
      }),
    ),
    GetPage(
      name: teacherDashboard,
      page: () => const TeacherDashboard(),
    ),
    GetPage(
      name: studentDashboard,
      page: () => const StudentDashboard(),
    ),
    GetPage(
      name: addUser,
      page: () => AddUserScreen(),
    ),
    GetPage(
      name: manageUsers,
      page: () => const ManageUsersScreen(),
    ),
    GetPage(
      name: manageClasses,
      page: () => const ManageClassesScreen(),
    ),
    GetPage(
      name: recentRegistrations,
      page: () => const RecentRegistrationsScreen(),
    ),
    GetPage(
      name: adminProfile,
      page: () => const AdminProfileScreen(),
    ),
  ];
}
