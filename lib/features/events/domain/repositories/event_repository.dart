// lib/features/events/domain/repositories/event_repository.dart
// Contrato/interfaz del repositorio de eventos

import '../entities/category.dart';
import '../entities/event.dart';

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
}
