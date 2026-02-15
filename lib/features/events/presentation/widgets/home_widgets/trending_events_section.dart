// lib/features/events/presentation/widgets/home_widgets/trending_events_section.dart
// Sección de eventos trending / populares cerca del usuario.

import 'package:flutter/material.dart';
import '../../../domain/entities/event.dart';
import '../shared/event_card.dart';

/// Sección horizontal de eventos tendencia.
///
/// Muestra un encabezado "Trending cerca de ti" y una lista
/// horizontal de [EventCard] con los eventos más populares.
class TrendingEventsSection extends StatelessWidget {
  /// Lista de eventos trending a mostrar.
  final List<Event> events;

  /// Callback cuando el usuario toca un evento.
  final Function(Event)? onEventTap;

  const TrendingEventsSection({
    super.key,
    required this.events,
    this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado de sección
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Trending cerca de ti',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              const Icon(Icons.more_horiz),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Lista horizontal de tarjetas de eventos
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: EventCard(
                  event: events[index],
                  onTap: () => onEventTap?.call(events[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
