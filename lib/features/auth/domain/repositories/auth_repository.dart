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

  AppUser? getCurrentUser();

  Stream<AppUser?> get authStateChanges;
}
