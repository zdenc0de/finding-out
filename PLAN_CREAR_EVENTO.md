# Plan: Agregar Nuevo Evento

## Resumen
Implementar la funcionalidad completa para crear nuevos eventos en la app Finding Out, siguiendo la arquitectura Clean Architecture existente con Riverpod y Supabase.

---

## Archivos a Modificar

| Archivo | Cambio |
|---------|--------|
| `lib/features/events/domain/repositories/event_repository.dart` | Agregar método `createEvent()` |
| `lib/core/errors/exceptions.dart` | Agregar `EventCreateException` |
| `lib/features/events/data/models/event_model.dart` | Agregar `toJsonForCreate()` y factory `forCreate()` |
| `lib/features/events/data/repositories/event_repository_impl.dart` | Implementar `createEvent()` con Supabase |
| `lib/features/events/presentation/providers/events_provider.dart` | Agregar estados y método `createEvent()` |
| `lib/core/utils/validators.dart` | Agregar `validateEventTitle()` |
| `lib/core/config/router_config.dart` | Agregar ruta `/events/create` |
| `lib/features/events/presentation/screens/events_home_screen.dart` | Agregar FAB para crear evento |

## Archivos a Crear

| Archivo | Descripción |
|---------|-------------|
| `lib/features/events/presentation/screens/create_event_screen.dart` | Pantalla con formulario |
| `lib/features/events/presentation/widgets/address_search_field.dart` | Campo de búsqueda de dirección con geocoding |

---

## Pasos de Implementación

### Fase 1: Capa de Datos (Backend)

1. **Agregar excepción** en `exceptions.dart`:
   ```dart
   class EventCreateException extends EventException
   ```

2. **Agregar método al contrato** en `event_repository.dart`:
   ```dart
   Future<Event> createEvent({
     required String title,
     String? description,
     required String categoryId,
     String? imageUrl,
     double? locationLat,
     double? locationLng,
     String? address,
     required DateTime startDate,
     DateTime? endDate,
   });
   ```

3. **Modificar EventModel** - agregar métodos para crear sin id/createdAt

4. **Implementar en repositorio** - INSERT a Supabase con `.select().single()` para retornar el evento creado

### Fase 2: State Management

5. **Extender EventsStatus** con: `creating`, `created`, `createError`

6. **Agregar a EventsState**: `successMessage`, `createdEvent`

7. **Agregar método `createEvent()`** en EventsNotifier que:
   - Cambia estado a `creating`
   - Llama al repositorio
   - En éxito: estado `created` + refresh de lista
   - En error: estado `createError` con mensaje

### Fase 3: Validadores

8. **Agregar `validateEventTitle()`** - mínimo 3 caracteres, máximo 100

### Fase 4: UI

9. **Crear AddressSearchField** - campo de búsqueda que:
   - Usuario escribe una dirección
   - Al presionar buscar, usa `geocoding` para obtener coordenadas
   - Muestra resultado con dirección formateada
   - Guarda `locationLat`, `locationLng` y `address` automáticamente

10. **Crear CreateEventScreen** con formulario:
    - Título (obligatorio)
    - Descripción (opcional, multilinea)
    - Categoría (dropdown)
    - URL imagen (opcional)
    - Fecha/hora inicio (obligatorio) - `showDatePicker` + `showTimePicker`
    - Fecha/hora fin (opcional)
    - Dirección (campo de búsqueda con geocoding) - obtiene coordenadas automáticamente

### Fase 5: Navegación

11. **Agregar ruta** `/events/create` en router (ANTES de `/events/:id`)

12. **Agregar FAB** en EventsHomeScreen:
    ```dart
    floatingActionButton: FloatingActionButton(
      onPressed: () => context.push('/events/create'),
      child: Icon(PhosphorIcons.plus()),
    ),
    ```

---

## Campos del Formulario

| Campo | Tipo | Obligatorio | Validación |
|-------|------|-------------|------------|
| Título | TextFormField | Sí | 3-100 caracteres |
| Descripción | TextFormField (multiline) | No | - |
| Categoría | DropdownButtonFormField | Sí | Debe seleccionar una |
| URL Imagen | TextFormField | No | URL válida (http/https) |
| Fecha inicio | DatePicker + TimePicker | Sí | - |
| Fecha fin | DatePicker + TimePicker | No | Posterior a inicio |
| Dirección | AddressSearchField | No | Geocoding → lat/lng automático |

### Flujo de Búsqueda de Dirección

1. Usuario escribe dirección (ej: "Paseo de la Reforma 222, CDMX")
2. Presiona botón de buscar
3. Se usa paquete `geocoding` para obtener coordenadas
4. Se muestra la dirección formateada encontrada
5. Se guardan automáticamente: `address`, `locationLat`, `locationLng`

---

## UX y Feedback

- **Loading**: Deshabilitar botón + CircularProgressIndicator mientras se crea
- **Éxito**: SnackBar verde + navegar a home + refresh de lista
- **Error**: SnackBar rojo con mensaje de error
- **Patrón**: Usar `ref.listen()` para reaccionar a cambios de estado

---

## Verificación

1. Ejecutar app y navegar al home
2. Verificar que aparece el FAB (+)
3. Tocar FAB → debe abrir formulario de creación
4. Llenar campos obligatorios (título, categoría, fecha inicio)
5. Tocar "Crear evento"
6. Verificar SnackBar de éxito
7. Verificar que regresa al home
8. Verificar que el nuevo evento aparece en la lista de su categoría
9. Verificar que aparece en el mapa (si tiene ubicación)
