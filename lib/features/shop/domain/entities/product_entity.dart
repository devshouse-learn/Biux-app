/// Entidad de Producto para la tienda de Biux
/// Representa un producto de ciclismo disponible para comprar
class ProductEntity {
  final String id;
  final String name;
  final String description; // Descripción corta
  final String? longDescription; // Descripción detallada (nuevo)
  final double price;
  final List<String> images;
  final String? videoUrl; // URL del video del producto (nuevo, máx 30 seg)
  final String category;
  final List<String> sizes;
  final int stock;
  final String sellerId;
  final String sellerName;
  final String? sellerCity; // Ciudad del vendedor (nuevo)
  final DateTime createdAt;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    this.longDescription,
    required this.price,
    required this.images,
    this.videoUrl,
    required this.category,
    required this.sizes,
    required this.stock,
    required this.sellerId,
    required this.sellerName,
    this.sellerCity,
    required this.createdAt,
    this.isActive = true,
    this.metadata,
  });

  bool get isAvailable => isActive && stock > 0;

  bool get hasMultipleSizes => sizes.length > 1;

  String get mainImage => images.isNotEmpty ? images.first : '';
  
  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  
  String get displayDescription => longDescription ?? description;

  ProductEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? longDescription,
    double? price,
    List<String>? images,
    String? videoUrl,
    String? category,
    List<String>? sizes,
    int? stock,
    String? sellerId,
    String? sellerName,
    String? sellerCity,
    DateTime? createdAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      longDescription: longDescription ?? this.longDescription,
      price: price ?? this.price,
      images: images ?? this.images,
      videoUrl: videoUrl ?? this.videoUrl,
      category: category ?? this.category,
      sizes: sizes ?? this.sizes,
      stock: stock ?? this.stock,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerCity: sellerCity ?? this.sellerCity,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }
}
