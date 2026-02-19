// lib/features/auth/domain/repositories/auth_repository.dart
// Contrato/interfaz del repositorio de autenticación

import '../entities/user.dart';

abstract class AuthRepository {
  Future<AppUser> signIn({
    required String email,
    required String password,
  });

  Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  Future<void> signOut();

  /// Envía un email para restablecer la contraseña
  Future<void> resetPassword(String email);

  /// Reenvía el email de verificación
  Future<void> resendVerificationEmail(String email);

  /// Actualiza la contraseña del usuario (después de reset)
  Future<void> updatePassword(String newPassword);

  /// Actualiza el perfil del usuario (nombre, avatar)
  Future<AppUser> updateProfile({
    String? displayName,
    String? avatarUrl,
  });

  /// Inicia sesión con Google
  Future<void> signInWithGoogle();

  /// Inicia sesión con Apple
  Future<void> signInWithApple();

  AppUser? getCurrentUser();

  Stream<AppUser?> get authStateChanges;
}
