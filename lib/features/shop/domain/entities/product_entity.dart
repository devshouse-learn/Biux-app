/// Entidad de Producto para la tienda de Biux
/// Representa un producto de ciclismo disponible para comprar
class ProductEntity {
  final String id;
  final String name;
  final String description; // Descripción corta
  final String? longDescription; // Descripción detallada
  final double price;
  final List<String> images;
  final String? videoUrl; // URL del video del producto (máx 30 seg)
  final String category;
  final List<String> sizes;
  final int stock;
  final String sellerId;
  final String sellerName;
  final String? sellerCity; // Ciudad del vendedor
  final DateTime createdAt;
  final bool isActive;
  final List<String> likedByUsers; // IDs de usuarios que dieron like
  final bool isSold; // Si el producto ya se vendió
  final Map<String, dynamic>? metadata;

  // ===== NUEVOS CAMPOS PARA INTEGRACIÓN CON RODADAS =====
  final bool isFeatured; // Si es producto destacado
  final List<String> recommendedForRides; // IDs de rodadas recomendadas
  final List<String>
  sponsoredRides; // IDs de rodadas que este producto patrocina
  final String?
  rideType; // Tipo de rodada: "montaña", "ruta", "urbano", "gravel", etc.
  final List<String> tags; // Tags para búsqueda: ["casco", "seguridad", "mtb"]
  final double? discount; // Descuento opcional (0-100)
  final DateTime? discountEndDate; // Fecha fin del descuento

  // ===== CAMPOS PARA SISTEMA DE SEGURIDAD ANTIRROBO =====
  final bool isBicycle; // Si el producto es una bicicleta completa
  final String?
  bikeFrameSerial; // Número de serie del cuadro (obligatorio si isBicycle = true)
  final String? bikeBrand; // Marca de la bicicleta
  final String? bikeModel; // Modelo de la bicicleta
  final String? bikeColor; // Color de la bicicleta
  final int? bikeYear; // Año de fabricación
  final bool
  isVerifiedNotStolen; // Si se verificó que no está reportada como robada
  final DateTime? stolenVerificationDate; // Fecha de última verificación
  final String? stolenVerificationBy; // ID del admin que verificó

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
    this.likedByUsers = const [],
    this.isSold = false,
    this.metadata,
    // Nuevos parámetros
    this.isFeatured = false,
    this.recommendedForRides = const [],
    this.sponsoredRides = const [],
    this.rideType,
    this.tags = const [],
    this.discount,
    this.discountEndDate,
    // Parámetros de seguridad antirrobo
    this.isBicycle = false,
    this.bikeFrameSerial,
    this.bikeBrand,
    this.bikeModel,
    this.bikeColor,
    this.bikeYear,
    this.isVerifiedNotStolen = false,
    this.stolenVerificationDate,
    this.stolenVerificationBy,
  });

  bool get isAvailable => isActive && stock > 0 && !isSold;

  bool get hasMultipleSizes => sizes.length > 1;

  String get mainImage => images.isNotEmpty ? images.first : '';

  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;

  String get displayDescription => longDescription ?? description;

  int get likesCount => likedByUsers.length;

  bool isLikedBy(String userId) => likedByUsers.contains(userId);

  // ===== GETTERS PARA RODADAS =====
  bool get hasDiscount =>
      discount != null &&
      discount! > 0 &&
      (discountEndDate == null || discountEndDate!.isAfter(DateTime.now()));

  double get finalPrice {
    if (hasDiscount) {
      return price * (1 - (discount! / 100));
    }
    return price;
  }

  bool get isRecommendedForRides => recommendedForRides.isNotEmpty;

  bool get sponsorsRides => sponsoredRides.isNotEmpty;

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
    List<String>? likedByUsers,
    bool? isSold,
    Map<String, dynamic>? metadata,
    bool? isFeatured,
    List<String>? recommendedForRides,
    List<String>? sponsoredRides,
    String? rideType,
    List<String>? tags,
    double? discount,
    DateTime? discountEndDate,
    // Parámetros de seguridad antirrobo
    bool? isBicycle,
    String? bikeFrameSerial,
    String? bikeBrand,
    String? bikeModel,
    String? bikeColor,
    int? bikeYear,
    bool? isVerifiedNotStolen,
    DateTime? stolenVerificationDate,
    String? stolenVerificationBy,
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
      likedByUsers: likedByUsers ?? this.likedByUsers,
      isSold: isSold ?? this.isSold,
      metadata: metadata ?? this.metadata,
      isFeatured: isFeatured ?? this.isFeatured,
      recommendedForRides: recommendedForRides ?? this.recommendedForRides,
      sponsoredRides: sponsoredRides ?? this.sponsoredRides,
      rideType: rideType ?? this.rideType,
      tags: tags ?? this.tags,
      discount: discount ?? this.discount,
      discountEndDate: discountEndDate ?? this.discountEndDate,
      // Campos de seguridad
      isBicycle: isBicycle ?? this.isBicycle,
      bikeFrameSerial: bikeFrameSerial ?? this.bikeFrameSerial,
      bikeBrand: bikeBrand ?? this.bikeBrand,
      bikeModel: bikeModel ?? this.bikeModel,
      bikeColor: bikeColor ?? this.bikeColor,
      bikeYear: bikeYear ?? this.bikeYear,
      isVerifiedNotStolen: isVerifiedNotStolen ?? this.isVerifiedNotStolen,
      stolenVerificationDate:
          stolenVerificationDate ?? this.stolenVerificationDate,
      stolenVerificationBy: stolenVerificationBy ?? this.stolenVerificationBy,
    );
  }
}
