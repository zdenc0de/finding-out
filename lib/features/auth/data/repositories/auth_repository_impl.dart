// lib/features/auth/data/repositories/auth_repository_impl.dart
// Implementación del repositorio de autenticación

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;

  AuthRepositoryImpl(this._client);

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Error al iniciar sesión');
      }

      return _mapUser(response.user!);
    } on AuthException catch (e) {
      throw Exception(_mapAuthError(e.message));
    }
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: displayName != null ? {'display_name': displayName} : null,
      );

      if (response.user == null) {
        throw Exception('Error al registrar usuario');
      }

      // Si no hay sesión, significa que requiere verificación de email
      if (response.session == null) {
        throw Exception('EMAIL_VERIFICATION_REQUIRED');
      }

      return _mapUser(response.user!);
    } on AuthException catch (e) {
      throw Exception(_mapAuthError(e.message));
    }
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  AppUser? getCurrentUser() {
    final user = _client.auth.currentUser;
    return user != null ? _mapUser(user) : null;
  }

  @override
  Stream<AppUser?> get authStateChanges {
    return _client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      return user != null ? _mapUser(user) : null;
    });
  }

  AppUser _mapUser(User user) {
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['display_name'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
      createdAt: DateTime.parse(user.createdAt),
    );
  }

  String _mapAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Email o contraseña incorrectos';
    }
    if (message.contains('Email not confirmed')) {
      return 'Debes confirmar tu email antes de iniciar sesión';
    }
    if (message.contains('User already registered')) {
      return 'Este email ya está registrado';
    }
    if (message.contains('Password should be at least')) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    if (message.contains('Unable to validate email')) {
      return 'El formato del email no es válido';
    }
    if (message.contains('Email rate limit exceeded')) {
      return 'Demasiados intentos. Intenta más tarde';
    }
    return message;
  }
}