// lib/features/profile/presentation/widgets/avatar_picker_field.dart
// Widget para seleccionar y subir foto de perfil

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/providers/storage_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Widget para seleccionar y subir foto de perfil (avatar).
class AvatarPickerField extends ConsumerStatefulWidget {
  /// Callback cuando se sube una imagen exitosamente.
  final ValueChanged<String?> onImageUploaded;

  /// URL inicial del avatar.
  final String? initialImageUrl;

  /// Nombre del usuario para mostrar iniciales.
  final String? userName;

  /// Email del usuario para mostrar iniciales como fallback.
  final String? userEmail;

  /// Radio del avatar.
  final double radius;

  const AvatarPickerField({
    super.key,
    required this.onImageUploaded,
    this.initialImageUrl,
    this.userName,
    this.userEmail,
    this.radius = 50,
  });

  @override
  ConsumerState<AvatarPickerField> createState() => _AvatarPickerFieldState();
}

class _AvatarPickerFieldState extends ConsumerState<AvatarPickerField> {
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

  @override
  void didUpdateWidget(AvatarPickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialImageUrl != oldWidget.initialImageUrl && _uploadedUrl == null) {
      _uploadedUrl = widget.initialImageUrl;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
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
        _error = 'Debes iniciar sesión';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _error = null;
    });

    try {
      final storageService = ref.read(storageServiceProvider);
      final url = await storageService.uploadProfileImage(_selectedFile!, userId);

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
              if (_uploadedUrl != null || _selectedFile != null)
                ListTile(
                  leading: Icon(PhosphorIcons.trash(), color: AppColors.error),
                  title: const Text('Eliminar foto', style: TextStyle(color: AppColors.error)),
                  onTap: () {
                    Navigator.pop(context);
                    _removeImage();
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
      children: [
        GestureDetector(
          onTap: _isUploading ? null : _showImageSourceDialog,
          child: Stack(
            children: [
              // Avatar
              _buildAvatar(context),
              // Icono de edición
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  child: _isUploading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : Icon(
                          PhosphorIcons.camera(),
                          size: 16,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                ),
              ),
            ],
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
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    ImageProvider? imageProvider;

    // Prioridad: archivo local > URL subida > URL inicial
    if (_selectedFile != null) {
      imageProvider = FileImage(_selectedFile!);
    } else if (_uploadedUrl != null && _uploadedUrl!.isNotEmpty) {
      imageProvider = NetworkImage(_uploadedUrl!);
    }

    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      backgroundImage: imageProvider,
      onBackgroundImageError: imageProvider != null ? (_, __) {} : null,
      child: _isUploading
          ? CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            )
          : (imageProvider == null
              ? Text(
                  StringUtils.getInitials(widget.userName ?? widget.userEmail),
                  style: TextStyle(
                    fontSize: widget.radius * 0.7,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : null),
    );
  }
}
