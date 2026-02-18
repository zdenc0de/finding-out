// lib/features/events/presentation/providers/event_filters_provider.dart
// Providers para gestionar los filtros rápidos de eventos

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/event.dart';
import 'events_provider.dart';

/// Tipos de filtros rápidos disponibles.
enum EventFilter {
  all('Todos'),
  today('Hoy'),
  thisWeekend('Este fin'),
  free('Gratis'),
  nearMe('Cerca de mí'),
  friends('Amigos van'),
  music('Música'),
  food('Comida');

  final String label;
  const EventFilter(this.label);
}

/// Provider para el filtro seleccionado actualmente.
final selectedEventFilterProvider = StateProvider<EventFilter>((ref) => EventFilter.all);

/// Provider que retorna los eventos filtrados según el filtro seleccionado.
final filteredEventsByCategoryProvider = Provider<Map<Category, List<Event>>>((ref) {
  final eventsState = ref.watch(eventsNotifierProvider);
  final selectedFilter = ref.watch(selectedEventFilterProvider);
  
  if (eventsState.eventsByCategory.isEmpty) return {};
  if (selectedFilter == EventFilter.all) return eventsState.eventsByCategory;

  final Map<Category, List<Event>> filteredMap = {};
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  // Calcular el fin de semana (Viernes, Sábado, Domingo)
  final friday = today.add(Duration(days: (5 - today.weekday + 7) % 7));
  final sunday = friday.add(const Duration(days: 2, hours: 23, minutes: 59));

  for (final entry in eventsState.eventsByCategory.entries) {
    final category = entry.key;
    final events = entry.value;

    final filteredEvents = events.where((event) {
      final titleLower = event.title.toLowerCase();
      final descLower = (event.description ?? '').toLowerCase();
      final categoryNameLower = category.name.toLowerCase();

      switch (selectedFilter) {
        case EventFilter.today:
          return event.startDate.year == today.year &&
                 event.startDate.month == today.month &&
                 event.startDate.day == today.day;
                 
        case EventFilter.thisWeekend:
          return event.startDate.isAfter(friday.subtract(const Duration(seconds: 1))) &&
                 event.startDate.isBefore(sunday.add(const Duration(seconds: 1)));
                 
        case EventFilter.free:
          // Buscamos 'gratis', 'free', '0' o similar en descripción
          return descLower.contains('gratis') || 
                 descLower.contains('entrada libre') || 
                 descLower.contains('sin costo') ||
                 titleLower.contains('gratis');
          
        case EventFilter.nearMe:
          // TODO: Implementar filtrado por distancia real
          return true; 
          
        case EventFilter.friends:
          // TODO: Implementar lógica de amigos
          return true;
          
        case EventFilter.music:
          return categoryNameLower.contains('música') || 
                 categoryNameLower.contains('concierto') ||
                 category.icon.contains('music');
                 
        case EventFilter.food:
          return categoryNameLower.contains('comida') || 
                 categoryNameLower.contains('restaurante') ||
                 categoryNameLower.contains('gastronomía') ||
                 category.icon.contains('restaurant') ||
                 category.icon.contains('fork');
                 
        case EventFilter.all:
          return true;
      }
    }).toList();

    if (filteredEvents.isNotEmpty) {
      filteredMap[category] = filteredEvents;
    }
  }

  return filteredMap;
});
