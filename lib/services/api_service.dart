import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class ApiService {
  // -------------------------------------------------------
  // IMPORTANT: Change this URL to match your backend server
  // Android emulator  → http://10.0.2.2:5000/api
  // iOS simulator     → http://localhost:5000/api
  // Real device       → http://YOUR_PC_LOCAL_IP:5000/api
  //   (e.g. http://192.168.1.5:5000/api)
  // -------------------------------------------------------
  // static const String baseUrl = 'http://localhost:3000/api';
  // static const String baseUrl = 'http://192.168.100.5:5000/api';
  static const String baseUrl = 'https://flutter-backend-gtkr.onrender.com/api';

  final _storage = GetStorage();

  // Retrieve the saved JWT token
  String? get token => _storage.read('token');

  // Headers with Authorization (for protected routes)
  Map<String, String> get authHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // Headers without Authorization (for public routes)
  Map<String, String> get headers => {
        'Content-Type': 'application/json',
      };

  // ─── AUTH ────────────────────────────────────────────────

  /// POST /api/auth/login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> googleLogin(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/google-login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token}),
    );

    return _handleResponse(response);
  }

  /// POST /api/auth/register  (students only)
  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: headers,
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return _handleResponse(response);
  }

  // ─── ADMIN ───────────────────────────────────────────────

  /// GET /api/admin/profile
  Future<Map<String, dynamic>> getAdminProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/profile'),
      headers: authHeaders,
    );
    return _handleResponse(response);
  }

  /// PUT /api/admin/profile
  Future<Map<String, dynamic>> updateAdminProfile(
      Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/profile'),
      headers: authHeaders,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  /// GET /api/admin/dashboard/stats
  Future<Map<String, dynamic>> getAdminStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/dashboard/stats'),
      headers: authHeaders,
    );
    return _handleResponse(response);
  }

  /// GET /api/admin/dashboard/recent-registrations
  Future<Map<String, dynamic>> getRecentRegistrations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/dashboard/recent-registrations'),
      headers: authHeaders,
    );
    return _handleResponse(response);
  }

  /// GET /api/admin/dashboard/classes-overview
  Future<Map<String, dynamic>> getClassesOverview() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/dashboard/classes-overview'),
      headers: authHeaders,
    );
    return _handleResponse(response);
  }

  /// GET /api/admin/users (with optional role filter)
  Future<Map<String, dynamic>> getAllUsers({String? role}) async {
    final uri = role != null && role.isNotEmpty && role != 'All'
        ? Uri.parse('$baseUrl/admin/users?role=${role.toLowerCase()}')
        : Uri.parse('$baseUrl/admin/users');

    final response = await http.get(
      uri,
      headers: authHeaders,
    );
    return _handleResponse(response);
  }

  /// POST /api/admin/users  (create any role)
  Future<Map<String, dynamic>> addUser(
      String name, String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/users'),
      headers: authHeaders,
      body: jsonEncode(
          {'name': name, 'email': email, 'password': password, 'role': role}),
    );
    return _handleResponse(response);
  }

  /// PUT /api/admin/users/:id
  Future<Map<String, dynamic>> updateUser(
      String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/users/$id'),
      headers: authHeaders,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  /// DELETE /api/admin/users/:id
  Future<Map<String, dynamic>> deleteUser(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/users/$id'),
      headers: authHeaders,
    );
    return _handleResponse(response);
  }

  
  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {'success': true, 'data': body};
    } else {
      String errorMessage = 'Something went wrong';
      if (body is Map) {
        errorMessage = body['message'] ?? body['error'] ?? errorMessage;
      }
      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }
}
