// (conflict markers removed - keeping remote version)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/features/shop/presentation/providers/shop_provider.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/features/shop/domain/entities/product_entity.dart';
import 'package:biux/features/shop/domain/entities/category_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/shop/presentation/widgets/shop_menu_drawer_widget.dart';
import 'package:biux/features/shop/presentation/widgets/shop_admin_dashboard_widget_v2.dart';
import '../widgets/request_seller_permission_dialog.dart';

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
      drawer: const ShopMenuDrawer(),
      backgroundColor: ColorTokens.neutral99, // Fondo claro y limpio
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // AppBar limpio estilo Chrome
          _buildChromeStyleAppBar(),

          // Selector de categoría desplegable
          SliverToBoxAdapter(child: _buildCategoryDropdown()),

          // Productos destacados
          _buildFeaturedSection(),

          // Toolbar
          SliverToBoxAdapter(child: _buildMinimalToolbar()),

          // Filtros avanzados
          if (_showFilters) SliverToBoxAdapter(child: _buildAdvancedFilters()),

          // Grid de productos
          _buildProductsGrid(),
        ],
      ),
    );
  }

  /// AppBar limpio estilo Chrome Web Store
  Widget _buildChromeStyleAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: ColorTokens.neutral100,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 70,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: ColorTokens.primary10),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: ColorTokens.neutral100,
          border: Border(
            bottom: BorderSide(color: ColorTokens.neutral95, width: 1),
          ),
        ),
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          right: 16,
          bottom: 8,
        ),
        child: Row(
          children: [
            // Logo o título
            Text(
              '🚴 Tienda Biux',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: ColorTokens.primary30,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 16),
            // Barra de búsqueda limpia
            Expanded(
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: ColorTokens.neutral99,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: ColorTokens.neutral95, width: 1),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: ColorTokens.neutral20, fontSize: 14),
                  onChanged: (query) {
                    context.read<ShopProvider>().searchProducts(query);
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar productos...',
                    hintStyle: TextStyle(
                      color: ColorTokens.neutral70,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: ColorTokens.neutral70,
                      size: 20,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: ColorTokens.neutral70,
                              size: 18,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              context.read<ShopProvider>().searchProducts('');
                              setState(() {});
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Carrito
            Consumer<ShopProvider>(
              builder: (context, shopProvider, child) {
                final itemCount = shopProvider.cartItemCount;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.shopping_bag_outlined,
                        size: 24,
                        color: ColorTokens.primary30,
                      ),
                      onPressed: () => context.push('/shop/cart'),
                      style: IconButton.styleFrom(
                        backgroundColor: ColorTokens.neutral99,
                      ),
                    ),
                    if (itemCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: ColorTokens.error50,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$itemCount',
                            style: TextStyle(
                              color: ColorTokens.neutral100,
                              fontSize: 9,
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
            // Menú de opciones (admin, ofertas, agregar producto)
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final currentUser = userProvider.user;
                final isAdmin = currentUser?.isAdmin ?? false;
                final canCreateProducts =
                    currentUser?.canCreateProducts ?? false;

                return PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: ColorTokens.primary30,
                    size: 24,
                  ),
                  offset: const Offset(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  elevation: 8,
                  onSelected: (value) {
                    switch (value) {
                      case 'offers':
                        _showOffersBottomSheet(context);
                        break;
                      case 'admin':
                        _showAdminDashboardSheet(context);
                        break;
                      case 'add':
                        if (canCreateProducts) {
                          context.push('/shop/add-product');
                        } else {
                          showRequestSellerPermissionDialog(context);
                        }
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'offers',
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_offer,
                            color: ColorTokens.warning50,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Ofertas y Beneficios',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    if (isAdmin)
                      PopupMenuItem(
                        value: 'admin',
                        child: Row(
                          children: [
                            Icon(
                              Icons.admin_panel_settings,
                              color: ColorTokens.primary30,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Panel Admin',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    if (canCreateProducts)
                      PopupMenuItem(
                        value: 'add',
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_circle,
                              color: ColorTokens.success40,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Agregar Producto',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Card de oferta individual
  Widget _buildOfferCard(
    String emoji,
    String label,
    Color bgColor,
    Color accentColor,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accentColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: ColorTokens.neutral30,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Sección de productos destacados
  Widget _buildFeaturedSection() {
    return SliverToBoxAdapter(
      child: Consumer<ShopProvider>(
        builder: (context, provider, child) {
          // ✅ FILTRAR: Solo productos destacados, disponibles Y con imágenes válidas
          final featuredProducts = provider.products
              .where((p) {
                // Debe ser destacado y disponible
                if (!p.isFeatured || !p.isAvailable) return false;
                // Debe tener imágenes válidas
                if (p.images.isEmpty) return false;
                return p.images.any(
                  (img) => img.isNotEmpty && img.trim().isNotEmpty,
                );
              })
              .take(6)
              .toList();

          if (featuredProducts.isEmpty) {
            return const SizedBox.shrink();
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            color: ColorTokens.neutral100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: ColorTokens.warning50,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Destacados para ti',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ColorTokens.neutral20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Productos seleccionados para ciclistas',
                  style: TextStyle(fontSize: 13, color: ColorTokens.neutral60),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: featuredProducts.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index < featuredProducts.length - 1 ? 12 : 0,
                        ),
                        child: _buildFeaturedProductCard(
                          featuredProducts[index],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Card de producto destacado horizontal
  Widget _buildFeaturedProductCard(ProductEntity product) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: ColorTokens.neutral99,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorTokens.neutral95),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/shop/${product.id}'),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: product.images.isNotEmpty
                        ? product.images.first
                        : '',
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    memCacheHeight: 400,
                    memCacheWidth: 400,
                    placeholder: (context, url) => Container(
                      color: ColorTokens.neutral95,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            ColorTokens.primary30,
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: ColorTokens.neutral95,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: ColorTokens.neutral70,
                      ),
                    ),
                  ),
                ),
              ),
              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ColorTokens.neutral20,
                          height: 1.2,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\$${product.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorTokens.primary30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Toolbar minimalista
  Widget _buildMinimalToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: ColorTokens.neutral100,
      child: Row(
        children: [
          // Contador de productos (solo válidos con imágenes)
          Consumer<ShopProvider>(
            builder: (context, provider, child) {
              final validCount = provider.products.where((p) {
                if (p.images.isEmpty) return false;
                return p.images.any(
                  (img) => img.isNotEmpty && img.trim().isNotEmpty,
                );
              }).length;

              return Text(
                '$validCount productos',
                style: TextStyle(
                  color: ColorTokens.neutral50,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
          const Spacer(),
          // Botón de filtros
          TextButton.icon(
            onPressed: () => setState(() => _showFilters = !_showFilters),
            icon: Icon(
              _showFilters ? Icons.filter_alt_off : Icons.filter_alt,
              size: 18,
              color: ColorTokens.primary30,
            ),
            label: Text(
              'Filtros',
              style: TextStyle(
                color: ColorTokens.primary30,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: ColorTokens.primary99,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: ColorTokens.primary90),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Selector de vista
          Container(
            decoration: BoxDecoration(
              color: ColorTokens.neutral99,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ColorTokens.neutral95),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.grid_view),
                  iconSize: 20,
                  color: _viewMode == 'grid'
                      ? ColorTokens.primary30
                      : ColorTokens.neutral70,
                  onPressed: () => setState(() => _viewMode = 'grid'),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
                Container(width: 1, height: 20, color: ColorTokens.neutral95),
                IconButton(
                  icon: Icon(Icons.view_list),
                  iconSize: 20,
                  color: _viewMode == 'list'
                      ? ColorTokens.primary30
                      : ColorTokens.neutral70,
                  onPressed: () => setState(() => _viewMode = 'list'),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ],
            ),
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
        mainAxisSize: MainAxisSize.min,
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
              // Evitar Spacer() que expande indefinidamente dentro de filas
              // anidadas en Slivers; usar un SizedBox flexible en su lugar.
              const SizedBox(height: 4),
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

        // ✅ FILTRAR PRODUCTOS: Solo mostrar productos con al menos una imagen válida
        final validProducts = shopProvider.products.where((product) {
          // Verificar que tenga imágenes Y que no estén vacías
          if (product.images.isEmpty) {
            print(
              '🚫 Producto SIN imágenes filtrado: ${product.name} (${product.id})',
            );
            return false;
          }
          // Verificar que al menos una imagen tenga contenido válido
          final hasValidImages = product.images.any(
            (img) => img.isNotEmpty && img.trim().isNotEmpty,
          );

          if (!hasValidImages) {
            print(
              '🚫 Producto con imágenes VACÍAS filtrado: ${product.name} (${product.id})',
            );
          }

          return hasValidImages;
        }).toList();

        print(
          '✅ Productos válidos mostrados: ${validProducts.length} de ${shopProvider.products.length}',
        );

        if (validProducts.isEmpty) {
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
                return _buildProductCardGrid(validProducts[index]);
              }, childCount: validProducts.length),
            ),
          );
        } else {
          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return _buildProductCardList(validProducts[index]);
            }, childCount: validProducts.length),
          );
        }
      },
    );
  }

  /// Card de producto estilo grid (Amazon/MercadoLibre)
  Widget _buildProductCardGrid(ProductEntity product) {
    return GestureDetector(
      onTap: () => context.push('/shop/${product.id}'),
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
                      filterQuality: FilterQuality.high,
                      memCacheHeight: 500,
                      memCacheWidth: 500,
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
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre
                    Flexible(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Rating
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < 4 ? Icons.star : Icons.star_border,
                              size: 11,
                              color: Colors.amber,
                            );
                          }),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '4.5',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

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
                                            context.push('/shop/cart'),
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
              filterQuality: FilterQuality.high,
              memCacheHeight: 200,
              memCacheWidth: 200,
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
              mainAxisSize: MainAxisSize.min,
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

  /// Dropdown compacto para seleccionar categoría
  Widget _buildCategoryDropdown() {
    final categories = [
      {'icon': Icons.apps, 'label': 'Todos', 'value': null},
      {
        'icon': Icons.pedal_bike,
        'label': 'Bicis',
        'value': ProductCategories.bikes,
      },
      {
        'icon': Icons.checkroom,
        'label': 'Jerseys',
        'value': ProductCategories.jerseys,
      },
      {
        'icon': Icons.sports,
        'label': 'Culotes',
        'value': ProductCategories.shorts,
      },
      {
        'icon': Icons.sports_motorsports,
        'label': 'Cascos',
        'value': ProductCategories.helmets,
      },
      {
        'icon': Icons.directions_run,
        'label': 'Calzado',
        'value': ProductCategories.shoes,
      },
      {
        'icon': Icons.settings,
        'label': 'Componentes',
        'value': ProductCategories.components,
      },
      {
        'icon': Icons.category,
        'label': 'Accesorios',
        'value': ProductCategories.accessories,
      },
    ];

    return Container(
      color: ColorTokens.neutral100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: ColorTokens.neutral99,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorTokens.neutral90),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: _tabController.index,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down, color: ColorTokens.neutral50),
            dropdownColor: ColorTokens.neutral100,
            borderRadius: BorderRadius.circular(12),
            items: categories.asMap().entries.map((entry) {
              final idx = entry.key;
              final cat = entry.value;
              return DropdownMenuItem<int>(
                value: idx,
                child: Row(
                  children: [
                    Icon(
                      cat['icon'] as IconData,
                      size: 20,
                      color: _tabController.index == idx
                          ? ColorTokens.primary30
                          : ColorTokens.neutral50,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      cat['label'] as String,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: _tabController.index == idx
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: _tabController.index == idx
                            ? ColorTokens.primary30
                            : ColorTokens.neutral30,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (idx) {
              if (idx != null) {
                setState(() {
                  _tabController.animateTo(idx);
                });
                final cat = categories[idx];
                final value = cat['value'] as String?;
                if (value == null) {
                  context.read<ShopProvider>().loadProducts();
                } else {
                  context.read<ShopProvider>().filterByCategory(value);
                }
              }
            },
          ),
        ),
      ),
    );
  }

  /// Bottom sheet con ofertas y beneficios
  void _showOffersBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: ColorTokens.neutral90,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              children: [
                Icon(Icons.local_offer, color: ColorTokens.warning50, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Ofertas y Beneficios',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColorTokens.neutral10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOfferCard(
                    '⚡',
                    'Ofertas\nRelámpago',
                    ColorTokens.warning99,
                    ColorTokens.warning50,
                    () {
                      Navigator.pop(ctx);
                      _showFlashOffersDialog(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOfferCard(
                    '🎯',
                    'Descuentos\nGrupales',
                    ColorTokens.info90,
                    ColorTokens.secondary50,
                    () {
                      Navigator.pop(ctx);
                      _showGroupDiscountsDialog(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildOfferCard(
                    '🏆',
                    'Productos\nPremium',
                    ColorTokens.secondary99,
                    ColorTokens.primary50,
                    () {
                      Navigator.pop(ctx);
                      _showPremiumProductsDialog(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOfferCard(
                    '🚚',
                    'Envío\nGratis',
                    ColorTokens.success99,
                    ColorTokens.success40,
                    () {
                      Navigator.pop(ctx);
                      _showShippingDiscountsDialog(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Bottom sheet con panel de administración
  void _showAdminDashboardSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: ColorTokens.neutral90,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    color: ColorTokens.primary30,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Panel de Administración',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColorTokens.neutral10,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: ColorTokens.neutral50),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ShopAdminDashboardWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extensión para el estado con los métodos de diálogos
extension _BenefitDialogs on _ShopScreenProState {
  /// Mostrar descuentos para grupos
  void _showGroupDiscountsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.blue[400]!],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Descuentos para Grupos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Contenido
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildInfoCard(
                    icon: Icons.group,
                    title: '¿Cómo funciona?',
                    description:
                        'Compra en grupo con tus amigos ciclistas y obtén descuentos especiales. Mientras más sean, mayor el descuento.',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),

                  _buildDiscountTier(
                    '3-5 personas',
                    '10% de descuento',
                    Colors.blue[300]!,
                  ),
                  _buildDiscountTier(
                    '6-10 personas',
                    '15% de descuento',
                    Colors.blue[400]!,
                  ),
                  _buildDiscountTier(
                    '11-20 personas',
                    '20% de descuento',
                    Colors.blue[500]!,
                  ),
                  _buildDiscountTier(
                    '21+ personas',
                    '25% de descuento',
                    Colors.blue[600]!,
                  ),

                  const SizedBox(height: 20),
                  _buildInfoCard(
                    icon: Icons.card_giftcard,
                    title: 'Beneficios adicionales',
                    description:
                        '• Envío gratis para grupos\n• Personalización incluida\n• Soporte prioritario\n• Descuentos acumulables',
                    color: Colors.green,
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Aquí podrías navegar a una pantalla de creación de grupo
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Contacta a un administrador para crear tu grupo de compra',
                          ),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_circle),
                    label: const Text('Crear Grupo de Compra'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mostrar ofertas relámpago
  void _showFlashOffersDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[600]!, Colors.orange[400]!],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Ofertas Relámpago',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Contenido
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildInfoCard(
                    icon: Icons.flash_on,
                    title: '¡Ofertas por tiempo limitado!',
                    description:
                        'Descuentos especiales que duran solo 24 horas. ¡Aprovecha antes de que terminen!',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 20),

                  _buildFlashOffer(
                    'Casco Profesional',
                    '\$450.000',
                    '\$299.000',
                    '35% OFF',
                    '18:45:23',
                  ),
                  _buildFlashOffer(
                    'Guantes Premium',
                    '\$120.000',
                    '\$79.000',
                    '34% OFF',
                    '12:15:45',
                  ),
                  _buildFlashOffer(
                    'Botella Térmica',
                    '\$85.000',
                    '\$49.000',
                    '42% OFF',
                    '06:30:12',
                  ),

                  const SizedBox(height: 20),
                  _buildInfoCard(
                    icon: Icons.notifications_active,
                    title: 'Recibe notificaciones',
                    description:
                        'Activa las notificaciones para enterarte de las nuevas ofertas relámpago antes que nadie.',
                    color: Colors.deepOrange,
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/settings/notifications');
                    },
                    icon: const Icon(Icons.notifications),
                    label: const Text('Activar Notificaciones'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mostrar productos premium
  void _showPremiumProductsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple[600]!, Colors.purple[400]!],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Productos Premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Contenido
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildInfoCard(
                    icon: Icons.star,
                    title: 'Calidad superior',
                    description:
                        'Productos de las mejores marcas internacionales con garantía extendida y certificaciones profesionales.',
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 20),

                  _buildPremiumProduct(
                    'Bicicleta Carbono Pro',
                    '\$8.500.000',
                    'Shimano Dura-Ace • Cuadro carbono T1000',
                    Icons.pedal_bike,
                  ),
                  _buildPremiumProduct(
                    'Kit Ciclismo Elite',
                    '\$1.200.000',
                    'Jersey + Culote profesional • Tecnología aerodinámica',
                    Icons.checkroom,
                  ),
                  _buildPremiumProduct(
                    'Potenciómetro Dual',
                    '\$2.800.000',
                    'Medición precisa • Compatible ANT+ y Bluetooth',
                    Icons.speed,
                  ),

                  const SizedBox(height: 20),
                  _buildInfoCard(
                    icon: Icons.verified,
                    title: 'Garantías premium',
                    description:
                        '• Garantía extendida de 2 años\n• Servicio técnico prioritario\n• Repuestos garantizados\n• Devolución en 30 días',
                    color: Colors.amber,
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Filtrar solo productos premium
                      context.read<ShopProvider>().filterByCategory(
                        ProductCategories.accessories,
                      );
                    },
                    icon: const Icon(Icons.filter_list),
                    label: const Text('Ver Todos los Premium'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widgets auxiliares
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountTier(String people, String discount, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.2), Colors.white],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.group, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  people,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  discount,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: color, size: 18),
        ],
      ),
    );
  }

  Widget _buildFlashOffer(
    String name,
    String originalPrice,
    String salePrice,
    String discount,
    String timeLeft,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.orange[50]!, Colors.white]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  discount,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                originalPrice,
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                salePrice,
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.timer, size: 16, color: Colors.red),
              const SizedBox(width: 4),
              Text(
                'Termina en: $timeLeft',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumProduct(
    String name,
    String price,
    String features,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.purple[50]!, Colors.white]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  features,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Mostrar descuentos por envío
  void _showShippingDiscountsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[600]!, Colors.green[400]!],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Text('🚚', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Descuentos por Envío',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Contenido
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildInfoCard(
                    icon: Icons.local_shipping,
                    title: 'Envío gratis por compra',
                    description:
                        'Obtén envío gratuito según el monto de tu compra. Mientras más compres, más ahorras en envío.',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 20),

                  _buildShippingTier(
                    'Compras desde \$50.000',
                    'Envío: \$15.000',
                    '0% descuento',
                    Colors.grey[400]!,
                  ),
                  _buildShippingTier(
                    'Compras desde \$100.000',
                    'Envío gratis',
                    '100% descuento',
                    Colors.green[300]!,
                  ),
                  _buildShippingTier(
                    'Compras desde \$200.000',
                    'Envío gratis + Express',
                    '100% + Express',
                    Colors.green[500]!,
                  ),
                  _buildShippingTier(
                    'Compras desde \$500.000',
                    'Envío gratis + Express + Seguro',
                    '100% + Beneficios',
                    Colors.green[700]!,
                  ),

                  const SizedBox(height: 20),
                  _buildInfoCard(
                    icon: Icons.location_on,
                    title: 'Cobertura nacional',
                    description:
                        '• Todas las ciudades principales\n• Municipios intermedios\n• Zonas rurales (costo adicional)\n• Envíos internacionales disponibles',
                    color: Colors.blue,
                  ),

                  const SizedBox(height: 20),
                  _buildInfoCard(
                    icon: Icons.access_time,
                    title: 'Tiempos de entrega',
                    description:
                        '• Ciudades principales: 2-3 días\n• Municipios: 4-6 días\n• Envío express: 24-48 horas\n• Zonas rurales: 7-10 días',
                    color: Colors.orange,
                  ),

                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber[100]!, Colors.amber[50]!],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber[700], size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '¡Tip para ahorrar!',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[900],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Combina tus compras para alcanzar \$100.000 y obtener envío gratis',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/shop/cart');
                    },
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Ir al Carrito'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingTier(
    String purchase,
    String shipping,
    String discount,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.2), Colors.white],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.local_shipping,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  purchase,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  shipping,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              discount,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// End of resolved conflict
