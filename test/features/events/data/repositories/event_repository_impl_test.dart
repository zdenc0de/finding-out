import 'package:flutter_test/flutter_test.dart';

import 'package:finding_out/features/events/data/models/category_model.dart';
import 'package:finding_out/features/events/data/models/event_model.dart';
import 'package:finding_out/features/events/domain/entities/category.dart';
import 'package:finding_out/features/events/domain/entities/event.dart';

/// Tests relacionados con la transformación de datos del repositorio.
/// 
/// Nota: Los tests del repositorio que requieren Supabase son mejor
/// probados como tests de integración con una instancia real o emulada.
/// 
/// Estos tests verifican la lógica de transformación de datos.
void main() {
  group('Event Repository - Data Transformations', () {
    group('CategoryModel transformations', () {
      test('debe convertir JSON de categoría a entity correctamente', () {
        final json = {
          'id': 'cat-music',
          'name': 'Música',
          'icon': 'music-notes',
          'color': '#FF5722',
          'display_order': 1,
        };

        final model = CategoryModel.fromJson(json);
        final entity = model.toEntity();

        expect(entity, isA<Category>());
        expect(entity.id, 'cat-music');
        expect(entity.name, 'Música');
        expect(entity.icon, 'music-notes');
        expect(entity.color, '#FF5722');
        expect(entity.displayOrder, 1);
      });

      test('debe manejar categoría con orden 0', () {
        final json = {
          'id': 'cat-first',
          'name': 'Primera',
          'icon': 'star',
          'color': '#000000',
          'display_order': 0,
        };

        final model = CategoryModel.fromJson(json);
        expect(model.displayOrder, 0);
      });
    });

    group('EventModel transformations', () {
      final testDate = DateTime(2024, 6, 15, 14, 30);
      
      test('debe convertir JSON completo de evento a entity', () {
        final json = {
          'id': 'event-123',
          'title': 'Festival de Verano',
          'description': 'El mejor festival del año',
          'category_id': 'cat-music',
          'image_url': 'https://example.com/festival.jpg',
          'location_lat': 19.4326,
          'location_lng': -99.1332,
          'address': 'Parque Central, CDMX',
          'start_date': testDate.toIso8601String(),
          'end_date': testDate.add(const Duration(hours: 6)).toIso8601String(),
          'created_by': 'user-456',
          'created_at': DateTime(2024, 1, 1).toIso8601String(),
        };

        final model = EventModel.fromJson(json);
        final entity = model.toEntity();

        expect(entity, isA<Event>());
        expect(entity.id, 'event-123');
        expect(entity.title, 'Festival de Verano');
        expect(entity.description, 'El mejor festival del año');
        expect(entity.categoryId, 'cat-music');
        expect(entity.imageUrl, 'https://example.com/festival.jpg');
        expect(entity.locationLat, 19.4326);
        expect(entity.locationLng, -99.1332);
        expect(entity.address, 'Parque Central, CDMX');
        expect(entity.startDate, testDate);
        expect(entity.createdBy, 'user-456');
      });

      test('debe manejar evento sin campos opcionales', () {
        final json = {
          'id': 'event-minimal',
          'title': 'Evento Simple',
          'category_id': 'cat-other',
          'start_date': testDate.toIso8601String(),
          'created_at': DateTime(2024, 1, 1).toIso8601String(),
          // Campos opcionales como null
          'description': null,
          'image_url': null,
          'location_lat': null,
          'location_lng': null,
          'address': null,
          'end_date': null,
          'created_by': null,
        };

        final model = EventModel.fromJson(json);
        final entity = model.toEntity();

        expect(entity.description, isNull);
        expect(entity.imageUrl, isNull);
        expect(entity.locationLat, isNull);
        expect(entity.locationLng, isNull);
        expect(entity.address, isNull);
        expect(entity.endDate, isNull);
        expect(entity.createdBy, isNull);
      });

      test('debe validar ubicación completa vs parcial', () {
        final eventWithLocation = Event(
          id: 'e1',
          title: 'Con ubicación',
          categoryId: 'c1',
          startDate: testDate,
          createdAt: testDate,
          locationLat: 19.4326,
          locationLng: -99.1332,
        );

        final eventWithoutLocation = Event(
          id: 'e2',
          title: 'Sin ubicación',
          categoryId: 'c1',
          startDate: testDate,
          createdAt: testDate,
        );

        // Con ubicación completa
        expect(eventWithLocation.locationLat, isNotNull);
        expect(eventWithLocation.locationLng, isNotNull);
        
        // Sin ubicación
        expect(eventWithoutLocation.locationLat, isNull);
        expect(eventWithoutLocation.locationLng, isNull);
      });

      test('debe detectar ubicación parcial (solo lat o solo lng)', () {
        final eventPartialLat = Event(
          id: 'e1',
          title: 'Solo lat',
          categoryId: 'c1',
          startDate: testDate,
          createdAt: testDate,
          locationLat: 19.4326,
          // locationLng es null
        );

        // Ubicación incompleta (solo tiene lat)
        expect(eventPartialLat.locationLat, isNotNull);
        expect(eventPartialLat.locationLng, isNull);
        
        // Helper para verificar ubicación completa
        bool hasCompleteLocation(Event e) => 
            e.locationLat != null && e.locationLng != null;
        
        expect(hasCompleteLocation(eventPartialLat), isFalse);
      });
    });

    group('Lista de eventos - Operaciones', () {
      final testDate = DateTime(2024, 6, 15);
      
      final events = [
        Event(id: 'e1', title: 'Evento 1', categoryId: 'cat-a', startDate: testDate, createdAt: testDate),
        Event(id: 'e2', title: 'Evento 2', categoryId: 'cat-b', startDate: testDate, createdAt: testDate),
        Event(id: 'e3', title: 'Evento 3', categoryId: 'cat-a', startDate: testDate, createdAt: testDate),
      ];

      test('debe filtrar eventos por categoría', () {
        final filtered = events.where((e) => e.categoryId == 'cat-a').toList();
        
        expect(filtered.length, 2);
        expect(filtered.every((e) => e.categoryId == 'cat-a'), isTrue);
      });

      test('debe agrupar eventos por categoría', () {
        final grouped = <String, List<Event>>{};
        for (final event in events) {
          grouped.putIfAbsent(event.categoryId, () => []).add(event);
        }

        expect(grouped.keys.length, 2);
        expect(grouped['cat-a']?.length, 2);
        expect(grouped['cat-b']?.length, 1);
      });
    });

    group('Ordenamiento de categorías', () {
      test('debe ordenar categorías por displayOrder', () {
        final categories = [
          const Category(id: 'c3', name: 'Tercera', icon: 'i', color: '#FFF', displayOrder: 3),
          const Category(id: 'c1', name: 'Primera', icon: 'i', color: '#FFF', displayOrder: 1),
          const Category(id: 'c2', name: 'Segunda', icon: 'i', color: '#FFF', displayOrder: 2),
        ];

        final sorted = List<Category>.from(categories)
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

        expect(sorted[0].name, 'Primera');
        expect(sorted[1].name, 'Segunda');
        expect(sorted[2].name, 'Tercera');
      });
    });
  });
}
