// lib/features/auth/domain/usecases/sign_up.dart
// Caso de uso para registro de usuario

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUp {
  final AuthRepository _repository;

  SignUp(this._repository);

  Future<AppUser> call({
    required String email,
    required String password,
    String? displayName,
  }) {
    return _repository.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}