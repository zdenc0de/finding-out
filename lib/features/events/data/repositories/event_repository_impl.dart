// lib/features/events/data/repositories/event_repository_impl.dart
// Implementación del repositorio de eventos

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../profile/data/models/public_profile_model.dart';
import '../../../profile/domain/entities/public_profile.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/event_attendance.dart';
import '../../domain/repositories/event_repository.dart';
import '../models/category_model.dart';
import '../models/event_attendance_model.dart';
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
        final categoryEvents =
            events.where((event) => event.categoryId == category.id).toList();
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
      final response =
          await _client.from('events').select().eq('id', id).maybeSingle();

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

  @override
  Future<int> getUserEventsCount(String userId) async {
    try {
      final response =
          await _client.from('events').select().eq('created_by', userId);

      return (response as List<dynamic>).length;
    } on PostgrestException {
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ASISTENCIA A EVENTOS
  // ─────────────────────────────────────────────────────────────────────────

  String? get _currentUserId => _client.auth.currentUser?.id;

  @override
  Future<void> markAttendance(String eventId, AttendanceStatus status) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }

    try {
      await _client.from('event_attendees').upsert(
            EventAttendanceModel.toJsonForUpsert(
              eventId: eventId,
              userId: currentUserId,
              status: status,
            ),
            onConflict: 'event_id,user_id',
          );
    } on PostgrestException catch (e) {
      throw EventException(e.message);
    }
  }

  @override
  Future<void> cancelAttendance(String eventId) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }

    try {
      await _client
          .from('event_attendees')
          .delete()
          .eq('event_id', eventId)
          .eq('user_id', currentUserId);
    } on PostgrestException catch (e) {
      throw EventException(e.message);
    }
  }

  @override
  Future<AttendanceStatus?> getMyAttendance(String eventId) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return null;

    try {
      final response = await _client
          .from('event_attendees')
          .select('status')
          .eq('event_id', eventId)
          .eq('user_id', currentUserId)
          .maybeSingle();

      if (response == null) return null;

      final status = response['status'] as String;
      return status == 'going'
          ? AttendanceStatus.going
          : AttendanceStatus.interested;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<PublicProfile>> getFriendsAttending(String eventId) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return [];

    try {
      // Obtener IDs de usuarios que sigo
      final followingResponse = await _client
          .from('followers')
          .select('following_id')
          .eq('follower_id', currentUserId);

      final followingIds = (followingResponse as List<dynamic>)
          .map((item) => item['following_id'] as String)
          .toList();

      if (followingIds.isEmpty) return [];

      // Obtener los que van al evento de entre mis seguidos
      final attendeesResponse = await _client
          .from('event_attendees')
          .select('user_id')
          .eq('event_id', eventId)
          .eq('status', 'going')
          .inFilter('user_id', followingIds);

      final attendeeIds = (attendeesResponse as List<dynamic>)
          .map((item) => item['user_id'] as String)
          .toList();

      if (attendeeIds.isEmpty) return [];

      // Obtener perfiles de los amigos que van
      final profilesResponse = await _client
          .from('profiles')
          .select('id, display_name, avatar_url, created_at')
          .inFilter('id', attendeeIds);

      return (profilesResponse as List<dynamic>)
          .map((json) =>
              PublicProfileModel.fromJson(json as Map<String, dynamic>))
          .map((model) => model.toEntity())
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<int> getAttendeeCount(String eventId) async {
    try {
      final response = await _client
          .from('event_attendees')
          .select()
          .eq('event_id', eventId)
          .eq('status', 'going');

      return (response as List<dynamic>).length;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<({int going, int interested})> getAttendeeStats(String eventId) async {
    try {
      final response = await _client
          .from('event_attendees')
          .select('status')
          .eq('event_id', eventId);

      final attendees = response as List<dynamic>;
      int going = 0;
      int interested = 0;

      for (final attendee in attendees) {
        final status = attendee['status'] as String;
        if (status == 'going') {
          going++;
        } else if (status == 'interested') {
          interested++;
        }
      }

      return (going: going, interested: interested);
    } catch (e) {
      return (going: 0, interested: 0);
    }
  }

  @override
  Future<Category?> getCategoryById(String categoryId) async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .eq('id', categoryId)
          .maybeSingle();

      if (response == null) return null;

      return CategoryModel.fromJson(response).toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> getUserAttendedEventsCount(String userId) async {
    try {
      final response =
          await _client.from('event_attendees').select().eq('user_id', userId);

      return (response as List<dynamic>).length;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<List<Event>> getMyUpcomingEvents() async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return [];

    try {
      // Obtener IDs de eventos a los que voy
      final attendanceResponse = await _client
          .from('event_attendees')
          .select('event_id')
          .eq('user_id', currentUserId)
          .eq('status', 'going');

      final eventIds = (attendanceResponse as List<dynamic>)
          .map((item) => item['event_id'] as String)
          .toList();

      if (eventIds.isEmpty) return [];

      // Obtener eventos futuros
      final now = DateTime.now().toUtc().toIso8601String();

      final eventsResponse = await _client
          .from('events')
          .select()
          .inFilter('id', eventIds)
          .gte('start_date', now)
          .order('start_date', ascending: true)
          .limit(5);

      return (eventsResponse as List<dynamic>)
          .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
          .map((model) => model.toEntity())
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Event>> getEventsByCreator(String userId) async {
    try {
      final response = await _client
          .from('events')
          .select()
          .eq('created_by', userId)
          .order('start_date', ascending: false)
          .limit(10);

      return (response as List<dynamic>)
          .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
          .map((model) => model.toEntity())
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Event>> searchEvents(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final sanitized = query.trim();
      final response = await _client
          .from('events')
          .select()
          .or('title.ilike.%$sanitized%,description.ilike.%$sanitized%,address.ilike.%$sanitized%')
          .order('start_date', ascending: true)
          .limit(20);

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
}
