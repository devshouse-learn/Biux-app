// (conflict markers removed - keeping remote version)
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
import 'package:biux/features/shop/presentation/widgets/shop_menu_drawer_widget.dart';
import 'package:biux/features/shop/presentation/screens/shop_admin_sheets.dart';
import 'package:biux/features/shop/presentation/widgets/shop_admin_dashboard_widget_v2.dart';
import 'package:biux/features/shop/presentation/widgets/promotions_widget.dart';
import '../widgets/request_seller_permission_dialog.dart';
// import '../widgets/recommended_for_rides_widget.dart'; // actualmente no usado

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
  bool _showOffersExpanded = false; // Control para barra desplegable de ofertas
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
            const SizedBox(width: 8),
            // Favoritos
            Consumer2<ShopProvider, UserProvider>(
              builder: (context, shopProvider, userProvider, child) {
                final uid = userProvider.user?.uid ?? '';
                final favCount = uid.isEmpty
                    ? 0
                    : shopProvider.products
                        .where((p) => p.isLikedBy(uid))
                        .length;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: Icon(
                        favCount > 0
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 24,
                        color: favCount > 0
                            ? Colors.red
                            : ColorTokens.primary30,
                      ),
                      onPressed: () => context.push('/shop/favorites'),
                      tooltip: 'Mis Favoritos',
                      style: IconButton.styleFrom(
                        backgroundColor: ColorTokens.neutral99,
                      ),
                    ),
                    if (favCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$favCount',
                            style: const TextStyle(
                              color: Colors.white,
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
            const SizedBox(width: 4),
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
                      case 'info':
                        _showShopInfoBottomSheet(context);
                        break;
                      case 'promociones':
                        _showPromotionsBottomSheet(context);
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
                      value: 'info',
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Info de Productos',
                            style: TextStyle(color: Colors.blue[800]),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'promociones',
                      child: Row(
                        children: [
                          Icon(Icons.campaign, size: 20, color: Colors.orange),
                          const SizedBox(width: 12),
                          Text('Promociones'),
                        ],
                      ),
                    ),
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

  /// Bottom sheet con información de productos y sugerencias
  void _showShopInfoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Título
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                    ),
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Información de la Tienda',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Contenido scrollable
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildInfoSection(
                      icon: Icons.storefront,
                      title: 'Productos Disponibles',
                      description:
                          'Puedes ofrecer productos relacionados con ciclismo: bicicletas, accesorios, componentes, indumentaria, nutrición y tecnología deportiva.',
                      items: [
                        'Bicicletas (ruta, montaña, urbanas, eléctricas)',
                        'Cascos y protección',
                        'Luces y reflectantes',
                        'Herramientas y repuestos',
                        'Ropa ciclista',
                        'Suplementos y nutrición',
                        'GPS y ciclocomputadores',
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoSection(
                      icon: Icons.category,
                      title: 'Categorías Populares',
                      description:
                          'Las categorías más buscadas por los ciclistas en nuestra plataforma:',
                      items: [
                        'Bicicletas completas',
                        'Componentes y repuestos',
                        'Accesorios de seguridad',
                        'Indumentaria',
                        'Electrónica y GPS',
                        'Nutrición deportiva',
                        'Mantenimiento',
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoSection(
                      icon: Icons.tips_and_updates,
                      title: 'Consejos para Vender',
                      description:
                          'Mejora tus ventas siguiendo estas recomendaciones:',
                      items: [
                        'Usa fotos de alta calidad',
                        'Describe detalladamente el estado del producto',
                        'Establece precios competitivos',
                        'Responde rápido a las consultas',
                        'Ofrece envío o entrega en mano',
                        'Mantén tu inventario actualizado',
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoSection(
                      icon: Icons.local_offer,
                      title: 'Ofertas y Promociones',
                      description:
                          'Atrae más compradores con estrategias de venta:',
                      items: [
                        'Descuentos por temporada',
                        'Packs y combos de productos',
                        'Envío gratis en compras mayores',
                        'Programa de fidelización',
                        'Ofertas flash por tiempo limitado',
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget helper para las secciones de información
  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String description,
    required List<String> items,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: Colors.blue[700]),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.blue[400],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(item, style: const TextStyle(fontSize: 14)),
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

  /// Chips de categorías horizontales estilo Chrome
  // ignore: unused_element
  Widget _buildCategoryChips() {
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

    return SliverToBoxAdapter(
      child: Container(
        color: ColorTokens.neutral100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: categories.map((cat) {
              final isSelected =
                  _tabController.index == categories.indexOf(cat);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: isSelected,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        cat['icon'] as IconData,
                        size: 16,
                        color: isSelected
                            ? ColorTokens.primary30
                            : ColorTokens.neutral60,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cat['label'] as String,
                        style: TextStyle(
                          color: isSelected
                              ? ColorTokens.primary30
                              : ColorTokens.neutral40,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  onSelected: (selected) {
                    _tabController.animateTo(categories.indexOf(cat));
                    _onCategoryChanged(cat['value'] as String?);
                  },
                  backgroundColor: ColorTokens.neutral99,
                  selectedColor: ColorTokens.primary99,
                  checkmarkColor: ColorTokens.primary30,
                  side: BorderSide(
                    color: isSelected
                        ? ColorTokens.primary30
                        : ColorTokens.neutral95,
                    width: 1,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// Barra de ofertas desplegable limpia
  // ignore: unused_element
  Widget _buildOffersBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorTokens.neutral100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorTokens.neutral95),
        boxShadow: [
          BoxShadow(
            color: ColorTokens.neutral90.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Cabecera clickeable
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _showOffersExpanded = !_showOffersExpanded;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ColorTokens.warning99,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: ColorTokens.warning90),
                      ),
                      child: Icon(
                        Icons.local_offer_outlined,
                        color: ColorTokens.warning50,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ofertas y Beneficios',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ColorTokens.neutral20,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _showOffersExpanded
                                ? 'Ocultar promociones'
                                : 'Descuentos especiales disponibles',
                            style: TextStyle(
                              fontSize: 13,
                              color: ColorTokens.neutral60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ColorTokens.error50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '4',
                        style: TextStyle(
                          color: ColorTokens.neutral100,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _showOffersExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: ColorTokens.neutral60,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Contenido expandible
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Divider(height: 1, color: ColorTokens.neutral95),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildOfferCard(
                              '⚡',
                              'Ofertas\nRelámpago',
                              ColorTokens.warning99,
                              ColorTokens.warning50,
                              () => _showFlashOffersDialog(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildOfferCard(
                              '🎯',
                              'Descuentos\nGrupales',
                              ColorTokens.info90,
                              ColorTokens.secondary50,
                              () => _showGroupDiscountsDialog(context),
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
                              () => _showPremiumProductsDialog(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildOfferCard(
                              '🚚',
                              'Envío\nGratis',
                              ColorTokens.success99,
                              ColorTokens.success40,
                              () => _showShippingDiscountsDialog(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            crossFadeState: _showOffersExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
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
                // Debe tener imágenes REALES (no placeholders)
                return _productHasRealImages(p);
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
                  child: _buildProductImage(
                    imageUrl: product.images.isNotEmpty
                        ? product.images.first
                        : '',
                    productName: product.name,
                    category: product.category,
                    fit: BoxFit.cover,
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
                return _productHasRealImages(p);
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

  /// AppBar profesional con búsqueda integrada (antiguo)
  // ignore: unused_element
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
                        // IMPLEMENTADO (STUB): Descomentar cuando se resuelva conflicto de dependencias con mobile_scanner
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
                  onPressed: () => context.push('/shop/cart'),
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
  /// Banner promocional integrado con Biux - Colores claros
  // ignore: unused_element
  Widget _buildPromoBanner() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: const Color(0xFF16242D).withValues(alpha: 0.1)),
      ),
      color: const Color(0xFFF0F7FF),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16242D).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.campaign_outlined,
                    color: Color(0xFF16242D),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Promociones de la Comunidad',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF16242D),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Comparte ofertas y eventos con otros ciclistas',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5A7A8A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo: Título de la promoción
            const Text(
              'Título de la promoción',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C4A5A),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              decoration: InputDecoration(
                hintText: 'Ej: Descuento en cascos de ciclismo',
                hintStyle: TextStyle(
                  color: const Color(0xFF16242D).withValues(alpha: 0.35),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: const Color(0xFF16242D).withValues(alpha: 0.12),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: const Color(0xFF16242D).withValues(alpha: 0.12),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF16242D),
                    width: 1.5,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.title,
                  color: const Color(0xFF16242D).withValues(alpha: 0.4),
                  size: 20,
                ),
              ),
              style: const TextStyle(color: Color(0xFF16242D), fontSize: 14),
            ),
            const SizedBox(height: 16),

            // Campo: Descripción
            const Text(
              'Descripción',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C4A5A),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Describe tu promoción, incluye detalles importantes como ubicación, horarios, condiciones...',
                hintStyle: TextStyle(
                  color: const Color(0xFF16242D).withValues(alpha: 0.35),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: const Color(0xFF16242D).withValues(alpha: 0.12),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: const Color(0xFF16242D).withValues(alpha: 0.12),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF16242D),
                    width: 1.5,
                  ),
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Icon(
                    Icons.description_outlined,
                    color: const Color(0xFF16242D).withValues(alpha: 0.4),
                    size: 20,
                  ),
                ),
              ),
              style: const TextStyle(color: Color(0xFF16242D), fontSize: 14),
            ),
            const SizedBox(height: 16),

            // Fila: Tipo + Fecha
            Row(
              children: [
                // Tipo de promoción
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tipo',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C4A5A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF16242D).withValues(alpha: 0.12),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: 'descuento',
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: const Color(0xFF16242D).withValues(alpha: 0.5),
                            ),
                            style: const TextStyle(
                              color: Color(0xFF16242D),
                              fontSize: 14,
                            ),
                            dropdownColor: Colors.white,
                            items: const [
                              DropdownMenuItem(
                                value: 'descuento',
                                child: Row(
                                  children: [
                                    Text('🏷️', style: TextStyle(fontSize: 16)),
                                    SizedBox(width: 8),
                                    Text('Descuento'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'oferta',
                                child: Row(
                                  children: [
                                    Text('🎁', style: TextStyle(fontSize: 16)),
                                    SizedBox(width: 8),
                                    Text('Oferta'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'evento',
                                child: Row(
                                  children: [
                                    Text('🚴', style: TextStyle(fontSize: 16)),
                                    SizedBox(width: 8),
                                    Text('Evento'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'novedad',
                                child: Row(
                                  children: [
                                    Text('✨', style: TextStyle(fontSize: 16)),
                                    SizedBox(width: 8),
                                    Text('Novedad'),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (value) {},
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Fecha de expiración
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Expira',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C4A5A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () async {
                          await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(
                              const Duration(days: 7),
                            ),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF16242D).withValues(alpha: 0.12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                                color: const Color(0xFF16242D).withValues(alpha: 0.4),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Seleccionar',
                                style: TextStyle(
                                  color: const Color(
                                    0xFF16242D,
                                  ).withValues(alpha: 0.5),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Campo: Ubicación (nuevo)
            const Text(
              'Ubicación (opcional)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C4A5A),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              decoration: InputDecoration(
                hintText: 'Ej: Tienda de ciclismo Calle 80, Bogotá',
                hintStyle: TextStyle(
                  color: const Color(0xFF16242D).withValues(alpha: 0.35),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: const Color(0xFF16242D).withValues(alpha: 0.12),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: const Color(0xFF16242D).withValues(alpha: 0.12),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF16242D),
                    width: 1.5,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                  color: const Color(0xFF16242D).withValues(alpha: 0.4),
                  size: 20,
                ),
              ),
              style: const TextStyle(color: Color(0xFF16242D), fontSize: 14),
            ),
            const SizedBox(height: 16),

            // Campo: Enlace o contacto (nuevo)
            const Text(
              'Enlace o contacto (opcional)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C4A5A),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              decoration: InputDecoration(
                hintText: 'Ej: https://mitienda.com o +57 300 123 4567',
                hintStyle: TextStyle(
                  color: const Color(0xFF16242D).withValues(alpha: 0.35),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: const Color(0xFF16242D).withValues(alpha: 0.12),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: const Color(0xFF16242D).withValues(alpha: 0.12),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF16242D),
                    width: 1.5,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.link,
                  color: const Color(0xFF16242D).withValues(alpha: 0.4),
                  size: 20,
                ),
              ),
              style: const TextStyle(color: Color(0xFF16242D), fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Nota informativa
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF16242D).withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF16242D).withValues(alpha: 0.08),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Color(0xFF5A7A8A)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Las promociones serán visibles para todos los ciclistas de tu comunidad durante el tiempo seleccionado.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5A7A8A),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Botón publicar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Promoción publicada exitosamente 🎉'),
                      backgroundColor: Color(0xFF16242D),
                    ),
                  );
                },
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text(
                  'Publicar Promoción',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16242D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildBenefitCard(
    String emoji,
    String text,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
        ),
      ),
    );
  }

  /// Toolbar con ordenamiento y vista
  // ignore: unused_element
  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          // Resultados count (solo productos válidos)
          Consumer<ShopProvider>(
            builder: (context, provider, child) {
              final validCount = provider.products.where((p) {
                return _productHasRealImages(p);
              }).length;

              return Text(
                '$validCount productos',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
          // Reemplazado Spacer() por un espacio flexible controlado para evitar
          // overflows en columnas y filas con altura/anchura limitada.
          const SizedBox(width: 8),

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

        // ✅ FILTRAR PRODUCTOS: Solo mostrar productos con fotos REALES (no placeholders)
        final validProducts = shopProvider.products.where((product) {
          if (!_productHasRealImages(product)) {
            debugPrint(
              '🚫 Producto filtrado (sin foto real): ${product.name} (${product.id}) - imgs: ${product.images}',
            );
            return false;
          }
          return true;
        }).toList();

        debugPrint(
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
                    child: _buildProductImage(
                      imageUrl: product.mainImage,
                      productName: product.name,
                      category: product.category,
                      width: double.infinity,
                      fit: BoxFit.cover,
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
                        return GestureDetector(
                          onTap: currentUser != null
                              ? () async {
                                  await context
                                      .read<ShopProvider>()
                                      .toggleProductLike(
                                        product.id,
                                        currentUser.uid,
                                      );
                                }
                              : null,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.9,
                            ),
                            child: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: isLiked
                                  ? Colors.red
                                  : Colors.grey[700],
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
            child: _buildProductImage(
              imageUrl: product.mainImage,
              productName: product.name,
              category: product.category,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
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

  /// ✅ Verifica si una URL de imagen es una foto REAL del producto
  /// Filtra placeholders genéricos, fondos de color sólido, y URLs falsas
  static bool _isRealProductImage(String url) {
    if (url.isEmpty || url.trim().isEmpty) return false;

    final lower = url.toLowerCase().trim();

    // ✅ Permitir URLs mock:// (productos de prueba con placeholder visual)
    if (lower.startsWith('mock://')) return true;

    // ✅ Permitir assets locales (imágenes descargadas del proyecto)
    if (lower.startsWith('asset://')) return true;

    // Debe ser una URL válida (http o https)
    if (!lower.startsWith('http://') && !lower.startsWith('https://')) {
      return false;
    }

    // 🚫 BLOQUEAR servicios de placeholder (fondos de color sólido)
    const blockedDomains = [
      'via.placeholder.com',
      'placehold.it',
      'placehold.co',
      'placeholder.com',
      'dummyimage.com',
      'fakeimg.pl',
      'placekitten.com',
      'picsum.photos',
      'lorempixel.com',
    ];

    for (final domain in blockedDomains) {
      if (lower.contains(domain)) return false;
    }

    // Filtrar URLs que son solo colores hex (ej: /FF0000, ?color=red)
    final hexColorPattern = RegExp(r'[?&/]([0-9a-f]{6}|[0-9a-f]{3})([?&/]|$)');
    if (hexColorPattern.hasMatch(lower) && !lower.contains('firebase')) {
      // Solo filtrar si parece ser un servicio de placeholder con color
      if (!lower.contains('firebasestorage') &&
          !lower.contains('googleapis.com') &&
          !lower.contains('cloudinary') &&
          !lower.contains('imgbb') &&
          !lower.contains('imgur')) {
        // Verificar si la URL NO tiene extensión de imagen real
        final hasImageExt =
            lower.endsWith('.jpg') ||
            lower.endsWith('.jpeg') ||
            lower.endsWith('.png') ||
            lower.endsWith('.webp') ||
            lower.endsWith('.gif');
        if (!hasImageExt && !lower.contains('token=')) return false;
      }
    }

    // ✅ Permitir Pexels (fotos reales de productos)
    if (lower.contains('images.pexels.com/photos/')) return true;

    // ✅ Permitir Unsplash (fotos fijas por ID, siempre coinciden con producto)
    if (lower.contains('images.unsplash.com/photo-')) return true;

    // Filtrar texto "Producto" en placeholders
    if (lower.contains('text=producto') || lower.contains('text=product')) {
      return false;
    }

    // Debe ser una URL válida (http o https)
    if (!lower.startsWith('http://') && !lower.startsWith('https://')) {
      return false;
    }

    return true;
  }

  /// Verifica si un producto tiene al menos una imagen REAL (no placeholder)
  static bool _productHasRealImages(ProductEntity product) {
    if (product.images.isEmpty) return false;
    return product.images.any((img) => _isRealProductImage(img));
  }

  /// Widget inteligente de imagen de producto.
  /// Si la URL es mock://, muestra un placeholder bonito con icono + nombre.
  /// Si es URL real, usa CachedNetworkImage.
  Widget _buildProductImage({
    required String imageUrl,
    required String productName,
    required String category,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    // Detectar si es mock placeholder
    if (imageUrl.startsWith('mock://')) {
      return _buildMockPlaceholder(
        productName: productName,
        category: category,
        width: width,
        height: height,
      );
    }

    // Detectar si es asset local (asset://img/shop/...)
    if (imageUrl.startsWith('asset://')) {
      final assetPath = imageUrl.replaceFirst('asset://', '');
      return Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildMockPlaceholder(
          productName: productName,
          category: category,
          width: width,
          height: height,
        ),
      );
    }

    // URL real: usar CachedNetworkImage
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.high,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => _buildMockPlaceholder(
        productName: productName,
        category: category,
        width: width,
        height: height,
      ),
    );
  }

  /// Placeholder bonito con gradiente, icono de categoría y nombre del producto
  Widget _buildMockPlaceholder({
    required String productName,
    required String category,
    double? width,
    double? height,
  }) {
    // Icono y colores por categoría
    final categoryConfig = _getCategoryVisual(category);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: categoryConfig.gradientColors,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            categoryConfig.icon,
            size: (height ?? 120) * 0.3,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              productName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: (height ?? 120) * 0.08,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              category,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: (height ?? 120) * 0.06,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Configuración visual por categoría (icono + colores de gradiente)
  static _CategoryVisual _getCategoryVisual(String category) {
    switch (category.toLowerCase()) {
      case 'jerseys':
        return _CategoryVisual(
          icon: Icons.checkroom,
          gradientColors: [const Color(0xFF1565C0), const Color(0xFF42A5F5)],
        );
      case 'shorts':
        return _CategoryVisual(
          icon: Icons.accessibility_new,
          gradientColors: [const Color(0xFF2E7D32), const Color(0xFF66BB6A)],
        );
      case 'gloves':
      case 'guantes':
        return _CategoryVisual(
          icon: Icons.back_hand,
          gradientColors: [const Color(0xFF6A1B9A), const Color(0xFFAB47BC)],
        );
      case 'helmets':
      case 'cascos':
        return _CategoryVisual(
          icon: Icons.sports_motorsports,
          gradientColors: [const Color(0xFFE65100), const Color(0xFFFF9800)],
        );
      case 'glasses':
      case 'gafas':
        return _CategoryVisual(
          icon: Icons.visibility,
          gradientColors: [const Color(0xFF00838F), const Color(0xFF4DD0E1)],
        );
      case 'shoes':
      case 'zapatillas':
      case 'calzado':
        return _CategoryVisual(
          icon: Icons.directions_run,
          gradientColors: [const Color(0xFFC62828), const Color(0xFFEF5350)],
        );
      default:
        return _CategoryVisual(
          icon: Icons.pedal_bike,
          gradientColors: [const Color(0xFF37474F), const Color(0xFF78909C)],
        );
    }
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
                      color: Colors.purple.withValues(alpha: 0.1),
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
                        color: Colors.purple.withValues(alpha: 0.1),
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
                      onPressed: () async {
                        final nav = GoRouter.of(context);
                        Navigator.pop(context);
                        await Future.delayed(const Duration(milliseconds: 300));
                        nav.go('/shop/seller-requests');
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
                      color: Colors.orange.withValues(alpha: 0.1),
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
                        color: Colors.orange.withValues(alpha: 0.1),
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
                      onPressed: () async {
                        final nav = GoRouter.of(context);
                        Navigator.pop(context);
                        await Future.delayed(const Duration(milliseconds: 300));
                        nav.go('/shop/manage-sellers');
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
                      color: Colors.red.withValues(alpha: 0.1),
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
                        color: Colors.red.withValues(alpha: 0.1),
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
                      onPressed: () async {
                        final nav = GoRouter.of(context);
                        Navigator.pop(context);
                        await Future.delayed(const Duration(milliseconds: 300));
                        nav.go('/shop/delete-all-products');
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

  // ignore: unused_element
  void _showPermissionRequestDialog(BuildContext context) {
    // Usar el nuevo widget de diálogo
    showRequestSellerPermissionDialog(context);
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

  /// Bottom sheet con promociones de la comunidad
  void _showPromotionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header con flecha atrás
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Icon(Icons.campaign, color: Colors.orange, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Promociones de la Comunidad',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content - Widget funcional
              const Expanded(child: PromotionsWidget()),
            ],
          ),
        ),
      ),
    );
  }

  /// Bottom sheet con promociones de la comunidad

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
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
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

  ///   /// Bottom sheet con panel de administración
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
                child: ShopAdminDashboardWidget(
                  onManageProducts: () {
                    Navigator.pop(context);
                    ShopAdminSheets.showManageProductsSheet(context);
                  },
                  onManageSellers: () {
                    Navigator.pop(context);
                    ShopAdminSheets.showManageSellersSheet(context);
                  },
                  onViewReports: () {
                    Navigator.pop(context);
                    ShopAdminSheets.showReportsSheet(context);
                  },
                  onViewRequests: () {
                    Navigator.pop(context);
                    ShopAdminSheets.showRequestsSheet(context);
                  },
                  onViewStats: () {
                    Navigator.pop(context);
                    ShopAdminSheets.showStatsSheet(context);
                  },
                  onSecurityCenter: () {
                    Navigator.pop(context);
                    ShopAdminSheets.showSecuritySheet(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet para gestionar productos de la tienda
// ignore: unused_element
void _showManageProductsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const Icon(Icons.inventory_2, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Gestión de Productos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumen de inventario
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Resumen de Inventario',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                'Total',
                                '0',
                                Icons.shopping_bag,
                                Colors.blue,
                              ),
                              _buildStatItem(
                                'Activos',
                                '0',
                                Icons.check_circle,
                                Colors.green,
                              ),
                              _buildStatItem(
                                'Agotados',
                                '0',
                                Icons.warning,
                                Colors.orange,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Acciones rápidas
                  const Text(
                    'Acciones Rápidas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildActionTile(
                    icon: Icons.add_circle,
                    color: Colors.green,
                    title: 'Agregar Producto',
                    subtitle: 'Añadir un nuevo producto al catálogo',
                    onTap: () {
                      Navigator.pop(context);
                      // Navegar a agregar producto
                    },
                  ),
                  _buildActionTile(
                    icon: Icons.edit,
                    color: Colors.blue,
                    title: 'Editar Productos',
                    subtitle: 'Modificar información de productos existentes',
                    onTap: () {},
                  ),
                  _buildActionTile(
                    icon: Icons.category,
                    color: Colors.purple,
                    title: 'Categorías',
                    subtitle: 'Organizar productos por categorías',
                    onTap: () {},
                  ),
                  _buildActionTile(
                    icon: Icons.local_offer,
                    color: Colors.red,
                    title: 'Ofertas y Descuentos',
                    subtitle: 'Configurar promociones especiales',
                    onTap: () {},
                  ),
                  _buildActionTile(
                    icon: Icons.photo_library,
                    color: Colors.teal,
                    title: 'Galería de Productos',
                    subtitle: 'Gestionar fotos y multimedia',
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  // Formulario rápido de precio
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Actualización Rápida de Precios',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Nombre del producto',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Nuevo precio',
                              prefixIcon: const Icon(Icons.attach_money),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.update),
                              label: const Text('Actualizar Precio'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
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
        ],
      ),
    ),
  );
}

/// Bottom sheet para gestionar vendedores
// ignore: unused_element
void _showManageSellersSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const Icon(Icons.people, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Gestión de Vendedores',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Formulario para agregar vendedor
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Agregar Vendedor',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Nombre completo',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Correo electrónico',
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Teléfono',
                              prefixIcon: const Icon(Icons.phone),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Rol',
                              prefixIcon: const Icon(Icons.badge),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'vendedor',
                                child: Text('Vendedor'),
                              ),
                              DropdownMenuItem(
                                value: 'supervisor',
                                child: Text('Supervisor'),
                              ),
                              DropdownMenuItem(
                                value: 'cajero',
                                child: Text('Cajero'),
                              ),
                            ],
                            onChanged: (value) {},
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.person_add),
                              label: const Text('Agregar Vendedor'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Vendedores Activos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildSellerCard(
                    'Sin vendedores registrados',
                    'Agrega vendedores para empezar',
                    Icons.person_off,
                    Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  // Permisos
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Permisos de Vendedores',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SwitchListTile(
                            title: const Text('Pueden modificar precios'),
                            value: false,
                            onChanged: (v) {},
                            secondary: const Icon(Icons.attach_money),
                          ),
                          SwitchListTile(
                            title: const Text('Pueden agregar productos'),
                            value: false,
                            onChanged: (v) {},
                            secondary: const Icon(Icons.add_box),
                          ),
                          SwitchListTile(
                            title: const Text('Pueden eliminar productos'),
                            value: false,
                            onChanged: (v) {},
                            secondary: const Icon(Icons.delete),
                          ),
                          SwitchListTile(
                            title: const Text('Pueden ver reportes'),
                            value: false,
                            onChanged: (v) {},
                            secondary: const Icon(Icons.bar_chart),
                          ),
                        ],
                      ),
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

/// Bottom sheet para reportes
// ignore: unused_element
void _showReportsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const Icon(Icons.assessment, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Reportes',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumen de ventas
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Resumen de Ventas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                'Hoy',
                                '\$0',
                                Icons.today,
                                Colors.blue,
                              ),
                              _buildStatItem(
                                'Semana',
                                '\$0',
                                Icons.date_range,
                                Colors.green,
                              ),
                              _buildStatItem(
                                'Mes',
                                '\$0',
                                Icons.calendar_month,
                                Colors.purple,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Filtros de reporte
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Generar Reporte',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Tipo de reporte',
                              prefixIcon: const Icon(Icons.description),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'ventas',
                                child: Text('Ventas'),
                              ),
                              DropdownMenuItem(
                                value: 'inventario',
                                child: Text('Inventario'),
                              ),
                              DropdownMenuItem(
                                value: 'clientes',
                                child: Text('Clientes'),
                              ),
                              DropdownMenuItem(
                                value: 'devoluciones',
                                child: Text('Devoluciones'),
                              ),
                            ],
                            onChanged: (value) {},
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Período',
                              prefixIcon: const Icon(Icons.schedule),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'hoy',
                                child: Text('Hoy'),
                              ),
                              DropdownMenuItem(
                                value: 'semana',
                                child: Text('Última semana'),
                              ),
                              DropdownMenuItem(
                                value: 'mes',
                                child: Text('Último mes'),
                              ),
                              DropdownMenuItem(
                                value: 'trimestre',
                                child: Text('Último trimestre'),
                              ),
                              DropdownMenuItem(
                                value: 'personalizado',
                                child: Text('Personalizado'),
                              ),
                            ],
                            onChanged: (value) {},
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.download),
                              label: const Text('Generar Reporte'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Top productos
                  const Text(
                    'Top Productos Vendidos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'Sin datos de ventas aún',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
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

/// Bottom sheet para solicitudes
// ignore: unused_element
void _showRequestsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const Icon(Icons.inbox, color: Colors.indigo),
                const SizedBox(width: 8),
                const Text(
                  'Solicitudes',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tabs de solicitudes
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Filtrar Solicitudes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Estado',
                              prefixIcon: const Icon(Icons.filter_list),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'todas',
                                child: Text('Todas'),
                              ),
                              DropdownMenuItem(
                                value: 'pendientes',
                                child: Text('Pendientes'),
                              ),
                              DropdownMenuItem(
                                value: 'aprobadas',
                                child: Text('Aprobadas'),
                              ),
                              DropdownMenuItem(
                                value: 'rechazadas',
                                child: Text('Rechazadas'),
                              ),
                            ],
                            onChanged: (value) {},
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Tipo de solicitud',
                              prefixIcon: const Icon(Icons.category),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'todas',
                                child: Text('Todas'),
                              ),
                              DropdownMenuItem(
                                value: 'devolucion',
                                child: Text('Devolución'),
                              ),
                              DropdownMenuItem(
                                value: 'cambio',
                                child: Text('Cambio'),
                              ),
                              DropdownMenuItem(
                                value: 'garantia',
                                child: Text('Garantía'),
                              ),
                              DropdownMenuItem(
                                value: 'reclamo',
                                child: Text('Reclamo'),
                              ),
                            ],
                            onChanged: (value) {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'Pendientes',
                        '0',
                        Icons.pending,
                        Colors.orange,
                      ),
                      _buildStatItem(
                        'En Proceso',
                        '0',
                        Icons.hourglass_top,
                        Colors.blue,
                      ),
                      _buildStatItem(
                        'Resueltas',
                        '0',
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Solicitudes Recientes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No hay solicitudes pendientes',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
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

/// Bottom sheet para estadísticas
// ignore: unused_element
void _showStatsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const Icon(Icons.analytics, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'Estadísticas',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPIs principales
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'KPIs del Negocio',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                'Visitas',
                                '0',
                                Icons.visibility,
                                Colors.blue,
                              ),
                              _buildStatItem(
                                'Clientes',
                                '0',
                                Icons.people,
                                Colors.green,
                              ),
                              _buildStatItem(
                                'Conversión',
                                '0%',
                                Icons.trending_up,
                                Colors.purple,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rendimiento de Ventas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                'Ingresos',
                                '\$0',
                                Icons.monetization_on,
                                Colors.green,
                              ),
                              _buildStatItem(
                                'Ticket Prom.',
                                '\$0',
                                Icons.receipt,
                                Colors.orange,
                              ),
                              _buildStatItem(
                                'Margen',
                                '0%',
                                Icons.pie_chart,
                                Colors.red,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Período de consulta
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Consultar Período',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: 'Desde',
                                    prefixIcon: const Icon(
                                      Icons.calendar_today,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onTap: () {},
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: 'Hasta',
                                    prefixIcon: const Icon(
                                      Icons.calendar_today,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onTap: () {},
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.search),
                              label: const Text('Consultar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Productos más visitados
                  const Text(
                    'Productos Más Visitados',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'Sin datos de visitas aún',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
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

/// Bottom sheet para centro de seguridad
// ignore: unused_element
void _showSecuritySheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const Icon(Icons.security, color: Colors.red),
                const SizedBox(width: 8),
                const Text(
                  'Centro de Seguridad',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Estado de seguridad
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.green[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.shield,
                            color: Colors.green[700],
                            size: 40,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estado: Seguro',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                                const Text(
                                  'No se detectaron problemas de seguridad',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Configuración de Seguridad',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Autenticación de dos factores'),
                          subtitle: const Text(
                            'Añade una capa extra de seguridad',
                          ),
                          value: false,
                          onChanged: (v) {},
                          secondary: const Icon(Icons.lock),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text(
                            'Notificaciones de inicio de sesión',
                          ),
                          subtitle: const Text(
                            'Recibe alertas cuando alguien accede',
                          ),
                          value: true,
                          onChanged: (v) {},
                          secondary: const Icon(Icons.notifications_active),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text('Registro de actividad'),
                          subtitle: const Text(
                            'Guarda un log de todas las acciones',
                          ),
                          value: true,
                          onChanged: (v) {},
                          secondary: const Icon(Icons.history),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text('Bloqueo por intentos fallidos'),
                          subtitle: const Text(
                            'Bloquea tras 5 intentos fallidos',
                          ),
                          value: false,
                          onChanged: (v) {},
                          secondary: const Icon(Icons.block),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Cambiar contraseña
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cambiar Contraseña',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Contraseña actual',
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Nueva contraseña',
                              prefixIcon: const Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Confirmar nueva contraseña',
                              prefixIcon: const Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.vpn_key),
                              label: const Text('Actualizar Contraseña'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Sesiones activas
                  const Text(
                    'Sesiones Activas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.phone_iphone,
                        color: Colors.blue,
                      ),
                      title: const Text('Este dispositivo'),
                      subtitle: const Text('Activo ahora'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Actual',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        'Cerrar todas las sesiones',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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

/// Helper: construir item de estadística
Widget _buildStatItem(String label, String value, IconData icon, Color color) {
  return Column(
    children: [
      Icon(icon, color: color, size: 28),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ],
  );
}

/// Helper: construir tile de acción
Widget _buildActionTile({
  required IconData icon,
  required Color color,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return Card(
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}

/// Helper: construir card de vendedor
Widget _buildSellerCard(String name, String role, IconData icon, Color color) {
  return Card(
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(role),
    ),
  );
}

/// Widget FAB con menú desplegable para opciones de tienda
// ignore: unused_element
class _ShopMenuFab extends StatelessWidget {
  final bool isAdmin;
  final bool canCreateProducts;
  final bool showOffersExpanded;
  final VoidCallback onToggleOffers;
  final VoidCallback onAdminDashboard;
  final VoidCallback onAddProduct;
  final VoidCallback onRequestPermission;

  const _ShopMenuFab({
    required this.isAdmin,
    required this.canCreateProducts,
    required this.showOffersExpanded,
    required this.onToggleOffers,
    required this.onAdminDashboard,
    required this.onAddProduct,
    required this.onRequestPermission,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'offers':
            onToggleOffers();
            break;
          case 'admin':
            onAdminDashboard();
            break;
          case 'add':
            if (canCreateProducts) {
              onAddProduct();
            } else {
              onRequestPermission();
            }
            break;
        }
      },
      offset: const Offset(0, -180),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      elevation: 8,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'offers',
          child: Row(
            children: [
              Icon(Icons.local_offer, color: ColorTokens.warning50, size: 22),
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
                Icon(Icons.add_circle, color: ColorTokens.success40, size: 22),
                const SizedBox(width: 12),
                const Text(
                  'Agregar Producto',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
      ],
      child: FloatingActionButton.small(
        heroTag: 'shopMenu',
        onPressed: null, // PopupMenuButton maneja el tap
        backgroundColor: ColorTokens.primary30,
        child: const Icon(Icons.more_vert, color: Colors.white, size: 22),
      ),
    );
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
  bool shouldRepaint(CustomPainter oldDelegate) => false;
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

/// Modelo visual para representar una categoría con icono y colores
class _CategoryVisual {
  final IconData icon;
  final List<Color> gradientColors;

  const _CategoryVisual({required this.icon, required this.gradientColors});
}
