import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/features/shop/data/models/product_model.dart';

/// Datasource para productos en Firebase Firestore
class ProductRemoteDataSource {
  final FirebaseFirestore _firestore;
  static const String _collection = 'products';

  ProductRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Obtener todos los productos activos
  Future<List<ProductModel>> getProducts() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener productos: $e');
    }
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
          .where((product) =>
              product.name.toLowerCase().contains(lowercaseQuery) ||
              product.description.toLowerCase().contains(lowercaseQuery))
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
