import 'package:biux/features/shop/domain/entities/product_entity.dart';

/// Entidad de Item del Carrito
class CartItemEntity {
  final ProductEntity product;
  final int quantity;
  final String? selectedSize;

  CartItemEntity({
    required this.product,
    required this.quantity,
    this.selectedSize,
  });

  double get subtotal => product.price * quantity;

  bool get needsSize => product.sizes.isNotEmpty && selectedSize == null;

  CartItemEntity copyWith({
    ProductEntity? product,
    int? quantity,
    String? selectedSize,
  }) {
    return CartItemEntity(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
    );
  }
}
