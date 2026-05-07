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
import '../views/teacher/class_details_screen.dart';
import '../views/teacher/mark_attendance_screen.dart';
import '../views/teacher/attendance_history_screen.dart';
import '../views/teacher/teacher_profile_screen.dart';
import '../views/student/student_dashboard.dart';
import '../views/student/student_class_details.dart';
import '../views/student/student_profile.dart';
import '../controllers/auth_controller.dart';
import '../controllers/admin_controller.dart';
import '../controllers/student_controller.dart';

class AppRoutes {
  // Route name constants
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const adminDashboard = '/admin-dashboard';
  static const teacherDashboard = '/teacher-dashboard';
  static const classDetails = '/class-details';
  static const markAttendance = '/mark-attendance';
  static const attendanceHistory = '/attendance-history';
  static const studentDashboard = '/student-dashboard';
  static const studentClassDetails = '/student-class-details';
  static const studentProfile = '/student-profile';
  static const addUser = '/add-user';
  static const teacherProfile = '/teacher-profile';
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
      page: () => TeacherDashboard(),
    ),
    GetPage(
      name: classDetails,
      page: () => ClassDetailsScreen(),
    ),
    GetPage(
      name: markAttendance,
      page: () => MarkAttendanceScreen(),
    ),
    GetPage(
      name: attendanceHistory,
      page: () => AttendanceHistoryScreen(),
    ),
    GetPage(
      name: teacherProfile,
      page: () => TeacherProfileScreen(),
    ),
    GetPage(
      name: studentDashboard,
  page: () => const StudentDashboard(),
  binding: BindingsBuilder(() {
    // This is the missing piece! 
    // It tells GetX to initialize the controller when the user hits this route.
    Get.lazyPut<StudentController>(() => StudentController());
  })
    ),
    GetPage(
      name: studentClassDetails,
      page: () => const StudentClassDetails(),
    ),
    GetPage(
      name: studentProfile,
      page: () => const StudentProfile(),
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
