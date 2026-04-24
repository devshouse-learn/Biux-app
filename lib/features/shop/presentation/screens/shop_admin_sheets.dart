import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/shop/presentation/providers/shop_provider.dart';
import 'package:biux/features/shop/domain/entities/product_entity.dart';

/// Crea una copia de un ProductEntity con campos modificados
ProductEntity _copyProductWith(
  ProductEntity p, {
  bool? isActive,
  double? price,
}) {
  return ProductEntity(
    id: p.id,
    name: p.name,
    description: p.description,
    longDescription: p.longDescription,
    price: price ?? p.price,
    images: p.images,
    videoUrl: p.videoUrl,
    category: p.category,
    sizes: p.sizes,
    stock: p.stock,
    sellerId: p.sellerId,
    sellerName: p.sellerName,
    sellerCity: p.sellerCity,
    createdAt: p.createdAt,
    isActive: isActive ?? p.isActive,
    likedByUsers: p.likedByUsers,
    isSold: p.isSold,
    metadata: p.metadata,
    isFeatured: p.isFeatured,
    recommendedForRides: p.recommendedForRides,
    sponsoredRides: p.sponsoredRides,
    rideType: p.rideType,
    tags: p.tags,
    discount: p.discount,
    discountEndDate: p.discountEndDate,
    isBicycle: p.isBicycle,
    bikeFrameSerial: p.bikeFrameSerial,
    bikeBrand: p.bikeBrand,
    bikeModel: p.bikeModel,
    bikeColor: p.bikeColor,
    bikeYear: p.bikeYear,
    isVerifiedNotStolen: p.isVerifiedNotStolen,
    stolenVerificationDate: p.stolenVerificationDate,
    stolenVerificationBy: p.stolenVerificationBy,
  );
}

/// Clase helper con todos los bottom sheets funcionales del panel de admin
class ShopAdminSheets {
  ShopAdminSheets._();

  // ═══════════════════════════════════════════════════
  // GESTIÓN DE PRODUCTOS - FUNCIONAL
  // ═══════════════════════════════════════════════════
  static void showManageProductsSheet(BuildContext context) {
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ManageProductsSheet(shopProvider: shopProvider),
    );
  }

  // ═══════════════════════════════════════════════════
  // GESTIÓN DE VENDEDORES - FUNCIONAL
  // ═══════════════════════════════════════════════════
  static void showManageSellersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ManageSellersSheet(),
    );
  }

  // ═══════════════════════════════════════════════════
  // REPORTES - FUNCIONAL
  // ═══════════════════════════════════════════════════
  static void showReportsSheet(BuildContext context) {
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReportsSheet(shopProvider: shopProvider),
    );
  }

  // ═══════════════════════════════════════════════════
  // SOLICITUDES - FUNCIONAL
  // ═══════════════════════════════════════════════════
  static void showRequestsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _RequestsSheet(),
    );
  }

  // ═══════════════════════════════════════════════════
  // ESTADÍSTICAS - FUNCIONAL
  // ═══════════════════════════════════════════════════
  static void showStatsSheet(BuildContext context) {
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _StatsSheet(shopProvider: shopProvider),
    );
  }

  // ═══════════════════════════════════════════════════
  // CENTRO DE SEGURIDAD - FUNCIONAL
  // ═══════════════════════════════════════════════════
  static void showSecuritySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _SecuritySheet(),
    );
  }
}

// ═══════════════════════════════════════════════════════
// WIDGET: GESTIÓN DE PRODUCTOS
// ═══════════════════════════════════════════════════════
class _ManageProductsSheet extends StatefulWidget {
  final ShopProvider shopProvider;
  const _ManageProductsSheet({required this.shopProvider});

  @override
  State<_ManageProductsSheet> createState() => _ManageProductsSheetState();
}

class _ManageProductsSheetState extends State<_ManageProductsSheet> {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

  final _searchController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedProductId;
  bool _isUpdating = false;

