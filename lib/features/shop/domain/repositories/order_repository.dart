import 'package:biux/features/shop/domain/entities/order_entity.dart';

/// Repository interface para órdenes
abstract class OrderRepository {
  /// Crear una nueva orden
  Future<String> createOrder(OrderEntity order);

  /// Obtener órdenes del usuario
  Future<List<OrderEntity>> getUserOrders(String userId);

  /// Obtener todas las órdenes (solo admins)
  Future<List<OrderEntity>> getAllOrders();

  /// Obtener una orden por ID
  Future<OrderEntity?> getOrderById(String id);

  /// Actualizar estado de la orden
  Future<void> updateOrderStatus(String orderId, String newStatus);

  /// Cancelar orden
  Future<void> cancelOrder(String orderId);
}
