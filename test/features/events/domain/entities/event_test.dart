import 'package:flutter_test/flutter_test.dart';
import 'package:finding_out/features/events/domain/entities/event.dart';

void main() {
  group('Event', () {
    final testDate = DateTime(2024, 1, 15, 10, 0);
    final createdAt = DateTime(2024, 1, 1);

    Event createEvent({String id = '1'}) {
      return Event(
        id: id,
        title: 'Concierto de Rock',
        description: 'Un gran concierto',
        categoryId: 'cat-1',
        imageUrl: 'https://example.com/image.jpg',
        locationLat: 19.4326,
        locationLng: -99.1332,
        address: 'CDMX, México',
        startDate: testDate,
        endDate: testDate.add(const Duration(hours: 3)),
        createdBy: 'user-1',
        createdAt: createdAt,
      );
    }

    test('debe crear un Event con todos los campos requeridos', () {
      final event = createEvent();

      expect(event.id, '1');
      expect(event.title, 'Concierto de Rock');
      expect(event.description, 'Un gran concierto');
      expect(event.categoryId, 'cat-1');
      expect(event.startDate, testDate);
      expect(event.createdAt, createdAt);
    });

    test('debe crear un Event con campos opcionales nulos', () {
      final event = Event(
        id: '2',
        title: 'Evento Simple',
        categoryId: 'cat-2',
        startDate: testDate,
        createdAt: createdAt,
      );

      expect(event.description, isNull);
      expect(event.imageUrl, isNull);
      expect(event.locationLat, isNull);
      expect(event.locationLng, isNull);
      expect(event.address, isNull);
      expect(event.endDate, isNull);
      expect(event.createdBy, isNull);
    });

    group('equality', () {
      test('dos eventos con el mismo id deben ser iguales', () {
        final event1 = createEvent(id: '1');
        final event2 = createEvent(id: '1');

        expect(event1, equals(event2));
      });

      test('dos eventos con diferente id deben ser diferentes', () {
        final event1 = createEvent(id: '1');
        final event2 = createEvent(id: '2');

        expect(event1, isNot(equals(event2)));
      });

      test('el evento debe ser igual a sí mismo', () {
        final event = createEvent();

        expect(event, equals(event));
      });

      test('el evento no debe ser igual a otro tipo de objeto', () {
        final event = createEvent();

        expect(event == 'not an event', isFalse);
      });
    });

    group('hashCode', () {
      test('dos eventos iguales deben tener el mismo hashCode', () {
        final event1 = createEvent(id: '1');
        final event2 = createEvent(id: '1');

        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('el hashCode debe basarse en el id', () {
        final event = createEvent(id: 'test-id');

        expect(event.hashCode, equals('test-id'.hashCode));
      });
    });
  });
}
