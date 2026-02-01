// lib/features/social/data/models/follow_relation_model.dart
// Modelo para serialización de relaciones de seguimiento con Supabase

import '../../domain/entities/follow_relation.dart';

class FollowRelationModel {
  final String id;
  final String followerId;
  final String followingId;
  final DateTime createdAt;

  const FollowRelationModel({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.createdAt,
  });

  factory FollowRelationModel.fromJson(Map<String, dynamic> json) {
    return FollowRelationModel(
      id: json['id'] as String,
      followerId: json['follower_id'] as String,
      followingId: json['following_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'follower_id': followerId,
      'following_id': followingId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Para crear un nuevo follow (sin id ni created_at)
  static Map<String, dynamic> toJsonForCreate({
    required String followerId,
    required String followingId,
  }) {
    return {
      'follower_id': followerId,
      'following_id': followingId,
    };
  }

  FollowRelation toEntity() {
    return FollowRelation(
      id: id,
      followerId: followerId,
      followingId: followingId,
      createdAt: createdAt,
    );
  }
}
