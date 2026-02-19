// lib/features/events/domain/usecases/get_events_by_category.dart
// Caso de uso para obtener eventos por categoría

import '../entities/event.dart';
import '../repositories/event_repository.dart';

class GetEventsByCategory {
  final EventRepository _repository;

  GetEventsByCategory(this._repository);

  Future<List<Event>> call(String categoryId) {
    return _repository.getEventsByCategory(categoryId);
  }
}
