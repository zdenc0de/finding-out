// lib/features/events/data/repositories/event_repository_impl.dart
// Implementación del repositorio de eventos

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../models/category_model.dart';
import '../models/event_model.dart';

/// Implementación del repositorio de eventos usando Supabase.
class EventRepositoryImpl implements EventRepository {
  final SupabaseClient _client;

  EventRepositoryImpl(this._client);

  @override
  Future<List<Category>> getCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .order('display_order', ascending: true);

      return (response as List<dynamic>)
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .map((model) => model.toEntity())
          .toList();
    } on PostgrestException catch (e) {
      throw CategoriesLoadException(e.message);
    } catch (e) {
      throw CategoriesLoadException(e.toString());
    }
  }

  @override
  Future<List<Event>> getEventsByCategory(String categoryId) async {
    try {
      final response = await _client
          .from('events')
          .select()
          .eq('category_id', categoryId)
          .order('start_date', ascending: true);

      return (response as List<dynamic>)
          .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
          .map((model) => model.toEntity())
          .toList();
    } on PostgrestException catch (e) {
      throw EventsLoadException(e.message);
    } catch (e) {
      throw EventsLoadException(e.toString());
    }
  }

  @override
  Future<Map<Category, List<Event>>> getEventsGroupedByCategory() async {
    try {
      // Obtener categorías ordenadas
      final categories = await getCategories();

      // Obtener todos los eventos
      final eventsResponse = await _client
          .from('events')
          .select()
          .order('start_date', ascending: true);

      final events = (eventsResponse as List<dynamic>)
          .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
          .map((model) => model.toEntity())
          .toList();

      // Agrupar eventos por categoría
      final Map<Category, List<Event>> result = {};

      for (final category in categories) {
        final categoryEvents = events
            .where((event) => event.categoryId == category.id)
            .toList();
        result[category] = categoryEvents;
      }

      return result;
    } on PostgrestException catch (e) {
      throw EventsLoadException(e.message);
    } on EventException {
      rethrow;
    } catch (e) {
      throw EventsLoadException(e.toString());
    }
  }

  @override
  Future<Event?> getEventById(String id) async {
    try {
      final response = await _client
          .from('events')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return EventModel.fromJson(response).toEntity();
    } on PostgrestException catch (e) {
      throw EventNotFoundException(e.message);
    } catch (e) {
      throw EventNotFoundException(e.toString());
    }
  }

  @override
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
  }) async {
    try {
      // Obtener el usuario actual para created_by
      final currentUser = _client.auth.currentUser;

      final eventModel = EventModel.forCreate(
        title: title,
        description: description,
        categoryId: categoryId,
        imageUrl: imageUrl,
        locationLat: locationLat,
        locationLng: locationLng,
        address: address,
        startDate: startDate,
        endDate: endDate,
        createdBy: currentUser?.id,
      );

      final response = await _client
          .from('events')
          .insert(eventModel.toJsonForCreate())
          .select()
          .single();

      return EventModel.fromJson(response).toEntity();
    } on PostgrestException catch (e) {
      throw EventCreateException(e.message);
    } catch (e) {
      throw EventCreateException(e.toString());
    }
  }
}
