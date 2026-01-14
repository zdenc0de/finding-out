// lib/features/auth/domain/usecases/sign_out.dart
// Caso de uso para cerrar sesión

import '../repositories/auth_repository.dart';

class SignOut {
  final AuthRepository _repository;

  SignOut(this._repository);

  Future<void> call() {
    return _repository.signOut();
  }
}