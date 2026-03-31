import 'package:biux/features/shop/domain/entities/cart_item_entity.dart';

/// Entidad de Orden de compra
class OrderEntity {
  final String id;
  final String userId;
  final String userName;
  final List<CartItemEntity> items;
  final double total;
  final String status;
  final String? deliveryAddress;
  final String? phoneNumber;
  final String? notes;
  final DateTime createdAt;
  final DateTime? completedAt;

  OrderEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.items,
    required this.total,
    required this.status,
    this.deliveryAddress,
    this.phoneNumber,
    this.notes,
    required this.createdAt,
    this.completedAt,
  });

  bool get isPending => status == OrderStatus.pending;
  bool get isProcessing => status == OrderStatus.processing;
  bool get isCompleted => status == OrderStatus.completed;
  bool get isCancelled => status == OrderStatus.cancelled;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  OrderEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    List<CartItemEntity>? items,
    double? total,
    String? status,
    String? deliveryAddress,
    String? phoneNumber,
    String? notes,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// Estados de una orden
class OrderStatus {
  static const String pending = 'pending';
  static const String processing = 'processing';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';

  static String getDisplayName(String status) {
    switch (status) {
      case pending:
        return 'order_status_pending';
      case processing:
        return 'order_status_processing';
      case completed:
        return 'order_status_completed';
      case cancelled:
        return 'order_status_cancelled';
      default:
        return 'unknown';
    }
  }
}
