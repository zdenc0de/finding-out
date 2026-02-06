// lib/features/events/presentation/widgets/attendee_stats_section.dart
// Sección que muestra estadísticas de asistentes al evento

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/events_provider.dart';

/// Widget que muestra las estadísticas de asistencia a un evento.
///
/// Muestra el número de personas que van (going) y las interesadas (interested).
class AttendeeStatsSection extends ConsumerWidget {
  final String eventId;

  const AttendeeStatsSection({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(attendeeStatsProvider(eventId));

    return statsAsync.when(
      loading: () => Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withAlpha(100),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (stats) {
        // No mostrar si no hay asistentes
        if (stats.going == 0 && stats.interested == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withAlpha(15),
                AppColors.secondary.withAlpha(15),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withAlpha(40),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Going count
                Expanded(
                  child: _StatItem(
                    icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                    iconColor: AppColors.success,
                    count: stats.going,
                    label: stats.going == 1 ? 'va' : 'van',
                  ),
                ),
                // Divider
                Container(
                  height: 40,
                  width: 1,
                  color: AppColors.outline.withAlpha(60),
                ),
                // Interested count
                Expanded(
                  child: _StatItem(
                    icon: PhosphorIcons.star(PhosphorIconsStyle.fill),
                    iconColor: AppColors.warning,
                    count: stats.interested,
                    label: stats.interested == 1 ? 'interesado' : 'interesados',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final PhosphorIconData icon;
  final Color iconColor;
  final int count;
  final String label;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 24, color: iconColor),
        const SizedBox(width: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
