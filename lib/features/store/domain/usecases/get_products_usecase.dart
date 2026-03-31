import 'package:biux/features/store/domain/entities/product_entity.dart';
import 'package:biux/features/store/domain/repositories/product_repository.dart';

/// Caso de uso para obtener todos los productos
class GetAllProductsUseCase {
  final ProductRepository repository;

  GetAllProductsUseCase(this.repository);

  Future<List<ProductEntity>> call() async {
    return await repository.getAllProducts();
  }
}

/// Caso de uso para obtener productos por categoría
class GetProductsByCategoryUseCase {
  final ProductRepository repository;

  GetProductsByCategoryUseCase(this.repository);

  Future<List<ProductEntity>> call(ProductCategory category) async {
    return await repository.getProductsByCategory(category);
  }
}

/// Caso de uso para obtener productos de un vendedor
class GetProductsBySellerUseCase {
  final ProductRepository repository;

  GetProductsBySellerUseCase(this.repository);

  Future<List<ProductEntity>> call(String sellerId) async {
    return await repository.getProductsBySeller(sellerId);
  }
}

/// Caso de uso para obtener productos destacados
class GetFeaturedProductsUseCase {
  final ProductRepository repository;

  GetFeaturedProductsUseCase(this.repository);

  Future<List<ProductEntity>> call() async {
    return await repository.getFeaturedProducts();
  }
}

/// Caso de uso para buscar productos
class SearchProductsUseCase {
  final ProductRepository repository;

  SearchProductsUseCase(this.repository);

  Future<List<ProductEntity>> call(String query) async {
    if (query.trim().isEmpty) {
      return await repository.getAllProducts();
    }
    return await repository.searchProducts(query);
  }
}
