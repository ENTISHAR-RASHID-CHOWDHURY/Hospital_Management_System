import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/auth_models.dart';
import '../../data/auth_repository.dart';
import '../../data/auth_user.dart';

class AuthState {
  const AuthState({
    this.user,
    this.token,
    this.status = AuthStatus.idle,
    this.error,
  });

  final AuthUser? user;
  final String? token;
  final AuthStatus status;
  final String? error;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null && token != null;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthUser? user,
    String? token,
    AuthStatus? status,
    String? error,
    bool clearError = false,
    bool removeUser = false,
    bool removeToken = false,
  }) {
    return AuthState(
      user: removeUser ? null : (user ?? this.user),
      token: removeToken ? null : (token ?? this.token),
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

enum AuthStatus { idle, loading, authenticated, error }

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository) : super(const AuthState()) {
    _restoreSession();
  }

  final AuthRepository _repository;

  Future<void> _restoreSession() async {
    final session = _repository.restoreSession();
    if (session != null) {
      state = state.copyWith(
        user: session.user,
        token: session.accessToken,
        status: AuthStatus.authenticated,
      );
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final session = await _repository.login(email: email, password: password);
      state = state.copyWith(
        user: session.user,
        token: session.accessToken,
        status: AuthStatus.authenticated,
      );
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.message);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final session = await _repository.register(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
      );
      state = state.copyWith(
        user: session.user,
        token: session.accessToken,
        status: AuthStatus.authenticated,
      );
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.message);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = state.copyWith(
      removeUser: true,
      removeToken: true,
      status: AuthStatus.idle,
      clearError: true,
    );
  }
}
