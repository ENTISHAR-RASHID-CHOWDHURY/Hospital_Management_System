import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/service_providers.dart';
import '../../data/auth_repository.dart';
import '../../data/auth_user.dart';
import '../controllers/auth_controller.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return RemoteAuthRepository(dio, LocalStorageService.instance);
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});

final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authControllerProvider);
});

final userRoleListProvider = Provider<List<UserRole>>((ref) {
  return UserRole.values;
});
