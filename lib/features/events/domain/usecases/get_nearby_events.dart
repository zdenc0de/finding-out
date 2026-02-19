// lib/features/events/domain/usecases/get_nearby_events.dart
// Caso de uso para obtener eventos cercanos (placeholder usando búsqueda)

import '../entities/event.dart';
import '../repositories/event_repository.dart';

class GetNearbyEvents {
  final EventRepository _repository;

  GetNearbyEvents(this._repository);

  /// Por ahora delega a búsqueda hasta tener geofencing real en el repo
  Future<List<Event>> call(String query) {
    return _repository.searchEvents(query);
  }
}