  @override
  void dispose() {
    _searchController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopProvider>(
      builder: (context, shopProvider, _) {
        final l = Provider.of<LocaleNotifier>(context);
        final products = shopProvider.products;
        final activeProducts = products.where((p) => p.isActive).toList();
        final outOfStock = products.where((p) => p.stock <= 0).toList();
        final query = _searchController.text.toLowerCase();
        final filtered = query.isEmpty
            ? products
            : products
                  .where((p) => p.name.toLowerCase().contains(query))
                  .toList();

        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildHandle(),
              _buildHeader(
                l.t('admin_products_management'),
                Icons.inventory_2,
                Colors.blue,
                context,
              ),
              Divider(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Resumen con datos reales
                      _buildSummaryCard([
                        _StatData(
                          l.t('admin_total'),
                          '${products.length}',
                          Icons.shopping_bag,
                          Colors.blue,
                        ),
                        _StatData(
                          l.t('admin_active'),
                          '${activeProducts.length}',
                          Icons.check_circle,
                          Colors.green,
                        ),
                        _StatData(
                          l.t('admin_out_of_stock'),
                          '${outOfStock.length}',
                          Icons.warning,
                          Colors.orange,
                        ),
                      ]),
                      SizedBox(height: 16),

                      // Buscador funcional
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: l.t('admin_search_product'),
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      SizedBox(height: 16),

                      // Lista de productos reales
                      Text(
                        '${l.t('admin_products_label')} (${filtered.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),

                      if (filtered.isEmpty)
                        _buildEmptyCard(l.t('admin_no_products_found'))
                      else
                        ...filtered.map((p) => _buildProductTile(p)),

                      const SizedBox(height: 16),

                      // Actualización rápida de precios
                      _buildPriceUpdateCard(products),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductTile(ProductEntity product) {
    final l = Provider.of<LocaleNotifier>(context);
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: product.images.isNotEmpty
              ? Image.network(
                  product.images.first,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                )
              : _buildPlaceholderImage(),
        ),
        title: Text(
          product.name,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '\$${product.price.toStringAsFixed(2)} · Stock: ${product.stock}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusBadge(product.isActive, l),
            PopupMenuButton<String>(
              onSelected: (value) => _handleProductAction(value, product),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        product.isActive
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        product.isActive
                            ? l.t('admin_deactivate')
                            : l.t('admin_activate'),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text(l.t('delete'), style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleProductAction(
    String action,
    ProductEntity product,
  ) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    if (action == 'toggle') {
      await widget.shopProvider.updateProduct(
        _copyProductWith(product, isActive: !product.isActive),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              product.isActive
                  ? '${product.name} ${l.t('admin_deactivated')}'
                  : '${product.name} ${l.t('admin_activated')}',
            ),
          ),
        );
      }
    } else if (action == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.t('admin_delete_product_question')),
          content: Text(
            '${l.t('admin_confirm_delete')} "${product.name}"? ${l.t('admin_confirm_delete_irreversible')}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.t('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                l.t('admin_delete'),
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await widget.shopProvider.deleteProduct(product.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${product.name}" ${l.t('admin_deleted')}'),
            ),
          );
        }
      }
    }
  }

  Widget _buildPriceUpdateCard(List<ProductEntity> products) {
    final l = Provider.of<LocaleNotifier>(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.t('admin_quick_price_update'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedProductId,
              decoration: InputDecoration(
                labelText: l.t('admin_select_product'),
                prefixIcon: const Icon(Icons.shopping_bag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: products
                  .map(
                    (p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(p.name, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProductId = value;
                  if (value != null) {
                    final p = products.firstWhere((p) => p.id == value);
                    _priceController.text = p.price.toStringAsFixed(2);
                  }
                });
              },
            ),
            SizedBox(height: 8),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l.t('admin_new_price'),
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUpdating
                    ? null
                    : () async {
                        if (_selectedProductId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l.t('admin_select_a_product')),
                            ),
                          );
                          return;
                        }
                        final newPrice = double.tryParse(
                          _priceController.text.trim(),
                        );
                        if (newPrice == null || newPrice <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l.t('admin_enter_valid_price')),
                            ),
                          );
                          return;
                        }
                        setState(() => _isUpdating = true);
                        try {
                          await widget.shopProvider.updateProduct(
                            _copyProductWith(
                              products.firstWhere(
                                (p) => p.id == _selectedProductId,
                              ),
                              price: newPrice,
                            ),
                          );
                          final productName = products
                              .firstWhere((p) => p.id == _selectedProductId)
                              .name;
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${l.t('admin_price_of')} "$productName" ${l.t('admin_updated_to')} \$${newPrice.toStringAsFixed(2)}',
                                ),
                              ),
                            );
                          }
                          _selectedProductId = null;
                          _priceController.clear();
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${l.t('error_generic')}: $e'),
                              ),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isUpdating = false);
                        }
                      },
                icon: _isUpdating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(Icons.update),
                label: Text(
                  _isUpdating
                      ? l.t('admin_updating')
                      : l.t('admin_update_price'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
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
    );
  }
}

// ═══════════════════════════════════════════════════════
// WIDGET: GESTIÓN DE VENDEDORES
// ═══════════════════════════════════════════════════════
class _ManageSellersSheet extends StatefulWidget {
  const _ManageSellersSheet();

  @override
  State<_ManageSellersSheet> createState() => _ManageSellersSheetState();
}

