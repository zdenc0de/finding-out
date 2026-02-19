// lib/features/events/domain/entities/friend_event_activity.dart
// Entidad que representa la actividad de amigos en un evento

import '../../../profile/domain/entities/public_profile.dart';
import 'event.dart';

class FriendEventActivity {
  final Event event;
  final List<PublicProfile> friends;

  const FriendEventActivity({
    required this.event,
    required this.friends,
  });

  /// Retorna un resumen de la actividad como texto
  /// Ejemplo: "María y 3 amigos van a un evento..."
  String get summary {
    if (friends.isEmpty) return '';
    
    final firstFriendName = friends.first.displayName ?? 'Un amigo';
    if (friends.length == 1) {
      return '$firstFriendName va a un evento...';
    } else {
      return '$firstFriendName y ${friends.length - 1} amigos van a un evento...';
    }
  }
}
