// lib/features/social/domain/entities/follow_relation.dart
// Entidad que representa una relación de seguimiento entre usuarios

class FollowRelation {
  final String id;
  final String followerId;
  final String followingId;
  final DateTime createdAt;

  const FollowRelation({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FollowRelation &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
