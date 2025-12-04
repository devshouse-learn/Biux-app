import 'package:biux/features/shop/domain/entities/product_entity.dart';
import 'package:biux/features/shop/domain/repositories/product_repository.dart';
import 'package:biux/features/shop/data/datasources/product_remote_datasource.dart';
import 'package:biux/features/shop/data/models/product_model.dart';

/// Implementación del ProductRepository
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ProductEntity>> getProducts() async {
    return await remoteDataSource.getProducts();
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(String category) async {
    return await remoteDataSource.getProductsByCategory(category);
  }

  @override
  Future<ProductEntity?> getProductById(String id) async {
    return await remoteDataSource.getProductById(id);
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    return await remoteDataSource.searchProducts(query);
  }

  @override
  Future<String> createProduct(ProductEntity product) async {
    final productModel = ProductModel.fromEntity(product);
    return await remoteDataSource.createProduct(productModel);
  }

  @override
  Future<void> updateProduct(ProductEntity product) async {
    final productModel = ProductModel.fromEntity(product);
    await remoteDataSource.updateProduct(productModel);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await remoteDataSource.deleteProduct(id);
  }

  @override
  Future<void> updateStock(String productId, int newStock) async {
    await remoteDataSource.updateStock(productId, newStock);
  }

  @override
  Future<List<ProductEntity>> getProductsBySeller(String sellerId) async {
    return await remoteDataSource.getProductsBySeller(sellerId);
  }
}
