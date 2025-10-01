import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Models
class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? avatar;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: json['role'] ?? '',
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'avatar': avatar,
    };
  }

  String get fullName => '$firstName $lastName';

  bool get isDoctor => role == 'DOCTOR';
  bool get isNurse => role == 'NURSE';
  bool get isPatient => role == 'PATIENT';
  bool get isReceptionist => role == 'RECEPTIONIST';
  bool get isPharmacist => role == 'PHARMACIST';
  bool get isLabTechnician => role == 'LAB_TECHNICIAN';
  bool get isBillingStaff => role == 'BILLING_MANAGER' || role == 'ACCOUNTANT';
  bool get isAdmin => role == 'SUPER_ADMIN';
}

class AuthState {
  final User? user;
  final String? token;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    String? token,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Auth Service
class AuthService {
  static const String baseUrl = 'http://localhost:3001/api';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userKey);
  }

  Future<void> saveAuthData(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    await prefs.setString(userKey, json.encode(user.toJson()));
  }

  Future<AuthState> getStoredAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(tokenKey);
      final userData = prefs.getString(userKey);

      if (token != null && userData != null) {
        final user = User.fromJson(json.decode(userData));
        return AuthState(
          user: user,
          token: token,
          isAuthenticated: true,
        );
      }
    } catch (e) {
      print('Error getting stored auth data: $e');
    }

    return AuthState();
  }

  Future<User?> getCurrentUser(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data['user']);
      }
    } catch (e) {
      print('Error getting current user: $e');
    }

    return null;
  }
}

// Auth Provider
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();

  AuthNotifier() : super(AuthState()) {
    _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    state = state.copyWith(isLoading: true);
    try {
      final authData = await _authService.getStoredAuthData();
      if (authData.isAuthenticated && authData.token != null) {
        // Verify token is still valid
        final user = await _authService.getCurrentUser(authData.token!);
        if (user != null) {
          state = authData.copyWith(user: user);
        } else {
          // Token is invalid, clear stored data
          await _authService.logout();
          state = AuthState();
        }
      } else {
        state = AuthState();
      }
    } catch (e) {
      state = AuthState(error: 'Failed to load stored authentication');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.login(email, password);

      // Extract user data from API response and map it properly
      final userApiData = response['user'];
      final userData = {
        'id': userApiData['id'].toString(), // Convert int to string
        'email': userApiData['email'],
        'firstName': userApiData['firstName'],
        'lastName': userApiData['lastName'],
        'role': userApiData['role']['name'], // Extract nested role name
        'avatar': userApiData['avatar'],
      };

      final user = User.fromJson(userData);
      final token = response['tokens']['accessToken']; // Extract access token

      await _authService.saveAuthData(token, user);

      state = AuthState(
        user: user,
        token: token,
        isAuthenticated: true,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authService.logout();
    } catch (e) {
      print('Logout error: $e');
    }

    state = AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  bool hasRole(List<String> allowedRoles) {
    return state.user != null && allowedRoles.contains(state.user!.role);
  }

  bool canAccessPatients() {
    return hasRole(['SUPER_ADMIN', 'DOCTOR', 'NURSE', 'RECEPTIONIST']);
  }

  bool canAccessPharmacy() {
    return hasRole(['SUPER_ADMIN', 'PHARMACIST', 'DOCTOR', 'NURSE']);
  }

  bool canAccessLab() {
    return hasRole(['SUPER_ADMIN', 'LAB_TECHNICIAN', 'DOCTOR', 'NURSE']);
  }

  bool canAccessBilling() {
    return hasRole(['SUPER_ADMIN', 'BILLING_MANAGER', 'ACCOUNTANT']);
  }

  bool canAccessReports() {
    return hasRole(['SUPER_ADMIN', 'DOCTOR']);
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Convenience providers
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final userRoleProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).user?.role;
});
