// lib/features/events/presentation/widgets/attendance_buttons.dart
// Botones para marcar asistencia a un evento

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/event_attendance.dart';
import '../../providers/events_provider.dart';

/// Botones para marcar asistencia a un evento.
///
/// Muestra dos botones: "Voy" y "Me interesa".
class AttendanceButtons extends ConsumerWidget {
  final String eventId;

  const AttendanceButtons({
    super.key,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceState = ref.watch(attendanceNotifierProvider(eventId));

    // Mostrar error si existe
    ref.listen(attendanceNotifierProvider(eventId), (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(attendanceNotifierProvider(eventId).notifier).clearError();
      }
    });

    final isGoing = attendanceState.status == AttendanceStatus.going;
    final isInterested = attendanceState.status == AttendanceStatus.interested;
    final isLoading = attendanceState.isLoading;

    return Row(
      children: [
        Expanded(
          child: _GoingButton(
            isSelected: isGoing,
            isLoading: isLoading,
            onPressed: () {
              final notifier =
                  ref.read(attendanceNotifierProvider(eventId).notifier);
              if (isGoing) {
                notifier.cancelAttendance();
              } else {
                notifier.markGoing();
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InterestedButton(
            isSelected: isInterested,
            isLoading: isLoading,
            onPressed: () {
              final notifier =
                  ref.read(attendanceNotifierProvider(eventId).notifier);
              if (isInterested) {
                notifier.cancelAttendance();
              } else {
                notifier.markInterested();
              }
            },
          ),
        ),
      ],
    );
  }
}

class _GoingButton extends StatelessWidget {
  final bool isSelected;
  final bool isLoading;
  final VoidCallback onPressed;

  const _GoingButton({
    required this.isSelected,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return FilledButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), size: 20),
        label: const Text('Voy'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          : Icon(PhosphorIcons.checkCircle(), size: 20),
      label: const Text('Voy'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}

class _InterestedButton extends StatelessWidget {
  final bool isSelected;
  final bool isLoading;
  final VoidCallback onPressed;

  const _InterestedButton({
    required this.isSelected,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return FilledButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(PhosphorIcons.heart(PhosphorIconsStyle.fill), size: 20),
        label: const Text('Me interesa'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.secondary,
              ),
            )
          : Icon(PhosphorIcons.heart(), size: 20),
      label: const Text('Me interesa'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.secondary,
        side: const BorderSide(color: AppColors.secondary),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}
