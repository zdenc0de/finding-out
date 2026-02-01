// lib/features/social/domain/entities/follow_stats.dart
// Estadísticas de seguidores y seguidos de un usuario

class FollowStats {
  final int followersCount;
  final int followingCount;

  const FollowStats({
    this.followersCount = 0,
    this.followingCount = 0,
  });

  FollowStats copyWith({
    int? followersCount,
    int? followingCount,
  }) {
    return FollowStats(
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FollowStats &&
          runtimeType == other.runtimeType &&
          followersCount == other.followersCount &&
          followingCount == other.followingCount;

  @override
  int get hashCode => followersCount.hashCode ^ followingCount.hashCode;
}
