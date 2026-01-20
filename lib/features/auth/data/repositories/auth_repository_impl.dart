// lib/features/auth/data/repositories/auth_repository_impl.dart
// Implementación del repositorio de autenticación

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final supabase.SupabaseClient _client;

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
        throw const UnknownException('signIn: response.user is null');
      }

      return _mapUser(response.user!);
    } on AppException {
      rethrow;
    } on supabase.AuthException catch (e) {
      throw _mapSupabaseAuthError(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
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
        throw const UnknownException('signUp: response.user is null');
      }

      // Si no hay sesión, significa que requiere verificación de email
      if (response.session == null) {
        throw const EmailVerificationRequiredException();
      }

      return _mapUser(response.user!);
    } on AppException {
      rethrow;
    } on supabase.AuthException catch (e) {
      throw _mapSupabaseAuthError(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw UnknownException(e.toString());
    }
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

  AppUser _mapUser(supabase.User user) {
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['display_name'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
      createdAt: DateTime.parse(user.createdAt),
    );
  }

  /// Mapea errores de Supabase a excepciones tipadas
  AuthException _mapSupabaseAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return InvalidCredentialsException(message);
    }
    if (message.contains('Email not confirmed')) {
      return EmailNotVerifiedException(message);
    }
    if (message.contains('User already registered')) {
      return EmailAlreadyInUseException(message);
    }
    if (message.contains('Password should be at least')) {
      return WeakPasswordException(message);
    }
    if (message.contains('Unable to validate email')) {
      return InvalidEmailException(message);
    }
    if (message.contains('Email rate limit exceeded')) {
      return RateLimitException(message);
    }
    // Error genérico de autenticación
    return AuthException('Error de autenticación', message);
  }
}
