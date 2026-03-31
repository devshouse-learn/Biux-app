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
      // Usar solo orderBy para evitar problemas de índice compuesto
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('fechaCreacion', descending: true)
          .get();

      // Filtrar activos en memoria
      return snapshot.docs
          .map((doc) => ProductModel.fromJson({...doc.data(), 'id': doc.id}))
          .where((product) => product.activo) 
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
      // Simplificar consulta - usar solo where o orderBy por separado
      final snapshot = await _firestore
          .collection(_collection)
          .where('categoria', isEqualTo: category.name)
          .get();

      // Filtrar activos y ordenar en memoria
      final products = snapshot.docs
          .map((doc) => ProductModel.fromJson({...doc.data(), 'id': doc.id}))
          .where((product) => product.activo)
          .toList();

      // Ordenar en memoria por fechaCreacion
      products.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
      
      return products;
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
      // Simplificar consulta usando solo where destacado
      final snapshot = await _firestore
          .collection(_collection)
          .where('destacado', isEqualTo: true)
          .limit(10)
          .get();

      // Filtrar activos y ordenar en memoria
      final products = snapshot.docs
          .map((doc) => ProductModel.fromJson({...doc.data(), 'id': doc.id}))
          .where((product) => product.activo)
          .toList();

      // Ordenar en memoria por fechaCreacion
      products.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
      
      return products;
    } catch (e) {
      throw Exception('Error al obtener productos destacados: $e');
    }
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    try {
      final queryLower = query.toLowerCase();

      // Obtener todos los productos
      final snapshot = await _firestore
          .collection(_collection)
          .get();

      // Búsqueda en memoria (Firestore no soporta búsqueda de texto completa nativa)
      final filtered = snapshot.docs.where((doc) {
        final data = doc.data();
        final nombre = (data['nombre'] ?? '').toString().toLowerCase();
        final descripcion = (data['descripcion'] ?? '').toString().toLowerCase();
        final activo = data['activo'] ?? true;
        final tags = List<String>.from(
          data['tags'] ?? [],
        ).map((t) => t.toLowerCase()).toList();

        return activo && (nombre.contains(queryLower) ||
            descripcion.contains(queryLower) ||
            tags.any((tag) => tag.contains(queryLower)));
      }).map((doc) => ProductModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      // Ordenar por relevancia (coincidencias en nombre tienen prioridad)
      filtered.sort((a, b) {
        final aNameMatch = a.nombre.toLowerCase().contains(queryLower);
        final bNameMatch = b.nombre.toLowerCase().contains(queryLower);
        
        if (aNameMatch && !bNameMatch) return -1;
        if (!aNameMatch && bNameMatch) return 1;
        
        return b.fechaCreacion.compareTo(a.fechaCreacion);
      });

      return filtered;
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
