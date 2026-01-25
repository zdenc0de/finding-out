import 'package:flutter_test/flutter_test.dart';
import 'package:finding_out/features/events/data/models/event_model.dart';
import 'package:finding_out/features/events/domain/entities/event.dart';

void main() {
  group('EventModel', () {
    final testStartDate = DateTime(2024, 1, 15, 10, 0);
    final testEndDate = DateTime(2024, 1, 15, 13, 0);
    final testCreatedAt = DateTime(2024, 1, 1, 12, 0);

    final testJson = {
      'id': 'event-123',
      'title': 'Concierto de Rock',
      'description': 'Un gran concierto de rock',
      'category_id': 'cat-music',
      'image_url': 'https://example.com/image.jpg',
      'location_lat': 19.4326,
      'location_lng': -99.1332,
      'address': 'Av. Reforma 123, CDMX',
      'start_date': '2024-01-15T10:00:00.000',
      'end_date': '2024-01-15T13:00:00.000',
      'created_by': 'user-456',
      'created_at': '2024-01-01T12:00:00.000',
    };

    final testModel = EventModel(
      id: 'event-123',
      title: 'Concierto de Rock',
      description: 'Un gran concierto de rock',
      categoryId: 'cat-music',
      imageUrl: 'https://example.com/image.jpg',
      locationLat: 19.4326,
      locationLng: -99.1332,
      address: 'Av. Reforma 123, CDMX',
      startDate: testStartDate,
      endDate: testEndDate,
      createdBy: 'user-456',
      createdAt: testCreatedAt,
    );

    group('fromJson', () {
      test('debe crear un EventModel desde JSON completo', () {
        final model = EventModel.fromJson(testJson);

        expect(model.id, 'event-123');
        expect(model.title, 'Concierto de Rock');
        expect(model.description, 'Un gran concierto de rock');
        expect(model.categoryId, 'cat-music');
        expect(model.imageUrl, 'https://example.com/image.jpg');
        expect(model.locationLat, 19.4326);
        expect(model.locationLng, -99.1332);
        expect(model.address, 'Av. Reforma 123, CDMX');
        expect(model.startDate, testStartDate);
        expect(model.endDate, testEndDate);
        expect(model.createdBy, 'user-456');
        expect(model.createdAt, testCreatedAt);
      });

      test('debe manejar campos opcionales nulos', () {
        final minimalJson = {
          'id': 'event-minimal',
          'title': 'Evento Simple',
          'category_id': 'cat-other',
          'description': null,
          'image_url': null,
          'location_lat': null,
          'location_lng': null,
          'address': null,
          'start_date': '2024-01-15T10:00:00.000',
          'end_date': null,
          'created_by': null,
          'created_at': '2024-01-01T12:00:00.000',
        };

        final model = EventModel.fromJson(minimalJson);

        expect(model.description, isNull);
        expect(model.imageUrl, isNull);
        expect(model.locationLat, isNull);
        expect(model.locationLng, isNull);
        expect(model.address, isNull);
        expect(model.endDate, isNull);
        expect(model.createdBy, isNull);
      });

      test('debe manejar location_lat y location_lng como int', () {
        final jsonWithIntCoords = {
          ...testJson,
          'location_lat': 19,
          'location_lng': -99,
        };

        final model = EventModel.fromJson(jsonWithIntCoords);

        expect(model.locationLat, 19.0);
        expect(model.locationLng, -99.0);
      });
    });

    group('toJson', () {
      test('debe convertir EventModel a JSON', () {
        final json = testModel.toJson();

        expect(json['id'], 'event-123');
        expect(json['title'], 'Concierto de Rock');
        expect(json['description'], 'Un gran concierto de rock');
        expect(json['category_id'], 'cat-music');
        expect(json['image_url'], 'https://example.com/image.jpg');
        expect(json['location_lat'], 19.4326);
        expect(json['location_lng'], -99.1332);
        expect(json['address'], 'Av. Reforma 123, CDMX');
        expect(json['start_date'], testStartDate.toIso8601String());
        expect(json['end_date'], testEndDate.toIso8601String());
        expect(json['created_by'], 'user-456');
        expect(json['created_at'], testCreatedAt.toIso8601String());
      });

      test('debe manejar campos opcionales nulos en toJson', () {
        final modelWithNulls = EventModel(
          id: 'event-minimal',
          title: 'Evento Simple',
          categoryId: 'cat-other',
          startDate: testStartDate,
          createdAt: testCreatedAt,
        );

        final json = modelWithNulls.toJson();

        expect(json['description'], isNull);
        expect(json['image_url'], isNull);
        expect(json['location_lat'], isNull);
        expect(json['location_lng'], isNull);
        expect(json['address'], isNull);
        expect(json['end_date'], isNull);
        expect(json['created_by'], isNull);
      });
    });

    group('toEntity', () {
      test('debe convertir EventModel a Event entity', () {
        final entity = testModel.toEntity();

        expect(entity, isA<Event>());
        expect(entity.id, testModel.id);
        expect(entity.title, testModel.title);
        expect(entity.description, testModel.description);
        expect(entity.categoryId, testModel.categoryId);
        expect(entity.imageUrl, testModel.imageUrl);
        expect(entity.locationLat, testModel.locationLat);
        expect(entity.locationLng, testModel.locationLng);
        expect(entity.address, testModel.address);
        expect(entity.startDate, testModel.startDate);
        expect(entity.endDate, testModel.endDate);
        expect(entity.createdBy, testModel.createdBy);
        expect(entity.createdAt, testModel.createdAt);
      });

      test('debe preservar valores nulos al convertir a entity', () {
        final modelWithNulls = EventModel(
          id: 'event-minimal',
          title: 'Evento Simple',
          categoryId: 'cat-other',
          startDate: testStartDate,
          createdAt: testCreatedAt,
        );

        final entity = modelWithNulls.toEntity();

        expect(entity.description, isNull);
        expect(entity.imageUrl, isNull);
        expect(entity.locationLat, isNull);
        expect(entity.locationLng, isNull);
        expect(entity.address, isNull);
        expect(entity.endDate, isNull);
        expect(entity.createdBy, isNull);
      });
    });

    group('round-trip', () {
      test('fromJson -> toJson debe preservar los datos', () {
        final model = EventModel.fromJson(testJson);
        final json = model.toJson();

        expect(json['id'], testJson['id']);
        expect(json['title'], testJson['title']);
        expect(json['description'], testJson['description']);
        expect(json['category_id'], testJson['category_id']);
      });
    });
  });
}