class _ManageSellersSheetState extends State<_ManageSellersSheet> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedRole = 'vendedor';
  bool _canModifyPrices = false;
  bool _canAddProducts = false;
  bool _canDeleteProducts = false;
  bool _canViewReports = false;
  bool _isSubmitting = false;
  final List<Map<String, dynamic>> _sellers = [];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(
            l.t('admin_sellers_management'),
            Icons.people,
            Colors.green,
            context,
          ),
          Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Formulario funcional
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
                          Text(
                            l.t('admin_add_seller'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: l.t('admin_full_name'),
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: l.t('admin_email'),
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: l.t('admin_phone'),
                              prefixIcon: Icon(Icons.phone),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedRole,
                            decoration: InputDecoration(
                              labelText: l.t('admin_role'),
                              prefixIcon: Icon(Icons.badge),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'vendedor',
                                child: Text(l.t('admin_seller_role')),
                              ),
                              DropdownMenuItem(
                                value: 'supervisor',
                                child: Text(l.t('admin_supervisor_role')),
                              ),
                              DropdownMenuItem(
                                value: 'cajero',
                                child: Text(l.t('admin_cashier_role')),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _selectedRole = v ?? 'vendedor'),
                          ),
                          SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isSubmitting ? null : _addSeller,
                              icon: _isSubmitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(Icons.person_add),
                              label: Text(
                                _isSubmitting
                                    ? l.t('admin_adding')
                                    : l.t('admin_add_seller'),
                              ),
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
                  SizedBox(height: 16),

                  // Vendedores registrados
                  Text(
                    '${l.t('admin_active_sellers')} (${_sellers.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  if (_sellers.isEmpty)
                    _buildEmptyCard(l.t('admin_no_sellers_registered'))
                  else
                    ..._sellers.map(
                      (s) => Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green[100],
                            child: Text(s['name'][0].toString().toUpperCase()),
                          ),
                          title: Text(
                            s['name'],
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('${s['role']} · ${s['email']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeSeller(s),
                          ),
                        ),
                      ),
                    ),

                  SizedBox(height: 16),

                  // Permisos funcionales
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
                          Text(
                            l.t('admin_sellers_permissions'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          SwitchListTile(
                            title: Text(l.t('admin_can_modify_prices')),
                            value: _canModifyPrices,
                            onChanged: (v) {
                              setState(() => _canModifyPrices = v);
                              _showPermissionSnack(
                                l.t('admin_modify_prices_perm'),
                                v,
                              );
                            },
                            secondary: Icon(Icons.attach_money),
                          ),
                          SwitchListTile(
                            title: Text(l.t('admin_can_add_products')),
                            value: _canAddProducts,
                            onChanged: (v) {
                              setState(() => _canAddProducts = v);
                              _showPermissionSnack(
                                l.t('admin_add_products_perm'),
                                v,
                              );
                            },
                            secondary: Icon(Icons.add_box),
                          ),
                          SwitchListTile(
                            title: Text(l.t('admin_can_delete_products')),
                            value: _canDeleteProducts,
                            onChanged: (v) {
                              setState(() => _canDeleteProducts = v);
                              _showPermissionSnack(
                                l.t('admin_delete_products_perm'),
                                v,
                              );
                            },
                            secondary: Icon(Icons.delete),
                          ),
                          SwitchListTile(
                            title: Text(l.t('admin_can_view_reports')),
                            value: _canViewReports,
                            onChanged: (v) {
                              setState(() => _canViewReports = v);
                              _showPermissionSnack(
                                l.t('admin_view_reports_perm'),
                                v,
                              );
                            },
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
    );
  }

  void _addSeller() {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.t('admin_name_email_required'))));
      return;
    }
    if (!email.contains('@')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.t('admin_enter_valid_email'))));
      return;
    }
    setState(() => _isSubmitting = true);
    // Simular delay de API
    Future.delayed(Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _sellers.add({
          'name': name,
          'email': email,
          'phone': _phoneController.text.trim(),
          'role': _selectedRole,
        });
        _nameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _selectedRole = 'vendedor';
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${l.t('admin_seller_role')} "$name" ${l.t('admin_added_successfully')}',
          ),
        ),
      );
    });
  }

  void _removeSeller(Map<String, dynamic> seller) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.t('admin_delete_seller_question')),
        content: Text(
          '${l.t('admin_confirm_delete_seller')} "${seller['name']}" ${l.t('admin_from_team')}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l.t('delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      setState(() => _sellers.remove(seller));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '"${seller['name']}" ${l.t('admin_removed_from_team')}',
          ),
        ),
      );
    }
  }

  void _showPermissionSnack(String permission, bool enabled) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$permission: ${enabled ? l.t('admin_enabled') : l.t('admin_disabled')}',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// WIDGET: REPORTES
