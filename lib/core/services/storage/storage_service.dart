// lib/core/services/storage/storage_service.dart
// Interfaz del servicio de almacenamiento

import 'dart:io';

/// Contrato del servicio de almacenamiento.
///
/// Define las operaciones disponibles para subir y gestionar archivos
/// en Supabase Storage.
abstract class StorageService {
  /// Sube una imagen de evento a Storage.
  ///
  /// [imageFile] - Archivo de imagen a subir
  /// [userId] - ID del usuario que sube la imagen
  ///
  /// Retorna la URL pública de la imagen subida.
  /// Lanza [ImageUploadException] si falla la subida.
  /// Lanza [ImageTooLargeException] si excede el tamaño máximo.
  /// Lanza [InvalidImageFormatException] si el formato no es válido.
  Future<String> uploadEventImage(File imageFile, String userId);

  /// Elimina una imagen de Storage.
  ///
  /// [imagePath] - Ruta del archivo en Storage (sin URL base)
  Future<void> deleteImage(String imagePath);

  /// Obtiene la URL pública de un archivo.
  ///
  /// [path] - Ruta del archivo en Storage
  String getPublicUrl(String path);
}
