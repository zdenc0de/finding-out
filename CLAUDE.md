# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Finding Out is a Flutter app for location-based event discovery. It uses Clean Architecture with Riverpod for state management and Supabase as the backend.

## Common Commands

```bash
# Run the app
flutter run

# Run linting/analysis
flutter analyze

# Run tests
flutter test

# Generate code (JSON serialization)
flutter pub run build_runner build --delete-conflicting-outputs

# Get dependencies
flutter pub get
```

## Architecture

The project follows **Clean Architecture** with three layers per feature:

```
lib/
├── core/                    # Shared concerns (theme, config, utils, widgets)
├── features/
│   └── [feature]/
│       ├── data/            # Repository implementations, datasources, DTOs
│       ├── domain/          # Entities, abstract repositories, use cases
│       └── presentation/    # Riverpod providers, screens, widgets
└── main.dart
```

### Layer Dependencies
- **Domain**: Pure Dart, no Flutter dependencies. Defines business rules.
- **Data**: Implements domain interfaces. Connects to Supabase.
- **Presentation**: Uses Riverpod providers. Consumes domain via data layer.

### State Management (Riverpod)

Pattern used throughout the app:
```dart
// 1. Repository provider (dependency injection)
final authRepositoryProvider = Provider<AuthRepository>((ref) => ...);

// 2. StateNotifier for complex state
class AuthNotifier extends StateNotifier<AuthState> { ... }

// 3. StateNotifierProvider to expose
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => ...);
```

Widget usage:
- `ref.watch()` - reactive rebuilds
- `ref.read()` - one-time access for actions
- `ref.listen()` - side effects (snackbars, navigation)

### Navigation (GoRouter)

Routes defined in `lib/core/config/router_config.dart`:
- **Public:** `/login`, `/register`, `/forgot-password`, `/verify-email`, `/reset-password`
- **Protected:** `/home` (MainShell with navbar), `/events/:id`, `/profile`, `/profile/edit`

The router has redirect logic that protects routes based on `AuthStatus`. Password recovery uses deep links (`findingout://callback`).

### Main Shell

`lib/core/widgets/main_shell.dart` wraps the home experience with a bottom navbar containing:
- Events list (EventsHomeScreen)
- Map view (EventsMapScreen)

### Theming

All colors in `lib/core/theme/app_colors.dart`, theme in `lib/core/theme/app_theme.dart`.
- Use `Theme.of(context)` to access theme properties
- Use `AppColors.primary` etc. for direct color access

### Icons

Uses **Phosphor Icons** (`phosphor_flutter`). Usage:
```dart
Icon(PhosphorIcons.calendar())                           // Regular
Icon(PhosphorIcons.calendar(PhosphorIconsStyle.duotone)) // Duotone for emphasis
```

### Backend (Supabase)

Initialized in `main()` via `SupabaseConfig.initialize()`. Access client via `SupabaseConfig.client`.

## Key Patterns

**Adding a new feature:**
1. Create folder structure under `lib/features/[name]/`
2. Define domain layer (entities, repository interface, use cases)
3. Implement data layer (repository impl, datasources)
4. Build presentation layer (providers, screens)
5. Add route in `router_config.dart` if needed

**Error handling in auth:**
`auth_repository_impl.dart` has `_mapAuthError()` that translates Supabase errors to Spanish.

**UI Language:** All user-facing text is in Spanish.
