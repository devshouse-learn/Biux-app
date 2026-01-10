import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/features/shop/presentation/providers/shop_provider.dart';
import 'package:biux/features/shop/presentation/widgets/product_card.dart';
import 'package:biux/features/shop/presentation/widgets/category_filter.dart';
import 'package:biux/features/shop/presentation/widgets/cart_button.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:go_router/go_router.dart';

/// Pantalla principal de la tienda
class ShopScreen extends StatefulWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cargar productos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShopProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.primary30,
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        elevation: 0,
        title: const Text(
          'Tienda Biux',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Consumer<ShopProvider>(
            builder: (context, shopProvider, child) {
              return CartButton(
                itemCount: shopProvider.cartItemCount,
                onPressed: () {
                  context.push('/shop/cart');
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            color: ColorTokens.primary30,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                context.read<ShopProvider>().searchProducts(query);
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ShopProvider>().searchProducts('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filtro de categorías
          Consumer<ShopProvider>(
            builder: (context, shopProvider, child) {
              return CategoryFilter(
                selectedCategory: shopProvider.selectedCategory,
                onCategorySelected: (category) {
                  shopProvider.filterByCategory(category);
                },
              );
            },
          ),

          const SizedBox(height: 16),

          // Grid de productos
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Consumer<ShopProvider>(
                builder: (context, shopProvider, child) {
                  if (shopProvider.isLoadingProducts) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: ColorTokens.secondary50,
                      ),
                    );
                  }

                  if (shopProvider.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            shopProvider.errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              shopProvider.clearError();
                              shopProvider.loadProducts();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorTokens.secondary50,
                            ),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }

                  final products = shopProvider.products;

                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay productos disponibles',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Intenta con otro filtro o búsqueda',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          context.push('/shop/${product.id}');
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      // Botón flotante para admin
      floatingActionButton: Consumer2<ShopProvider, UserProvider>(
        builder: (context, shopProvider, userProvider, child) {
          // Verificar si el usuario es admin
          final isAdmin = userProvider.user?.isAdmin ?? false;

          if (!isAdmin) return const SizedBox.shrink();

          return FloatingActionButton(
            onPressed: () {
              context.push('/shop/admin');
            },
            backgroundColor: ColorTokens.secondary50,
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}
