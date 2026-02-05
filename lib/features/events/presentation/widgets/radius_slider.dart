// lib/features/events/presentation/widgets/radius_slider.dart
// Slider para configurar el radio de búsqueda de eventos destacados

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/featured_events_provider.dart';

/// Bottom sheet con slider para configurar el radio de búsqueda.
///
/// Permite seleccionar entre 5 y 15 km.
class RadiusSliderSheet extends ConsumerWidget {
  const RadiusSliderSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRadius = ref.watch(searchRadiusProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Título
          Row(
            children: [
              Icon(
                PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Radio de búsqueda',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ajusta el radio para ver eventos cercanos a tu ubicación',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),

          // Valor actual
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${currentRadius.toInt()} km',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Slider
          Row(
            children: [
              Text(
                '5 km',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.outline,
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withAlpha(30),
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12,
                    ),
                  ),
                  child: Slider(
                    value: currentRadius,
                    min: 5,
                    max: 15,
                    divisions: 10,
                    onChanged: (value) {
                      ref.read(searchRadiusProvider.notifier).state = value;
                    },
                  ),
                ),
              ),
              Text(
                '15 km',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Botón de confirmar
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Aplicar'),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

/// Muestra el sheet de configuración de radio.
void showRadiusSliderSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const RadiusSliderSheet(),
  );
}
