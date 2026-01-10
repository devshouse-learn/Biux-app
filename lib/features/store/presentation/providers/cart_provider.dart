import 'package:flutter/foundation.dart';
import 'package:biux/features/store/domain/entities/product_entity.dart';

/// Item del carrito con producto y cantidad
class CartItem {
  final ProductEntity product;
  int cantidad;

  CartItem({required this.product, this.cantidad = 1});

  double get subtotal => product.precioFinal * cantidad;
}

/// Provider para gestión del carrito de compras
class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  /// Número total de items en el carrito
  int get itemCount => _items.length;

  /// Cantidad total de productos (considerando cantidades)
  int get totalQuantity {
    return _items.values.fold(0, (sum, item) => sum + item.cantidad);
  }

  /// Total del carrito
  double get total {
    return _items.values.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  /// Verificar si el carrito está vacío
  bool get isEmpty => _items.isEmpty;

  /// Verificar si el carrito tiene productos
  bool get isNotEmpty => _items.isNotEmpty;

  /// Agregar producto al carrito
  void addItem(ProductEntity product, {int cantidad = 1}) {
    if (!product.disponible) {
      throw Exception('Producto no disponible');
    }

    if (cantidad > product.stock) {
      throw Exception('Stock insuficiente. Disponibles: ${product.stock}');
    }

    if (_items.containsKey(product.id)) {
      // Si ya existe, incrementar cantidad
      final newQuantity = _items[product.id]!.cantidad + cantidad;

      if (newQuantity > product.stock) {
        throw Exception('Stock insuficiente. Disponibles: ${product.stock}');
      }

      _items[product.id]!.cantidad = newQuantity;
    } else {
      // Si no existe, agregarlo
      _items[product.id] = CartItem(product: product, cantidad: cantidad);
    }

    notifyListeners();
  }

  /// Remover producto del carrito
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  /// Actualizar cantidad de un producto
  void updateQuantity(String productId, int newQuantity) {
    if (!_items.containsKey(productId)) {
      return;
    }

    final product = _items[productId]!.product;

    if (newQuantity <= 0) {
      removeItem(productId);
      return;
    }

    if (newQuantity > product.stock) {
      throw Exception('Stock insuficiente. Disponibles: ${product.stock}');
    }

    _items[productId]!.cantidad = newQuantity;
    notifyListeners();
  }

  /// Incrementar cantidad de un producto
  void incrementQuantity(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }

    final item = _items[productId]!;
    updateQuantity(productId, item.cantidad + 1);
  }

  /// Decrementar cantidad de un producto
  void decrementQuantity(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }

    final item = _items[productId]!;
    updateQuantity(productId, item.cantidad - 1);
  }

  /// Limpiar carrito
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /// Verificar si un producto está en el carrito
  bool containsProduct(String productId) {
    return _items.containsKey(productId);
  }

  /// Obtener cantidad de un producto en el carrito
  int getProductQuantity(String productId) {
    return _items[productId]?.cantidad ?? 0;
  }

  /// Obtener lista de productos del carrito
  List<CartItem> getCartItems() {
    return _items.values.toList();
  }

  /// Validar stock antes del checkout
  /// Retorna true si todo está OK, false si hay problemas de stock
  bool validateStock() {
    for (var item in _items.values) {
      if (item.cantidad > item.product.stock) {
        return false;
      }
      if (!item.product.disponible) {
        return false;
      }
    }
    return true;
  }

  /// Obtener productos con problemas de stock
  List<String> getStockIssues() {
    final issues = <String>[];

    for (var item in _items.values) {
      if (!item.product.disponible) {
        issues.add('${item.product.nombre} ya no está disponible');
      } else if (item.cantidad > item.product.stock) {
        issues.add(
          '${item.product.nombre}: solo quedan ${item.product.stock} unidades',
        );
      }
    }

    return issues;
  }
}
