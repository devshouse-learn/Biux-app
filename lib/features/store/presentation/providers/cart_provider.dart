import 'package:flutter/foundation.dart';
import 'package:biux/features/store/domain/entities/product_entity.dart';
import 'package:biux/features/store/domain/entities/coupon_entity.dart';
import 'package:biux/features/store/data/datasources/coupon_datasource.dart';

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
  final CouponDataSource _couponDataSource = CouponDataSource();
  
  CouponEntity? _appliedCoupon;
  String? _couponErrorMessage;
  String? _selectedPayment;

  Map<String, CartItem> get items => {..._items};
  CouponEntity? get appliedCoupon => _appliedCoupon;
  String? get couponErrorMessage => _couponErrorMessage;
  String? get selectedPayment => _selectedPayment;

  void setSelectedPayment(String? method) {
    _selectedPayment = method;
    notifyListeners();
  }

  /// Número total de items en el carrito
  int get itemCount => _items.length;

  /// Cantidad total de productos (considerando cantidades)
  int get totalQuantity {
    return _items.values.fold(0, (sum, item) => sum + item.cantidad);
  }

  /// Subtotal del carrito (antes de descuentos)
  double get subtotal {
    return _items.values.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  /// Descuento aplicado por el cupón
  double get couponDiscount {
    if (_appliedCoupon == null) return 0;
    return _appliedCoupon!.calculateDiscount(subtotal);
  }

  /// Total del carrito (después de descuentos)
  double get total {
    final totalBeforeDiscount = subtotal;
    final discount = couponDiscount;
    return totalBeforeDiscount - discount;
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
    _appliedCoupon = null;
    _couponErrorMessage = null;
  _selectedPayment = null;
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

  /// Aplicar cupón de descuento
  bool applyCoupon(String code) {
    _couponErrorMessage = null;

    if (code.trim().isEmpty) {
      _couponErrorMessage = 'Ingresa un código de cupón';
      notifyListeners();
      return false;
    }

    final coupon = _couponDataSource.getCouponByCode(code);

    if (coupon == null) {
      _couponErrorMessage = 'Cupón no válido';
      notifyListeners();
      return false;
    }

    if (!coupon.isValid) {
      _couponErrorMessage = 'Cupón expirado o inactivo';
      notifyListeners();
      return false;
    }

    if (coupon.minPurchase != null && subtotal < coupon.minPurchase!) {
      _couponErrorMessage =
          'Compra mínima de \$${coupon.minPurchase!.toStringAsFixed(0)} COP';
      notifyListeners();
      return false;
    }

    _appliedCoupon = coupon;
    notifyListeners();
    return true;
  }

  /// Remover cupón aplicado
  void removeCoupon() {
    _appliedCoupon = null;
    _couponErrorMessage = null;
    notifyListeners();
  }

  /// Limpiar mensaje de error del cupón
  void clearCouponError() {
    _couponErrorMessage = null;
    notifyListeners();
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
