import 'package:biux/features/store/domain/entities/order_entity.dart';

/// Repositorio abstracto para gestión de pedidos
abstract class OrderRepository {
  /// Obtener todos los pedidos de un usuario
  Future<List<OrderEntity>> getUserOrders(String userId);

  /// Obtener un pedido por ID
  Future<OrderEntity?> getOrderById(String orderId);

  /// Crear un nuevo pedido
  Future<String> createOrder(OrderEntity order);

  /// Actualizar estado de un pedido
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus);

  /// Actualizar tracking de un pedido
  Future<void> updateTracking(String orderId, String trackingNumber);

  /// Cancelar un pedido
  Future<void> cancelOrder(String orderId);

  /// Obtener pedidos por estado
  Future<List<OrderEntity>> getOrdersByStatus(OrderStatus status);

  /// Obtener todos los pedidos (solo admin)
  Future<List<OrderEntity>> getAllOrders();

  /// Obtener pedidos que contienen productos de un vendedor específico
  Future<List<OrderEntity>> getOrdersWithSellerProducts(String sellerId);
}