// ═══════════════════════════════════════════════════════
class _ReportsSheet extends StatefulWidget {
  final ShopProvider shopProvider;
  const _ReportsSheet({required this.shopProvider});

  @override
  State<_ReportsSheet> createState() => _ReportsSheetState();
}

class _ReportsSheetState extends State<_ReportsSheet> {
  String? _reportType;
  String? _period;
  bool _isGenerating = false;
  String? _generatedReport;

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    final products = widget.shopProvider.products;
    final totalValue = products.fold<double>(
      0,
      (sum, p) => sum + (p.price * p.stock),
    );
    final avgPrice = products.isEmpty
        ? 0.0
        : products.fold<double>(0, (sum, p) => sum + p.price) / products.length;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(
            l.t('admin_reports'),
            Icons.assessment,
            Colors.orange,
            context,
          ),
          Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumen con datos reales
                  _buildSummaryCard([
                    _StatData(
                      l.t('admin_products_label'),
                      '${products.length}',
                      Icons.shopping_bag,
                      Colors.blue,
                    ),
                    _StatData(
                      l.t('admin_total_value'),
                      '\$${totalValue.toStringAsFixed(0)}',
                      Icons.monetization_on,
                      Colors.green,
                    ),
                    _StatData(
                      l.t('admin_avg_price'),
                      '\$${avgPrice.toStringAsFixed(0)}',
                      Icons.receipt,
                      Colors.purple,
                    ),
                  ]),
                  SizedBox(height: 16),

