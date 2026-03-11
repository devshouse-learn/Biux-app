/// Categorías de productos para ciclistas
enum ProductCategory {
  bicicletas,
  componentes,
  accesorios,
  ropa,
  nutricion,
  electronica,
  herramientas,
  proteccion,
  otros;

  String get displayName {
    switch (this) {
      case ProductCategory.bicicletas:
        return 'cat_bicycles';
      case ProductCategory.componentes:
        return 'cat_components';
      case ProductCategory.accesorios:
        return 'cat_accessories';
      case ProductCategory.ropa:
        return 'cat_clothing';
      case ProductCategory.nutricion:
        return 'cat_nutrition';
      case ProductCategory.electronica:
        return 'cat_electronics';
      case ProductCategory.herramientas:
        return 'cat_tools';
      case ProductCategory.proteccion:
        return 'cat_protection';
      case ProductCategory.otros:
        return 'cat_other';
    }
  }
}

/// Entidad de dominio para Producto
class ProductEntity {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final double? descuento; // Porcentaje de descuento (0-100)
  final ProductCategory categoria;
  final String vendedorId; // ID del vendedor que creó el producto
  final String? vendedorNombre; // Nombre del vendedor (para mostrar)
  final List<String> imagenes; // URLs de las imágenes del producto
  final int stock; // Cantidad disponible
  final bool destacado; // Si es producto destacado
  final bool activo; // Si está activo o desactivado
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;
  final List<String> tags; // Etiquetas para búsqueda y filtrado
  final Map<String, dynamic>?
  especificaciones; // Detalles técnicos del producto

  const ProductEntity({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    this.descuento,
    required this.categoria,
    required this.vendedorId,
    this.vendedorNombre,
    this.imagenes = const [],
    this.stock = 0,
    this.destacado = false,
    this.activo = true,
    required this.fechaCreacion,
    this.fechaActualizacion,
    this.tags = const [],
    this.especificaciones,
  });

  /// Precio final después de aplicar descuento
  double get precioFinal {
    if (descuento != null && descuento! > 0) {
      return precio * (1 - descuento! / 100);
    }
    return precio;
  }

  /// Si tiene descuento activo
  bool get tieneDescuento => descuento != null && descuento! > 0;

  /// Si está disponible para compra
  bool get disponible => activo && stock > 0;

  /// Imagen principal (primera de la lista)
  String? get imagenPrincipal => imagenes.isNotEmpty ? imagenes.first : null;

  /// Copiar producto con cambios
  ProductEntity copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    double? precio,
    double? descuento,
    ProductCategory? categoria,
    String? vendedorId,
    String? vendedorNombre,
    List<String>? imagenes,
    int? stock,
    bool? destacado,
    bool? activo,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    List<String>? tags,
    Map<String, dynamic>? especificaciones,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      descuento: descuento ?? this.descuento,
      categoria: categoria ?? this.categoria,
      vendedorId: vendedorId ?? this.vendedorId,
      vendedorNombre: vendedorNombre ?? this.vendedorNombre,
      imagenes: imagenes ?? this.imagenes,
      stock: stock ?? this.stock,
      destacado: destacado ?? this.destacado,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      tags: tags ?? this.tags,
      especificaciones: especificaciones ?? this.especificaciones,
    );
  }
}
