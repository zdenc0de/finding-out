// lib/core/providers/storage_provider.dart
// Provider de Riverpod para el servicio de almacenamiento

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/supabase_config.dart';
import '../services/storage/storage_service.dart';
import '../services/storage/storage_service_impl.dart';

/// Provider para la instancia del servicio de almacenamiento.
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageServiceImpl(SupabaseConfig.client);
});
