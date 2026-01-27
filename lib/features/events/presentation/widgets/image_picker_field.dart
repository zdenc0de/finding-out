// lib/features/events/presentation/widgets/image_picker_field.dart
// Widget para seleccionar y subir imágenes de eventos

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/providers/storage_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Widget para seleccionar y subir imágenes de eventos.
///
/// Permite al usuario:
/// - Seleccionar imagen de la galería
/// - Tomar foto con la cámara
/// - Ver preview de la imagen
/// - Subir automáticamente a Supabase Storage
class ImagePickerField extends ConsumerStatefulWidget {
  /// Callback cuando se sube una imagen exitosamente.
  /// Retorna la URL pública de la imagen.
  final ValueChanged<String?> onImageUploaded;

  /// URL inicial de la imagen (para edición).
  final String? initialImageUrl;

  const ImagePickerField({
    super.key,
    required this.onImageUploaded,
    this.initialImageUrl,
  });

  @override
  ConsumerState<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends ConsumerState<ImagePickerField> {
  final ImagePicker _picker = ImagePicker();

  File? _selectedFile;
  String? _uploadedUrl;
  bool _isUploading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _uploadedUrl = widget.initialImageUrl;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() {
        _selectedFile = File(pickedFile.path);
        _error = null;
      });

      await _uploadImage();
    } catch (e) {
      setState(() {
        _error = 'Error al seleccionar imagen';
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedFile == null) return;

    final userId = ref.read(authNotifierProvider).user?.id;
    if (userId == null) {
      setState(() {
        _error = 'Debes iniciar sesión para subir imágenes';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _error = null;
    });

    try {
      final storageService = ref.read(storageServiceProvider);
      final url = await storageService.uploadEventImage(_selectedFile!, userId);

      setState(() {
        _uploadedUrl = url;
        _isUploading = false;
      });

      widget.onImageUploaded(url);
    } on ImageTooLargeException catch (e) {
      setState(() {
        _error = e.message;
        _isUploading = false;
        _selectedFile = null;
      });
    } on InvalidImageFormatException catch (e) {
      setState(() {
        _error = e.message;
        _isUploading = false;
        _selectedFile = null;
      });
    } on ImageUploadException catch (e) {
      setState(() {
        _error = e.message;
        _isUploading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al subir la imagen';
        _isUploading = false;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedFile = null;
      _uploadedUrl = null;
      _error = null;
    });
    widget.onImageUploaded(null);
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(PhosphorIcons.camera()),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(PhosphorIcons.images()),
                title: const Text('Elegir de galería'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Área de imagen
        GestureDetector(
          onTap: _isUploading ? null : _showImageSourceDialog,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _error != null ? AppColors.error : AppColors.outline,
                width: _error != null ? 2 : 1,
              ),
            ),
            child: _buildContent(),
          ),
        ),

        // Error
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                ),
          ),
        ],

        // Indicador de éxito
        if (_uploadedUrl != null && _error == null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                size: 16,
                color: AppColors.success,
              ),
              const SizedBox(width: 4),
              Text(
                'Imagen subida correctamente',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
                    ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildContent() {
    // Estado de carga
    if (_isUploading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text(
            'Subiendo imagen...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ],
      );
    }

    // Imagen seleccionada (archivo local o URL)
    if (_selectedFile != null || _uploadedUrl != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: _selectedFile != null
                ? Image.file(
                    _selectedFile!,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    _uploadedUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          PhosphorIcons.imageSquare(),
                          size: 48,
                          color: AppColors.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
          ),
          // Botones de acción
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                // Cambiar imagen
                _ActionButton(
                  icon: PhosphorIcons.pencil(),
                  onTap: _showImageSourceDialog,
                  tooltip: 'Cambiar imagen',
                ),
                const SizedBox(width: 8),
                // Eliminar imagen
                _ActionButton(
                  icon: PhosphorIcons.trash(),
                  onTap: _removeImage,
                  tooltip: 'Eliminar imagen',
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Estado vacío
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          PhosphorIcons.imageSquare(),
          size: 48,
          color: AppColors.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        Text(
          'Agregar imagen',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Toca para seleccionar',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

/// Botón de acción circular para las imágenes.
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 20,
              color: isDestructive ? AppColors.error : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
