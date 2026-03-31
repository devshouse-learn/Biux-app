import 'package:biux/features/shop/domain/entities/order_entity.dart';
import 'package:biux/features/shop/domain/repositories/order_repository.dart';
import 'package:biux/features/shop/data/datasources/order_remote_datasource.dart';
import 'package:biux/features/shop/data/models/order_model.dart';

/// Implementación del OrderRepository
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> createOrder(OrderEntity order) async {
    final orderModel = OrderModel.fromEntity(order);
    return await remoteDataSource.createOrder(orderModel);
  }

  @override
  Future<List<OrderEntity>> getUserOrders(String userId) async {
    return await remoteDataSource.getUserOrders(userId);
  }

  @override
  Future<List<OrderEntity>> getAllOrders() async {
    return await remoteDataSource.getAllOrders();
  }

  @override
  Future<OrderEntity?> getOrderById(String id) async {
    return await remoteDataSource.getOrderById(id);
  }

  @override
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await remoteDataSource.updateOrderStatus(orderId, newStatus);
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await remoteDataSource.cancelOrder(orderId);
  }
}
