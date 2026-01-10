import 'package:biux/features/store/domain/entities/product_entity.dart';
import 'package:biux/features/store/domain/repositories/product_repository.dart';

/// Caso de uso para actualizar un producto
/// Solo el vendedor dueño o un administrador pueden actualizar
class UpdateProductUseCase {
  final ProductRepository repository;

  UpdateProductUseCase(this.repository);

  Future<void> call(ProductEntity product) async {
    // Validaciones básicas
    if (product.nombre.trim().isEmpty) {
      throw Exception('El nombre del producto es requerido');
    }

    if (product.precio <= 0) {
      throw Exception('El precio debe ser mayor a 0');
    }

    await repository.updateProduct(product);
  }
}
