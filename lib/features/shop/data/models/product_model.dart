import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/features/shop/domain/entities/product_entity.dart';

/// Modelo de datos para Product con serialización JSON
class ProductModel extends ProductEntity {
  ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.images,
    required super.category,
    required super.sizes,
    required super.stock,
    required super.sellerId,
    required super.sellerName,
    required super.createdAt,
    super.isActive,
    super.metadata,
  });

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      images: entity.images,
      category: entity.category,
      sizes: entity.sizes,
      stock: entity.stock,
      sellerId: entity.sellerId,
      sellerName: entity.sellerName,
      createdAt: entity.createdAt,
      isActive: entity.isActive,
      metadata: entity.metadata,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      category: json['category'] as String? ?? '',
      sizes: (json['sizes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      sellerId: json['sellerId'] as String? ?? '',
      sellerName: json['sellerName'] as String? ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : json['createdAt'] is String
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      isActive: json['isActive'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel.fromJson({
      ...data,
      'id': doc.id,
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'images': images,
      'category': category,
      'sizes': sizes,
      'stock': stock,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
      if (metadata != null) 'metadata': metadata,
    };
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // Firebase genera el ID
    return json;
  }
}
