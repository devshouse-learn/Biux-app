import 'package:biux/features/store/domain/repositories/product_repository.dart';

/// Caso de uso para eliminar un producto
/// Solo el vendedor dueño o un administrador pueden eliminar
class DeleteProductUseCase {
  final ProductRepository repository;

  DeleteProductUseCase(this.repository);

  Future<void> call(String productId) async {
    if (productId.isEmpty) {
      throw Exception('ID de producto inválido');
    }

    await repository.deleteProduct(productId);
  }
}
