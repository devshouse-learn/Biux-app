import 'package:biux/features/shop/domain/entities/product_entity.dart';

/// Repository interface para productos
abstract class ProductRepository {
  /// Obtener todos los productos activos
  Future<List<ProductEntity>> getProducts();

  /// Obtener productos por categoría
  Future<List<ProductEntity>> getProductsByCategory(String category);

  /// Obtener un producto por ID
  Future<ProductEntity?> getProductById(String id);

  /// Buscar productos por nombre o descripción
  Future<List<ProductEntity>> searchProducts(String query);

  /// Crear un nuevo producto (solo admins)
  Future<String> createProduct(ProductEntity product);

  /// Actualizar un producto existente (solo admins)
  Future<void> updateProduct(ProductEntity product);

  /// Eliminar un producto (solo admins)
  Future<void> deleteProduct(String id);

  /// Actualizar stock de un producto
  Future<void> updateStock(String productId, int newStock);

  /// Obtener productos del vendedor
  Future<List<ProductEntity>> getProductsBySeller(String sellerId);
}
