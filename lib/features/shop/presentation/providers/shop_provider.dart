import 'package:flutter/foundation.dart';
import 'package:biux/features/shop/domain/entities/product_entity.dart';
import 'package:biux/features/shop/domain/entities/category_entity.dart';
import 'package:biux/features/shop/domain/entities/cart_item_entity.dart';
import 'package:biux/features/shop/domain/entities/order_entity.dart';
import 'package:biux/features/shop/domain/repositories/product_repository.dart';
import 'package:biux/features/shop/domain/repositories/order_repository.dart';

/// Datos de un cupón de descuento
class CouponData {
  final double discount; // Porcentaje de descuento (0.0 - 1.0)
  final String description;
  final double? minPurchase; // Compra mínima requerida (opcional)

  const CouponData({
    required this.discount,
    required this.description,
    this.minPurchase,
  });
}

/// Provider para gestionar el estado de la tienda
class ShopProvider with ChangeNotifier {
  final ProductRepository productRepository;
  final OrderRepository orderRepository;

  ShopProvider({
    required this.productRepository,
    required this.orderRepository,
  });

  // Estado de productos
  List<ProductEntity> _allProducts = [];
  List<ProductEntity> _filteredProducts = [];
  bool _isLoadingProducts = false;
  String? _errorMessage;

  // Estado de filtros
  String _selectedCategory = ProductCategories.all;
  String _searchQuery = '';

  // Estado del carrito
  List<CartItemEntity> _cartItems = [];

  // Estado de cupones
  String? _appliedCoupon;
  double _couponDiscount = 0.0;
  String? _couponErrorMessage;

  // Estado de órdenes
  List<OrderEntity> _userOrders = [];
  bool _isLoadingOrders = false;

  // Getters
  List<ProductEntity> get products => _filteredProducts;
  bool get isLoadingProducts => _isLoadingProducts;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  List<CartItemEntity> get cartItems => _cartItems;
  int get cartItemCount =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get cartTotal =>
      _cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  List<OrderEntity> get userOrders => _userOrders;
  bool get isLoadingOrders => _isLoadingOrders;
  bool get hasItemsInCart => _cartItems.isNotEmpty;

  // Getters de cupones
  String? get appliedCoupon => _appliedCoupon;
  double get couponDiscount => _couponDiscount;
  String? get couponErrorMessage => _couponErrorMessage;
  double get cartTotalWithDiscount => cartTotal - _couponDiscount;

