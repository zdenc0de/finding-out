// lib/features/events/data/models/category_model.dart
// Modelo de datos para categorías (serialización/deserialización)

import '../../domain/entities/category.dart';

/// Modelo de datos para categorías con serialización JSON.
///
/// Se usa para convertir datos de Supabase a entidades de dominio.
class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String color;
  final int displayOrder;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.displayOrder,
  });

  /// Crea un CategoryModel desde un mapa JSON (Supabase).
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      displayOrder: json['display_order'] as int,
    );
  }

  /// Convierte el modelo a JSON para enviar a Supabase.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'display_order': displayOrder,
    };
  }

  /// Convierte el modelo a una entidad de dominio.
  Category toEntity() {
    return Category(
      id: id,
      name: name,
      icon: icon,
      color: color,
      displayOrder: displayOrder,
    );
  }
}
