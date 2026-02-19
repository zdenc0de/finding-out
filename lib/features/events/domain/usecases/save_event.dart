// lib/features/events/domain/usecases/save_event.dart
// Caso de uso para crear (guardar) un evento

import '../entities/event.dart';
import '../repositories/event_repository.dart';

class SaveEvent {
  final EventRepository _repository;

  SaveEvent(this._repository);

  Future<Event> call({
    required String title,
    String? description,
    required String categoryId,
    String? imageUrl,
    double? locationLat,
    double? locationLng,
    String? address,
    required DateTime startDate,
    DateTime? endDate,
  }) {
    return _repository.createEvent(
      title: title,
      description: description,
      categoryId: categoryId,
      imageUrl: imageUrl,
      locationLat: locationLat,
      locationLng: locationLng,
      address: address,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
