import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';
import '../utils/storage_utils.dart';
import 'base_providers.dart';

// Auth State
class AuthState {
  final User? user;
  final String? token;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null && token != null;

  AuthState copyWith({
    User? user,
    String? token,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Auth State Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final StorageUtils _storage;

  AuthNotifier(this._authService, this._storage) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    try {
      final token = await _storage.getToken();
      if (token != null) {
        // Try to get current user, but don't fail if it doesn't work
        try {
          final user = await _authService.getCurrentUser();
          state = state.copyWith(
            user: user,
            token: token,
            isLoading: false,
            clearError: true,
          );
        } catch (e) {
          // If getCurrentUser fails, just clear the stored token and continue
          await _storage.removeToken();
          state = state.copyWith(
            isLoading: false,
            clearError: true,
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          clearError: true,
        );
      }
    } catch (e) {
      // Don't set error on initial check - just continue
      state = state.copyWith(
        isLoading: false,
        clearError: true,
      );
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
    }

    await _storage.clearAll();
    state = const AuthState();
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String role,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        role: role,
      );

      // Auto-login after registration
      await _storage.saveToken(response.token);

      state = state.copyWith(
        user: response.user,
        token: response.token,
        isLoading: false,
        clearError: true,
      );

      return true;
    } catch (e) {
      String errorMessage = 'Registration failed. Please try again.';

      if (e is DioException) {
        if (e.response?.statusCode == 409) {
          errorMessage = 'Email already exists';
        } else if (e.type == DioExceptionType.connectionTimeout) {
          errorMessage = 'Connection timeout. Please check your internet.';
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = 'Cannot connect to server. Please try again later.';
        }
      }

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      return false;
    }
  }

  Future<bool> deleteAccount({
    required String password,
    required String reason,
    String? additionalInfo,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _authService.deleteAccount(
        password: password,
        reason: reason,
        additionalInfo: additionalInfo,
      );

      // Clear all data and logout
      await _storage.clearAll();
      state = const AuthState();

      return true;
    } catch (e) {
      String errorMessage = 'Failed to delete account. Please try again.';

      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          errorMessage = 'Invalid password';
        } else if (e.response?.statusCode == 403) {
          errorMessage = 'Account deletion not allowed';
        }
      }

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Call the auth service to login
      final response = await _authService.login(email, password);

      // Save token to storage
      await _storage.saveToken(response.token);
      if (rememberMe) {
        await _storage.setRememberMe(true);
      }

      // Update state with user info
      state = state.copyWith(
        user: response.user,
        token: response.token,
        isLoading: false,
        clearError: true,
      );

