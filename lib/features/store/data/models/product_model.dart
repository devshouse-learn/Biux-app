import 'package:biux/features/store/domain/entities/product_entity.dart';

/// Modelo de datos para Producto (implementación de ProductEntity)
/// Incluye métodos para convertir de/hacia JSON y Firestore
class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.nombre,
    required super.descripcion,
    required super.precio,
    super.descuento,
    required super.categoria,
    required super.vendedorId,
    super.vendedorNombre,
    super.imagenes,
    super.stock,
    super.destacado,
    super.activo,
    required super.fechaCreacion,
    super.fechaActualizacion,
    super.tags,
    super.especificaciones,
  });

  /// Crear ProductModel desde JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precio: (json['precio'] ?? 0).toDouble(),
      descuento: json['descuento']?.toDouble(),
      categoria: ProductCategory.values.firstWhere(
        (e) => e.name == json['categoria'],
        orElse: () => ProductCategory.otros,
      ),
      vendedorId: json['vendedorId'] ?? '',
      vendedorNombre: json['vendedorNombre'],
      imagenes: json['imagenes'] != null
          ? List<String>.from(json['imagenes'])
          : [],
      stock: json['stock'] ?? 0,
      destacado: json['destacado'] ?? false,
      activo: json['activo'] ?? true,
      fechaCreacion: json['fechaCreacion'] != null
          ? DateTime.parse(json['fechaCreacion'])
          : DateTime.now(),
      fechaActualizacion: json['fechaActualizacion'] != null
          ? DateTime.parse(json['fechaActualizacion'])
          : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      especificaciones: json['especificaciones'],
    );
  }

  /// Convertir ProductModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'descuento': descuento,
      'categoria': categoria.name,
      'vendedorId': vendedorId,
      'vendedorNombre': vendedorNombre,
      'imagenes': imagenes,
      'stock': stock,
      'destacado': destacado,
      'activo': activo,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaActualizacion': fechaActualizacion?.toIso8601String(),
      'tags': tags,
      'especificaciones': especificaciones,
    };
  }

  /// Crear ProductModel desde ProductEntity
  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      nombre: entity.nombre,
      descripcion: entity.descripcion,
      precio: entity.precio,
      descuento: entity.descuento,
      categoria: entity.categoria,
      vendedorId: entity.vendedorId,
      vendedorNombre: entity.vendedorNombre,
      imagenes: entity.imagenes,
      stock: entity.stock,
      destacado: entity.destacado,
      activo: entity.activo,
      fechaCreacion: entity.fechaCreacion,
      fechaActualizacion: entity.fechaActualizacion,
      tags: entity.tags,
      especificaciones: entity.especificaciones,
    );
  }
}
