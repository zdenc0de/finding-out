// lib/features/auth/data/repositories/auth_repository_impl.dart
// Implementación del repositorio de autenticación

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/config/supabase_config.dart';
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
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: SupabaseConfig.redirectUrl,
      );
    } on supabase.AuthException catch (e) {
      throw _mapSupabaseAuthError(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> resendVerificationEmail(String email) async {
    try {
      await _client.auth.resend(
        type: supabase.OtpType.signup,
        email: email,
      );
    } on supabase.AuthException catch (e) {
      throw _mapSupabaseAuthError(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(
        supabase.UserAttributes(password: newPassword),
      );
    } on supabase.AuthException catch (e) {
      throw _mapSupabaseAuthError(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<AppUser> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        throw const ProfileUpdateException('No hay usuario autenticado');
      }

      // Construir el mapa de datos a actualizar
      final Map<String, dynamic> data = {
        ...?currentUser.userMetadata,
      };

      if (displayName != null) {
        data['display_name'] = displayName;
      }
      if (avatarUrl != null) {
        data['avatar_url'] = avatarUrl;
      }

      final response = await _client.auth.updateUser(
        supabase.UserAttributes(data: data),
      );

      if (response.user == null) {
        throw const UnknownException('updateProfile: response.user is null');
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
    final lowerMessage = message.toLowerCase();

    // Credenciales inválidas (email o contraseña incorrectos)
    if (lowerMessage.contains('invalid login credentials') ||
        lowerMessage.contains('invalid credentials')) {
      return InvalidCredentialsException(message);
    }

    // Email no confirmado/verificado
    if (lowerMessage.contains('email not confirmed') ||
        lowerMessage.contains('email not verified')) {
      return EmailNotVerifiedException(message);
    }

    // Usuario ya registrado
    if (lowerMessage.contains('user already registered') ||
        lowerMessage.contains('already been registered')) {
      return EmailAlreadyInUseException(message);
    }

    // Contraseña débil
    if (lowerMessage.contains('password should be at least') ||
        lowerMessage.contains('password is too weak') ||
        lowerMessage.contains('weak password')) {
      return WeakPasswordException(message);
    }

    // Email inválido
    if (lowerMessage.contains('unable to validate email') ||
        lowerMessage.contains('invalid email')) {
      return InvalidEmailException(message);
    }

    // Límite de intentos excedido
    if (lowerMessage.contains('rate limit') ||
        lowerMessage.contains('too many requests') ||
        lowerMessage.contains('email rate limit exceeded')) {
      return RateLimitException(message);
    }

    // Error de red/conexión
    if (lowerMessage.contains('network') ||
        lowerMessage.contains('connection') ||
        lowerMessage.contains('socket') ||
        lowerMessage.contains('timeout')) {
      return NetworkException(message);
    }

    // Sesión expirada
    if (lowerMessage.contains('session expired') ||
        lowerMessage.contains('refresh token') ||
        lowerMessage.contains('jwt expired')) {
      return const AuthException(
          'Tu sesión ha expirado. Inicia sesión nuevamente');
    }

    // Error genérico de autenticación
    return AuthException('Error de autenticación: $message', message);
  }
}
