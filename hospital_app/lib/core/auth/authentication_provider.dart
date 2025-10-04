import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'role_permissions.dart';
import '../dev/demo_names.dart';

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String department;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic> metadata;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    this.isActive = true,
    required this.createdAt,
    this.lastLoginAt,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString(),
      'department': department,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: UserRole.values.firstWhere(
        (role) => role.toString() == json['role'],
        orElse: () => UserRole.guest,
      ),
      department: json['department'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
      metadata: json['metadata'] ?? {},
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? department,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? metadata,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      department: department ?? this.department,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

class AuthenticationProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // Permission checking methods
  bool hasPermission(Permission permission) {
    if (_currentUser == null) return false;
    return RolePermissions.hasPermission(_currentUser!.role, permission);
  }

  bool hasAnyPermission(List<Permission> permissions) {
    return permissions.any((permission) => hasPermission(permission));
  }

  bool hasAllPermissions(List<Permission> permissions) {
    return permissions.every((permission) => hasPermission(permission));
  }

  List<Permission> getUserPermissions() {
    if (_currentUser == null) return [];
    return RolePermissions.getPermissions(_currentUser!.role);
  }

  // Authentication methods
  Future<bool> login(String email, String password,
      {bool isDeveloperMode = false}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Check if trying to use demo accounts outside developer mode
      if (!isDeveloperMode && _isDemoAccount(email)) {
        _errorMessage = 'Demo accounts are only available in Developer Mode';
        _setLoading(false);
        notifyListeners();
        return false;
      }

      // Mock authentication - in real app, this would call your backend
      final user = await _authenticateUser(email, password, isDeveloperMode);

      if (user != null) {
        _currentUser = user.copyWith(lastLoginAt: DateTime.now());
        await _saveUserSession();
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid email or password';
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _clearUserSession();
    notifyListeners();
  }

  // Developer mode: Allow role-playing as any demo user
  Future<bool> loginAsDeveloper(String demoUserEmail) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // For demo users from the API, create a user object based on the email
      // This would normally come from your backend API
      final user = await _createDemoUserFromEmail(demoUserEmail);

      if (user != null) {
        _currentUser = user.copyWith(lastLoginAt: DateTime.now());
        await _saveUserSession();
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to authenticate as demo user';
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Developer login failed: ${e.toString()}';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Create a user object from demo user email
  Future<User?> _createDemoUserFromEmail(String email) async {
    try {
      // Extract role and create appropriate user
      UserRole role = UserRole.patient; // default
      String department = 'General';
      String name = 'Demo User';

      // Extract name from email (everything before @)
      final emailParts = email.split('@');
      if (emailParts.isNotEmpty) {
        final namePart = emailParts[0];
        // Convert email username to display name (e.g., "john.doe" -> "John Doe")
        name = namePart
            .split('.')
            .map((part) => part[0].toUpperCase() + part.substring(1))
            .join(' ');
      }

      // Determine role from email content
      final emailLower = email.toLowerCase();
      if (emailLower.contains('admin')) {
        role = UserRole.superAdmin;
        department = 'Administration';
      } else if (emailLower.contains('doctor') || emailLower.contains('dr')) {
        role = UserRole.doctor;
        department = 'Medical';
      } else if (emailLower.contains('nurse')) {
        role = UserRole.nurse;
        department = 'Nursing';
      } else if (emailLower.contains('pharmacist') ||
          emailLower.contains('pharmacy')) {
        role = UserRole.pharmacist;
        department = 'Pharmacy';
      } else if (emailLower.contains('lab') ||
          emailLower.contains('laboratory')) {
        role = UserRole.labTechnician;
        department = 'Laboratory';
      } else if (emailLower.contains('reception') ||
          emailLower.contains('front')) {
        role = UserRole.receptionist;
        department = 'Front Desk';
      } else if (emailLower.contains('patient')) {
        role = UserRole.patient;
        department = 'Patient Care';
      }

      return User(
        id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        role: role,
        department: department,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  // Note: Demo users are now fetched from the backend API via DeveloperApiService
  // This method is kept for backwards compatibility but should use the API
  @Deprecated(
      'Use DeveloperApiService.getDemoUsers() instead for real demo users')
  List<User> getDemoUsers() {
    return [
      // Emergency fallback accounts only
      User(
        id: 'emergency-1',
        name: getDemoDisplayName('emergency-1'),
        email: 'admin@hospital.com',
        role: UserRole.superAdmin,
        department: 'Administration',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      User(
        id: 'emergency-2',
        name: getDemoDisplayName('emergency-2'),
        email: 'doctor@hospital.com',
        role: UserRole.doctor,
        department: 'Emergency',
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
      ),
    ];
  }

  Future<void> loadSavedSession() async {
    _setLoading(true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');

      if (userJson != null) {
        final userData = jsonDecode(userJson);
        _currentUser = User.fromJson(userData);
      }
    } catch (e) {
      debugPrint('Error loading saved session: $e');
    }

    _setLoading(false);
    notifyListeners();
  }

  Future<void> _saveUserSession() async {
    if (_currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', jsonEncode(_currentUser!.toJson()));
    }
  }

  Future<void> _clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Mock user database - in real app, this would be handled by backend
  Future<User?> _authenticateUser(
      String email, String password, bool isDeveloperMode) async {
    // Emergency fallback demo accounts - only available in developer mode
    final emergencyDemoUsers = {
      'admin@hospital.com': User(
        id: 'emergency-1',
        name: getDemoDisplayName('emergency-1'),
        email: 'admin@hospital.com',
        role: UserRole.superAdmin,
        department: 'Administration',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      'doctor@hospital.com': User(
        id: 'emergency-2',
        name: getDemoDisplayName('emergency-2'),
        email: 'doctor@hospital.com',
        role: UserRole.doctor,
        department: 'Emergency',
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
      ),
    };

    // Only allow emergency demo account authentication in developer mode
    if (emergencyDemoUsers.containsKey(email) && password == 'password123') {
      if (isDeveloperMode) {
        return emergencyDemoUsers[email];
      } else {
        return null; // Reject demo account login outside developer mode
      }
    }

    // Here you would normally validate against your actual user database
    // For production, implement real authentication logic
    return null;
  }

  // Helper method to check if an email is an emergency demo account
  bool _isDemoAccount(String email) {
    final emergencyDemoEmails = {
      'admin@hospital.com',
      'doctor@hospital.com',
    };
    return emergencyDemoEmails.contains(email);
  }

  // Emergency access override
  Future<bool> requestEmergencyAccess(String reason) async {
    if (_currentUser == null) return false;

    // Log emergency access request
    debugPrint('Emergency access requested by ${_currentUser!.name}: $reason');

    // In real app, this would:
    // 1. Log the emergency access request
    // 2. Send notifications to administrators
    // 3. Temporarily elevate permissions
    // 4. Set an expiration time for the elevated access

    return true;
  }

  // Password change
  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    if (_currentUser == null) return false;

    _setLoading(true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // In real app, this would validate current password and update in backend
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Password change failed: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  // Profile update
  Future<bool> updateProfile({
    String? name,
    String? department,
    Map<String, dynamic>? metadata,
  }) async {
    if (_currentUser == null) return false;

    _setLoading(true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        department: department ?? _currentUser!.department,
        metadata: metadata ?? _currentUser!.metadata,
      );

      await _saveUserSession();
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Profile update failed: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }
}
