/// Entidad de Categoría de productos de ciclismo
class CategoryEntity {
  final String id;
  final String name;
  final String icon;
  final int productCount;

  CategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    this.productCount = 0,
  });

  CategoryEntity copyWith({
    String? id,
    String? name,
    String? icon,
    int? productCount,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      productCount: productCount ?? this.productCount,
    );
  }
}

/// Categorías predefinidas para productos de ciclismo
class ProductCategories {
  static const String jerseys = 'jerseys';
  static const String shorts = 'shorts';
  static const String helmets = 'cascos';
  static const String glasses = 'gafas';
  static const String gloves = 'guantes';
  static const String shoes = 'zapatos';
  static const String accessories = 'accesorios';
  static const String all = 'todos';

  static List<CategoryEntity> getAll() {
    return [
      CategoryEntity(
        id: all,
        name: 'Todos',
        icon: '🛍️',
      ),
      CategoryEntity(
        id: jerseys,
        name: 'Jerseys',
        icon: '👕',
      ),
      CategoryEntity(
        id: shorts,
        name: 'Shorts',
        icon: '🩳',
      ),
      CategoryEntity(
        id: helmets,
        name: 'Cascos',
        icon: '🪖',
      ),
      CategoryEntity(
        id: glasses,
        name: 'Gafas',
        icon: '🕶️',
      ),
      CategoryEntity(
        id: gloves,
        name: 'Guantes',
        icon: '🧤',
      ),
      CategoryEntity(
        id: shoes,
        name: 'Zapatos',
        icon: '👟',
      ),
      CategoryEntity(
        id: accessories,
        name: 'Accesorios',
        icon: '🎒',
      ),
    ];
  }

  static String getCategoryName(String categoryId) {
    final category = getAll().firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => CategoryEntity(id: '', name: 'Desconocido', icon: ''),
    );
    return category.name;
  }
}
