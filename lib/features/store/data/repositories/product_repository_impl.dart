import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/features/store/data/models/product_model.dart';
import 'package:biux/features/store/domain/entities/product_entity.dart';
import 'package:biux/features/store/domain/repositories/product_repository.dart';

/// Implementación del repositorio de productos usando Firestore
class ProductRepositoryImpl implements ProductRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'productos';

  ProductRepositoryImpl(this._firestore);

  @override
  Future<List<ProductEntity>> getAllProducts() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('activo', isEqualTo: true)
          .orderBy('fechaCreacion', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ProductModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener productos: $e');
    }
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(
    ProductCategory category,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('activo', isEqualTo: true)
          .where('categoria', isEqualTo: category.name)
          .orderBy('fechaCreacion', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ProductModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener productos por categoría: $e');
    }
  }

  @override
  Future<List<ProductEntity>> getProductsBySeller(String sellerId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('vendedorId', isEqualTo: sellerId)
          .orderBy('fechaCreacion', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ProductModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener productos del vendedor: $e');
    }
  }

  @override
  Future<List<ProductEntity>> getFeaturedProducts() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('activo', isEqualTo: true)
          .where('destacado', isEqualTo: true)
          .orderBy('fechaCreacion', descending: true)
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => ProductModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener productos destacados: $e');
    }
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    try {
      final queryLower = query.toLowerCase();

      final snapshot = await _firestore
          .collection(_collection)
          .where('activo', isEqualTo: true)
          .get();

      // Búsqueda en memoria (Firestore no soporta búsqueda de texto completa nativa)
      final filtered = snapshot.docs.where((doc) {
        final data = doc.data();
        final nombre = (data['nombre'] ?? '').toString().toLowerCase();
        final descripcion = (data['descripcion'] ?? '')
            .toString()
            .toLowerCase();
        final tags = List<String>.from(
          data['tags'] ?? [],
        ).map((t) => t.toLowerCase()).toList();

        return nombre.contains(queryLower) ||
            descripcion.contains(queryLower) ||
            tags.any((tag) => tag.contains(queryLower));
      }).toList();

      return filtered
          .map((doc) => ProductModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Error al buscar productos: $e');
    }
  }

  @override
  Future<ProductEntity?> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(productId).get();

      if (!doc.exists) {
        return null;
      }

      return ProductModel.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      throw Exception('Error al obtener producto: $e');
    }
  }

  @override
  Future<void> createProduct(ProductEntity product) async {
    try {
      final model = ProductModel.fromEntity(product);
      final data = model.toJson();
      data.remove('id'); // Firestore genera el ID

      await _firestore.collection(_collection).add(data);
    } catch (e) {
      throw Exception('Error al crear producto: $e');
    }
  }

  @override
  Future<void> updateProduct(ProductEntity product) async {
    try {
      final model = ProductModel.fromEntity(
        product.copyWith(fechaActualizacion: DateTime.now()),
      );
      final data = model.toJson();
      data.remove('id');

      await _firestore.collection(_collection).doc(product.id).update(data);
    } catch (e) {
      throw Exception('Error al actualizar producto: $e');
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection(_collection).doc(productId).delete();
    } catch (e) {
      throw Exception('Error al eliminar producto: $e');
    }
  }

  @override
  Future<void> updateStock(String productId, int newStock) async {
    try {
      await _firestore.collection(_collection).doc(productId).update({
        'stock': newStock,
        'fechaActualizacion': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error al actualizar stock: $e');
    }
  }

  @override
  Future<void> toggleFeatured(String productId, bool featured) async {
    try {
      await _firestore.collection(_collection).doc(productId).update({
        'destacado': featured,
        'fechaActualizacion': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error al actualizar producto destacado: $e');
    }
  }

  @override
  Future<void> toggleActive(String productId, bool active) async {
    try {
      await _firestore.collection(_collection).doc(productId).update({
        'activo': active,
        'fechaActualizacion': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error al actualizar estado del producto: $e');
    }
  }
}
