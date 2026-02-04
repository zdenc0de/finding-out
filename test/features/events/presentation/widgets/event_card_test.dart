import 'package:flutter_test/flutter_test.dart';

import 'package:finding_out/features/events/domain/entities/event.dart';
import 'package:finding_out/features/events/presentation/widgets/event_card.dart';

/// Tests unitarios para constantes y propiedades de EventCard.
/// 
/// Nota: Los tests completos de widget que requieren providers
/// son mejor probados en tests de integración.
void main() {
  group('EventCard - Unit Tests', () {
    group('Constantes', () {
      test('debe tener cardWidth de 180.0', () {
        expect(EventCard.cardWidth, equals(180.0));
      });

      test('debe tener imageHeight de 100.0', () {
        expect(EventCard.imageHeight, equals(100.0));
      });
    });

    group('Event entity validations', () {
      final testDate = DateTime(2024, 6, 15, 14, 30);
      
      test('debe validar que evento tiene campos requeridos', () {
        final event = Event(
          id: 'event-123',
          title: 'Festival de Verano',
          categoryId: 'cat-music',
          startDate: testDate,
          createdAt: testDate,
        );

        expect(event.id, isNotEmpty);
        expect(event.title, isNotEmpty);
        expect(event.categoryId, isNotEmpty);
        expect(event.startDate, equals(testDate));
      });

      test('debe manejar evento con todos los campos', () {
        final event = Event(
          id: 'event-123',
          title: 'Festival de Verano',
          description: 'El mejor festival',
          categoryId: 'cat-music',
          imageUrl: 'https://example.com/img.jpg',
          locationLat: 19.4326,
          locationLng: -99.1332,
          address: 'Parque Central',
          startDate: testDate,
          endDate: testDate.add(const Duration(hours: 4)),
          createdBy: 'user-123',
          createdAt: testDate,
        );

        expect(event.description, isNotNull);
        expect(event.imageUrl, isNotNull);
        expect(event.locationLat, isNotNull);
        expect(event.locationLng, isNotNull);
        expect(event.address, isNotNull);
        expect(event.endDate, isNotNull);
        expect(event.createdBy, isNotNull);
      });

      test('debe manejar evento mínimo para EventCard', () {
        final minimalEvent = Event(
          id: 'e1',
          title: 'Evento Mínimo',
          categoryId: 'c1',
          startDate: testDate,
          createdAt: testDate,
        );

        // Campos opcionales deben ser null
        expect(minimalEvent.description, isNull);
        expect(minimalEvent.imageUrl, isNull);
        expect(minimalEvent.address, isNull);
      });

      test('debe validar que eventos con imagen tienen URL válida', () {
        final eventWithImage = Event(
          id: 'e1',
          title: 'Con imagen',
          categoryId: 'c1',
          startDate: testDate,
          createdAt: testDate,
          imageUrl: 'https://example.com/image.jpg',
        );

        expect(eventWithImage.imageUrl, startsWith('http'));
      });
    });
  });
}
