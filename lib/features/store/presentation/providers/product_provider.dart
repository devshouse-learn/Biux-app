import 'package:flutter/foundation.dart';
import 'package:biux/features/store/domain/entities/product_entity.dart';
import 'package:biux/features/store/domain/usecases/create_product_usecase.dart';
import 'package:biux/features/store/domain/usecases/get_products_usecase.dart';
import 'package:biux/features/store/domain/usecases/update_product_usecase.dart';
import 'package:biux/features/store/domain/usecases/delete_product_usecase.dart';
import 'package:biux/features/users/domain/entities/user_entity.dart';

/// Provider para gestión de productos con control de roles y permisos
class ProductProvider with ChangeNotifier {
  final GetAllProductsUseCase _getAllProductsUseCase;
  final GetProductsByCategoryUseCase _getProductsByCategoryUseCase;
  final GetProductsBySellerUseCase _getProductsBySellerUseCase;
  final GetFeaturedProductsUseCase _getFeaturedProductsUseCase;
  final SearchProductsUseCase _searchProductsUseCase;
  final CreateProductUseCase _createProductUseCase;
  final UpdateProductUseCase _updateProductUseCase;
  final DeleteProductUseCase _deleteProductUseCase;

  ProductProvider({
    required GetAllProductsUseCase getAllProductsUseCase,
    required GetProductsByCategoryUseCase getProductsByCategoryUseCase,
    required GetProductsBySellerUseCase getProductsBySellerUseCase,
    required GetFeaturedProductsUseCase getFeaturedProductsUseCase,
    required SearchProductsUseCase searchProductsUseCase,
    required CreateProductUseCase createProductUseCase,
    required UpdateProductUseCase updateProductUseCase,
    required DeleteProductUseCase deleteProductUseCase,
  }) : _getAllProductsUseCase = getAllProductsUseCase,
       _getProductsByCategoryUseCase = getProductsByCategoryUseCase,
       _getProductsBySellerUseCase = getProductsBySellerUseCase,
       _getFeaturedProductsUseCase = getFeaturedProductsUseCase,
       _searchProductsUseCase = searchProductsUseCase,
       _createProductUseCase = createProductUseCase,
       _updateProductUseCase = updateProductUseCase,
       _deleteProductUseCase = deleteProductUseCase;

  List<ProductEntity> _products = [];
  List<ProductEntity> _featuredProducts = [];
  bool _isLoading = false;
  String? _error;
  ProductCategory? _selectedCategory;
  String _searchQuery = '';

  // Getters
  List<ProductEntity> get products => _products;
  List<ProductEntity> get featuredProducts => _featuredProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ProductCategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  /// Cargar todos los productos
  Future<void> loadAllProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _getAllProductsUseCase();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cargar productos por categoría
  Future<void> loadProductsByCategory(ProductCategory category) async {
    _isLoading = true;
    _error = null;
    _selectedCategory = category;
    notifyListeners();

    try {
      _products = await _getProductsByCategoryUseCase(category);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cargar productos de un vendedor
  Future<void> loadSellerProducts(String sellerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _getProductsBySellerUseCase(sellerId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cargar productos destacados
  Future<void> loadFeaturedProducts() async {
    try {
      _featuredProducts = await _getFeaturedProductsUseCase();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Buscar productos
  Future<void> searchProducts(String query) async {
    _isLoading = true;
    _error = null;
    _searchQuery = query;
    _selectedCategory = null;
    notifyListeners();

    try {
      _products = await _searchProductsUseCase(query);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crear un nuevo producto
  /// Requiere que el usuario sea vendedor o administrador
  Future<void> createProduct(
    ProductEntity product,
    UserEntity currentUser,
  ) async {
    if (!currentUser.canCreateProducts) {
      throw Exception('No tienes permisos para crear productos');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _createProductUseCase(product);
      await loadAllProducts(); // Recargar productos
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Actualizar un producto existente
  /// Requiere que el usuario sea el vendedor dueño o administrador
  Future<void> updateProduct(
    ProductEntity product,
    UserEntity currentUser,
  ) async {
    if (!_canModifyProduct(product, currentUser)) {
      throw Exception('No tienes permisos para modificar este producto');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _updateProductUseCase(product);
      await loadAllProducts(); // Recargar productos
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Eliminar un producto
  /// Requiere que el usuario sea el vendedor dueño o administrador
  Future<void> deleteProduct(
    String productId,
    ProductEntity product,
    UserEntity currentUser,
  ) async {
    if (!_canModifyProduct(product, currentUser)) {
      throw Exception('No tienes permisos para eliminar este producto');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _deleteProductUseCase(productId);
      _products.removeWhere((p) => p.id == productId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verificar si un usuario puede modificar un producto
  bool _canModifyProduct(ProductEntity product, UserEntity user) {
    // Admin puede modificar cualquier producto
    if (user.isAdministrador) {
      return true;
    }

    // Vendedor solo puede modificar sus propios productos
    if (user.isVendedor && product.vendedorId == user.id) {
      return true;
    }

    return false;
  }

  /// Limpiar filtros y búsqueda
  void clearFilters() {
    _selectedCategory = null;
    _searchQuery = '';
    loadAllProducts();
  }

  /// Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