  /// Cargar todos los productos
  Future<void> loadProducts() async {
    _isLoadingProducts = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allProducts = await productRepository.getProducts();
      _applyFilters();
      _isLoadingProducts = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar productos: $e';
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  /// Filtrar por categoría
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  /// Buscar productos
  void searchProducts(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Aplicar todos los filtros
  void _applyFilters() {
    _filteredProducts = _allProducts.where((product) {
      // Filtro por categoría
      final matchesCategory =
          _selectedCategory == ProductCategories.all ||
          product.category == _selectedCategory;

      // Filtro por búsqueda
      final matchesSearch =
          _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      return matchesCategory && matchesSearch;
    }).toList();
  }

  /// Limpiar filtros
  void clearFilters() {
    _selectedCategory = ProductCategories.all;
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  /// Agregar producto al carrito
  void addToCart(ProductEntity product, {String? selectedSize}) {
    print('🛒 ShopProvider.addToCart llamado:');
    print('  - Producto: ${product.name} (ID: ${product.id})');
    print('  - Talla: $selectedSize');
    print('  - Carrito actual: ${_cartItems.length} items');

    // Verificar si el producto ya está en el carrito
    final existingIndex = _cartItems.indexWhere(
      (item) =>
          item.product.id == product.id && item.selectedSize == selectedSize,
    );

    if (existingIndex >= 0) {
      // Incrementar cantidad
      print('  ✓ Producto ya existe en carrito, incrementando cantidad');
      final existing = _cartItems[existingIndex];
      _cartItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity + 1,
      );
      print('  - Nueva cantidad: ${_cartItems[existingIndex].quantity}');
    } else {
      // Agregar nuevo item
      print('  ✓ Agregando nuevo producto al carrito');
      _cartItems.add(
        CartItemEntity(
          product: product,
          quantity: 1,
          selectedSize: selectedSize,
        ),
      );
    }

    print('  - Carrito actualizado: ${_cartItems.length} items');
    print('  - Total items: $cartItemCount');
    print('  - Total precio: \$$cartTotal');
    notifyListeners();
    print('  ✅ notifyListeners() llamado');
  }

  /// Remover producto del carrito
  void removeFromCart(String productId, {String? selectedSize}) {
    _cartItems.removeWhere(
      (item) =>
          item.product.id == productId && item.selectedSize == selectedSize,
    );
    notifyListeners();
  }

  /// Actualizar cantidad de un item en el carrito
  void updateCartItemQuantity(
    String productId,
    int newQuantity, {
    String? selectedSize,
  }) {
    if (newQuantity <= 0) {
      removeFromCart(productId, selectedSize: selectedSize);
      return;
    }

    final index = _cartItems.indexWhere(
      (item) =>
          item.product.id == productId && item.selectedSize == selectedSize,
    );

    if (index >= 0) {
      _cartItems[index] = _cartItems[index].copyWith(quantity: newQuantity);
      notifyListeners();
    }
  }

  /// Limpiar carrito
  void clearCart() {
    _cartItems.clear();
    _appliedCoupon = null;
    _couponDiscount = 0.0;
    _couponErrorMessage = null;
    notifyListeners();
  }

  /// Aplicar cupón de descuento (solo para compras)
  bool applyCoupon(String couponCode) {
    _couponErrorMessage = null;

    // Validar que hay items en el carrito
    if (_cartItems.isEmpty) {
      _couponErrorMessage = 'Agrega productos al carrito primero';
      notifyListeners();
      return false;
    }

    // Validar compra mínima
    const double minimumPurchase = 50000; // Compra mínima 50.000 COP
    if (cartTotal < minimumPurchase) {
      _couponErrorMessage =
          'Compra mínima: \$${minimumPurchase.toStringAsFixed(0)} COP';
      notifyListeners();
      return false;
    }

    // Cupones organizados por categoría
    final Map<String, CouponData> validCoupons = {
      // Cupones generales
      'BIUX10': CouponData(
        discount: 0.10,
        description: 'Descuento general 10%',
      ),
      'BIUX15': CouponData(
        discount: 0.15,
        description: 'Descuento general 15%',
      ),
      'BIUX20': CouponData(
        discount: 0.20,
        description: 'Descuento general 20%',
      ),

      // Cupones especiales
      'PRIMERACOMPRA': CouponData(
        discount: 0.15,
        description: 'Primera compra 15%',
      ),
      'CICLISTA': CouponData(discount: 0.12, description: 'Ciclistas 12%'),
      'NUEVOCLIENTE': CouponData(
        discount: 0.18,
        description: 'Nuevo cliente 18%',
      ),

      // Cupones estacionales
      'VERANO2026': CouponData(
        discount: 0.25,
        description: 'Verano 2026 - 25%',
      ),
      'ENERO2026': CouponData(discount: 0.20, description: 'Enero 2026 - 20%'),

      // Cupones VIP
      'VIP30': CouponData(
        discount: 0.30,
        description: 'Cliente VIP 30%',
        minPurchase: 200000,
      ),
      'ELITE40': CouponData(
        discount: 0.40,
        description: 'Elite 40%',
        minPurchase: 500000,
      ),
    };

    final couponData = validCoupons[couponCode.toUpperCase()];

    if (couponData == null) {
      _couponErrorMessage = 'Cupón inválido o expirado';
      notifyListeners();
      return false;
    }

    // Validar compra mínima específica del cupón
    if (couponData.minPurchase != null && cartTotal < couponData.minPurchase!) {
      _couponErrorMessage =
          'Compra mínima para este cupón: \$${couponData.minPurchase!.toStringAsFixed(0)} COP';
      notifyListeners();
      return false;
    }

    // Calcular descuento
    _couponDiscount = cartTotal * couponData.discount;
    _appliedCoupon = couponCode.toUpperCase();

    print('🎟️ Cupón aplicado: $_appliedCoupon (${couponData.description})');
    print(
      '💰 Descuento: \$${_couponDiscount.toStringAsFixed(0)} COP (${(couponData.discount * 100).toStringAsFixed(0)}%)',
    );
    print(
      '💵 Total con descuento: \$${cartTotalWithDiscount.toStringAsFixed(0)} COP',
    );

    notifyListeners();
    return true;
  }

  /// Obtener lista de cupones disponibles organizados
  List<Map<String, dynamic>> getAvailableCoupons() {
    return [
      {
        'category': 'Generales',
        'coupons': [
          {
            'code': 'BIUX10',
            'discount': '10%',
            'description': 'Descuento general',
          },
          {
            'code': 'BIUX15',
            'discount': '15%',
            'description': 'Descuento general',
          },
          {
            'code': 'BIUX20',
            'discount': '20%',
            'description': 'Descuento general',
          },
        ],
      },
      {
        'category': 'Especiales',
        'coupons': [
          {
            'code': 'PRIMERACOMPRA',
            'discount': '15%',
            'description': 'Primera compra',
          },
          {
            'code': 'CICLISTA',
            'discount': '12%',
            'description': 'Para ciclistas',
          },
          {
            'code': 'NUEVOCLIENTE',
            'discount': '18%',
            'description': 'Nuevo cliente',
          },
        ],
      },
      {
        'category': 'Temporada',
        'coupons': [
          {
            'code': 'VERANO2026',
            'discount': '25%',
            'description': 'Promoción verano',
          },
          {
            'code': 'ENERO2026',
            'discount': '20%',
            'description': 'Promoción enero',
          },
        ],
      },
      {
        'category': 'VIP',
        'coupons': [
          {
            'code': 'VIP30',
            'discount': '30%',
            'description': 'Compra mínima \$200.000',
          },
          {
            'code': 'ELITE40',
            'discount': '40%',
            'description': 'Compra mínima \$500.000',
          },
        ],
      },
    ];
  }

  /// Remover cupón aplicado
  void removeCoupon() {
    _appliedCoupon = null;
    _couponDiscount = 0.0;
    _couponErrorMessage = null;
    notifyListeners();
  }

  /// Crear orden desde el carrito
  Future<String?> createOrderFromCart({
    required String userId,
    required String userName,
    String? deliveryAddress,
    String? phoneNumber,
    String? notes,
  }) async {
    if (_cartItems.isEmpty) {
      _errorMessage = 'El carrito está vacío';
      notifyListeners();
      return null;
    }

    try {
      // Calcular total final (con descuento de cupón si aplica)
      final finalTotal = cartTotalWithDiscount;

      // Agregar info del cupón a las notas si se aplicó uno
      String finalNotes = notes ?? '';
      if (_appliedCoupon != null) {
        final couponInfo =
            '\n🎟️ Cupón aplicado: $_appliedCoupon (Descuento: \$${_couponDiscount.toStringAsFixed(0)} COP)';
        finalNotes = finalNotes.isEmpty ? couponInfo : '$finalNotes$couponInfo';
      }

      final order = OrderEntity(
        id: '', // Firebase genera el ID
        userId: userId,
        userName: userName,
        items: List.from(_cartItems),
        total: finalTotal,
        status: OrderStatus.pending,
        deliveryAddress: deliveryAddress,
        phoneNumber: phoneNumber,
        notes: finalNotes,
        createdAt: DateTime.now(),
      );

      final orderId = await orderRepository.createOrder(order);

      // Actualizar stock de productos
      for (final item in _cartItems) {
        final newStock = item.product.stock - item.quantity;
        await productRepository.updateStock(item.product.id, newStock);
      }

      // Limpiar carrito (y cupón)
      clearCart();

      // Recargar productos para actualizar stock
      await loadProducts();

      return orderId;
    } catch (e) {
      _errorMessage = 'Error al crear orden: $e';
      notifyListeners();
      return null;
    }
  }

  /// Comprar ahora (compra directa sin pasar por el carrito)
  /// Crea una orden inmediata con un solo producto
  Future<String?> buyNow({
    required String userId,
    required String userName,
    required ProductEntity product,
    required int quantity,
    String? selectedSize,
    required String deliveryAddress,
    required String phoneNumber,
    String? notes,
  }) async {
    try {
      // Validar stock
      if (product.stock < quantity) {
        _errorMessage = 'Stock insuficiente';
        notifyListeners();
        return null;
      }

      // Validar talla si es necesaria
      if (product.sizes.isNotEmpty && selectedSize == null) {
        _errorMessage = 'Debes seleccionar una talla';
        notifyListeners();
        return null;
      }

      // Crear item temporal
      final cartItem = CartItemEntity(
        product: product,
        quantity: quantity,
        selectedSize: selectedSize,
      );

      // Crear orden
      final order = OrderEntity(
        id: '',
        userId: userId,
        userName: userName,
        items: [cartItem],
        total: cartItem.subtotal,
        status: OrderStatus.pending,
        deliveryAddress: deliveryAddress,
        phoneNumber: phoneNumber,
        notes: notes,
        createdAt: DateTime.now(),
      );

      final orderId = await orderRepository.createOrder(order);

      // Actualizar stock del producto
      final newStock = product.stock - quantity;
      await productRepository.updateStock(product.id, newStock);

      // Recargar productos para actualizar stock
      await loadProducts();

      return orderId;
    } catch (e) {
      _errorMessage = 'Error al realizar compra: $e';
      notifyListeners();
      return null;
    }
  }

  /// Cargar órdenes del usuario
  Future<void> loadUserOrders(String userId) async {
    _isLoadingOrders = true;
    notifyListeners();

    try {
      _userOrders = await orderRepository.getUserOrders(userId);
      _isLoadingOrders = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar órdenes: $e';
      _isLoadingOrders = false;
      notifyListeners();
    }
  }

  /// Cancelar orden
  Future<bool> cancelOrder(String orderId) async {
    try {
      await orderRepository.cancelOrder(orderId);

      // Actualizar lista de órdenes
      final index = _userOrders.indexWhere((order) => order.id == orderId);
      if (index >= 0) {
        _userOrders[index] = _userOrders[index].copyWith(
          status: OrderStatus.cancelled,
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _errorMessage = 'Error al cancelar orden: $e';
      notifyListeners();
      return false;
    }
  }

  /// Crear producto (solo admins y vendedores autorizados)
  Future<bool> createProduct(
    ProductEntity product, {
    required bool canCreateProducts,
  }) async {
    if (!canCreateProducts) {
      _errorMessage =
          'No tienes permiso para crear productos. Contacta a un administrador.';
      notifyListeners();
      return false;
    }

    try {
      await productRepository.createProduct(product);
      await loadProducts(); // Recargar productos
      return true;
    } catch (e) {
      _errorMessage = 'Error al crear producto: $e';
      notifyListeners();
      return false;
    }
  }

  /// Actualizar producto (solo admins)
  Future<bool> updateProduct(ProductEntity product) async {
    try {
      await productRepository.updateProduct(product);
      await loadProducts(); // Recargar productos
      return true;
    } catch (e) {
      _errorMessage = 'Error al actualizar producto: $e';
      notifyListeners();
      return false;
    }
  }

  /// Eliminar producto (solo admins)
  Future<bool> deleteProduct(String productId) async {
    try {
      await productRepository.deleteProduct(productId);
      await loadProducts(); // Recargar productos
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar producto: $e';
      notifyListeners();
      return false;
    }
  }

  /// Eliminar TODOS los productos sin imágenes (función de limpieza)
  Future<int> deleteProductsWithoutImages() async {
    int deletedCount = 0;

    try {
      // Recargar productos para tener la lista más actualizada
      await loadProducts();

      // Encontrar productos sin imágenes válidas
      final productsToDelete = _allProducts.where((product) {
        if (product.images.isEmpty) return true;
        return !product.images.any(
          (img) => img.isNotEmpty && img.trim().isNotEmpty,
        );
      }).toList();

      print(
        '🗑️ Productos sin imágenes encontrados: ${productsToDelete.length}',
      );

      // Eliminar cada producto sin imagen
      for (final product in productsToDelete) {
        try {
          print(
            '🗑️ Eliminando producto sin imagen: ${product.name} (${product.id})',
          );
          await productRepository.deleteProduct(product.id);
          deletedCount++;
        } catch (e) {
          print('❌ Error eliminando ${product.name}: $e');
        }
      }

      // Recargar productos después de la limpieza
      await loadProducts();

      print('✅ Productos eliminados: $deletedCount');
      return deletedCount;
    } catch (e) {
      _errorMessage = 'Error en limpieza de productos: $e';
      notifyListeners();
      return deletedCount;
    }
  }

  /// Dar like/unlike a un producto (operación atómica en Firestore)
  Future<bool> toggleProductLike(String productId, String userId) async {
    try {
      final productIndex = _allProducts.indexWhere((p) => p.id == productId);
      if (productIndex == -1) return false;

      final product = _allProducts[productIndex];
      final likedByUsers = List<String>.from(product.likedByUsers);

      // Actualizar localmente PRIMERO (respuesta instantánea)
      if (likedByUsers.contains(userId)) {
        likedByUsers.remove(userId);
      } else {
        likedByUsers.add(userId);
      }

      final updatedProduct = product.copyWith(likedByUsers: likedByUsers);
      _allProducts[productIndex] = updatedProduct;
      _applyFilters();
      notifyListeners();

      // Luego guardar en Firestore con operación atómica
      await productRepository.toggleProductLike(productId, userId);

      return true;
    } catch (e) {
      // Revertir cambio local si falla Firestore
      await loadProducts();
      _errorMessage = 'Error al dar me gusta: \$e';
      notifyListeners();
      return false;
    }
  }

  /// Marcar producto como vendido (solo el vendedor)
  Future<bool> markProductAsSold(String productId, String userId) async {
    try {
      final productIndex = _allProducts.indexWhere((p) => p.id == productId);
      if (productIndex == -1) return false;

      final product = _allProducts[productIndex];

      // Solo el vendedor puede marcar como vendido
      if (product.sellerId != userId) {
        _errorMessage =
            'Solo el vendedor puede marcar el producto como vendido';
        notifyListeners();
        return false;
      }

      final updatedProduct = product.copyWith(isSold: true, stock: 0);
      await productRepository.updateProduct(updatedProduct);

      // Actualizar localmente
      _allProducts[productIndex] = updatedProduct;
      _applyFilters();
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Error al marcar como vendido: $e';
      notifyListeners();
      return false;
    }
  }

  /// Limpiar mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
