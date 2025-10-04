import 'dart:convert';
import 'package:http/http.dart' as http;

class DeveloperApiService {
  static const String baseUrl = 'http://localhost:3001/api/developer';
  static const String authPhrase = 'dev@hospital2025';

  String? _token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'x-developer-phrase': authPhrase,
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // Create Developer Account
  Future<Map<String, dynamic>> createAccount(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/accounts/create'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'displayName': displayName,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Developer Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true && data['token'] != null) {
        _token = data['token'];
      }
      return data;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Developer Logout
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: _headers,
      );

      _token = null;
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Delete Developer Account
  Future<Map<String, dynamic>> deleteAccount(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/accounts/$id'),
        headers: _headers,
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get All Developer Accounts
  Future<Map<String, dynamic>> getAllAccounts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/accounts'),
        headers: _headers,
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Select Role (Impersonate)
  Future<Map<String, dynamic>> selectRole(
      String role, String? demoUserId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/role/select'),
        headers: _headers,
        body: jsonEncode({
          'role': role,
          'demoUserId': demoUserId,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get Session Info
  Future<Map<String, dynamic>> getSession() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/session'),
        headers: _headers,
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get Demo Users by Role
  Future<Map<String, dynamic>> getDemoUsers(String role) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/demo-users/$role'),
        headers: _headers,
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Set token for authenticated requests
  void setToken(String token) {
    _token = token;
  }

  // Get current token
  String? get token => _token;

  // Clear token
  void clearToken() {
    _token = null;
  }
}
