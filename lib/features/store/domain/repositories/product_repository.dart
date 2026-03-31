import 'package:biux/features/store/domain/entities/product_entity.dart';

/// Repositorio abstracto para gestión de productos
/// Define los métodos que debe implementar cualquier fuente de datos
abstract class ProductRepository {
  /// Obtener todos los productos activos
  Future<List<ProductEntity>> getAllProducts();

  /// Obtener productos por categoría
  Future<List<ProductEntity>> getProductsByCategory(ProductCategory category);

  /// Obtener productos de un vendedor específico
  Future<List<ProductEntity>> getProductsBySeller(String sellerId);

  /// Obtener productos destacados
  Future<List<ProductEntity>> getFeaturedProducts();

  /// Buscar productos por texto
  Future<List<ProductEntity>> searchProducts(String query);

  /// Obtener un producto por ID
  Future<ProductEntity?> getProductById(String productId);

  /// Crear un nuevo producto (solo vendedores y admin)
  Future<void> createProduct(ProductEntity product);

  /// Actualizar un producto existente (solo el vendedor dueño o admin)
  Future<void> updateProduct(ProductEntity product);

  /// Eliminar un producto (solo el vendedor dueño o admin)
  Future<void> deleteProduct(String productId);

  /// Actualizar stock de un producto
  Future<void> updateStock(String productId, int newStock);

  /// Marcar/desmarcar producto como destacado (solo admin)
  Future<void> toggleFeatured(String productId, bool featured);

  /// Activar/desactivar producto
  Future<void> toggleActive(String productId, bool active);
}
