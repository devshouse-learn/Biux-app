import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/features/shop/domain/entities/order_entity.dart';
import 'package:biux/features/shop/domain/entities/cart_item_entity.dart';
import 'package:biux/features/shop/data/models/product_model.dart';

/// Modelo de datos para Order con serialización JSON
class OrderModel extends OrderEntity {
  OrderModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.items,
    required super.total,
    required super.status,
    super.deliveryAddress,
    super.phoneNumber,
    super.notes,
    required super.createdAt,
    super.completedAt,
  });

  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      userId: entity.userId,
      userName: entity.userName,
      items: entity.items,
      total: entity.total,
      status: entity.status,
      deliveryAddress: entity.deliveryAddress,
      phoneNumber: entity.phoneNumber,
      notes: entity.notes,
      createdAt: entity.createdAt,
      completedAt: entity.completedAt,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => CartItemEntity(
                    product: ProductModel.fromJson(
                        item['product'] as Map<String, dynamic>),
                    quantity: (item['quantity'] as num?)?.toInt() ?? 1,
                    selectedSize: item['selectedSize'] as String?,
                  ))
              .toList() ??
          [],
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? OrderStatus.pending,
      deliveryAddress: json['deliveryAddress'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : json['createdAt'] is String
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] is Timestamp
              ? (json['completedAt'] as Timestamp).toDate()
              : DateTime.parse(json['completedAt'] as String))
          : null,
    );
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel.fromJson({
      ...data,
      'id': doc.id,
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'items': items
          .map((item) => {
                'product': ProductModel.fromEntity(item.product).toJson(),
                'quantity': item.quantity,
                if (item.selectedSize != null) 'selectedSize': item.selectedSize,
              })
          .toList(),
      'total': total,
      'status': status,
      if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (notes != null) 'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
    };
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }
}
