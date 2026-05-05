import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../services/auth_storage.dart';
import '../services/zlibrary_api.dart';
import 'zlibrary_provider.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final ZLibraryApi _api;
  final AuthStorage _storage = AuthStorage();

  AuthNotifier(this._api) : super(AuthState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);

    try {
      final credentials = await _storage.getCredentials();
      final userId = credentials['userId'];
      final userKey = credentials['userKey'];

      if (userId != null && userKey != null) {
        try {
          final response = await _api.getProfile();
          if (response.success && response.data != null) {
            state = AuthState(user: response.data);
          } else {
            await _storage.clearCredentials();
            state = AuthState();
          }
        } catch (e) {
          final email = credentials['email'];
          final name = credentials['name'];
          final user = User(
            id: userId,
            email: email ?? '',
            name: name ?? 'User',
            remixUserkey: userKey,
          );
          state = AuthState(user: user);
          print('Profile verification failed, using cached credentials: $e');
        }
      } else {
        state = AuthState();
      }
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _api.login(email, password);

      if (response.success && response.data != null) {
        final user = response.data!;

        await _storage.saveCredentials(
          userId: user.id,
          userKey: user.remixUserkey,
          email: user.email,
          name: user.name,
          password: password,
        );

        state = AuthState(user: user);
        return true;
      } else {
        state = AuthState(error: response.error ?? 'Login failed');
        return false;
      }
    } catch (e) {
      state = AuthState(error: e.toString());
      return false;
    }
  }

  Future<bool> loginWithToken(String userId, String userKey) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _api.loginWithToken(userId, userKey);

      if (response.success && response.data != null) {
        state = AuthState(user: response.data);
        return true;
      } else {
        state = AuthState(error: response.error ?? 'Token login failed');
        return false;
      }
    } catch (e) {
      state = AuthState(error: e.toString());
      return false;
    }
  }

  Future<ApiResponse<void>> sendVerificationCode(
    String email,
    String password,
    String name,
  ) async {
    return await _api.sendCode(email, password, name);
  }

  Future<bool> register(
    String email,
    String password,
    String name,
    String code,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _api.verifyCode(email, password, name, code);

      if (response.success) {
        return await login(email, password);
      } else {
        state = AuthState(error: response.error ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      state = AuthState(error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.clearCredentials();
    state = AuthState();
  }

  Future<void> refreshProfile() async {
    if (!state.isAuthenticated) return;

    try {
      final response = await _api.getProfile();
      if (response.success && response.data != null) {
        state = AuthState(user: response.data);
      }
    } catch (e) {
      // Keep existing state on error
    }
  }

  Future<List<Map<dynamic, dynamic>>> getSavedAccounts() async {
    return await _storage.getStoredAccounts();
  }

  Future<bool> switchAccount(Map<String, dynamic> account) async {
    final userId = account['userId'];
    final userKey = account['userKey'];
    final email = account['email'];
    final password = account['password'];

    if (userId != null && userKey != null) {
      return await loginWithToken(userId, userKey);
    } else if (email != null && password != null) {
      return await login(email, password);
    }
    return false;
  }

  Future<void> removeAccount(String userId) async {
    await _storage.removeAccount(userId);
  }
}

/// Auth state provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final api = ref.watch(zlibraryApiProvider);
  return AuthNotifier(api);
});
