// lib/features/events/domain/entities/event_attendance.dart
// Entidad que representa la asistencia de un usuario a un evento

/// Estado de asistencia a un evento.
enum AttendanceStatus {
  going,
  interested,
}

/// Representa la asistencia de un usuario a un evento.
class EventAttendance {
  final String id;
  final String eventId;
  final String userId;
  final AttendanceStatus status;
  final DateTime createdAt;

  const EventAttendance({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.status,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventAttendance &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
