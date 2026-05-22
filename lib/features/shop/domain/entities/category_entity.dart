/// Entidad de CategorÃ­a de productos de ciclismo
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

/// CategorÃ­as predefinidas para productos de ciclismo Biux
class ProductCategories {
  // CategorÃ­as principales
  static const String all = 'todos';
  static const String jerseys = 'jerseys';
  static const String shorts = 'culotes';
  static const String helmets = 'cascos';
  static const String glasses = 'gafas';
  static const String gloves = 'guantes';
  static const String shoes = 'zapatos';
  static const String accessories = 'accesorios';

  // Nuevas categorÃ­as especÃ­ficas para ciclistas
  static const String bikes = 'bicicletas';
  static const String components = 'componentes';
  static const String nutrition = 'nutricion';
  static const String electronics = 'electronica';
  static const String maintenance = 'mantenimiento';
  static const String safety = 'seguridad';
  static const String hydration = 'hidratacion';
  static const String storage = 'almacenamiento';

  static List<CategoryEntity> getAll() {
    return [
      CategoryEntity(id: all, name: 'Todos', icon: 'ðŸ›ï¸'),
      CategoryEntity(id: bikes, name: 'Bicicletas', icon: 'ðŸš´'),
      CategoryEntity(id: jerseys, name: 'Jerseys', icon: 'ðŸ‘•'),
      CategoryEntity(id: shorts, name: 'Culotes', icon: 'ðŸ©³'),
      CategoryEntity(id: helmets, name: 'Cascos', icon: 'ðŸª–'),
      CategoryEntity(id: gloves, name: 'Guantes', icon: 'ðŸ§¤'),
      CategoryEntity(id: glasses, name: 'Gafas', icon: 'ðŸ•¶ï¸'),
      CategoryEntity(id: shoes, name: 'Calzado', icon: 'ðŸ‘Ÿ'),
      CategoryEntity(id: components, name: 'Componentes', icon: 'âš™ï¸'),
      CategoryEntity(id: electronics, name: 'ElectrÃ³nica', icon: 'ðŸ“±'),
      CategoryEntity(id: nutrition, name: 'NutriciÃ³n', icon: 'ðŸŽ'),
      CategoryEntity(id: hydration, name: 'HidrataciÃ³n', icon: 'ðŸ’§'),
      CategoryEntity(id: safety, name: 'Seguridad', icon: 'ðŸ¦º'),
      CategoryEntity(id: maintenance, name: 'Mantenimiento', icon: 'ðŸ”§'),
      CategoryEntity(id: storage, name: 'Almacenamiento', icon: 'ðŸŽ’'),
      CategoryEntity(id: accessories, name: 'Accesorios', icon: 'âœ¨'),
    ];
  }

  static List<CategoryEntity> getMainCategories() {
    // CategorÃ­as principales que se muestran en el Tab
    return [
      CategoryEntity(id: bikes, name: 'Bicicletas', icon: 'ï¿½'),
      CategoryEntity(id: jerseys, name: 'Jerseys', icon: 'ðŸ‘•'),
      CategoryEntity(id: shorts, name: 'Culotes', icon: 'ðŸ©³'),
      CategoryEntity(id: helmets, name: 'Cascos', icon: 'ðŸª–'),
      CategoryEntity(id: shoes, name: 'Calzado', icon: 'ðŸ‘Ÿ'),
      CategoryEntity(id: components, name: 'Componentes', icon: 'âš™ï¸'),
      CategoryEntity(id: accessories, name: 'MÃ¡s', icon: 'âœ¨'),
    ];
  }

  static String getCategoryName(String categoryId) {
    final category = getAll().firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => CategoryEntity(id: '', name: 'Desconocido', icon: ''),
    );
    return category.name;
  }

  static CategoryEntity? getCategoryById(String id) {
    try {
      return getAll().firstWhere((cat) => cat.id == id);
    } on Exception catch (e) {
      return null;
    }
  }
}

