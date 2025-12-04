import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/features/shop/data/models/order_model.dart';
import 'package:biux/features/shop/domain/entities/order_entity.dart';

/// Datasource para órdenes en Firebase Firestore
class OrderRemoteDataSource {
  final FirebaseFirestore _firestore;
  static const String _collection = 'orders';

  OrderRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Crear una nueva orden
  Future<String> createOrder(OrderModel order) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(order.toFirestore());

      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear orden: $e');
    }
  }

  /// Obtener órdenes del usuario
  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener órdenes del usuario: $e');
    }
  }

  /// Obtener todas las órdenes (solo admins)
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener todas las órdenes: $e');
    }
  }

  /// Obtener una orden por ID
  Future<OrderModel?> getOrderById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

      if (!doc.exists) {
        return null;
      }

      return OrderModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Error al obtener orden: $e');
    }
  }

  /// Actualizar estado de la orden
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final Map<String, dynamic> updateData = {'status': newStatus};
      
      if (newStatus == OrderStatus.completed) {
        updateData['completedAt'] = Timestamp.now();
      }

      await _firestore
          .collection(_collection)
          .doc(orderId)
          .update(updateData);
    } catch (e) {
      throw Exception('Error al actualizar estado de orden: $e');
    }
  }

  /// Cancelar orden
  Future<void> cancelOrder(String orderId) async {
    try {
      await updateOrderStatus(orderId, OrderStatus.cancelled);
    } catch (e) {
      throw Exception('Error al cancelar orden: $e');
    }
  }
}
