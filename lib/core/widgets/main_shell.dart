// lib/core/widgets/main_shell.dart
// Shell principal que contiene el navbar flotante y las pantallas principales

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../features/events/presentation/screens/create_event_screen.dart';
import '../../features/events/presentation/screens/events_home_screen.dart';
import '../../features/events/presentation/screens/events_map_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/user_search_screen.dart';
import 'floating_navbar.dart';

/// Provider para el índice actual del tab seleccionado
final currentTabIndexProvider = StateProvider<int>((ref) => 0);

/// Provider para la ubicación de destino del mapa (cuando se navega desde un evento)
/// Se limpia después de usarse
final mapTargetLocationProvider = StateProvider<LatLng?>((ref) => null);

/// Shell principal que envuelve las pantallas con el navbar flotante.
///
/// Maneja la navegación entre las pantallas principales:
/// - Índice 0: EventsHomeScreen (lista de eventos por categoría)
/// - Índice 1: EventsMapScreen (mapa con eventos)
/// - Índice 2: CreateEventScreen (crear nuevo evento)
/// - Índice 3: ProfileScreen (perfil del usuario)
/// - Índice 4: UserSearchScreen (buscar usuarios)
///
/// Usa carga lazy: cada pantalla se construye solo al visitarla
/// por primera vez y se mantiene viva con Offstage.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  /// Tracks which pages have been visited at least once.
  final Set<int> _initializedPages = {0}; // Home is always initialized

  static const List<Widget> _pages = [
    EventsHomeScreen(),
    EventsMapScreen(),
    CreateEventScreen(),
    ProfileScreen(),
    UserSearchScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentTabIndexProvider);

    // Mark the current page as initialized on first visit
    if (!_initializedPages.contains(currentIndex)) {
      _initializedPages.add(currentIndex);
    }

    return Scaffold(
      body: Stack(
        children: [
          // Lazy-loaded pages: only build when first visited,
          // then keep alive with Offstage
          for (int i = 0; i < _pages.length; i++)
            if (_initializedPages.contains(i))
              Offstage(
                offstage: currentIndex != i,
                child: _pages[i],
              ),
        ],
      ),
      // Navbar ahora gestionado por Scaffold
      bottomNavigationBar: FloatingNavbar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(currentTabIndexProvider.notifier).state = index;
        },
      ),
    );
  }
}
