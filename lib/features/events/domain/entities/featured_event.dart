// lib/features/events/domain/entities/featured_event.dart
// Entidad para eventos destacados con score calculado

import 'category.dart';
import 'event.dart';

/// Representa un evento destacado con información adicional para ranking.
///
/// El score se calcula como: 0.6 * (proximidad de fecha) + 0.4 * (asistentes)
/// donde proximidad de fecha es mayor para eventos más cercanos en el tiempo.
class FeaturedEvent {
  /// Evento base
  final Event event;

  /// Categoría del evento
  final Category category;

  /// Cantidad de asistentes confirmados (status = 'going')
  final int attendeeCount;

  /// Distancia desde la ubicación del usuario en kilómetros
  final double distanceKm;

  /// Score calculado para ordenamiento (mayor = más relevante)
  final double score;

  const FeaturedEvent({
    required this.event,
    required this.category,
    required this.attendeeCount,
    required this.distanceKm,
    required this.score,
  });

  /// Calcula el score combinado para un evento.
  ///
  /// Fórmula: score = 0.6 * fechaScore + 0.4 * asistentesScore
  /// - fechaScore: Inversamente proporcional a los días hasta el evento (0-1)
  /// - asistentesScore: Proporción respecto al máximo de asistentes (0-1)
  static double calculateScore({
    required DateTime eventDate,
    required int attendeeCount,
    required int maxAttendees,
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();

    // Score de fecha: eventos más cercanos tienen mayor score
    // Usamos 1/(días+1) para evitar división por cero y dar mayor peso a eventos próximos
    final daysUntilEvent = eventDate.difference(currentTime).inDays;
    if (daysUntilEvent < 0) return 0; // Eventos pasados no son relevantes

    // Normalizar: eventos hoy = 1.0, eventos en 30+ días = ~0.03
    final dateScore = 1.0 / (daysUntilEvent + 1);

    // Score de asistentes: proporción respecto al máximo
    final attendeeScore = maxAttendees > 0 ? attendeeCount / maxAttendees : 0.0;

    // Score combinado: 60% fecha, 40% asistentes
    return (0.6 * dateScore) + (0.4 * attendeeScore);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeaturedEvent && other.event.id == event.id;
  }

  @override
  int get hashCode => event.id.hashCode;
}
