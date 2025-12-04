import 'package:flutter/foundation.dart';
import 'package:biux/features/shop/domain/entities/product_entity.dart';
import 'package:biux/features/shop/domain/entities/category_entity.dart';
import 'package:biux/features/shop/domain/entities/cart_item_entity.dart';
import 'package:biux/features/shop/domain/entities/order_entity.dart';
import 'package:biux/features/shop/domain/repositories/product_repository.dart';
import 'package:biux/features/shop/domain/repositories/order_repository.dart';

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
  int get cartItemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get cartTotal => _cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  List<OrderEntity> get userOrders => _userOrders;
  bool get isLoadingOrders => _isLoadingOrders;
  bool get hasItemsInCart => _cartItems.isNotEmpty;

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
      final matchesCategory = _selectedCategory == ProductCategories.all ||
          product.category == _selectedCategory;

      // Filtro por búsqueda
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase());

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
    // Verificar si el producto ya está en el carrito
    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.id == product.id && item.selectedSize == selectedSize,
    );

    if (existingIndex >= 0) {
      // Incrementar cantidad
      final existing = _cartItems[existingIndex];
      _cartItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity + 1,
      );
    } else {
      // Agregar nuevo item
      _cartItems.add(CartItemEntity(
        product: product,
        quantity: 1,
        selectedSize: selectedSize,
      ));
    }

    notifyListeners();
  }

  /// Remover producto del carrito
  void removeFromCart(String productId, {String? selectedSize}) {
    _cartItems.removeWhere(
      (item) => item.product.id == productId && item.selectedSize == selectedSize,
    );
    notifyListeners();
  }

  /// Actualizar cantidad de un item en el carrito
  void updateCartItemQuantity(String productId, int newQuantity, {String? selectedSize}) {
    if (newQuantity <= 0) {
      removeFromCart(productId, selectedSize: selectedSize);
      return;
    }

    final index = _cartItems.indexWhere(
      (item) => item.product.id == productId && item.selectedSize == selectedSize,
    );

    if (index >= 0) {
      _cartItems[index] = _cartItems[index].copyWith(quantity: newQuantity);
      notifyListeners();
    }
  }

  /// Limpiar carrito
  void clearCart() {
    _cartItems.clear();
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
      final order = OrderEntity(
        id: '', // Firebase genera el ID
        userId: userId,
        userName: userName,
        items: List.from(_cartItems),
        total: cartTotal,
        status: OrderStatus.pending,
        deliveryAddress: deliveryAddress,
        phoneNumber: phoneNumber,
        notes: notes,
        createdAt: DateTime.now(),
      );

      final orderId = await orderRepository.createOrder(order);

      // Actualizar stock de productos
      for (final item in _cartItems) {
        final newStock = item.product.stock - item.quantity;
        await productRepository.updateStock(item.product.id, newStock);
      }

      // Limpiar carrito
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

  /// Crear producto (solo admins)
  Future<bool> createProduct(ProductEntity product) async {
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

  /// Limpiar mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
