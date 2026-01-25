// lib/features/events/presentation/widgets/event_marker.dart
// Widget de marcador de evento para el mapa

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_colors.dart';

/// Widget de marcador para eventos en el mapa.
///
/// Muestra un pin con el color de la categoría del evento.
class EventMarkerWidget extends StatelessWidget {
  /// Color hexadecimal de la categoría (e.g., "#FF5733")
  final String colorHex;

  /// Tamaño del marcador
  final double size;

  /// Si el marcador está seleccionado
  final bool isSelected;

  const EventMarkerWidget({
    super.key,
    required this.colorHex,
    this.size = 40,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(colorHex);
    final markerSize = isSelected ? size * 1.2 : size;

    return SizedBox(
      width: markerSize,
      height: markerSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Sombra
          Positioned(
            bottom: 0,
            child: Container(
              width: markerSize * 0.4,
              height: markerSize * 0.15,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(markerSize * 0.2),
              ),
            ),
          ),
          // Pin
          Icon(
            PhosphorIconsFill.mapPin,
            size: markerSize,
            color: color,
            shadows: const [
              Shadow(
                color: Colors.black38,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Parsea el color hexadecimal a Color.
  Color _parseColor(String hex) {
    try {
      final colorValue = int.parse(hex.replaceFirst('#', '0xFF'));
      return Color(colorValue);
    } catch (e) {
      return AppColors.primary;
    }
  }
}

/// Marcador para la ubicación del usuario.
///
/// Muestra un punto azul con un círculo pulsante.
class UserLocationMarker extends StatelessWidget {
  /// Tamaño del marcador
  final double size;

  const UserLocationMarker({
    super.key,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 2,
      height: size * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Círculo exterior (accuracy indicator)
          Container(
            width: size * 2,
            height: size * 2,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
          ),
          // Borde blanco
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          // Punto azul interior
          Container(
            width: size * 0.7,
            height: size * 0.7,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

/// Marcador animado para la ubicación del usuario.
///
/// Incluye una animación de pulso para indicar la ubicación activa.
class AnimatedUserLocationMarker extends StatefulWidget {
  /// Tamaño del marcador
  final double size;

  const AnimatedUserLocationMarker({
    super.key,
    this.size = 24,
  });

  @override
  State<AnimatedUserLocationMarker> createState() =>
      _AnimatedUserLocationMarkerState();
}

class _AnimatedUserLocationMarkerState extends State<AnimatedUserLocationMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 2.5,
      height: widget.size * 2.5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Círculo pulsante
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: widget.size * 2 * _animation.value,
                height: widget.size * 2 * _animation.value,
                decoration: BoxDecoration(
                  color: AppColors.primary
                      .withValues(alpha: 0.15 / _animation.value),
                  shape: BoxShape.circle,
                ),
              );
            },
          ),
          // Marcador estático
          UserLocationMarker(size: widget.size),
        ],
      ),
    );
  }
}