      return true;
    } catch (e) {
      String errorMessage = 'Login failed. Please try again.';

      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          errorMessage = 'Invalid email or password';
        } else if (e.type == DioExceptionType.connectionTimeout) {
          errorMessage = 'Connection timeout. Please check your internet.';
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = 'Cannot connect to server. Please try again later.';
        }
      }

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      return false;
    }
  }

  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.changePassword(currentPassword, newPassword);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // Developer mode: Login as demo user for role-playing
  Future<bool> loginAsDeveloper(String demoUserEmail, {String? role}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Create a demo user object from the email and role
      final user = _createDemoUserFromEmail(demoUserEmail, role: role);

      if (user != null) {
        // Set user state immediately for developer mode
        state = AuthState(
          user: user,
          token: 'demo_token_${DateTime.now().millisecondsSinceEpoch}',
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          error: 'Failed to create demo user',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Developer login failed: ${e.toString()}',
        isLoading: false,
      );
      return false;
    }
  }

  // Helper method to create demo user from email
  User? _createDemoUserFromEmail(String email, {String? role}) {
    try {
      // Parse role from string to UserRole enum
      UserRole userRole = UserRole.PATIENT; // default

      if (role != null) {
        userRole = _parseUserRole(role);
      } else {
        // Try to extract from email (fallback)
        if (email.contains('admin')) {
          userRole = UserRole.ADMIN;
        } else if (email.contains('doctor')) {
          userRole = UserRole.DOCTOR;
        } else if (email.contains('nurse')) {
          userRole = UserRole.NURSE;
        } else if (email.contains('pharmacist')) {
          userRole = UserRole.PHARMACIST;
        } else if (email.contains('lab') || email.contains('laboratory')) {
          userRole = UserRole.LABORATORY;
        } else if (email.contains('receptionist')) {
          userRole = UserRole.RECEPTIONIST;
        }
      }

      // Extract name from email
      final nameParts = email.split('@')[0].split('.');
      final firstName =
          nameParts.isNotEmpty ? nameParts[0].toUpperCase() : 'Demo';
      final lastName =
          nameParts.length > 1 ? nameParts[1].toUpperCase() : 'User';

      final user = User(
        id: 'demo_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: userRole,
      );

      return user;
    } catch (e) {
      return null;
    }
  }

  // Helper method to parse string role to UserRole enum
  UserRole _parseUserRole(String roleString) {
    switch (roleString.toUpperCase()) {
      case 'ADMIN':
      case 'SUPER_ADMIN':
        return UserRole.ADMIN;
      case 'DOCTOR':
        return UserRole.DOCTOR;
      case 'NURSE':
        return UserRole.NURSE;
      case 'RECEPTIONIST':
        return UserRole.RECEPTIONIST;
      case 'PHARMACIST':
        return UserRole.PHARMACIST;
      case 'LAB_TECHNICIAN':
      case 'LABORATORY':
        return UserRole.LABORATORY;
      case 'PATIENT':
        return UserRole.PATIENT;
      default:
        return UserRole.PATIENT; // Default fallback
    }
  }

  bool hasRole(List<String> allowedRoles) {
    if (state.user == null) return false;

    final userRoleName = state.user!.role.toString().split('.').last;
    return allowedRoles
        .any((role) => role.toLowerCase() == userRoleName.toLowerCase());
  }
}

// Providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final storageProvider = Provider<StorageUtils>((ref) => StorageUtils());

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(dioProvider));
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authServiceProvider),
    ref.read(storageProvider),
  );
});

// Set up auth interceptor after providers are defined
final authenticatedDioProvider = Provider<Dio>((ref) {
  final dio = ref.read(dioProvider);

  // Add auth interceptor
  dio.interceptors.clear(); // Clear any existing interceptors
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final authState = ref.read(authProvider);
        if (authState.token != null) {
          options.headers['Authorization'] = 'Bearer ${authState.token}';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Token expired, logout user
          ref.read(authProvider.notifier).logout();
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});

// Auth guards
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user != null && authState.token != null;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});

final userRoleProvider = Provider<UserRole?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.role;
});

// Role-based access providers
final canAccessPatientsProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return [
    UserRole.ADMIN,
    UserRole.DOCTOR,
    UserRole.NURSE,
    UserRole.RECEPTIONIST,
  ].contains(role);
});

final canAccessPharmacyProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return [
    UserRole.ADMIN,
    UserRole.PHARMACIST,
    UserRole.DOCTOR,
  ].contains(role);
});

final canAccessLabProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return [
    UserRole.ADMIN,
    UserRole.LABORATORY,
    UserRole.DOCTOR,
    UserRole.NURSE,
  ].contains(role);
});

final canAccessBillingProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return [
    UserRole.ADMIN,
    UserRole.RECEPTIONIST,
    UserRole.DOCTOR,
  ].contains(role);
});

final canAccessFacilityProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return [
    UserRole.ADMIN,
    UserRole.NURSE,
    UserRole.DOCTOR,
  ].contains(role);
});

final canManageUsersProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return role == UserRole.ADMIN;
});

final isDoctorProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return role == UserRole.DOCTOR;
});

final isNurseProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return role == UserRole.NURSE;
});

final isPharmacistProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return role == UserRole.PHARMACIST;
});

final isLaboratoryProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return role == UserRole.LABORATORY;
});
