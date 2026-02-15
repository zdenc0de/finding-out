import 'package:flutter_test/flutter_test.dart';
import 'package:finding_out/features/auth/domain/entities/user.dart';

void main() {
  group('AppUser', () {
    final createdAt = DateTime(2024, 1, 1);

    AppUser createUser({String id = '1'}) {
      return AppUser(
        id: id,
        email: 'test@example.com',
        displayName: 'Test User',
        avatarUrl: 'https://example.com/avatar.jpg',
        createdAt: createdAt,
      );
    }

    test('debe crear un AppUser con todos los campos', () {
      final user = createUser();

      expect(user.id, '1');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.avatarUrl, 'https://example.com/avatar.jpg');
      expect(user.createdAt, createdAt);
    });

    test('debe crear un AppUser con campos opcionales nulos', () {
      final user = AppUser(
        id: '2',
        email: 'minimal@example.com',
        createdAt: createdAt,
      );

      expect(user.displayName, isNull);
      expect(user.avatarUrl, isNull);
    });

    group('copyWith', () {
      test('debe copiar con nuevos valores', () {
        final user = createUser();
        final copied = user.copyWith(
          displayName: 'Nuevo Nombre',
          avatarUrl: 'https://example.com/new-avatar.jpg',
        );

        expect(copied.id, user.id);
        expect(copied.email, user.email);
        expect(copied.displayName, 'Nuevo Nombre');
        expect(copied.avatarUrl, 'https://example.com/new-avatar.jpg');
        expect(copied.createdAt, user.createdAt);
      });

      test('debe mantener valores originales si no se especifican nuevos', () {
        final user = createUser();
        final copied = user.copyWith();

        expect(copied.id, user.id);
        expect(copied.email, user.email);
        expect(copied.displayName, user.displayName);
        expect(copied.avatarUrl, user.avatarUrl);
        expect(copied.createdAt, user.createdAt);
      });

      test('debe poder actualizar solo un campo', () {
        final user = createUser();
        final copied = user.copyWith(email: 'newemail@example.com');

        expect(copied.email, 'newemail@example.com');
        expect(copied.displayName, user.displayName);
      });
    });

    group('equality', () {
      test('dos usuarios con el mismo id deben ser iguales', () {
        final user1 = createUser(id: '1');
        final user2 = createUser(id: '1');

        expect(user1, equals(user2));
      });

      test('dos usuarios con diferente id deben ser diferentes', () {
        final user1 = createUser(id: '1');
        final user2 = createUser(id: '2');

        expect(user1, isNot(equals(user2)));
      });

      test('el usuario debe ser igual a sí mismo', () {
        final user = createUser();

        expect(user, equals(user));
      });

      test('el usuario no debe ser igual a otro tipo de objeto', () {
        final user = createUser();

        expect(user, isNot(equals('not a user')));
      });
    });

    group('hashCode', () {
      test('dos usuarios iguales deben tener el mismo hashCode', () {
        final user1 = createUser(id: '1');
        final user2 = createUser(id: '1');

        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('el hashCode debe basarse en el id', () {
        final user = createUser(id: 'test-id');

        expect(user.hashCode, equals('test-id'.hashCode));
      });
    });

    group('toString', () {
      test('debe retornar una representación legible', () {
        final user = createUser();
        final string = user.toString();

        expect(string, contains('AppUser'));
        expect(string, contains(user.id));
        expect(string, contains(user.email));
        expect(string, contains(user.displayName!));
      });
    });
  });
}
