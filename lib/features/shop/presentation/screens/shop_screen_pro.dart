import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/features/shop/presentation/providers/shop_provider.dart';
import 'package:biux/features/shop/presentation/providers/seller_request_provider.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/features/shop/domain/entities/product_entity.dart';
import 'package:biux/features/shop/domain/entities/category_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import '../widgets/request_seller_permission_dialog.dart';
import '../widgets/recommended_for_rides_widget.dart';

/// Tienda virtual profesional con características de e-commerce avanzadas
class ShopScreenPro extends StatefulWidget {
  final String? initialSearch;

  const ShopScreenPro({Key? key, this.initialSearch}) : super(key: key);

  @override
  State<ShopScreenPro> createState() => _ShopScreenProState();
}

class _ShopScreenProState extends State<ShopScreenPro>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _sortBy =
      'relevant'; // relevant, price_low, price_high, newest, popular
  String _viewMode = 'grid'; // grid, list
  bool _showFilters = false;
  late TabController _tabController;

  // Filtros avanzados
  RangeValues _priceRange = const RangeValues(0, 1000000);
  bool _inStockOnly = false;
  double _minRating = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);

    // Si hay búsqueda inicial, aplicarla
    if (widget.initialSearch != null && widget.initialSearch!.isNotEmpty) {
      _searchController.text = widget.initialSearch!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ShopProvider>().loadProducts().then((_) {
          context.read<ShopProvider>().searchProducts(widget.initialSearch!);
        });
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ShopProvider>().loadProducts();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // DEBUG VISUAL - Descomentado para ver información del usuario
          // SliverToBoxAdapter(
          //   child: Consumer<UserProvider>(
          //     builder: (context, userProvider, child) {
          //       final user = userProvider.user;
          //       return Container(
          //         color: Colors.red,
          //         padding: const EdgeInsets.all(12),
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Text('🔴 DEBUG MODE 🔴', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          //             Text('Usuario: ${user?.name ?? "NULL"}', style: TextStyle(color: Colors.white)),
          //             Text('UID: ${user?.uid ?? "NULL"}', style: TextStyle(color: Colors.white, fontSize: 10)),
          //             Text('isAdmin: ${user?.isAdmin ?? false}', style: TextStyle(color: Colors.white)),
          //             Text('canSellProducts: ${user?.canSellProducts ?? false}', style: TextStyle(color: Colors.white)),
          //             Text('canCreateProducts: ${user?.canCreateProducts ?? false}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          //           ],
          //         ),
          //       );
          //     },
          //   ),
          // ),

          // AppBar profesional con sticky search
          _buildSliverAppBar(),

          // Banner promocional
          SliverToBoxAdapter(child: _buildPromoBanner()),

          // Categorías con tabs
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: ColorTokens.primary30,
                labelColor: ColorTokens.primary30,
                unselectedLabelColor: Colors.black87,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                onTap: (index) {
                  final categories = [
                    null, // Todos
                    ProductCategories.bikes,
                    ProductCategories.jerseys,
                    ProductCategories.shorts,
                    ProductCategories.helmets,
                    ProductCategories.shoes,
                    ProductCategories.components,
                    ProductCategories.accessories,
                  ];
                  _onCategoryChanged(categories[index]);
                },
                tabs: const [
                  Tab(icon: Icon(Icons.dashboard), text: 'Todos'),
                  Tab(icon: Icon(Icons.pedal_bike), text: 'Bicis'),
                  Tab(icon: Icon(Icons.checkroom), text: 'Jerseys'),
                  Tab(icon: Icon(Icons.sports), text: 'Culotes'),
                  Tab(icon: Icon(Icons.sports_motorsports), text: 'Cascos'),
                  Tab(icon: Icon(Icons.directions_run), text: 'Calzado'),
                  Tab(icon: Icon(Icons.settings), text: 'Componentes'),
                  Tab(icon: Icon(Icons.category), text: 'Más'),
                ],
              ),
            ),
          ),

          // Toolbar: Ordenar y Vista
          SliverToBoxAdapter(child: _buildToolbar()),

          // Productos recomendados para rodadas
          SliverToBoxAdapter(
            child: Consumer<ShopProvider>(
              builder: (context, provider, child) {
                // Mostrar productos destacados o los primeros 6
                final recommendedProducts = provider.products
                    .where((p) => p.isFeatured || p.isAvailable)
                    .take(6)
                    .toList();

                if (recommendedProducts.isNotEmpty) {
                  return RecommendedForRidesWidget(
                    products: recommendedProducts,
                    subtitle: 'Equípate para tus próximas aventuras 🚴',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          // Panel de filtros (expandible)
          if (_showFilters) SliverToBoxAdapter(child: _buildAdvancedFilters()),

          // Grid/List de productos
          _buildProductsGrid(),
        ],
      ),

      // Floating Action Buttons
      floatingActionButton: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final currentUser = userProvider.user;
          final canCreateProducts = currentUser?.canCreateProducts ?? false;

          // � Log simplificado (descomentar líneas abajo para más detalle)
          if (canCreateProducts) {
            print(
              '✅ Botón de agregar producto VISIBLE para: ${currentUser?.name}',
            );
          }
          // print('🔴 User: ${currentUser?.name ?? "NULL"}');
          // print('🔴 UID: ${currentUser?.uid ?? "NULL"}');
          // print('🔴 isAdmin: ${currentUser?.isAdmin ?? false}');
          // print('🔴 canSellProducts: ${currentUser?.canSellProducts ?? false}');
          // print('🔴 canCreateProducts: $canCreateProducts');

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Botón para crear/agregar producto - Solo para usuarios autorizados
              if (canCreateProducts) ...[
                FloatingActionButton(
                  heroTag: 'add_product',
                  onPressed: () {
                    // Si el usuario puede crear productos, ir al admin
                    if (currentUser?.isAdmin == true ||
                        currentUser?.canSellProducts == true) {
                      context.go('/shop/admin');
                    } else {
                      // Mostrar diálogo pidiendo autorización
                      _showPermissionRequestDialog(context);
                    }
                  },
                  backgroundColor: ColorTokens.secondary50,
                  tooltip: 'Agregar Producto',
                  child: const Icon(
                    Icons.add_shopping_cart,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Botón de filtros
              FloatingActionButton.small(
                heroTag: 'filters',
                onPressed: () => setState(() => _showFilters = !_showFilters),
                backgroundColor: Colors.white,
                child: Icon(
                  _showFilters ? Icons.filter_alt_off : Icons.filter_alt,
                  color: ColorTokens.primary30,
                ),
              ),
              const SizedBox(height: 8),

              // Botón scroll to top
              FloatingActionButton.small(
                heroTag: 'scroll_top',
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                backgroundColor: ColorTokens.primary30,
                child: const Icon(Icons.arrow_upward, color: Colors.white),
              ),
            ],
          );
        },
      ),
    );
  }

  /// AppBar profesional con búsqueda integrada
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: ColorTokens.primary30,
      elevation: 4,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ColorTokens.primary30,
                ColorTokens.primary30.withValues(alpha: 0.8),
              ],
            ),
          ),
          padding: const EdgeInsets.only(
            top: 60,
            left: 16,
            right: 16,
            bottom: 8,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Barra de búsqueda profesional
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                  onChanged: (query) {
                    context.read<ShopProvider>().searchProducts(query);
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar productos, marcas, categorías...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: Icon(
                      Icons.search,
                      color: ColorTokens.primary30,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              context.read<ShopProvider>().searchProducts('');
                              setState(() {});
                            },
                          )
                        // TODO: Descomentar cuando se resuelva conflicto de dependencias con mobile_scanner
                        : null,
                    // : IconButton(
                    //     icon: const Icon(Icons.qr_code_scanner, color: Colors.grey),
                    //     onPressed: () {
                    //       context.push('/shop/qr-scanner');
                    //     },
                    //   ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        // Carrito con badge
        Consumer<ShopProvider>(
          builder: (context, shopProvider, child) {
            final itemCount = shopProvider.cartItemCount;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined, size: 28),
                  onPressed: () => context.go('/shop/cart'),
                ),
                if (itemCount > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '$itemCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),

        // Menú de opciones
        Consumer2<UserProvider, SellerRequestProvider>(
          builder: (context, userProvider, requestProvider, child) {
            final currentUser = userProvider.user;
            final isAdmin = currentUser?.isAdmin ?? false;
            final pendingCount = requestProvider.pendingCount;

            return PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'orders':
                    context.go('/shop/orders');
                    break;
                  case 'favorites':
                    context.go('/shop/favorites');
                    break;
                  case 'seller_requests':
                    _showSellerRequestsModal(context);
                    break;
                  case 'manage_sellers':
                    _showManageSellersModal(context);
                    break;
                  case 'delete_all_products':
                    _showDeleteAllProductsModal(context);
                    break;
                  case 'request_seller':
                    showRequestSellerPermissionDialog(context);
                    break;
                  case 'help':
                    _showHelpDialog();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'orders',
                  child: Row(
                    children: [
                      Icon(Icons.receipt_long, size: 20),
                      SizedBox(width: 12),
                      Text('Mis Pedidos'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'favorites',
                  child: Row(
                    children: [
                      Icon(Icons.favorite_border, size: 20),
                      SizedBox(width: 12),
                      Text('Favoritos'),
                    ],
                  ),
                ),
                // Solo mostrar a usuarios NO autorizados (para solicitar permiso)
                if (!isAdmin && !(currentUser?.canSellProducts ?? false)) ...[
                  const PopupMenuItem(
                    value: 'request_seller',
                    child: Row(
                      children: [
                        Icon(Icons.request_page, size: 20, color: Colors.blue),
                        SizedBox(width: 12),
                        Text(
                          'Solicitar Vender Productos',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Solo mostrar a administradores
                if (isAdmin) ...[
                  PopupMenuItem(
                    value: 'seller_requests',
                    child: Row(
                      children: [
                        Badge(
                          label: Text('$pendingCount'),
                          isLabelVisible: pendingCount > 0,
                          child: const Icon(
                            Icons.pending_actions,
                            size: 20,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Solicitudes de Vendedores',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'manage_sellers',
                    child: Row(
                      children: [
                        Icon(Icons.people, size: 20, color: Colors.orange),
                        SizedBox(width: 12),
                        Text(
                          'Gestionar Vendedores',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete_all_products',
                    child: Row(
                      children: [
                        Icon(Icons.delete_forever, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text(
                          'Eliminar Todos los Productos',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const PopupMenuItem(
                  value: 'help',
                  child: Row(
                    children: [
                      Icon(Icons.help_outline, size: 20),
                      SizedBox(width: 12),
                      Text('Ayuda'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Banner promocional integrado con Biux
  Widget _buildPromoBanner() {
    return Column(
      children: [
        // Banner principal de ciclismo
        Container(
          height: 140,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                ColorTokens.primary30,
                ColorTokens.primary30.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Patrón de fondo
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: CustomPaint(painter: BikePatternPainter()),
                  ),
                ),
                // Contenido
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '🚴 TIENDA BIUX',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Equípate para tus rodadas',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ColorTokens.secondary50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    '🏷️ Hasta 30% OFF',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Envío gratis > \$100k',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.95),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.pedal_bike,
                        size: 56,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Mini banners de beneficios
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildBenefitCard(
                  '🎯',
                  'Descuentos para grupos',
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildBenefitCard(
                  '⚡',
                  'Ofertas relámpago',
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildBenefitCard(
                  '🏆',
                  'Productos premium',
                  Colors.purple,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitCard(String emoji, String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  /// Toolbar con ordenamiento y vista
  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          // Resultados count
          Consumer<ShopProvider>(
            builder: (context, provider, child) {
              return Text(
                '${provider.products.length} productos',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
          const Spacer(),

          // Ordenar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButton<String>(
              value: _sortBy,
              underline: const SizedBox(),
              icon: const Icon(Icons.sort, size: 18),
              isDense: true,
              items: const [
                DropdownMenuItem(
                  value: 'relevant',
                  child: Text('Más relevantes'),
                ),
                DropdownMenuItem(
                  value: 'price_low',
                  child: Text('Menor precio'),
                ),
                DropdownMenuItem(
                  value: 'price_high',
                  child: Text('Mayor precio'),
                ),
                DropdownMenuItem(value: 'newest', child: Text('Más recientes')),
                DropdownMenuItem(value: 'popular', child: Text('Más vendidos')),
              ],
              onChanged: (value) {
                setState(() => _sortBy = value!);
                _applySorting();
              },
            ),
          ),
          const SizedBox(width: 12),

          // Vista Grid/List
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.grid_view,
                  color: _viewMode == 'grid'
                      ? ColorTokens.primary30
                      : Colors.grey,
                ),
                onPressed: () => setState(() => _viewMode = 'grid'),
                iconSize: 20,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              IconButton(
                icon: Icon(
                  Icons.view_list,
                  color: _viewMode == 'list'
                      ? ColorTokens.primary30
                      : Colors.grey,
                ),
                onPressed: () => setState(() => _viewMode = 'list'),
                iconSize: 20,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Panel de filtros avanzados
  Widget _buildAdvancedFilters() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune, color: ColorTokens.primary30),
              const SizedBox(width: 8),
              const Text(
                'Filtros Avanzados',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Limpiar'),
              ),
            ],
          ),
          const Divider(),

          // Rango de precios
          const Text(
            'Rango de precio',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 1000000,
            divisions: 20,
            labels: RangeLabels(
              '\$${(_priceRange.start / 1000).round()}k',
              '\$${(_priceRange.end / 1000).round()}k',
            ),
            onChanged: (values) {
              setState(() => _priceRange = values);
            },
            activeColor: ColorTokens.primary30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$${_formatPrice(_priceRange.start)}'),
              Text('\$${_formatPrice(_priceRange.end)}'),
            ],
          ),
          const SizedBox(height: 16),

          // Checkboxes
          CheckboxListTile(
            title: const Text('Solo productos en stock'),
            value: _inStockOnly,
            onChanged: (value) => setState(() => _inStockOnly = value!),
            activeColor: ColorTokens.primary30,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),

          const SizedBox(height: 16),

          // Calificación mínima
          const Text(
            'Calificación mínima',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() => _minRating = index + 1.0),
                child: Icon(
                  index < _minRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          // Botón aplicar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.primary30,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Aplicar Filtros',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Grid de productos (responsive)
  Widget _buildProductsGrid() {
    return Consumer<ShopProvider>(
      builder: (context, shopProvider, child) {
        if (shopProvider.isLoadingProducts) {
          return const SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando productos...'),
                ],
              ),
            ),
          );
        }

        if (shopProvider.products.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No se encontraron productos',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Limpiar filtros'),
                  ),
                ],
              ),
            ),
          );
        }

        // Grid o List según modo
        if (_viewMode == 'grid') {
          return SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                return _buildProductCardGrid(shopProvider.products[index]);
              }, childCount: shopProvider.products.length),
            ),
          );
        } else {
          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return _buildProductCardList(shopProvider.products[index]);
            }, childCount: shopProvider.products.length),
          );
        }
      },
    );
  }

  /// Card de producto estilo grid (Amazon/MercadoLibre)
  Widget _buildProductCardGrid(ProductEntity product) {
    return GestureDetector(
      onTap: () => context.go('/shop/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen con badges
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Imagen
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: product.mainImage,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 40),
                      ),
                    ),
                  ),

                  // Badge de descuento (si aplica)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '20% OFF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Botón favorito
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        final currentUser = userProvider.user;
                        final isLiked =
                            currentUser != null &&
                            product.isLikedBy(currentUser.uid);
                        final canLike = product.isAvailable;

                        return GestureDetector(
                          onTap: canLike && currentUser != null
                              ? () async {
                                  final success = await context
                                      .read<ShopProvider>()
                                      .toggleProductLike(
                                        product.id,
                                        currentUser.uid,
                                      );
                                  if (!success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'No puedes dar me gusta a este producto',
                                        ),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                }
                              : null,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white.withValues(
                              alpha: canLike ? 0.9 : 0.5,
                            ),
                            child: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: isLiked
                                  ? Colors.red
                                  : (canLike
                                        ? Colors.grey[700]
                                        : Colors.grey[400]),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Badge stock bajo
                  if (product.stock < 5 && product.stock > 0)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Solo ${product.stock}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info del producto
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Rating
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < 4 ? Icons.star : Icons.star_border,
                              size: 12,
                              color: Colors.amber,
                            );
                          }),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '4.5 (120)',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Likes counter
                    if (product.likesCount > 0)
                      Row(
                        children: [
                          Icon(Icons.favorite, size: 12, color: Colors.red),
                          const SizedBox(width: 4),
                          Text(
                            '${product.likesCount} Me gusta',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                    // Badge VENDIDO
                    if (product.isSold)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'VENDIDO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    const Spacer(),

                    // Precio
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Precio tachado
                              Text(
                                '\$${_formatPrice(product.price * 1.25)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              // Precio actual
                              Text(
                                '\$${_formatPrice(product.price)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: ColorTokens.primary30,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Botón agregar al carrito
                        GestureDetector(
                          onTap: product.isAvailable && !product.isSold
                              ? () {
                                  context.read<ShopProvider>().addToCart(
                                    product,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${product.name} agregado al carrito',
                                      ),
                                      duration: const Duration(seconds: 2),
                                      action: SnackBarAction(
                                        label: 'Ver Carrito',
                                        onPressed: () =>
                                            context.go('/shop/cart'),
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: product.isAvailable && !product.isSold
                                  ? ColorTokens.primary30
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add_shopping_cart,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card de producto estilo lista
  Widget _buildProductCardList(ProductEntity product) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Imagen
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: product.mainImage,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      return Icon(
                        index < 4 ? Icons.star : Icons.star_border,
                        size: 14,
                        color: Colors.amber,
                      );
                    }),
                    const SizedBox(width: 4),
                    Text(
                      '(120)',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${_formatPrice(product.price)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorTokens.primary30,
                  ),
                ),
              ],
            ),
          ),

          // Botón agregar
          IconButton(
            onPressed: () {
              context.read<ShopProvider>().addToCart(product);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Producto agregado al carrito'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.add_shopping_cart),
            color: ColorTokens.primary30,
          ),
        ],
      ),
    );
  }

  // Helpers
  String _formatPrice(double price) {
    final priceStr = price.toStringAsFixed(0);
    final regex = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
    return priceStr.replaceAllMapped(regex, (Match match) => '${match[1]}.');
  }

  void _onCategoryChanged(String? category) {
    if (category == null || category.isEmpty) {
      context.read<ShopProvider>().filterByCategory('');
    } else {
      context.read<ShopProvider>().filterByCategory(category);
    }
  }

  void _applySorting() {
    // Implementar lógica de ordenamiento
  }

  void _applyFilters() {
    // Implementar lógica de filtros avanzados
    setState(() => _showFilters = false);
  }

  void _clearFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 1000000);
      _inStockOnly = false;
      _minRating = 0;
      _searchController.clear();
    });
    context.read<ShopProvider>().clearFilters();
  }

  /// Mostrar pantalla de Solicitudes de Vendedores con estado vacío
  void _showSellerRequestsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Barra superior con indicador
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.pending_actions,
                      color: Colors.purple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Solicitudes de Vendedores',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Gestiona permisos de venta',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Estado vacío
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: Colors.purple[300],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '¡No hay solicitudes pendientes!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Text(
                        'Todas las solicitudes de vendedores han sido procesadas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.admin_panel_settings),
                      label: const Text('Panel de administración'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mostrar pantalla de Gestionar Vendedores con estado vacío
  void _showManageSellersModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Barra superior con indicador
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.people,
                      color: Colors.orange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gestionar Vendedores',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Administra permisos de usuarios',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Estado vacío
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.group_outlined,
                        size: 80,
                        color: Colors.orange[300],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Sistema de vendedores activo',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Text(
                        'Gestiona los permisos de venta de los usuarios de tu plataforma',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.settings),
                      label: const Text('Configurar permisos'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mostrar confirmación de Eliminar Todos los Productos
  void _showDeleteAllProductsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Barra superior con indicador
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.warning_rounded,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Eliminar Productos',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Gestión de inventario',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Estado de advertencia
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 80,
                        color: Colors.red[300],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Gestión de Inventario',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Text(
                        'Administra y organiza el inventario de productos de tu tienda',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.inventory),
                      label: const Text('Ver inventario'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Centro de Ayuda'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Llámanos'),
              subtitle: const Text('300 123 4567'),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: const Text('ayuda@biux.com'),
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Chat en vivo'),
              subtitle: const Text('Lun-Vie 9am-6pm'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showPermissionRequestDialog(BuildContext context) {
    // Usar el nuevo widget de diálogo
    showRequestSellerPermissionDialog(context);
  }
}

/// Custom painter para patrón de bicicletas en el banner
class BikePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const double bikeSize = 40;
    const double spacing = 60;

    for (double x = -bikeSize; x < size.width + bikeSize; x += spacing) {
      for (double y = -bikeSize; y < size.height + bikeSize; y += spacing) {
        _drawBike(canvas, paint, Offset(x, y), bikeSize);
      }
    }
  }

  void _drawBike(Canvas canvas, Paint paint, Offset center, double size) {
    final radius = size / 8;

    // Rueda trasera
    canvas.drawCircle(Offset(center.dx - size / 4, center.dy), radius, paint);

    // Rueda delantera
    canvas.drawCircle(Offset(center.dx + size / 4, center.dy), radius, paint);

    // Marco simple
    canvas.drawLine(
      Offset(center.dx - size / 4, center.dy),
      Offset(center.dx, center.dy - size / 4),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - size / 4),
      Offset(center.dx + size / 4, center.dy),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
