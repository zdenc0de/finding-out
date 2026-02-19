// lib/features/auth/presentation/providers/auth_provider.dart
// Provider de Riverpod para gestión de autenticación

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/config/supabase_config.dart';
import '../../../../core/errors/exceptions.dart';
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
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  pendingVerification,   // Registro exitoso, esperando verificación
  emailNotVerified,      // Intento de login con email no verificado
  passwordResetSent,     // Email de recuperación enviado
  passwordRecoveryMode,  // Usuario llegó desde el deep link de recovery
  passwordUpdated,       // Contraseña actualizada exitosamente
  profileUpdated,        // Perfil actualizado exitosamente
  error,
}

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  final String? errorMessage;
  final String? successMessage;
  final String? pendingEmail; // Email pendiente de verificación

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.successMessage,
    this.pendingEmail,
  });

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? errorMessage,
    String? successMessage,
    String? pendingEmail,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      successMessage: successMessage,
      pendingEmail: pendingEmail ?? this.pendingEmail,
    );
  }
}

// Notifier para acciones de auth
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  StreamSubscription<supabase.AuthState>? _authSubscription;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _init();
    _listenToAuthEvents();
  }

  void _init() {
    final user = _repository.getCurrentUser();
    if (user != null) {
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Escucha eventos de autenticación de Supabase (deep links, etc.)
  void _listenToAuthEvents() {
    _authSubscription = SupabaseConfig.client.auth.onAuthStateChange.listen(
      (data) {
        final event = data.event;
        final session = data.session;

        // Sincronizar estado basado en eventos globales de auth
        switch (event) {
          case supabase.AuthChangeEvent.signedIn:
            if (session != null) {
              final user = _repository.getCurrentUser();
              state = AuthState(status: AuthStatus.authenticated, user: user);
            }
            break;
          case supabase.AuthChangeEvent.signedOut:
            state = const AuthState(status: AuthStatus.unauthenticated);
            break;
          case supabase.AuthChangeEvent.userUpdated:
            final user = _repository.getCurrentUser();
            state = state.copyWith(user: user);
            break;
          case supabase.AuthChangeEvent.passwordRecovery:
            state = const AuthState(status: AuthStatus.passwordRecoveryMode);
            break;
          case supabase.AuthChangeEvent.tokenRefreshed:
            // Opcional: manejar si es necesario
            break;
          default:
            break;
        }
      },
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final user = await _repository.signIn(email: email, password: password);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } on EmailNotVerifiedException catch (e) {
      // Caso especial: email no verificado
      state = AuthState(
        status: AuthStatus.emailNotVerified,
        errorMessage: e.userMessage,
        pendingEmail: email,
      );
    } on AppException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.userMessage,
      );
    } catch (e) {
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: 'Ha ocurrido un error inesperado',
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      await _repository.signInWithGoogle();
      // No actualizamos el estado aquí, se actualizará solo en el listener
      // de auth state changes cuando se redirija de vuelta.
    } on AppException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.userMessage,
      );
    } catch (e) {
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: 'Ha ocurrido un error inesperado',
      );
    }
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      await _repository.signInWithApple();
      // No actualizamos el estado aquí, se actualizará solo en el listener
      // de auth state changes cuando se redirija de vuelta.
    } on AppException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.userMessage,
      );
    } catch (e) {
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: 'Ha ocurrido un error inesperado',
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
    } on EmailVerificationRequiredException {
      state = AuthState(
        status: AuthStatus.pendingVerification,
        pendingEmail: email,
      );
    } on AppException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.userMessage,
      );
    } catch (e) {
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: 'Ha ocurrido un error inesperado',
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      await _repository.signOut();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } on AppException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.userMessage,
      );
    } catch (e) {
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: 'Ha ocurrido un error inesperado',
      );
    }
  }

  void clearError() {
    if (state.user != null) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: state.user,
      );
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  void clearSuccess() {
    if (state.user != null) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: state.user,
      );
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Envía email de recuperación de contraseña
  Future<void> resetPassword(String email) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      await _repository.resetPassword(email);
      state = const AuthState(
        status: AuthStatus.passwordResetSent,
        successMessage: 'Te enviamos un email para restablecer tu contraseña',
      );
    } on AppException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.userMessage,
      );
    } catch (e) {
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: 'Ha ocurrido un error inesperado',
      );
    }
  }

  /// Reenvía email de verificación
  Future<void> resendVerificationEmail(String email) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      await _repository.resendVerificationEmail(email);
      state = AuthState(
        status: AuthStatus.pendingVerification,
        pendingEmail: email,
        successMessage: 'Email de verificación reenviado',
      );
    } on AppException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.userMessage,
        pendingEmail: email,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: 'Ha ocurrido un error inesperado',
        pendingEmail: email,
      );
    }
  }

  /// Actualiza la contraseña (después de reset password)
  Future<void> updatePassword(String newPassword) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      await _repository.updatePassword(newPassword);
      // Cerrar sesión después de actualizar la contraseña
      await _repository.signOut();
      state = const AuthState(
        status: AuthStatus.passwordUpdated,
        successMessage: 'Contraseña actualizada correctamente. Inicia sesión con tu nueva contraseña.',
      );
    } on AppException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.userMessage,
      );
    } catch (e) {
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: 'Ha ocurrido un error inesperado',
      );
    }
  }

  /// Actualiza el perfil del usuario
  Future<void> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final updatedUser = await _repository.updateProfile(
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
      state = AuthState(
        status: AuthStatus.profileUpdated,
        user: updatedUser,
        successMessage: 'Perfil actualizado correctamente',
      );
    } on AppException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        user: state.user,
        errorMessage: e.userMessage,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        user: state.user,
        errorMessage: 'Ha ocurrido un error inesperado',
      );
    }
  }
}

// Provider del notifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

/// Un [ChangeNotifier] que GoRouter puede usar para recargar la ruta
/// cuando cambia el estado de autenticación.
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    // Escuchamos el authNotifierProvider y notificamos a los listeners
    // de este ChangeNotifier cada vez que el estado cambie.
    _ref.listen<AuthState>(
      authNotifierProvider,
      (previous, next) {
        // Notificar al router solo si el status cambió (para evitar refrescos innecesarios)
        if (previous?.status != next.status) {
          notifyListeners();
        }
      },
    );
  }
}

/// Provider para el RouterNotifier
final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});
