// lib/features/auth/domain/usecases/sign_in.dart
// Caso de uso para iniciar sesión

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignIn {
  final AuthRepository _repository;

  SignIn(this._repository);

  Future<AppUser> call({
    required String email,
    required String password,
  }) {
    return _repository.signIn(email: email, password: password);
  }
}