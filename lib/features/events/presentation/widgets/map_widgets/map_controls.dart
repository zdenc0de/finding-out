// lib/features/events/presentation/widgets/map_controls.dart
// Controles de navegación para el mapa (brújula, zoom, ubicación)

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../core/theme/app_colors.dart';

/// Controles de navegación del mapa estilo Google Maps.
///
/// Incluye: brújula, botones de zoom (+/-), y botón de ubicación.
class MapControls extends StatelessWidget {
  /// Rotación actual del mapa en radianes.
  final double mapRotation;

  /// Callback cuando se presiona el botón de zoom in.
  final VoidCallback onZoomIn;

  /// Callback cuando se presiona el botón de zoom out.
  final VoidCallback onZoomOut;

  /// Callback cuando se presiona la brújula (resetear rotación).
  final VoidCallback onCompassTap;

  /// Callback cuando se presiona el botón de ubicación.
  final VoidCallback onMyLocationTap;

  /// Indica si se está cargando la ubicación.
  final bool isLoadingLocation;

  const MapControls({
    super.key,
    required this.mapRotation,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onCompassTap,
    required this.onMyLocationTap,
    this.isLoadingLocation = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Brújula (solo visible si el mapa está rotado)
        if (mapRotation != 0)
          _CompassButton(
            rotation: -mapRotation,
            onTap: onCompassTap,
          ),
        const SizedBox(height: 8),
        // Controles de zoom
        _ZoomControls(
          onZoomIn: onZoomIn,
          onZoomOut: onZoomOut,
        ),
        const SizedBox(height: 8),
        // Botón de mi ubicación
        _LocationButton(
          isLoading: isLoadingLocation,
          onTap: onMyLocationTap,
        ),
      ],
    );
  }
}

/// Botón de brújula que indica el norte.
class _CompassButton extends StatelessWidget {
  final double rotation;
  final VoidCallback onTap;

  const _CompassButton({
    required this.rotation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(24),
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(8),
          child: Transform.rotate(
            angle: rotation,
            child: CustomPaint(
              painter: _CompassPainter(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Painter para dibujar la brújula.
class _CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Triángulo norte (rojo)
    final northPath = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx - 6, center.dy)
      ..lineTo(center.dx + 6, center.dy)
      ..close();

    final northPaint = Paint()
      ..color = AppColors.error
      ..style = PaintingStyle.fill;

    canvas.drawPath(northPath, northPaint);

    // Triángulo sur (gris)
    final southPath = Path()
      ..moveTo(center.dx, center.dy + radius)
      ..lineTo(center.dx - 6, center.dy)
      ..lineTo(center.dx + 6, center.dy)
      ..close();

    final southPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.fill;

    canvas.drawPath(southPath, southPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Controles de zoom (+/-).
class _ZoomControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const _ZoomControls({
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      color: AppColors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zoom In
          _ZoomButton(
            icon: PhosphorIcons.plus(),
            onTap: onZoomIn,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          Container(
            height: 1,
            width: 32,
            color: Colors.grey.shade300,
          ),
          // Zoom Out
          _ZoomButton(
            icon: PhosphorIcons.minus(),
            onTap: onZoomOut,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
          ),
        ],
      ),
    );
  }
}

/// Botón individual de zoom.
class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  const _ZoomButton({
    required this.icon,
    required this.onTap,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: AppColors.onSurfaceVariant,
          size: 22,
        ),
      ),
    );
  }
}

/// Botón de ubicación actual.
class _LocationButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _LocationButton({
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(24),
      color: AppColors.surface,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : Icon(
                  PhosphorIcons.navigationArrow(PhosphorIconsStyle.fill),
                  color: AppColors.primary,
                  size: 22,
                ),
        ),
      ),
    );
  }
}
