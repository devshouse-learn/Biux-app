import 'package:biux/features/store/domain/entities/product_entity.dart';
import 'package:biux/features/store/domain/repositories/product_repository.dart';

/// Caso de uso para crear un producto
/// Solo vendedores y administradores pueden crear productos
class CreateProductUseCase {
  final ProductRepository repository;

  CreateProductUseCase(this.repository);

  Future<void> call(ProductEntity product) async {
    // Validaciones básicas
    if (product.nombre.trim().isEmpty) {
      throw Exception('El nombre del producto es requerido');
    }

    if (product.precio <= 0) {
      throw Exception('El precio debe ser mayor a 0');
    }

    if (product.vendedorId.isEmpty) {
      throw Exception('El vendedor es requerido');
    }

    await repository.createProduct(product);
  }
}
