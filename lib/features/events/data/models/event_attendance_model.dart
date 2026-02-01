// lib/features/events/data/models/event_attendance_model.dart
// Modelo para serialización de asistencia a eventos con Supabase

import '../../domain/entities/event_attendance.dart';

class EventAttendanceModel {
  final String id;
  final String eventId;
  final String userId;
  final AttendanceStatus status;
  final DateTime createdAt;

  const EventAttendanceModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.status,
    required this.createdAt,
  });

  factory EventAttendanceModel.fromJson(Map<String, dynamic> json) {
    return EventAttendanceModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      userId: json['user_id'] as String,
      status: _parseStatus(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static AttendanceStatus _parseStatus(String status) {
    switch (status) {
      case 'going':
        return AttendanceStatus.going;
      case 'interested':
        return AttendanceStatus.interested;
      default:
        return AttendanceStatus.interested;
    }
  }

  static String _statusToString(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.going:
        return 'going';
      case AttendanceStatus.interested:
        return 'interested';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'user_id': userId,
      'status': _statusToString(status),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Para crear/actualizar asistencia (sin id ni created_at)
  static Map<String, dynamic> toJsonForUpsert({
    required String eventId,
    required String userId,
    required AttendanceStatus status,
  }) {
    return {
      'event_id': eventId,
      'user_id': userId,
      'status': _statusToString(status),
    };
  }

  EventAttendance toEntity() {
    return EventAttendance(
      id: id,
      eventId: eventId,
      userId: userId,
      status: status,
      createdAt: createdAt,
    );
  }
}
