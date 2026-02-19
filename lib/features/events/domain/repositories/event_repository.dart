// lib/features/events/domain/repositories/event_repository.dart
// Contrato/interfaz del repositorio de eventos

import '../../../profile/domain/entities/public_profile.dart';
import '../entities/category.dart';
import '../entities/event.dart';
import '../entities/event_attendance.dart';
import '../entities/friend_event_activity.dart';

/// Contrato del repositorio de eventos.
///
/// Define las operaciones disponibles para obtener categorías y eventos.
/// La implementación concreta se encuentra en la capa de datos.
abstract class EventRepository {
  /// Obtiene todas las categorías ordenadas por displayOrder.
  Future<List<Category>> getCategories();

  /// Obtiene los eventos de una categoría específica.
  Future<List<Event>> getEventsByCategory(String categoryId);

  /// Obtiene todos los eventos agrupados por categoría.
  ///
  /// Retorna un mapa donde la clave es la categoría y el valor
  /// es la lista de eventos de esa categoría.
  Future<Map<Category, List<Event>>> getEventsGroupedByCategory();

  /// Obtiene un evento específico por su ID.
  Future<Event?> getEventById(String id);

  /// Crea un nuevo evento.
  ///
  /// Retorna el evento creado con su ID generado por el servidor.
  Future<Event> createEvent({
    required String title,
    String? description,
    required String categoryId,
    String? imageUrl,
    double? locationLat,
    double? locationLng,
    String? address,
    required DateTime startDate,
    DateTime? endDate,
  });

  /// Obtiene el conteo de eventos creados por un usuario.
  Future<int> getUserEventsCount(String userId);

  // ─────────────────────────────────────────────────────────────────────────
  // ASISTENCIA A EVENTOS
  // ─────────────────────────────────────────────────────────────────────────

  /// Marca asistencia a un evento.
  Future<void> markAttendance(String eventId, AttendanceStatus status);

  /// Cancela asistencia a un evento.
  Future<void> cancelAttendance(String eventId);

  /// Obtiene el estado de asistencia del usuario actual para un evento.
  Future<AttendanceStatus?> getMyAttendance(String eventId);

  /// Obtiene los amigos (usuarios seguidos) que van a un evento.
  Future<List<PublicProfile>> getFriendsAttending(String eventId);

  /// Obtiene la actividad de los amigos (usuarios seguidos) en eventos próximos.
  Future<List<FriendEventActivity>> getFriendsActivity();

  /// Obtiene el conteo total de asistentes a un evento.
  Future<int> getAttendeeCount(String eventId);

  /// Obtiene estadísticas de asistentes (going e interested).
  Future<({int going, int interested})> getAttendeeStats(String eventId);

  /// Obtiene una categoría por su ID.
  Future<Category?> getCategoryById(String categoryId);

  /// Obtiene el conteo de eventos a los que ha asistido un usuario.
  Future<int> getUserAttendedEventsCount(String userId);

  /// Obtiene los próximos eventos a los que el usuario actual va.
  Future<List<Event>> getMyUpcomingEvents();

  /// Obtiene los eventos creados por un usuario.
  Future<List<Event>> getEventsByCreator(String userId);

  /// Busca eventos por texto en título, descripción o dirección.
  Future<List<Event>> searchEvents(String query);
}
