/// Entidad de Producto para la tienda de Biux
/// Representa un producto de ciclismo disponible para comprar
class ProductEntity {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> images;
  final String category;
  final List<String> sizes;
  final int stock;
  final String sellerId;
  final String sellerName;
  final DateTime createdAt;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    required this.category,
    required this.sizes,
    required this.stock,
    required this.sellerId,
    required this.sellerName,
    required this.createdAt,
    this.isActive = true,
    this.metadata,
  });

  bool get isAvailable => isActive && stock > 0;

  bool get hasMultipleSizes => sizes.length > 1;

  String get mainImage => images.isNotEmpty ? images.first : '';

  ProductEntity copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    List<String>? images,
    String? category,
    List<String>? sizes,
    int? stock,
    String? sellerId,
    String? sellerName,
    DateTime? createdAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      images: images ?? this.images,
      category: category ?? this.category,
      sizes: sizes ?? this.sizes,
      stock: stock ?? this.stock,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }
}
