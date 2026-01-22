// lib/features/events/domain/entities/category.dart
// Entidad de dominio para categorías de eventos

/// Representa una categoría de eventos en el dominio.
///
/// Las categorías agrupan eventos por tipo (Música, Deportes, etc.)
/// y definen su apariencia visual (icono y color).
class Category {
  final String id;
  final String name;
  final String icon;
  final String color;
  final int displayOrder;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.displayOrder,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