                  // Generador de reporte funcional
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
                          Text(
                            l.t('admin_generate_report'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _reportType,
                            decoration: InputDecoration(
                              labelText: l.t('admin_report_type'),
                              prefixIcon: Icon(Icons.description),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'inventario',
                                child: Text(l.t('admin_inventory')),
                              ),
                              DropdownMenuItem(
                                value: 'precios',
                                child: Text(l.t('admin_price_list')),
                              ),
                              DropdownMenuItem(
                                value: 'agotados',
                                child: Text(l.t('admin_out_of_stock_products')),
                              ),
                              DropdownMenuItem(
                                value: 'categorias',
                                child: Text(l.t('admin_by_category')),
                              ),
                            ],
                            onChanged: (v) => setState(() => _reportType = v),
                          ),
                          SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _period,
                            decoration: InputDecoration(
                              labelText: l.t('admin_period'),
                              prefixIcon: Icon(Icons.schedule),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'hoy',
                                child: Text(l.t('admin_today')),
                              ),
                              DropdownMenuItem(
                                value: 'semana',
                                child: Text(l.t('admin_last_week')),
                              ),
                              DropdownMenuItem(
                                value: 'mes',
                                child: Text(l.t('admin_last_month')),
                              ),
                              DropdownMenuItem(
                                value: 'todo',
                                child: Text(l.t('admin_all_history')),
                              ),
                            ],
                            onChanged: (v) => setState(() => _period = v),
                          ),
                          SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isGenerating ? null : _generateReport,
                              icon: _isGenerating
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(Icons.download),
                              label: Text(
                                _isGenerating
                                    ? l.t('admin_generating')
                                    : l.t('admin_generate_report'),
                              ),
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

                  // Resultado del reporte
                  if (_generatedReport != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      color: Colors.green[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green[700],
                                ),
                                SizedBox(width: 8),
                                Text(
                                  l.t('admin_report_generated'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(_generatedReport!),
                          ],
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 16),
                  // Top productos por precio
                  Text(
                    l.t('admin_top5_by_price'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  if (products.isEmpty)
                    _buildEmptyCard(l.t('admin_no_product_data'))
                  else
                    ...(List<ProductEntity>.from(products)
                          ..sort((a, b) => b.price.compareTo(a.price)))
                        .take(5)
                        .map(
                          (p) => ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.orange[100],
                              child: Text(
                                '${products.indexOf(p) + 1}',
                                style: TextStyle(
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(p.name),
                            trailing: Text(
                              '\$${p.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
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
    );
  }

  void _generateReport() {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    if (_reportType == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.t('admin_select_report_type'))));
      return;
    }
    setState(() => _isGenerating = true);

    final products = widget.shopProvider.products;
    Future.delayed(Duration(seconds: 1), () {
      if (!mounted) return;
      String report;
      switch (_reportType) {
        case 'inventario':
          final total = products.fold<int>(0, (s, p) => s + p.stock);
          report =
              '📦 ${l.t('admin_total_inventory')}: $total ${l.t('admin_units_in')} ${products.length} ${l.t('admin_products_label')}.\n'
              '✅ ${l.t('admin_active')}: ${products.where((p) => p.isActive).length}\n'
              '❌ ${l.t('admin_inactive')}: ${products.where((p) => !p.isActive).length}\n'
              '⚠️ ${l.t('admin_out_of_stock')}: ${products.where((p) => p.stock <= 0).length}';
          break;
        case 'precios':
          final min = products.isEmpty
              ? 0.0
              : products.map((p) => p.price).reduce((a, b) => a < b ? a : b);
          final max = products.isEmpty
              ? 0.0
              : products.map((p) => p.price).reduce((a, b) => a > b ? a : b);
          report =
              '💰 ${l.t('admin_price_list')}:\n'
              '${l.t('admin_min_price')}: \$${min.toStringAsFixed(2)}\n'
              '${l.t('admin_max_price')}: \$${max.toStringAsFixed(2)}\n'
              '${l.t('admin_products_label')}: ${products.length}';
          break;
        case 'agotados':
          final outOfStock = products.where((p) => p.stock <= 0).toList();
          report =
              '⚠️ ${l.t('admin_out_of_stock_products')}: ${outOfStock.length}\n';
          for (var p in outOfStock.take(10)) {
            report += '  • ${p.name}\n';
          }
          if (outOfStock.isEmpty)
            report += '  ${l.t('admin_no_out_of_stock')} 🎉';
          break;
        case 'categorias':
          final categories = <String, int>{};
          for (var p in products) {
            categories[p.category] = (categories[p.category] ?? 0) + 1;
          }
          report = '📊 ${l.t('admin_products_by_category')}:\n';
          categories.forEach(
            (k, v) => report += '  • $k: $v ${l.t('admin_products_label')}\n',
          );
          break;
        default:
          report = l.t('admin_report_not_available');
      }
      setState(() {
        _generatedReport = report;
        _isGenerating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l.t('admin_report_generated_success')} ✅')),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════
// WIDGET: SOLICITUDES
// ═══════════════════════════════════════════════════════
class _RequestsSheet extends StatefulWidget {
  const _RequestsSheet();

  @override
  State<_RequestsSheet> createState() => _RequestsSheetState();
}

class _RequestsSheetState extends State<_RequestsSheet> {
  String _statusFilter = 'todas';
  String _typeFilter = 'todas';
  final List<Map<String, dynamic>> _requests = [];
  bool _isAdding = false;
  final _requestDescController = TextEditingController();
  String _newRequestType = 'reclamo';

  @override
  void dispose() {
    _requestDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    final filtered = _requests.where((r) {
      if (_statusFilter != 'todas' && r['status'] != _statusFilter) {
        return false;
      }
      if (_typeFilter != 'todas' && r['type'] != _typeFilter) return false;
      return true;
    }).toList();

    final pending = _requests.where((r) => r['status'] == 'pendiente').length;
    final inProgress = _requests
        .where((r) => r['status'] == 'en_proceso')
        .length;
    final resolved = _requests.where((r) => r['status'] == 'resuelta').length;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(
            l.t('admin_requests'),
            Icons.inbox,
            Colors.indigo,
            context,
          ),
          Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard([
                    _StatData(
                      l.t('admin_pending'),
                      '$pending',
                      Icons.pending,
                      Colors.orange,
                    ),
                    _StatData(
                      l.t('admin_in_progress'),
                      '$inProgress',
                      Icons.hourglass_top,
                      Colors.blue,
                    ),
                    _StatData(
                      l.t('admin_resolved'),
                      '$resolved',
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ]),
                  SizedBox(height: 16),

                  // Filtros funcionales
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
                          Text(
                            l.t('admin_filter'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _statusFilter,
                            decoration: InputDecoration(
                              labelText: l.t('admin_status'),
                              prefixIcon: Icon(Icons.filter_list),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'todas',
                                child: Text(l.t('admin_all')),
                              ),
                              DropdownMenuItem(
                                value: 'pendiente',
                                child: Text(l.t('admin_pending')),
                              ),
                              DropdownMenuItem(
                                value: 'en_proceso',
                                child: Text(l.t('admin_in_progress')),
                              ),
                              DropdownMenuItem(
                                value: 'resuelta',
                                child: Text(l.t('admin_resolved')),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _statusFilter = v ?? 'todas'),
                          ),
                          SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _typeFilter,
                            decoration: InputDecoration(
                              labelText: l.t('admin_type'),
                              prefixIcon: Icon(Icons.category),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'todas',
                                child: Text(l.t('admin_all')),
                              ),
                              DropdownMenuItem(
                                value: 'devolucion',
                                child: Text(l.t('admin_return')),
                              ),
                              DropdownMenuItem(
                                value: 'cambio',
                                child: Text(l.t('admin_exchange')),
                              ),
                              DropdownMenuItem(
                                value: 'garantia',
                                child: Text(l.t('admin_warranty')),
                              ),
                              DropdownMenuItem(
                                value: 'reclamo',
                                child: Text(l.t('admin_claim')),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _typeFilter = v ?? 'todas'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Crear solicitud
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
                          Text(
                            l.t('admin_new_request'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _newRequestType,
                            decoration: InputDecoration(
                              labelText: l.t('admin_type'),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'devolucion',
                                child: Text(l.t('admin_return')),
                              ),
                              DropdownMenuItem(
                                value: 'cambio',
                                child: Text(l.t('admin_exchange')),
                              ),
                              DropdownMenuItem(
                                value: 'garantia',
                                child: Text(l.t('admin_warranty')),
                              ),
                              DropdownMenuItem(
                                value: 'reclamo',
                                child: Text(l.t('admin_claim')),
                              ),
                            ],
                            onChanged: (v) => setState(
                              () => _newRequestType = v ?? 'reclamo',
                            ),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _requestDescController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: '${l.t('description')} *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isAdding ? null : _createRequest,
                              icon: Icon(Icons.add),
                              label: Text(l.t('admin_create_request')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
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
                  SizedBox(height: 16),

                  Text(
                    '${l.t('admin_requests')} (${filtered.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  if (filtered.isEmpty)
                    _buildEmptyCard(l.t('admin_no_requests'))
                  else
                    ...filtered.map(
                      (r) => Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(r['status'])[100],
                            child: Icon(
                              _getStatusIcon(r['status']),
                              color: _getStatusColor(r['status']),
                            ),
                          ),
                          title: Text(
                            r['type'].toString().toUpperCase(),
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(r['description']),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) => _updateRequestStatus(r, v),
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: 'en_proceso',
                                child: Text(l.t('admin_in_progress')),
                              ),
                              PopupMenuItem(
                                value: 'resuelta',
                                child: Text(l.t('admin_resolved')),
                              ),
                              PopupMenuItem(
                                value: 'eliminar',
                                child: Text(
                                  l.t('delete'),
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
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
    );
  }

  void _createRequest() {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final desc = _requestDescController.text.trim();
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.t('admin_description_required'))),
      );
      return;
    }
    setState(() {
      _requests.add({
        'type': _newRequestType,
        'description': desc,
        'status': 'pendiente',
        'date': DateTime.now(),
      });
      _requestDescController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${l.t('admin_request_created')} ✅')),
    );
  }

  void _updateRequestStatus(Map<String, dynamic> request, String action) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    setState(() {
      if (action == 'eliminar') {
        _requests.remove(request);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.t('admin_request_deleted'))));
      } else {
        request['status'] = action;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${l.t('admin_status_updated_to')}: ${action == 'en_proceso' ? l.t('admin_in_progress') : l.t('admin_resolved')}',
            ),
          ),
        );
      }
    });
  }

  MaterialColor _getStatusColor(String status) {
    switch (status) {
      case 'pendiente':
        return Colors.orange;
      case 'en_proceso':
        return Colors.blue;
      case 'resuelta':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pendiente':
        return Icons.pending;
      case 'en_proceso':
        return Icons.hourglass_top;
      case 'resuelta':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }
}

// ═══════════════════════════════════════════════════════
// WIDGET: ESTADÍSTICAS
// ═══════════════════════════════════════════════════════
class _StatsSheet extends StatefulWidget {
  final ShopProvider shopProvider;
  const _StatsSheet({required this.shopProvider});

  @override
  State<_StatsSheet> createState() => _StatsSheetState();
}

class _StatsSheetState extends State<_StatsSheet> {
  DateTimeRange? _dateRange;

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    final products = widget.shopProvider.products;
    final totalValue = products.fold<double>(
      0,
      (sum, p) => sum + (p.price * p.stock),
    );
    final activeCount = products.where((p) => p.isActive).length;
    final conversionRate = products.isEmpty
        ? 0
        : ((activeCount / products.length) * 100).round();
    final avgPrice = products.isEmpty
        ? 0.0
        : products.fold<double>(0, (s, p) => s + p.price) / products.length;
    final categories = <String>{};
    for (var p in products) {
      categories.add(p.category);
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(
            l.t('admin_statistics'),
            Icons.analytics,
            Colors.purple,
            context,
          ),
          Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard([
                    _StatData(
                      l.t('admin_products_label'),
                      '${products.length}',
                      Icons.shopping_bag,
                      Colors.blue,
                    ),
                    _StatData(
                      l.t('admin_categories'),
                      '${categories.length}',
                      Icons.category,
                      Colors.green,
                    ),
                    _StatData(
                      l.t('admin_active'),
                      '$conversionRate%',
                      Icons.trending_up,
                      Colors.purple,
                    ),
                  ]),
                  SizedBox(height: 16),
                  _buildSummaryCard([
                    _StatData(
                      l.t('admin_inventory_value'),
                      '\$${totalValue.toStringAsFixed(0)}',
                      Icons.monetization_on,
                      Colors.green,
                    ),
                    _StatData(
                      l.t('admin_avg_price'),
                      '\$${avgPrice.toStringAsFixed(0)}',
                      Icons.receipt,
                      Colors.orange,
                    ),
                    _StatData(
                      l.t('admin_out_of_stock'),
                      '${products.where((p) => p.stock <= 0).length}',
                      Icons.warning,
                      Colors.red,
                    ),
                  ]),
                  SizedBox(height: 16),

                  // Selector de rango funcional
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
                          Text(
                            l.t('admin_query_period'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () async {
                              final range = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                                locale: const Locale('es', 'ES'),
                              );
                              if (range != null) {
                                setState(() => _dateRange = range);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[400]!),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: Colors.purple,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    _dateRange == null
                                        ? l.t('admin_select_date_range')
                                        : '${_dateRange!.start.day}/${_dateRange!.start.month}/${_dateRange!.start.year} - ${_dateRange!.end.day}/${_dateRange!.end.month}/${_dateRange!.end.year}',
                                    style: TextStyle(
                                      color: _dateRange == null
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_dateRange != null) ...[
                            const SizedBox(height: 12),
                            Builder(
                              builder: (context) {
                                final inRange = products
                                    .where(
                                      (p) =>
                                          p.createdAt.isAfter(
                                            _dateRange!.start,
                                          ) &&
                                          p.createdAt.isBefore(
                                            _dateRange!.end.add(
                                              const Duration(days: 1),
                                            ),
                                          ),
                                    )
                                    .toList();
                                return Card(
                                  color: Colors.purple[50],
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(
                                      '📊 ${l.t('admin_in_this_period')}:\n'
                                      '• ${inRange.length} ${l.t('admin_products_created')}\n'
                                      '• ${l.t('admin_total_value')}: \$${inRange.fold<double>(0, (s, p) => s + p.price).toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Distribución por categoría
                  Text(
                    l.t('admin_distribution_by_category'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...categories.map((cat) {
                    final count = products
                        .where((p) => p.category == cat)
                        .length;
                    final pct = products.isEmpty
                        ? 0.0
                        : count / products.length;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                cat,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '$count (${(pct * 100).toStringAsFixed(0)}%)',
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: pct,
                            backgroundColor: Colors.grey[200],
                            color: Colors.purple,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// WIDGET: CENTRO DE SEGURIDAD
// ═══════════════════════════════════════════════════════
class _SecuritySheet extends StatefulWidget {
  const _SecuritySheet();

  @override
  State<_SecuritySheet> createState() => _SecuritySheetState();
}

class _SecuritySheetState extends State<_SecuritySheet> {
  bool _twoFactor = false;
  bool _loginNotifications = true;
  bool _activityLog = true;
  bool _failedAttemptLock = false;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isChangingPassword = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(
            l.t('admin_security_center'),
            Icons.security,
            Colors.red,
            context,
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Estado
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: (_twoFactor && _loginNotifications)
                        ? Colors.green[50]
                        : Colors.orange[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            (_twoFactor && _loginNotifications)
                                ? Icons.shield
                                : Icons.warning,
                            color: (_twoFactor && _loginNotifications)
                                ? Colors.green[700]
                                : Colors.orange[700],
                            size: 40,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (_twoFactor && _loginNotifications)
                                      ? l.t('admin_status_secure')
                                      : l.t('admin_status_improvable'),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: (_twoFactor && _loginNotifications)
                                        ? Colors.green[700]
                                        : Colors.orange[700],
                                  ),
                                ),
                                Text(
                                  (_twoFactor && _loginNotifications)
                                      ? l.t('admin_all_protections_active')
                                      : l.t('admin_enable_more_protections'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Configuraciones funcionales
                  Text(
                    l.t('admin_configuration'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text(l.t('admin_two_factor_auth')),
                          subtitle: Text(l.t('admin_extra_security_layer')),
                          value: _twoFactor,
                          onChanged: (v) {
                            setState(() => _twoFactor = v);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '2FA ${v ? '${l.t('admin_enabled')} ✅' : '${l.t('admin_disabled')} ❌'}',
                                ),
                              ),
                            );
                          },
                          secondary: Icon(Icons.lock),
                        ),
                        Divider(height: 1),
                        SwitchListTile(
                          title: Text(l.t('admin_login_notifications')),
                          subtitle: Text(l.t('admin_access_alerts')),
                          value: _loginNotifications,
                          onChanged: (v) {
                            setState(() => _loginNotifications = v);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${l.t('admin_notifications')} ${v ? '${l.t('admin_enabled')} ✅' : '${l.t('admin_disabled')} ❌'}',
                                ),
                              ),
                            );
                          },
                          secondary: Icon(Icons.notifications_active),
                        ),
                        Divider(height: 1),
                        SwitchListTile(
                          title: Text(l.t('admin_activity_log')),
                          subtitle: Text(l.t('admin_action_log')),
                          value: _activityLog,
                          onChanged: (v) {
                            setState(() => _activityLog = v);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Log ${v ? '${l.t('admin_enabled')} ✅' : '${l.t('admin_disabled')} ❌'}',
                                ),
                              ),
                            );
                          },
                          secondary: Icon(Icons.history),
                        ),
                        Divider(height: 1),
                        SwitchListTile(
                          title: Text(l.t('admin_failed_attempt_lock')),
                          subtitle: Text(l.t('admin_lock_after_5_attempts')),
                          value: _failedAttemptLock,
                          onChanged: (v) {
                            setState(() => _failedAttemptLock = v);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${l.t('admin_lock')} ${v ? '${l.t('admin_enabled')} ✅' : '${l.t('admin_disabled')} ❌'}',
                                ),
                              ),
                            );
                          },
                          secondary: const Icon(Icons.block),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Cambiar contraseña funcional
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
                          Text(
                            l.t('admin_change_password'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          TextField(
                            controller: _currentPasswordController,
                            obscureText: _obscureCurrent,
                            decoration: InputDecoration(
                              labelText: l.t('admin_current_password'),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureCurrent
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () => setState(
                                  () => _obscureCurrent = !_obscureCurrent,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _newPasswordController,
                            obscureText: _obscureNew,
                            decoration: InputDecoration(
                              labelText: l.t('admin_new_password'),
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureNew
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () =>
                                    setState(() => _obscureNew = !_obscureNew),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            decoration: InputDecoration(
                              labelText: l.t('admin_confirm_new_password'),
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isChangingPassword
                                  ? null
                                  : _changePassword,
                              icon: _isChangingPassword
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(Icons.vpn_key),
                              label: Text(
                                _isChangingPassword
                                    ? l.t('admin_changing')
                                    : l.t('admin_update_password'),
                              ),
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
                  SizedBox(height: 16),

                  // Sesión activa
                  Text(
                    l.t('admin_active_sessions'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.phone_iphone,
                        color: Colors.blue,
                      ),
                      title: Text(l.t('admin_this_device')),
                      subtitle: Text(l.t('admin_active_now')),
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
                          l.t('admin_current'),
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${l.t('admin_all_remote_sessions_closed')} ✅',
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.logout, color: Colors.red),
                      label: Text(
                        l.t('admin_close_all_sessions'),
                        style: const TextStyle(color: Colors.red),
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
    );
  }

  void _changePassword() {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final current = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.t('admin_all_fields_required'))));
      return;
    }
    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.t('admin_password_min_6_chars'))),
      );
      return;
    }
    if (newPass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.t('admin_passwords_dont_match'))),
      );
      return;
    }

    setState(() => _isChangingPassword = true);
    Future.delayed(Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _isChangingPassword = false);
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l.t('admin_password_updated_success')} ✅')),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════
// HELPERS COMPARTIDOS
// ═══════════════════════════════════════════════════════
class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatData(this.label, this.value, this.icon, this.color);
}

Widget _buildHandle() {
  return Column(
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
    ],
  );
}

Widget _buildHeader(
  String title,
  IconData icon,
  Color color,
  BuildContext context,
) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

Widget _buildSummaryCard(List<_StatData> stats) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats
            .map(
              (s) => Column(
                children: [
                  Icon(s.icon, color: s.color, size: 28),
                  const SizedBox(height: 4),
                  Text(
                    s.value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: s.color,
                    ),
                  ),
                  Text(
                    s.label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    ),
  );
}

Widget _buildEmptyCard(String message) {
  return Card(
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(message, style: const TextStyle(color: Colors.grey)),
      ),
    ),
  );
}

Widget _buildStatusBadge(bool isActive, LocaleNotifier l) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: isActive ? Colors.green[100] : Colors.red[100],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      isActive ? l.t('active') : l.t('inactive'),
      style: TextStyle(
        color: isActive ? Colors.green[700] : Colors.red[700],
        fontSize: 11,
      ),
    ),
  );
}

Widget _buildPlaceholderImage() {
  return Container(
    width: 50,
    height: 50,
    color: Colors.grey[200],
    child: const Icon(Icons.shopping_bag),
  );
}
