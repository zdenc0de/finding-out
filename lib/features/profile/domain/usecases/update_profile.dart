// lib/features/profile/domain/usecases/update_profile.dart
// Caso de uso para actualizar perfil

import '../entities/public_profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfile {
  final ProfileRepository _repository;

  UpdateProfile(this._repository);

  Future<PublicProfile> call({
    String? displayName,
    String? avatarUrl,
  }) {
    return _repository.updateProfile(
      displayName: displayName,
      avatarUrl: avatarUrl,
    );
  }
}
