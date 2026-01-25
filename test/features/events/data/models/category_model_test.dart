import 'package:flutter_test/flutter_test.dart';
import 'package:finding_out/features/events/data/models/category_model.dart';
import 'package:finding_out/features/events/domain/entities/category.dart';

void main() {
  group('CategoryModel', () {
    final testJson = {
      'id': 'cat-music',
      'name': 'Música',
      'icon': 'music_note',
      'color': '#FF5733',
      'display_order': 1,
    };

    final testModel = CategoryModel(
      id: 'cat-music',
      name: 'Música',
      icon: 'music_note',
      color: '#FF5733',
      displayOrder: 1,
    );

    group('fromJson', () {
      test('debe crear un CategoryModel desde JSON', () {
        final model = CategoryModel.fromJson(testJson);

        expect(model.id, 'cat-music');
        expect(model.name, 'Música');
        expect(model.icon, 'music_note');
        expect(model.color, '#FF5733');
        expect(model.displayOrder, 1);
      });

      test('debe manejar diferentes valores de display_order', () {
        final jsonWithOrder0 = {...testJson, 'display_order': 0};
        final jsonWithOrder99 = {...testJson, 'display_order': 99};

        final model0 = CategoryModel.fromJson(jsonWithOrder0);
        final model99 = CategoryModel.fromJson(jsonWithOrder99);

        expect(model0.displayOrder, 0);
        expect(model99.displayOrder, 99);
      });
    });

    group('toJson', () {
      test('debe convertir CategoryModel a JSON', () {
        final json = testModel.toJson();

        expect(json['id'], 'cat-music');
        expect(json['name'], 'Música');
        expect(json['icon'], 'music_note');
        expect(json['color'], '#FF5733');
        expect(json['display_order'], 1);
      });

      test('debe usar snake_case para las claves JSON', () {
        final json = testModel.toJson();

        expect(json.containsKey('display_order'), isTrue);
        expect(json.containsKey('displayOrder'), isFalse);
      });
    });

    group('toEntity', () {
      test('debe convertir CategoryModel a Category entity', () {
        final entity = testModel.toEntity();

        expect(entity, isA<Category>());
        expect(entity.id, testModel.id);
        expect(entity.name, testModel.name);
        expect(entity.icon, testModel.icon);
        expect(entity.color, testModel.color);
        expect(entity.displayOrder, testModel.displayOrder);
      });
    });

    group('round-trip', () {
      test('fromJson -> toJson debe preservar los datos', () {
        final model = CategoryModel.fromJson(testJson);
        final json = model.toJson();

        expect(json['id'], testJson['id']);
        expect(json['name'], testJson['name']);
        expect(json['icon'], testJson['icon']);
        expect(json['color'], testJson['color']);
        expect(json['display_order'], testJson['display_order']);
      });
    });

    group('multiple categories', () {
      test('debe crear múltiples categorías correctamente', () {
        final categories = [
          {'id': 'cat-1', 'name': 'Música', 'icon': 'music', 'color': '#FF0000', 'display_order': 1},
          {'id': 'cat-2', 'name': 'Deportes', 'icon': 'sports', 'color': '#00FF00', 'display_order': 2},
          {'id': 'cat-3', 'name': 'Arte', 'icon': 'art', 'color': '#0000FF', 'display_order': 3},
        ];

        final models = categories.map((json) => CategoryModel.fromJson(json)).toList();

        expect(models.length, 3);
        expect(models[0].name, 'Música');
        expect(models[1].name, 'Deportes');
        expect(models[2].name, 'Arte');
      });
    });
  });
}
