// lib/core/widgets/main_shell.dart
// Shell principal que contiene el navbar flotante y las pantallas principales

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/events/presentation/screens/create_event_screen.dart';
import '../../features/events/presentation/screens/events_home_screen.dart';
import '../../features/events/presentation/screens/events_map_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/user_search_screen.dart';
import 'floating_navbar.dart';

/// Provider para el índice actual del tab seleccionado
final currentTabIndexProvider = StateProvider<int>((ref) => 0);

/// Shell principal que envuelve las pantallas con el navbar flotante.
///
/// Maneja la navegación entre las pantallas principales:
/// - Índice 0: EventsHomeScreen (lista de eventos por categoría)
/// - Índice 1: EventsMapScreen (mapa con eventos)
/// - Índice 2: CreateEventScreen (crear nuevo evento)
/// - Índice 3: ProfileScreen (perfil del usuario)
/// - Índice 4: UserSearchScreen (buscar usuarios)
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentTabIndexProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Contenido de la pantalla actual
          IndexedStack(
            index: currentIndex,
            children: const [
              EventsHomeScreen(),
              EventsMapScreen(),
              CreateEventScreen(),
              ProfileScreen(),
              UserSearchScreen(),
            ],
          ),

          // Navbar flotante
          FloatingNavbar(
            currentIndex: currentIndex,
            onTap: (index) {
              ref.read(currentTabIndexProvider.notifier).state = index;
            },
          ),
        ],
      ),
    );
  }
}
