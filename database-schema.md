# Finding Out - Database Schema

## Overview

Base de datos en Supabase para la aplicación de descubrimiento de eventos en CDMX.

---

## Tablas

### `profiles`

Almacena la información de perfil de los usuarios, vinculada a `auth.users`.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | `uuid` (PK, FK → auth.users.id) | Identificador único del usuario |
| `display_name` | `text` | Nombre público del usuario |
| `avatar_url` | `text` | URL de la imagen de perfil |
| `created_at` | `timestamptz` | Fecha de creación del perfil |

---

### `events`

Contiene todos los eventos disponibles en la plataforma.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | `uuid` (PK) | Identificador único del evento |
| `title` | `text` (NOT NULL) | Título del evento |
| `description` | `text` | Descripción detallada |
| `category_id` | `uuid` (FK → categories.id) | Categoría del evento |
| `image_url` | `text` | URL de la imagen del evento |
| `location_lat` | `float8` | Latitud de la ubicación |
| `location_lng` | `float8` | Longitud de la ubicación |
| `address` | `text` | Dirección física del evento |
| `start_date` | `timestamptz` | Fecha y hora de inicio |
| `end_date` | `timestamptz` | Fecha y hora de fin |
| `created_by` | `uuid` (FK → profiles.id) | Usuario que creó el evento |
| `created_at` | `timestamptz` | Fecha de creación del registro |

---

### `categories`

Catálogo de categorías para clasificar eventos.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | `uuid` (PK) | Identificador único de la categoría |
| `name` | `text` | Nombre de la categoría (ej: "Música", "Arte") |
| `icon` | `text` | Nombre del icono a mostrar |
| `color` | `text` | Color en formato hex para la UI |
| `display_order` | `int4` | Orden de aparición en la app |
| `created_at` | `timestamptz` | Fecha de creación |

---

## Relaciones

```
auth.users.id ──────┐
                    │
                    ▼
              ┌──────────┐
              │ profiles │
              └────┬─────┘
                   │
                   │ created_by
                   ▼
              ┌──────────┐       ┌────────────┐
              │  events  │──────▶│ categories │
              └──────────┘       └────────────┘
                            category_id
```

## Notas de implementación

- **Autenticación**: La tabla `profiles` se crea automáticamente cuando un usuario se registra mediante un trigger en Supabase.
- **Geolocalización**: `location_lat` y `location_lng` almacenan coordenadas para mostrar eventos en el mapa de CDMX.
- **RLS (Row Level Security)**: Configurar políticas para que los usuarios solo puedan editar sus propios eventos.
