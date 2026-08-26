import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/network/dio_client.dart';

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioClientProvider));
});

final authStateProvider = NotifierProvider<AuthNotifier, UserModel?>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<UserModel?> {
  late final AuthRepository _repository;

  @override
  UserModel? build() {
    _repository = ref.watch(authRepositoryProvider);
    _checkAuth();
    return null;
  }

  Future<void> _checkAuth() async {
    final isAuthenticated = await _repository.isAuthenticated();
    if (isAuthenticated) {
      try {
        state = await _repository.fetchUser();
      } catch (e) {
        state = null;
      }
    } else {
      state = null;
    }
  }

  Future<UserModel> login(String username, String password) async {
    final user = await _repository.login(username, password);
    state = user;
    return user;
  }

  Future<void> register(String name, String email, String mobile, String password) async {
    await _repository.register(name, email, password);
  }

  Future<void> updateProfile(String username, String? password) async {
    final updatedUser = await _repository.updateProfile(username, password);
    state = updatedUser;
  }

  Future<void> logout() async {
    await _repository.logout();
    state = null;
  }
}
