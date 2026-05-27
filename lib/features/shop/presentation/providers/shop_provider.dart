import 'package:flutter/foundation.dart';
import 'package:biux/features/shop/domain/entities/product_entity.dart';
import 'package:biux/features/shop/data/models/product_model.dart';
import 'package:biux/features/shop/domain/entities/category_entity.dart';
import 'package:biux/features/shop/domain/entities/cart_item_entity.dart';
import 'package:biux/features/shop/domain/entities/order_entity.dart';
import 'package:biux/features/shop/domain/repositories/product_repository.dart';
import 'package:biux/features/shop/domain/repositories/order_repository.dart';

/// Datos de un cupÃ³n de descuento
class CouponData {
  final double discount; // Porcentaje de descuento (0.0 - 1.0)
  final String description;
  final double? minPurchase; // Compra mÃ­nima requerida (opcional)

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

  // Estado de Ã³rdenes
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
    } on FirebaseException catch (e) {
      _errorMessage = 'shop_load_error';
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  /// Filtrar por categorÃ­a
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
      // Filtro por categorÃ­a
      final matchesCategory =
          _selectedCategory == ProductCategories.all ||
          product.category == _selectedCategory;

      // Filtro por bÃºsqueda
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
    debugPrint('ðŸ›’ ShopProvider.addToCart llamado:');
    debugPrint('  - Producto: ${product.name} (ID: ${product.id})');
    debugPrint('  - Talla: $selectedSize');
    debugPrint('  - Carrito actual: ${_cartItems.length} items');

    // Verificar si el producto ya estÃ¡ en el carrito
    final existingIndex = _cartItems.indexWhere(
      (item) =>
          item.product.id == product.id && item.selectedSize == selectedSize,
    );

    if (existingIndex >= 0) {
      // Incrementar cantidad
      debugPrint('  âœ“ Producto ya existe en carrito, incrementando cantidad');
      final existing = _cartItems[existingIndex];
      _cartItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity + 1,
      );
      debugPrint('  - Nueva cantidad: ${_cartItems[existingIndex].quantity}');
    } else {
      // Agregar nuevo item
      debugPrint('  âœ“ Agregando nuevo producto al carrito');
      _cartItems.add(
        CartItemEntity(
          product: product,
          quantity: 1,
          selectedSize: selectedSize,
        ),
      );
    }

    debugPrint('  - Carrito actualizado: ${_cartItems.length} items');
    debugPrint('  - Total items: $cartItemCount');
    debugPrint('  - Total precio: \$$cartTotal');
    notifyListeners();
    debugPrint('  âœ… notifyListeners() llamado');
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

  /// Aplicar cupÃ³n de descuento (solo para compras)
  bool applyCoupon(String couponCode) {
    _couponErrorMessage = null;

    // Validar que hay items en el carrito
    if (_cartItems.isEmpty) {
      _couponErrorMessage = 'shop_cart_empty_coupon';
      notifyListeners();
      return false;
    }

    // Validar compra mÃ­nima
    const double minimumPurchase = 50000; // Compra mÃ­nima 50.000 COP
    if (cartTotal < minimumPurchase) {
      _couponErrorMessage =
          'Compra mÃ­nima: \$${minimumPurchase.toStringAsFixed(0)} COP';
      notifyListeners();
      return false;
    }

    // Cupones organizados por categorÃ­a
    final Map<String, CouponData> validCoupons = {
      // Cupones generales
      'BIUX10': CouponData(
        discount: 0.10,
        description: 'shop_discount_general_10',
      ),
      'BIUX15': CouponData(
        discount: 0.15,
        description: 'shop_discount_general_15',
      ),
      'BIUX20': CouponData(
        discount: 0.20,
        description: 'shop_discount_general_20',
      ),

      // Cupones especiales
      'PRIMERACOMPRA': CouponData(
        discount: 0.15,
        description: 'shop_discount_first_purchase',
      ),
      'CICLISTA': CouponData(
        discount: 0.12,
        description: 'shop_discount_cyclists',
      ),
      'NUEVOCLIENTE': CouponData(
        discount: 0.18,
        description: 'shop_discount_new_client',
      ),

      // Cupones estacionales
      'VERANO2026': CouponData(
        discount: 0.25,
        description: 'shop_discount_summer',
      ),
      'ENERO2026': CouponData(
        discount: 0.20,
        description: 'shop_discount_january',
      ),

      // Cupones VIP
      'VIP30': CouponData(
        discount: 0.30,
        description: 'shop_discount_vip',
        minPurchase: 200000,
      ),
      'ELITE40': CouponData(
        discount: 0.40,
        description: 'shop_discount_elite',
        minPurchase: 500000,
      ),
    };

    final couponData = validCoupons[couponCode.toUpperCase()];

    if (couponData == null) {
      _couponErrorMessage = 'shop_coupon_invalid';
      notifyListeners();
      return false;
    }

    // Validar compra mÃ­nima especÃ­fica del cupÃ³n
    if (couponData.minPurchase != null && cartTotal < couponData.minPurchase!) {
      _couponErrorMessage =
          'Compra mÃ­nima para este cupÃ³n: \$${couponData.minPurchase!.toStringAsFixed(0)} COP';
      notifyListeners();
      return false;
    }

    // Calcular descuento
    _couponDiscount = cartTotal * couponData.discount;
    _appliedCoupon = couponCode.toUpperCase();

    debugPrint(
      'ðŸŽŸï¸ CupÃ³n aplicado: $_appliedCoupon (${couponData.description})',
    );
    debugPrint(
      'ðŸ’° Descuento: \$${_couponDiscount.toStringAsFixed(0)} COP (${(couponData.discount * 100).toStringAsFixed(0)}%)',
    );
    debugPrint(
      'ðŸ’µ Total con descuento: \$${cartTotalWithDiscount.toStringAsFixed(0)} COP',
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
            'description': 'PromociÃ³n verano',
          },
          {
            'code': 'ENERO2026',
            'discount': '20%',
            'description': 'PromociÃ³n enero',
          },
        ],
      },
      {
        'category': 'VIP',
        'coupons': [
          {
            'code': 'VIP30',
            'discount': '30%',
            'description': 'Compra mÃ­nima \$200.000',
          },
          {
            'code': 'ELITE40',
            'discount': '40%',
            'description': 'Compra mÃ­nima \$500.000',
          },
        ],
      },
    ];
  }

  /// Remover cupÃ³n aplicado
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
      _errorMessage = 'shop_cart_empty';
      notifyListeners();
      return null;
    }

    try {
      // Calcular total final (con descuento de cupÃ³n si aplica)
      final finalTotal = cartTotalWithDiscount;

      // Agregar info del cupÃ³n a las notas si se aplicÃ³ uno
      String finalNotes = notes ?? '';
      if (_appliedCoupon != null) {
        final couponInfo =
            '\nðŸŽŸï¸ CupÃ³n aplicado: $_appliedCoupon (Descuento: \$${_couponDiscount.toStringAsFixed(0)} COP)';
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

      // Limpiar carrito (y cupÃ³n)
      clearCart();

      // Recargar productos para actualizar stock
      await loadProducts();

      return orderId;
    } on FirebaseException catch (e) {
      _errorMessage = 'shop_order_error';
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
        _errorMessage = 'shop_stock_insufficient';
        notifyListeners();
        return null;
      }

      // Validar talla si es necesaria
      if (product.sizes.isNotEmpty && selectedSize == null) {
        _errorMessage = 'shop_size_required';
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
    } on FirebaseException catch (e) {
      _errorMessage = 'shop_purchase_error';
      notifyListeners();
      return null;
    }
  }

  /// Cargar Ã³rdenes del usuario
  Future<void> loadUserOrders(String userId) async {
    _isLoadingOrders = true;
    notifyListeners();

    try {
      _userOrders = await orderRepository.getUserOrders(userId);
      _isLoadingOrders = false;
      notifyListeners();
    } on FirebaseException catch (e) {
      _errorMessage = 'shop_orders_load_error';
      _isLoadingOrders = false;
      notifyListeners();
    }
  }

  /// Cancelar orden
  Future<bool> cancelOrder(String orderId) async {
    try {
      await orderRepository.cancelOrder(orderId);

      // Actualizar lista de Ã³rdenes
      final index = _userOrders.indexWhere((order) => order.id == orderId);
      if (index >= 0) {
        _userOrders[index] = _userOrders[index].copyWith(
          status: OrderStatus.cancelled,
        );
        notifyListeners();
      }

      return true;
    } on FirebaseException catch (e) {
      _errorMessage = 'shop_cancel_error';
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
    } on FirebaseException catch (e) {
      _errorMessage = 'shop_create_product_error';
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
    } on FirebaseException catch (e) {
      _errorMessage = 'shop_update_product_error';
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
    } on FirebaseException catch (e) {
      _errorMessage = 'shop_delete_product_error';
      notifyListeners();
      return false;
    }
  }

  /// Eliminar TODOS los productos sin imÃ¡genes (funciÃ³n de limpieza)
  Future<int> deleteProductsWithoutImages() async {
    int deletedCount = 0;

    try {
      // Recargar productos para tener la lista mÃ¡s actualizada
      await loadProducts();

      // Encontrar productos sin imÃ¡genes vÃ¡lidas
      final productsToDelete = _allProducts.where((product) {
        if (product.images.isEmpty) return true;
        return !product.images.any(
          (img) => img.isNotEmpty && img.trim().isNotEmpty,
        );
      }).toList();

      debugPrint(
        'ðŸ—‘ï¸ Productos sin imÃ¡genes encontrados: ${productsToDelete.length}',
      );

      // Eliminar cada producto sin imagen
      for (final product in productsToDelete) {
        try {
          debugPrint(
            'ðŸ—‘ï¸ Eliminando producto sin imagen: ${product.name} (${product.id})',
          );
          await productRepository.deleteProduct(product.id);
          deletedCount++;
        } on FirebaseException catch (e) {
          debugPrint('âŒ Error eliminando ${product.name}: $e');
        }
      }

      // Recargar productos despuÃ©s de la limpieza
      await loadProducts();

      debugPrint('âœ… Productos eliminados: $deletedCount');
      return deletedCount;
    } on FirebaseException catch (e) {
      _errorMessage = 'shop_cleanup_error';
      notifyListeners();
      return deletedCount;
    }
  }

  /// Dar like/unlike a un producto (operaciÃ³n atÃ³mica en Firestore)
  Future<bool> toggleProductLike(String productId, String userId) async {
    try {
      debugPrint(
        'LIKE_PROVIDER>>> toggleProductLike productId=$productId userId=$userId',
      );
      final productIndex = _allProducts.indexWhere((p) => p.id == productId);
      debugPrint(
        'LIKE_PROVIDER>>> productIndex=$productIndex allProducts=${_allProducts.length}',
      );
      if (productIndex == -1) return false;

      final product = _allProducts[productIndex];
      final likedByUsers = List<String>.from(product.likedByUsers);

      // Actualizar localmente PRIMERO (respuesta instantÃ¡nea)
      if (likedByUsers.contains(userId)) {
        likedByUsers.remove(userId);
      } else {
        likedByUsers.add(userId);
      }

      final updatedEntity = product.copyWith(likedByUsers: likedByUsers);
      // Convertir a ProductModel para mantener el tipo correcto en _allProducts
      final updatedProduct = ProductModel.fromEntity(updatedEntity);
      _allProducts[productIndex] = updatedProduct;
      _applyFilters();
      debugPrint(
        'LIKE_PROVIDER>>> filteredProducts=${_filteredProducts.length} notifying...',
      );
      notifyListeners();

      // Luego guardar en Firestore (si hay userId valido)
      if (userId.isNotEmpty && userId != 'local_user') {
        try {
          debugPrint('LIKE_PROVIDER>>> saving to Firestore...');
          await productRepository.toggleProductLike(productId, userId);
          debugPrint('LIKE_PROVIDER>>> Firestore saved OK');
        } on FirebaseException catch (e) {
          debugPrint(
            'LIKE_PROVIDER>>> Firestore error (like se mantiene local): $e',
          );
          // NO revertimos - el like se queda como Instagram/TikTok
        }
      }

      return true;
    } on FirebaseException catch (e) {
      debugPrint('LIKE_PROVIDER>>> ERROR critico: $e');
      // Revertir cambio local si falla Firestore
      await loadProducts();
      _errorMessage = 'shop_like_error';
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
    } on FirebaseException catch (e) {
      _errorMessage = 'shop_sold_error';
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

