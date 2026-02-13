import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/features/shop/domain/entities/product_entity.dart';

/// Modelo de datos para Product con serialización JSON
class ProductModel extends ProductEntity {
  ProductModel({
    required super.id,
    required super.name,
    required super.description,
    super.longDescription,
    required super.price,
    required super.images,
    super.videoUrl,
    required super.category,
    required super.sizes,
    required super.stock,
    required super.sellerId,
    required super.sellerName,
    super.sellerCity,
    required super.createdAt,
    super.isActive,
    super.likedByUsers,
    super.isSold,
    super.metadata,
    // Campos de seguridad antirrobo
    super.isBicycle,
    super.bikeFrameSerial,
    super.bikeBrand,
    super.bikeModel,
    super.bikeColor,
    super.bikeYear,
    super.isVerifiedNotStolen,
    super.stolenVerificationDate,
    super.stolenVerificationBy,
  });

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      longDescription: entity.longDescription,
      price: entity.price,
      images: entity.images,
      videoUrl: entity.videoUrl,
      category: entity.category,
      sizes: entity.sizes,
      stock: entity.stock,
      sellerId: entity.sellerId,
      sellerName: entity.sellerName,
      sellerCity: entity.sellerCity,
      createdAt: entity.createdAt,
      isActive: entity.isActive,
      likedByUsers: entity.likedByUsers,
      isSold: entity.isSold,
      metadata: entity.metadata,
      // Campos de seguridad antirrobo
      isBicycle: entity.isBicycle,
      bikeFrameSerial: entity.bikeFrameSerial,
      bikeBrand: entity.bikeBrand,
      bikeModel: entity.bikeModel,
      bikeColor: entity.bikeColor,
      bikeYear: entity.bikeYear,
      isVerifiedNotStolen: entity.isVerifiedNotStolen,
      stolenVerificationDate: entity.stolenVerificationDate,
      stolenVerificationBy: entity.stolenVerificationBy,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      longDescription: json['longDescription'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      videoUrl: json['videoUrl'] as String?,
      category: json['category'] as String? ?? '',
      sizes:
          (json['sizes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      sellerId: json['sellerId'] as String? ?? '',
      sellerName: json['sellerName'] as String? ?? '',
      sellerCity: json['sellerCity'] as String?,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      isActive: json['isActive'] as bool? ?? true,
      likedByUsers:
          (json['likedByUsers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isSold: json['isSold'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
      // Campos de seguridad antirrobo
      isBicycle: json['isBicycle'] as bool? ?? false,
      bikeFrameSerial: json['bikeFrameSerial'] as String?,
      bikeBrand: json['bikeBrand'] as String?,
      bikeModel: json['bikeModel'] as String?,
      bikeColor: json['bikeColor'] as String?,
      bikeYear: (json['bikeYear'] as num?)?.toInt(),
      isVerifiedNotStolen: json['isVerifiedNotStolen'] as bool? ?? false,
      stolenVerificationDate: json['stolenVerificationDate'] is Timestamp
          ? (json['stolenVerificationDate'] as Timestamp).toDate()
          : json['stolenVerificationDate'] is String
          ? DateTime.parse(json['stolenVerificationDate'] as String)
          : null,
      stolenVerificationBy: json['stolenVerificationBy'] as String?,
    );
  }

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel.fromJson({...data, 'id': doc.id});
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      if (longDescription != null) 'longDescription': longDescription,
      'price': price,
      'images': images,
      if (videoUrl != null) 'videoUrl': videoUrl,
      'category': category,
      'sizes': sizes,
      'stock': stock,
      'sellerId': sellerId,
      'sellerName': sellerName,
      if (sellerCity != null) 'sellerCity': sellerCity,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
      'likedByUsers': likedByUsers,
      'isSold': isSold,
      if (metadata != null) 'metadata': metadata,
      // Campos de seguridad antirrobo
      'isBicycle': isBicycle,
      if (bikeFrameSerial != null) 'bikeFrameSerial': bikeFrameSerial,
      if (bikeBrand != null) 'bikeBrand': bikeBrand,
      if (bikeModel != null) 'bikeModel': bikeModel,
      if (bikeColor != null) 'bikeColor': bikeColor,
      if (bikeYear != null) 'bikeYear': bikeYear,
      'isVerifiedNotStolen': isVerifiedNotStolen,
      if (stolenVerificationDate != null)
        'stolenVerificationDate': Timestamp.fromDate(stolenVerificationDate!),
      if (stolenVerificationBy != null)
        'stolenVerificationBy': stolenVerificationBy,
    };
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // Firebase genera el ID
    return json;
  }
}
