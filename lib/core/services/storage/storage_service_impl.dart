// lib/core/services/storage/storage_service_impl.dart
// Implementación del servicio de almacenamiento con Supabase

import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart' hide StorageException;
import 'package:uuid/uuid.dart';

import '../../errors/exceptions.dart';
import 'storage_service.dart';

/// Implementación del servicio de almacenamiento usando Supabase Storage.
class StorageServiceImpl implements StorageService {
  final SupabaseClient _client;

  /// Nombre del bucket para imágenes de eventos
  static const String _bucketName = 'event-images';

  /// Tamaño máximo de archivo: 5MB
  static const int _maxFileSizeBytes = 5 * 1024 * 1024;

  /// Extensiones de imagen permitidas
  static const List<String> _allowedExtensions = ['jpg', 'jpeg', 'png', 'webp', 'gif'];

  StorageServiceImpl(this._client);

  @override
  Future<String> uploadEventImage(File imageFile, String userId) async {
    // Validar que el archivo existe
    if (!await imageFile.exists()) {
      throw const ImageUploadException('El archivo no existe');
    }

    // Validar tamaño del archivo
    final fileSize = await imageFile.length();
    if (fileSize > _maxFileSizeBytes) {
      throw const ImageTooLargeException();
    }

    // Validar extensión del archivo
    final extension = _getFileExtension(imageFile.path);
    if (!_allowedExtensions.contains(extension.toLowerCase())) {
      throw const InvalidImageFormatException();
    }

    // Generar nombre único para el archivo
    final uuid = const Uuid().v4();
    final fileName = '$uuid.$extension';
    final filePath = '$userId/$fileName';

    try {
      // Subir archivo a Supabase Storage
      await _client.storage.from(_bucketName).upload(
            filePath,
            imageFile,
            fileOptions: FileOptions(
              contentType: _getContentType(extension),
              upsert: false,
            ),
          );

      // Retornar URL pública
      return getPublicUrl(filePath);
    } catch (e) {
      throw ImageUploadException(e.toString());
    }
  }

  @override
  Future<void> deleteImage(String imagePath) async {
    try {
      await _client.storage.from(_bucketName).remove([imagePath]);
    } catch (e) {
      throw ImageUploadException(e.toString());
    }
  }

  @override
  String getPublicUrl(String path) {
    return _client.storage.from(_bucketName).getPublicUrl(path);
  }

  /// Obtiene la extensión de un archivo.
  String _getFileExtension(String filePath) {
    final lastDot = filePath.lastIndexOf('.');
    if (lastDot == -1) return '';
    return filePath.substring(lastDot + 1);
  }

  /// Obtiene el content type según la extensión.
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }
}
