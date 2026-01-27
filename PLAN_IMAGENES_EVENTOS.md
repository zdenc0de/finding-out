# Plan: Subir Imágenes a Eventos

## Resumen
Implementar la funcionalidad para subir imágenes desde el dispositivo a Supabase Storage y asociarlas a los eventos.

---

## Parte 1: Configuración de Supabase (Manual)

### 1.1 Crear Bucket de Storage

1. Ir a **Supabase Dashboard** → **Storage**
2. Click en **"New bucket"**
3. Configurar:
   - **Name:** `event-images`
   - **Public bucket:** ✅ Activado (para que las imágenes sean accesibles públicamente)
   - **File size limit:** 5MB (opcional)
   - **Allowed MIME types:** `image/jpeg, image/png, image/webp, image/gif`

### 1.2 Configurar Políticas RLS

Ir a **Storage** → **Policies** → bucket `event-images`:

**Política 1: SELECT (lectura pública)**
```sql
-- Nombre: "Imágenes públicas"
-- Operación: SELECT
-- Aplica a: public (todos)
CREATE POLICY "Imagenes publicas"
ON storage.objects FOR SELECT
USING (bucket_id = 'event-images');
```

**Política 2: INSERT (usuarios autenticados pueden subir)**
```sql
-- Nombre: "Usuarios pueden subir"
-- Operación: INSERT
-- Aplica a: authenticated
CREATE POLICY "Usuarios pueden subir"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'event-images');
```

**Política 3: DELETE (usuarios pueden eliminar sus propias imágenes)**
```sql
-- Nombre: "Usuarios pueden eliminar sus imagenes"
-- Operación: DELETE
-- Aplica a: authenticated
CREATE POLICY "Usuarios pueden eliminar sus imagenes"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'event-images' AND auth.uid()::text = (storage.foldername(name))[1]);
```

> **Nota:** La estructura de carpetas será: `event-images/{user_id}/{filename}`

---

## Parte 2: Cambios en Flutter

### Archivos a Modificar

| Archivo | Cambio |
|---------|--------|
| `pubspec.yaml` | Agregar `image_picker` |
| `android/app/src/main/AndroidManifest.xml` | Permisos de cámara/galería |
| `ios/Runner/Info.plist` | Permisos de cámara/galería |
| `lib/features/events/presentation/screens/create_event_screen.dart` | Reemplazar campo URL por selector de imagen |

### Archivos a Crear

| Archivo | Descripción |
|---------|-------------|
| `lib/core/services/storage/storage_service.dart` | Interfaz del servicio |
| `lib/core/services/storage/storage_service_impl.dart` | Implementación con Supabase |
| `lib/core/providers/storage_provider.dart` | Provider de Riverpod |
| `lib/core/errors/exceptions.dart` | Agregar excepciones de storage |
| `lib/features/events/presentation/widgets/image_picker_field.dart` | Widget selector de imagen |

---

## Pasos de Implementación

### Paso 1: Agregar Dependencia
```yaml
# pubspec.yaml
dependencies:
  image_picker: ^1.0.7
```

### Paso 2: Configurar Permisos Android
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.CAMERA"/>
<uses-feature android:name="android.hardware.camera" android:required="false"/>
```

### Paso 3: Configurar Permisos iOS
```xml
<!-- ios/Runner/Info.plist -->
<key>NSCameraUsageDescription</key>
<string>Finding Out necesita acceso a la cámara para tomar fotos de eventos.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Finding Out necesita acceso a tu galería para seleccionar fotos de eventos.</string>
```

### Paso 4: Crear Excepciones de Storage
```dart
// En exceptions.dart
class StorageException extends AppException { ... }
class ImageUploadException extends StorageException { ... }
class ImageTooLargeException extends StorageException { ... }
class InvalidImageFormatException extends StorageException { ... }
```

### Paso 5: Crear Storage Service
```dart
// storage_service.dart
abstract class StorageService {
  Future<String> uploadEventImage(File imageFile, String userId);
  Future<void> deleteEventImage(String imageUrl);
  String getPublicUrl(String path);
}
```

### Paso 6: Implementar Storage Service
```dart
// storage_service_impl.dart
class StorageServiceImpl implements StorageService {
  final SupabaseClient _client;
  static const String _bucketName = 'event-images';
  static const int _maxFileSizeBytes = 5 * 1024 * 1024; // 5MB

  @override
  Future<String> uploadEventImage(File imageFile, String userId) async {
    // Validar tamaño
    // Generar nombre único con uuid
    // Subir a Supabase Storage
    // Retornar URL pública
  }
}
```

### Paso 7: Crear Widget ImagePickerField
```dart
// image_picker_field.dart
class ImagePickerField extends StatefulWidget {
  final ValueChanged<String?> onImageSelected;
  final String? initialImageUrl;

  // Permite:
  // - Seleccionar desde galería
  // - Tomar foto con cámara
  // - Vista previa de la imagen
  // - Eliminar imagen seleccionada
  // - Indicador de carga durante upload
}
```

### Paso 8: Modificar CreateEventScreen
- Reemplazar el `TextFormField` de URL por `ImagePickerField`
- El widget sube la imagen y retorna la URL
- Manejar estados de carga

---

## Flujo de Usuario

1. Usuario toca el campo de imagen
2. Aparece bottom sheet: "Cámara" | "Galería"
3. Usuario selecciona/toma foto
4. Se muestra preview de la imagen
5. Al tocar "Crear Evento":
   - Primero se sube la imagen a Storage
   - Se obtiene la URL pública
   - Se crea el evento con la URL
6. Si falla el upload, se muestra error

---

## Estructura de Archivos en Storage

```
event-images/
├── {user_id_1}/
│   ├── {uuid1}.jpg
│   └── {uuid2}.png
├── {user_id_2}/
│   └── {uuid3}.jpg
```

---

## Consideraciones

- **Compresión:** Considerar comprimir imágenes antes de subir (paquete `flutter_image_compress`)
- **Tamaño máximo:** 5MB por imagen
- **Formatos:** JPEG, PNG, WebP, GIF
- **Limpieza:** Si el usuario cancela la creación del evento después de subir imagen, la imagen queda huérfana (considerar cron job de limpieza en Supabase)

---

## Verificación

1. [ ] Bucket `event-images` creado en Supabase
2. [ ] Políticas RLS configuradas
3. [ ] Permisos de cámara/galería funcionan en Android
4. [ ] Permisos de cámara/galería funcionan en iOS
5. [ ] Se puede seleccionar imagen de galería
6. [ ] Se puede tomar foto con cámara
7. [ ] Preview de imagen se muestra correctamente
8. [ ] Imagen se sube a Supabase Storage
9. [ ] URL pública funciona (imagen visible)
10. [ ] Evento se crea con la imagen
11. [ ] Imagen aparece en el detalle del evento
12. [ ] Imagen aparece en las cards de eventos
