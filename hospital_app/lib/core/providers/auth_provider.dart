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

  AuthState copyWith({
    User? user,
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
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
        final user = await _authService.getCurrentUser();
        state = state.copyWith(
          user: user,
          token: token,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.login(email, password);
      await _storage.saveToken(result.token);
      await _storage.saveUser(result.user);

      state = state.copyWith(
        user: result.user,
        token: result.token,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
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
    UserRole.SUPER_ADMIN,
    UserRole.DOCTOR,
    UserRole.NURSE,
    UserRole.RECEPTIONIST,
  ].contains(role);
});

final canAccessPharmacyProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return [
    UserRole.SUPER_ADMIN,
    UserRole.PHARMACIST,
    UserRole.DOCTOR,
  ].contains(role);
});

final canAccessLabProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return [
    UserRole.SUPER_ADMIN,
    UserRole.LAB_TECHNICIAN,
    UserRole.DOCTOR,
    UserRole.NURSE,
  ].contains(role);
});

final canAccessBillingProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return [
    UserRole.SUPER_ADMIN,
    UserRole.BILLING_MANAGER,
    UserRole.ACCOUNTANT,
    UserRole.DOCTOR,
  ].contains(role);
});

final canAccessFacilityProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return [
    UserRole.SUPER_ADMIN,
    UserRole.FACILITY_MANAGER,
    UserRole.NURSE,
    UserRole.DOCTOR,
  ].contains(role);
});

final canManageUsersProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return role == UserRole.SUPER_ADMIN;
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

final isLabTechnicianProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return role == UserRole.LAB_TECHNICIAN;
});
