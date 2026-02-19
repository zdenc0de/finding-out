// lib/features/profile/domain/usecases/get_user_profile.dart
// Caso de uso para obtener perfil de usuario

import '../entities/public_profile.dart';
import '../repositories/profile_repository.dart';

class GetUserProfile {
  final ProfileRepository _repository;

  GetUserProfile(this._repository);

  Future<PublicProfile?> call(String userId) {
    return _repository.getProfileById(userId);
  }
}
