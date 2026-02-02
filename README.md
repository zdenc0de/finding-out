# Finding Out

**Explora tu ciudad** - App de descubrimiento de eventos basada en ubicación.

---

## Stack Tecnológico

| Categoría | Tecnología |
|-----------|------------|
| Framework | Flutter 3.3+ |
| Estado | Riverpod |
| Backend | Supabase (Auth, DB, Storage) |
| Mapas | flutter_map + OpenStreetMap (actual) → Google Maps (próximamente) |
| Arquitectura | Clean Architecture |

---

## Plan de Febrero 2025 - Perfeccionar la App

### Semana 1 (3-9 Feb): Migración a Google Maps

#### Día 1-2: Configuración
- [ ] Crear proyecto en Google Cloud Console
- [ ] Habilitar APIs: Maps SDK, Places API, Geocoding API
- [ ] Crear API key con restricciones (Android/iOS)
- [ ] Configurar billing (tarjeta de crédito)
- [ ] Agregar API key a variables de entorno (.env)

#### Día 3-4: Reemplazar Mapas
- [ ] Instalar `google_maps_flutter`
- [ ] Migrar `EventsMapScreen` de flutter_map a Google Maps
- [ ] Migrar `MapLocationPickerScreen` a Google Maps
- [ ] Actualizar marcadores y estilos

#### Día 5-7: Reemplazar Autocompletado
- [ ] Instalar `google_places_flutter` o usar Places API directo
- [ ] Reemplazar Photon por Google Places Autocomplete
- [ ] Actualizar `AddressAutocompleteField` con nuevo provider
- [ ] Guardar Place ID además de coordenadas (opcional)
- [ ] Probar y ajustar UX

### Semana 2 (10-16 Feb): Funcionalidades Pendientes

#### Sistema Social
- [ ] Notificaciones cuando amigos confirman asistencia
- [ ] Feed de actividad de amigos
- [ ] Invitar amigos a eventos

#### Mejoras de Eventos
- [ ] Filtros avanzados (fecha, distancia, categoría)
- [ ] Búsqueda de eventos por texto
- [ ] Eventos destacados/trending
- [ ] Compartir evento (deep link)

#### Perfil
- [ ] Historial de eventos asistidos
- [ ] Estadísticas del usuario
- [ ] Configuración de notificaciones

### Semana 3 (17-23 Feb): Pulido y UX

#### Animaciones
- [ ] Transiciones entre pantallas
- [ ] Animaciones de carga (shimmer)
- [ ] Feedback táctil (haptics)

#### Accesibilidad
- [ ] Revisar contraste de colores
- [ ] Agregar labels semánticos
- [ ] Soporte para lectores de pantalla

#### Performance
- [ ] Optimizar carga de imágenes
- [ ] Implementar paginación en listas
- [ ] Cache de datos offline

### Semana 4 (24-28 Feb): Testing y Preparación

#### Testing
- [ ] Tests unitarios de repositorios
- [ ] Tests de widgets críticos
- [ ] Pruebas manuales completas en Android/iOS

#### Preparación para lanzamiento
- [ ] Configurar Firebase Crashlytics
- [ ] Configurar analytics básicos
- [ ] Preparar assets para stores (iconos, screenshots)
- [ ] Escribir descripción para Play Store / App Store
- [ ] Crear cuenta de desarrollador si no existe

---

## Plan de Implementación: Google Maps

### 1. Configuración en Google Cloud Console

```bash
# 1. Ir a https://console.cloud.google.com
# 2. Crear proyecto "Finding Out"
# 3. Habilitar APIs:
#    - Maps SDK for Android
#    - Maps SDK for iOS
#    - Places API
#    - Geocoding API
# 4. Crear API Key en Credentials
# 5. Restringir API Key:
#    - Android: SHA-1 fingerprint + package name
#    - iOS: Bundle identifier
```

### 2. Configuración en Flutter

