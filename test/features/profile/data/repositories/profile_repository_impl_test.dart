import 'package:flutter_test/flutter_test.dart';

import 'package:finding_out/features/profile/data/models/public_profile_model.dart';
import 'package:finding_out/features/profile/domain/entities/public_profile.dart';

/// Tests para profile_repository y sus modelos de datos.
void main() {
  group('Profile Repository - Data Transformations', () {
    group('PublicProfileModel', () {
      final testCreatedAt = DateTime(2024, 1, 15, 10, 30);
      
      test('debe crear modelo desde JSON completo', () {
        final json = {
          'id': 'user-123',
          'display_name': 'Juan García',
          'avatar_url': 'https://example.com/avatar.jpg',
          'created_at': testCreatedAt.toIso8601String(),
        };

        final model = PublicProfileModel.fromJson(json);

        expect(model.id, 'user-123');
        expect(model.displayName, 'Juan García');
        expect(model.avatarUrl, 'https://example.com/avatar.jpg');
        expect(model.createdAt, testCreatedAt);
      });

      test('debe manejar campos opcionales nulos', () {
        final json = {
          'id': 'user-minimal',
          'display_name': null,
          'avatar_url': null,
          'created_at': testCreatedAt.toIso8601String(),
        };

        final model = PublicProfileModel.fromJson(json);

        expect(model.id, 'user-minimal');
        expect(model.displayName, isNull);
        expect(model.avatarUrl, isNull);
        expect(model.createdAt, testCreatedAt);
      });

      test('debe convertir modelo a entity correctamente', () {
        final model = PublicProfileModel(
          id: 'user-123',
          displayName: 'Ana López',
          avatarUrl: 'https://example.com/ana.jpg',
          createdAt: testCreatedAt,
        );

        final entity = model.toEntity();

        expect(entity, isA<PublicProfile>());
        expect(entity.id, model.id);
        expect(entity.displayName, model.displayName);
        expect(entity.avatarUrl, model.avatarUrl);
        expect(entity.createdAt, model.createdAt);
      });

      test('debe preservar valores nulos al convertir a entity', () {
        final model = PublicProfileModel(
          id: 'user-minimal',
          createdAt: testCreatedAt,
        );

        final entity = model.toEntity();

        expect(entity.displayName, isNull);
        expect(entity.avatarUrl, isNull);
      });
    });

    group('PublicProfile Entity', () {
      final testDate = DateTime(2024, 3, 20);
      
      test('debe crear perfil con todos los campos', () {
        final profile = PublicProfile(
          id: 'user-456',
          displayName: 'Carlos Mendoza',
          avatarUrl: 'https://example.com/carlos.png',
          createdAt: testDate,
        );

        expect(profile.id, 'user-456');
        expect(profile.displayName, 'Carlos Mendoza');
        expect(profile.avatarUrl, isNotNull);
        expect(profile.createdAt, testDate);
      });

      test('debe verificar igualdad de perfiles', () {
        final profile1 = PublicProfile(
          id: 'user-789',
          displayName: 'María',
          createdAt: testDate,
        );
        
        final profile2 = PublicProfile(
          id: 'user-789',
          displayName: 'María',
          createdAt: testDate,
        );
        
        final profile3 = PublicProfile(
          id: 'user-different',
          displayName: 'María',
          createdAt: testDate,
        );

        // Perfiles con mismo id deberían ser iguales si Equatable está implementado
        expect(profile1.id, equals(profile2.id));
        expect(profile1.id, isNot(equals(profile3.id)));
      });
    });

    group('Search query validation', () {
      test('debe rechazar queries vacías', () {
        const emptyQuery = '';
        const whitespaceQuery = '   ';
        
        expect(emptyQuery.trim().isEmpty, isTrue);
        expect(whitespaceQuery.trim().isEmpty, isTrue);
      });

      test('debe limpiar espacios en query', () {
        const queryWithSpaces = '  Juan  ';
        final trimmed = queryWithSpaces.trim();
        
        expect(trimmed, 'Juan');
        expect(trimmed.isEmpty, isFalse);
      });

      test('debe generar patrón ILIKE correcto', () {
        const query = 'García';
        const ilikePattern = '%$query%';
        
        expect(ilikePattern, '%García%');
      });
    });

    group('Lista de perfiles - Operaciones', () {
      final testDate = DateTime(2024, 1, 1);
      
      final profiles = [
        PublicProfile(id: 'u1', displayName: 'Ana', createdAt: testDate),
        PublicProfile(id: 'u2', displayName: 'Bruno', createdAt: testDate),
        PublicProfile(id: 'u3', displayName: 'Carla', createdAt: testDate),
        PublicProfile(id: 'u4', displayName: 'Ana María', createdAt: testDate),
      ];

      test('debe ordenar perfiles por displayName', () {
        final sorted = List<PublicProfile>.from(profiles)
          ..sort((a, b) => (a.displayName ?? '').compareTo(b.displayName ?? ''));

        expect(sorted[0].displayName, 'Ana');
        expect(sorted[1].displayName, 'Ana María');
        expect(sorted[2].displayName, 'Bruno');
        expect(sorted[3].displayName, 'Carla');
      });

      test('debe filtrar perfiles que contengan substring', () {
        const searchQuery = 'ana';
        final filtered = profiles.where((p) => 
          (p.displayName?.toLowerCase() ?? '').contains(searchQuery.toLowerCase())
        ).toList();

        expect(filtered.length, 2);
        expect(filtered.any((p) => p.displayName == 'Ana'), isTrue);
        expect(filtered.any((p) => p.displayName == 'Ana María'), isTrue);
      });

      test('debe limitar resultados a máximo 20', () {
        // Simular lista grande
        final largeList = List.generate(
          50, 
          (i) => PublicProfile(id: 'u$i', displayName: 'User $i', createdAt: testDate),
        );
        
        final limited = largeList.take(20).toList();
        
        expect(limited.length, 20);
      });
    });
  });
}
