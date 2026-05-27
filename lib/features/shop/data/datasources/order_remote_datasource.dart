import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:biux/features/shop/data/models/order_model.dart';
import 'package:biux/features/shop/domain/entities/order_entity.dart';

/// Datasource para Ã³rdenes en Firebase Firestore
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
    } on FirebaseException catch (e) {
      throw Exception('Error al crear orden: $e');
    }
  }

  /// Obtener Ã³rdenes del usuario
  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw Exception('Error al obtener Ã³rdenes del usuario: $e');
    }
  }

  /// Obtener todas las Ã³rdenes (solo admins)
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw Exception('Error al obtener todas las Ã³rdenes: $e');
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
    } on FirebaseException catch (e) {
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

      await _firestore.collection(_collection).doc(orderId).update(updateData);
    } on FirebaseException catch (e) {
      throw Exception('Error al actualizar estado de orden: $e');
    }
  }

  /// Cancelar orden
  Future<void> cancelOrder(String orderId) async {
    try {
      await updateOrderStatus(orderId, OrderStatus.cancelled);
    } on FirebaseException catch (e) {
      throw Exception('Error al cancelar orden: $e');
    }
  }
}

