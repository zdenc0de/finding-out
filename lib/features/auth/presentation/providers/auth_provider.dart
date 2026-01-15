// lib/features/auth/presentation/providers/auth_provider.dart
// Provider de Riverpod para gestión de autenticación

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/supabase_config.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

// Provider del repositorio
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(SupabaseConfig.client);
});

// Provider del usuario actual (stream)
final authStateProvider = StreamProvider<AppUser?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

// Provider del usuario actual (síncrono)
final currentUserProvider = Provider<AppUser?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull;
});

// Provider para saber si está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

// Estado para el notifier
enum AuthStatus { initial, loading, authenticated, unauthenticated, pendingVerification, error }

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

// Notifier para acciones de auth
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _init();
  }

  void _init() {
    final user = _repository.getCurrentUser();
    if (user != null) {
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final user = await _repository.signIn(email: email, password: password);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final user = await _repository.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      // Verificación de email requerida (registro exitoso)
      if (e.toString().contains('EMAIL_VERIFICATION_REQUIRED')) {
        state = const AuthState(status: AuthStatus.pendingVerification);
        return;
      }
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      await _repository.signOut();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      errorMessage: null,
    );
  }
}

// Provider del notifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});