```yaml
# pubspec.yaml
dependencies:
  google_maps_flutter: ^2.5.0
  google_places_flutter: ^2.0.8  # O flutter_google_places_sdk
  # Remover:
  # flutter_map: ^6.1.0
  # latlong2: ^0.9.0
```

```dart
// android/app/src/main/AndroidManifest.xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${GOOGLE_MAPS_API_KEY}"/>
```

```swift
// ios/Runner/AppDelegate.swift
GMSServices.provideAPIKey("YOUR_API_KEY")
```

### 3. Archivos a Modificar

| Archivo | Cambio |
|---------|--------|
| `pubspec.yaml` | Cambiar dependencias de mapas |
| `android/app/src/main/AndroidManifest.xml` | Agregar API key |
| `ios/Runner/AppDelegate.swift` | Agregar API key |
| `events_map_screen.dart` | Migrar a GoogleMap widget |
| `map_location_picker_screen.dart` | Migrar a GoogleMap widget |
| `address_autocomplete_field.dart` | Usar Google Places Autocomplete |
| `location_search_provider.dart` | Cambiar a Places API |
| `photon_datasource.dart` | Eliminar (ya no se usa) |

### 4. Modelo de Costos (Referencia)

| Usuarios/día | Maps | Autocomplete | Geocoding | Total/mes |
|--------------|------|--------------|-----------|-----------|
| 50 | Gratis | Gratis | Gratis | $0 |
| 100 | Gratis | Gratis | Gratis | $0 |
| 500 | ~$10 | ~$5 | ~$5 | ~$20 |
| 1,000 | ~$30 | ~$15 | ~$10 | ~$55 |

*10,000 llamadas gratuitas por servicio cada mes*

---

## Roadmap de Lanzamiento - Marzo 2025

### Semana 1: Beta Cerrada
- [ ] Invitar 20-50 usuarios de confianza
- [ ] Recopilar feedback
- [ ] Corregir bugs críticos

### Semana 2: Beta Abierta
- [ ] Publicar en Play Store (beta abierta)
- [ ] Publicar en TestFlight
- [ ] Monitorear crashes y analytics

### Semana 3-4: Lanzamiento Oficial
- [ ] Publicar versión 1.0 en stores
- [ ] Campaña en redes sociales
- [ ] Monitorear y responder reviews

---

## Estructura del Proyecto

```
lib/
├── core/                    # Compartido
│   ├── config/              # Router, Supabase config
│   ├── errors/              # Excepciones
│   ├── providers/           # Providers globales
│   ├── theme/               # Colores, tema
│   ├── utils/               # Helpers, formatters
│   └── widgets/             # Widgets compartidos
│
├── features/
│   ├── auth/                # Autenticación
│   ├── events/              # Eventos (listado, detalle, crear)
│   ├── location_search/     # Búsqueda de ubicaciones
│   ├── profile/             # Perfil de usuario
│   └── social/              # Sistema social (follows, attendance)
│
└── main.dart
```

---

## Comandos Útiles

```bash
# Ejecutar app
flutter run

# Análisis estático
flutter analyze

# Tests
flutter test

# Build Android
flutter build apk --release

# Build iOS
flutter build ios --release
```

---

## Estado Actual (Febrero 2025)

### Completado
- [x] Autenticación completa (login, registro, recuperar contraseña)
- [x] CRUD de eventos
- [x] Mapa de eventos con marcadores
- [x] Sistema social (seguir usuarios, asistencia a eventos)
- [x] Navegación con 5 tabs
- [x] Autocompletado de direcciones (Photon API)
- [x] Selector de ubicación en mapa
- [x] Diseño Santorini consistente
- [x] Perfil con estadísticas de seguidores
- [x] "Mis próximos eventos" en perfil

### Pendiente
- [ ] Migración a Google Maps
- [ ] Notificaciones push
- [ ] Filtros avanzados de eventos
- [ ] Compartir eventos
- [ ] Modo offline
- [ ] Tests automatizados

---

## Contribuidores

- **Desarrollo**: [Tu nombre]
- **Asistencia técnica**: Claude (Anthropic)
