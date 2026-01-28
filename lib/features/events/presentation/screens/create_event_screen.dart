// lib/features/events/presentation/screens/create_event_screen.dart
// Pantalla para crear un nuevo evento

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/category.dart';
import '../providers/events_provider.dart';
import '../widgets/address_search_field.dart';
import '../widgets/image_picker_field.dart';

/// Pantalla para crear un nuevo evento.
class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Estado del formulario
  String? _selectedCategoryId;
  String? _imageUrl;
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  double? _locationLat;
  double? _locationLng;
  String? _address;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(eventsNotifierProvider);
    final categories = eventsState.sortedCategories;
    final isCreating = eventsState.status == EventsStatus.creating;

    // Escuchar cambios de estado
    ref.listen<EventsState>(eventsNotifierProvider, (previous, next) {
      if (next.status == EventsStatus.created) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage ?? 'Evento creado'),
            backgroundColor: AppColors.success,
          ),
        );
        ref.read(eventsNotifierProvider.notifier).clearCreateState();
        context.pop();
      }

      if (next.status == EventsStatus.createError && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft()),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Crear Evento'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Título
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Título *',
                hintText: 'Nombre del evento',
                prefixIcon: Icon(PhosphorIcons.textT()),
              ),
              validator: Validators.validateEventTitle,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Descripción
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
                hintText: 'Describe tu evento',
                prefixIcon: Icon(PhosphorIcons.article()),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Categoría
            DropdownButtonFormField<String>(
              initialValue: _selectedCategoryId,
              decoration: InputDecoration(
                labelText: 'Categoría *',
                prefixIcon: Icon(PhosphorIcons.tag()),
              ),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category.id,
                  child: Row(
                    children: [
                      _buildCategoryIcon(category),
                      const SizedBox(width: 8),
                      Text(category.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategoryId = value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Selecciona una categoría';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Imagen del evento
            Text(
              'Imagen',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ImagePickerField(
              onImageUploaded: (url) {
                setState(() => _imageUrl = url);
              },
            ),
            const SizedBox(height: 24),

            // Sección de fecha y hora
            Text(
              'Fecha y hora',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            // Fecha y hora de inicio
            _buildDateTimeRow(
              label: 'Inicio *',
              date: _startDate,
              time: _startTime,
              onDateTap: () => _selectDate(isStart: true),
              onTimeTap: () => _selectTime(isStart: true),
              isRequired: true,
            ),
            const SizedBox(height: 12),

            // Fecha y hora de fin
            _buildDateTimeRow(
              label: 'Fin',
              date: _endDate,
              time: _endTime,
              onDateTap: () => _selectDate(isStart: false),
              onTimeTap: () => _selectTime(isStart: false),
              isRequired: false,
            ),
            const SizedBox(height: 24),

            // Sección de ubicación
            Text(
              'Ubicación',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            // Campo de búsqueda de dirección
            AddressSearchField(
              onAddressFound: (result) {
                setState(() {
                  if (result != null) {
                    _locationLat = result.latitude;
                    _locationLng = result.longitude;
                    _address = result.formattedAddress;
                  } else {
                    _locationLat = null;
                    _locationLng = null;
                    _address = null;
                  }
                });
              },
            ),
            const SizedBox(height: 32),

            // Botón de crear
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: isCreating ? null : _submitForm,
                child: isCreating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Crear Evento'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(Category category) {
    final color = Color(
      int.parse(category.color.replaceFirst('#', '0xFF')),
    );
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        PhosphorIcons.circle(PhosphorIconsStyle.fill),
        color: color,
        size: 14,
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Widget _buildDateTimeRow({
    required String label,
    required DateTime? date,
    required TimeOfDay? time,
    required VoidCallback onDateTap,
    required VoidCallback onTimeTap,
    required bool isRequired,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onDateTap,
            icon: Icon(PhosphorIcons.calendar(), size: 18),
            label: Text(
              date != null
                  ? DateFormatter.formatMediumDate(date)
                  : 'Seleccionar fecha',
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onTimeTap,
            icon: Icon(PhosphorIcons.clock(), size: 18),
            label: Text(
              time != null ? _formatTime(time) : 'Hora',
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate({required bool isStart}) async {
    final now = DateTime.now();
    final initialDate = isStart
        ? (_startDate ?? now)
        : (_endDate ?? _startDate ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      locale: const Locale('es', 'MX'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              headerHelpStyle: Theme.of(context).textTheme.labelLarge,
              dayStyle: Theme.of(context).textTheme.bodyMedium,
            ),
            iconButtonTheme: IconButtonThemeData(
              style: IconButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime({required bool isStart}) async {
    final initialTime = isStart
        ? (_startTime ?? TimeOfDay.now())
        : (_endTime ?? _startTime ?? TimeOfDay.now());

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      initialEntryMode: TimePickerEntryMode.inputOnly,
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: const Locale('en', 'US'),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _submitForm() {
    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar fecha de inicio
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona la fecha de inicio'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Combinar fecha y hora de inicio
    final startDateTime = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime?.hour ?? 0,
      _startTime?.minute ?? 0,
    );

    // Combinar fecha y hora de fin (si existe)
    DateTime? endDateTime;
    if (_endDate != null) {
      endDateTime = DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
        _endTime?.hour ?? 23,
        _endTime?.minute ?? 59,
      );

      // Validar que fin sea posterior a inicio
      if (endDateTime.isBefore(startDateTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La fecha de fin debe ser posterior al inicio'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    // Crear evento
    ref.read(eventsNotifierProvider.notifier).createEvent(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          categoryId: _selectedCategoryId!,
          imageUrl: _imageUrl,
          locationLat: _locationLat,
          locationLng: _locationLng,
          address: _address,
          startDate: startDateTime,
          endDate: endDateTime,
        );
  }
}
