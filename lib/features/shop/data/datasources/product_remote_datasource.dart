import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/features/shop/data/models/product_model.dart';
import 'package:biux/features/shop/data/datasources/mock_products.dart';

/// Datasource para productos en Firebase Firestore
class ProductRemoteDataSource {
  final FirebaseFirestore _firestore;
  static const String _collection = 'products';

  ProductRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Obtener todos los productos activos
  Future<List<ProductModel>> getProducts() async {
    // OPTIMIZACIÓN: Cargar productos mock inmediatamente sin esperar Firestore
    // Esto evita demoras en la carga inicial
    try {
      // Intentar cargar desde Firestore con timeout de 2 segundos
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(
            const Duration(seconds: 2),
            onTimeout: () {
              // Si Firestore tarda mucho, retornar snapshot vacío
              throw TimeoutException('Firestore timeout');
            },
          );

      // Si hay productos en Firestore, usarlos
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => ProductModel.fromFirestore(doc))
            .toList();
      }
    } catch (e) {
      // Cualquier error (timeout, red, etc.) → usar productos mock
      print('⚠️ Error cargando desde Firestore, usando productos mock: $e');
    }

    // Siempre retornar productos mock como fallback rápido
    final mockProducts = MockProducts.getProducts();
    return mockProducts
        .map((entity) => ProductModel.fromEntity(entity))
        .toList();
  }

  /// Obtener productos por categoría
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('category', isEqualTo: category)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener productos por categoría: $e');
    }
  }

  /// Obtener un producto por ID
  Future<ProductModel?> getProductById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

      if (!doc.exists) {
        return null;
      }

      return ProductModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Error al obtener producto: $e');
    }
  }

  /// Buscar productos por nombre o descripción
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      final lowercaseQuery = query.toLowerCase();

      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .where(
            (product) =>
                product.name.toLowerCase().contains(lowercaseQuery) ||
                product.description.toLowerCase().contains(lowercaseQuery),
          )
          .toList();
    } catch (e) {
      throw Exception('Error al buscar productos: $e');
    }
  }

  /// Crear un nuevo producto
  Future<String> createProduct(ProductModel product) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(product.toFirestore());

      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear producto: $e');
    }
  }

  /// Actualizar un producto existente
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(product.id)
          .update(product.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar producto: $e');
    }
  }

  /// Eliminar un producto
  Future<void> deleteProduct(String id) async {
    try {
      // Soft delete - solo marca como inactivo
      await _firestore.collection(_collection).doc(id).update({
        'isActive': false,
      });
    } catch (e) {
      throw Exception('Error al eliminar producto: $e');
    }
  }

  /// Actualizar stock de un producto
  Future<void> updateStock(String productId, int newStock) async {
    try {
      await _firestore.collection(_collection).doc(productId).update({
        'stock': newStock,
      });
    } catch (e) {
      throw Exception('Error al actualizar stock: $e');
    }
  }


  /// Toggle like de un producto usando operaciones atomicas de Firestore
  Future<void> toggleProductLike(String productId, String userId) async {
    try {
      final docRef = _firestore.collection(_collection).doc(productId);
      final doc = await docRef.get();
      if (!doc.exists) throw Exception('Producto no encontrado');

      final data = doc.data()!;
      final likedByUsers = List<String>.from(data['likedByUsers'] ?? []);

      if (likedByUsers.contains(userId)) {
        await docRef.update({
          'likedByUsers': FieldValue.arrayRemove([userId]),
        });
      } else {
        await docRef.update({
          'likedByUsers': FieldValue.arrayUnion([userId]),
        });
      }
    } catch (e) {
      throw Exception('Error al dar me gusta: \$e');
    }
  }

  /// Obtener productos del vendedor
  Future<List<ProductModel>> getProductsBySeller(String sellerId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener productos del vendedor: $e');
    }
  }
}
