import 'package:flutter_test/flutter_test.dart';
import 'package:finding_out/features/events/domain/entities/category.dart';

void main() {
  group('Category', () {
    Category createCategory({String id = '1'}) {
      return Category(
        id: id,
        name: 'Música',
        icon: 'music_note',
        color: '#FF5733',
        displayOrder: 1,
      );
    }

    test('debe crear una Category con todos los campos', () {
      final category = createCategory();

      expect(category.id, '1');
      expect(category.name, 'Música');
      expect(category.icon, 'music_note');
      expect(category.color, '#FF5733');
      expect(category.displayOrder, 1);
    });

    group('equality', () {
      test('dos categorías con el mismo id deben ser iguales', () {
        final cat1 = createCategory(id: '1');
        final cat2 = createCategory(id: '1');

        expect(cat1, equals(cat2));
      });

      test('dos categorías con diferente id deben ser diferentes', () {
        final cat1 = createCategory(id: '1');
        final cat2 = createCategory(id: '2');

        expect(cat1, isNot(equals(cat2)));
      });

      test('la categoría debe ser igual a sí misma', () {
        final category = createCategory();

        expect(category, equals(category));
      });

      test('la categoría no debe ser igual a otro tipo de objeto', () {
        final category = createCategory();

        expect(category == 'not a category', isFalse);
      });
    });

    group('hashCode', () {
      test('dos categorías iguales deben tener el mismo hashCode', () {
        final cat1 = createCategory(id: '1');
        final cat2 = createCategory(id: '1');

        expect(cat1.hashCode, equals(cat2.hashCode));
      });

      test('el hashCode debe basarse en el id', () {
        final category = createCategory(id: 'test-id');

        expect(category.hashCode, equals('test-id'.hashCode));
      });
    });
  });
}
