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

### `followers`

Relaciones de seguimiento entre usuarios.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | `uuid` (PK) | Identificador único de la relación |
| `follower_id` | `uuid` (FK → auth.users.id) | Usuario que sigue |
| `following_id` | `uuid` (FK → auth.users.id) | Usuario que es seguido |
| `created_at` | `timestamptz` | Fecha de creación |

**Constraints:**
- `UNIQUE (follower_id, following_id)` - Evita duplicados
- `CHECK (follower_id != following_id)` - No puedes seguirte a ti mismo

**Índices:**
- `idx_followers_follower_id` en `follower_id`
- `idx_followers_following_id` en `following_id`

---

### `event_attendees`

Asistencia de usuarios a eventos.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | `uuid` (PK) | Identificador único |
| `event_id` | `uuid` (FK → events.id) | Evento al que asiste |
| `user_id` | `uuid` (FK → auth.users.id) | Usuario que asiste |
| `status` | `text` | Estado: 'going' o 'interested' |
| `created_at` | `timestamptz` | Fecha de creación |

**Constraints:**
- `UNIQUE (event_id, user_id)` - Un usuario solo puede tener una entrada por evento
- `CHECK (status IN ('going', 'interested'))` - Estados válidos

**Índices:**
- `idx_event_attendees_event_id` en `event_id`
- `idx_event_attendees_user_id` en `user_id`

---

## Relaciones

```
                         ┌───────────────┐
                         │  auth.users   │
                         └───────┬───────┘
                                 │
              ┌──────────────────┼──────────────────┐
              │                  │                  │
              ▼                  ▼                  ▼
        ┌───────────┐      ┌──────────┐      ┌─────────────────┐
        │ followers │      │ profiles │      │ event_attendees │
        └───────────┘      └────┬─────┘      └────────┬────────┘
         follower_id            │                     │
         following_id           │ created_by          │ user_id
                                ▼                     │ event_id
                          ┌──────────┐                │
                          │  events  │◀───────────────┘
                          └────┬─────┘
                               │ category_id
                               ▼
                         ┌────────────┐
                         │ categories │
                         └────────────┘
```

## Notas de implementación

- **Autenticación**: La tabla `profiles` se crea automáticamente cuando un usuario se registra mediante un trigger en Supabase.
- **Geolocalización**: `location_lat` y `location_lng` almacenan coordenadas para mostrar eventos en el mapa de CDMX.
- **RLS (Row Level Security)**: Configurar políticas para que los usuarios solo puedan editar sus propios eventos.

## RLS Policies

### `followers`
```sql
-- Cualquier usuario autenticado puede ver quien sigue a quien
CREATE POLICY "Followers viewable by authenticated" ON followers
FOR SELECT TO authenticated USING (true);

-- Solo puedes crear tus propios follows
CREATE POLICY "Users can follow others" ON followers
FOR INSERT TO authenticated WITH CHECK (auth.uid() = follower_id);

-- Solo puedes eliminar tus propios follows
CREATE POLICY "Users can unfollow" ON followers
FOR DELETE TO authenticated USING (auth.uid() = follower_id);
```

### `event_attendees`
```sql
-- Cualquier usuario autenticado puede ver asistentes
CREATE POLICY "Attendees viewable by authenticated" ON event_attendees
FOR SELECT TO authenticated USING (true);

-- Solo puedes marcar tu propia asistencia
CREATE POLICY "Users can mark attendance" ON event_attendees
FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

-- Solo puedes actualizar tu propia asistencia
CREATE POLICY "Users can update own attendance" ON event_attendees
FOR UPDATE TO authenticated USING (auth.uid() = user_id);

-- Solo puedes eliminar tu propia asistencia
CREATE POLICY "Users can remove attendance" ON event_attendees
FOR DELETE TO authenticated USING (auth.uid() = user_id);
```
