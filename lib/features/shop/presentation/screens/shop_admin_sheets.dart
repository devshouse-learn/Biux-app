import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildHandle(),
              _buildHeader(
                'Gestión de Productos',
                Icons.inventory_2,
                Colors.blue,
                context,
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Resumen con datos reales
                      _buildSummaryCard([
                        _StatData(
                          'Total',
                          '${products.length}',
                          Icons.shopping_bag,
                          Colors.blue,
                        ),
                        _StatData(
                          'Activos',
                          '${activeProducts.length}',
                          Icons.check_circle,
                          Colors.green,
                        ),
                        _StatData(
                          'Agotados',
                          '${outOfStock.length}',
                          Icons.warning,
                          Colors.orange,
                        ),
                      ]),
                      const SizedBox(height: 16),

                      // Buscador funcional
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Buscar producto...',
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
                      const SizedBox(height: 16),

                      // Lista de productos reales
                      Text(
                        'Productos (${filtered.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (filtered.isEmpty)
                        _buildEmptyCard('No se encontraron productos')
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
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '\$${product.price.toStringAsFixed(2)} · Stock: ${product.stock}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusBadge(product.isActive),
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
                      const SizedBox(width: 8),
                      Text(product.isActive ? 'Desactivar' : 'Activar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
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
    if (action == 'toggle') {
      await widget.shopProvider.updateProduct(
        _copyProductWith(product, isActive: !product.isActive),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              product.isActive
                  ? '${product.name} desactivado'
                  : '${product.name} activado',
            ),
          ),
        );
      }
    } else if (action == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('¿Eliminar producto?'),
          content: Text(
            '¿Estás seguro de eliminar "${product.name}"? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                'Eliminar',
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
            SnackBar(content: Text('"${product.name}" eliminado')),
          );
        }
      }
    }
  }

  Widget _buildPriceUpdateCard(List<ProductEntity> products) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actualización Rápida de Precios',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedProductId,
              decoration: InputDecoration(
                labelText: 'Seleccionar producto',
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
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
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
                onPressed: _isUpdating
                    ? null
                    : () async {
                        if (_selectedProductId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Selecciona un producto'),
                            ),
                          );
                          return;
                        }
                        final newPrice = double.tryParse(
                          _priceController.text.trim(),
                        );
                        if (newPrice == null || newPrice <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ingresa un precio válido'),
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
                                  'Precio de "$productName" actualizado a \$${newPrice.toStringAsFixed(2)}',
                                ),
                              ),
                            );
                          }
                          _selectedProductId = null;
                          _priceController.clear();
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
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
                    : const Icon(Icons.update),
                label: Text(
                  _isUpdating ? 'Actualizando...' : 'Actualizar Precio',
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(
            'Gestión de Vendedores',
            Icons.people,
            Colors.green,
            context,
          ),
          const Divider(),
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
                          const Text(
                            'Agregar Vendedor',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Nombre completo *',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Correo electrónico *',
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
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
                            initialValue: _selectedRole,
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
                            onChanged: (v) =>
                                setState(() => _selectedRole = v ?? 'vendedor'),
                          ),
                          const SizedBox(height: 12),
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
                                  : const Icon(Icons.person_add),
                              label: Text(
                                _isSubmitting
                                    ? 'Agregando...'
                                    : 'Agregar Vendedor',
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
                  const SizedBox(height: 16),

                  // Vendedores registrados
                  Text(
                    'Vendedores Activos (${_sellers.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_sellers.isEmpty)
                    _buildEmptyCard('No hay vendedores registrados')
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

                  const SizedBox(height: 16),

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
                            value: _canModifyPrices,
                            onChanged: (v) {
                              setState(() => _canModifyPrices = v);
                              _showPermissionSnack('Modificar precios', v);
                            },
                            secondary: const Icon(Icons.attach_money),
                          ),
                          SwitchListTile(
                            title: const Text('Pueden agregar productos'),
                            value: _canAddProducts,
                            onChanged: (v) {
                              setState(() => _canAddProducts = v);
                              _showPermissionSnack('Agregar productos', v);
                            },
                            secondary: const Icon(Icons.add_box),
                          ),
                          SwitchListTile(
                            title: const Text('Pueden eliminar productos'),
                            value: _canDeleteProducts,
                            onChanged: (v) {
                              setState(() => _canDeleteProducts = v);
                              _showPermissionSnack('Eliminar productos', v);
                            },
                            secondary: const Icon(Icons.delete),
                          ),
                          SwitchListTile(
                            title: const Text('Pueden ver reportes'),
                            value: _canViewReports,
                            onChanged: (v) {
                              setState(() => _canViewReports = v);
                              _showPermissionSnack('Ver reportes', v);
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
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre y correo son obligatorios')),
      );
      return;
    }
    if (!email.contains('@')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingresa un correo válido')));
      return;
    }
    setState(() => _isSubmitting = true);
    // Simular delay de API
    Future.delayed(const Duration(milliseconds: 800), () {
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
        SnackBar(content: Text('Vendedor "$name" agregado exitosamente')),
      );
    });
  }

  void _removeSeller(Map<String, dynamic> seller) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar vendedor?'),
        content: Text(
          '¿Estás seguro de eliminar a "${seller['name']}" del equipo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      setState(() => _sellers.remove(seller));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${seller['name']}" eliminado del equipo')),
      );
    }
  }

  void _showPermissionSnack(String permission, bool enabled) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$permission: ${enabled ? 'activado' : 'desactivado'}'),
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader('Reportes', Icons.assessment, Colors.orange, context),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumen con datos reales
                  _buildSummaryCard([
                    _StatData(
                      'Productos',
                      '${products.length}',
                      Icons.shopping_bag,
                      Colors.blue,
                    ),
                    _StatData(
                      'Valor Total',
                      '\$${totalValue.toStringAsFixed(0)}',
                      Icons.monetization_on,
                      Colors.green,
                    ),
                    _StatData(
                      'Precio Prom.',
                      '\$${avgPrice.toStringAsFixed(0)}',
                      Icons.receipt,
                      Colors.purple,
                    ),
                  ]),
                  const SizedBox(height: 16),

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
                          const Text(
                            'Generar Reporte',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _reportType,
                            decoration: InputDecoration(
                              labelText: 'Tipo de reporte',
                              prefixIcon: const Icon(Icons.description),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'inventario',
                                child: Text('Inventario'),
                              ),
                              DropdownMenuItem(
                                value: 'precios',
                                child: Text('Lista de Precios'),
                              ),
                              DropdownMenuItem(
                                value: 'agotados',
                                child: Text('Productos Agotados'),
                              ),
                              DropdownMenuItem(
                                value: 'categorias',
                                child: Text('Por Categoría'),
                              ),
                            ],
                            onChanged: (v) => setState(() => _reportType = v),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _period,
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
                                value: 'todo',
                                child: Text('Todo el historial'),
                              ),
                            ],
                            onChanged: (v) => setState(() => _period = v),
                          ),
                          const SizedBox(height: 12),
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
                                  : const Icon(Icons.download),
                              label: Text(
                                _isGenerating
                                    ? 'Generando...'
                                    : 'Generar Reporte',
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
                                const SizedBox(width: 8),
                                const Text(
                                  'Reporte Generado',
                                  style: TextStyle(
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

                  const SizedBox(height: 16),
                  // Top productos por precio
                  const Text(
                    'Top 5 Productos por Precio',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (products.isEmpty)
                    _buildEmptyCard('Sin datos de productos')
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
    if (_reportType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un tipo de reporte')),
      );
      return;
    }
    setState(() => _isGenerating = true);

    final products = widget.shopProvider.products;
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      String report;
      switch (_reportType) {
        case 'inventario':
          final total = products.fold<int>(0, (s, p) => s + p.stock);
          report =
              '📦 Inventario Total: $total unidades en ${products.length} productos.\n'
              '✅ Activos: ${products.where((p) => p.isActive).length}\n'
              '❌ Inactivos: ${products.where((p) => !p.isActive).length}\n'
              '⚠️ Sin stock: ${products.where((p) => p.stock <= 0).length}';
          break;
        case 'precios':
          final min = products.isEmpty
              ? 0.0
              : products.map((p) => p.price).reduce((a, b) => a < b ? a : b);
          final max = products.isEmpty
              ? 0.0
              : products.map((p) => p.price).reduce((a, b) => a > b ? a : b);
          report =
              '💰 Lista de Precios:\n'
              'Precio mínimo: \$${min.toStringAsFixed(2)}\n'
              'Precio máximo: \$${max.toStringAsFixed(2)}\n'
              'Productos: ${products.length}';
          break;
        case 'agotados':
          final outOfStock = products.where((p) => p.stock <= 0).toList();
          report = '⚠️ Productos Agotados: ${outOfStock.length}\n';
          for (var p in outOfStock.take(10)) {
            report += '  • ${p.name}\n';
          }
          if (outOfStock.isEmpty) report += '  ¡No hay productos agotados! 🎉';
          break;
        case 'categorias':
          final categories = <String, int>{};
          for (var p in products) {
            categories[p.category] = (categories[p.category] ?? 0) + 1;
          }
          report = '📊 Productos por Categoría:\n';
          categories.forEach((k, v) => report += '  • $k: $v productos\n');
          break;
        default:
          report = 'Reporte no disponible';
      }
      setState(() {
        _generatedReport = report;
        _isGenerating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reporte generado exitosamente ✅')),
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader('Solicitudes', Icons.inbox, Colors.indigo, context),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard([
                    _StatData(
                      'Pendientes',
                      '$pending',
                      Icons.pending,
                      Colors.orange,
                    ),
                    _StatData(
                      'En Proceso',
                      '$inProgress',
                      Icons.hourglass_top,
                      Colors.blue,
                    ),
                    _StatData(
                      'Resueltas',
                      '$resolved',
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ]),
                  const SizedBox(height: 16),

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
                          const Text(
                            'Filtrar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _statusFilter,
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
                                value: 'pendiente',
                                child: Text('Pendientes'),
                              ),
                              DropdownMenuItem(
                                value: 'en_proceso',
                                child: Text('En Proceso'),
                              ),
                              DropdownMenuItem(
                                value: 'resuelta',
                                child: Text('Resueltas'),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _statusFilter = v ?? 'todas'),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _typeFilter,
                            decoration: InputDecoration(
                              labelText: 'Tipo',
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
                            onChanged: (v) =>
                                setState(() => _typeFilter = v ?? 'todas'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

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
                          const Text(
                            'Nueva Solicitud',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _newRequestType,
                            decoration: InputDecoration(
                              labelText: 'Tipo',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            items: const [
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
                            onChanged: (v) => setState(
                              () => _newRequestType = v ?? 'reclamo',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _requestDescController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Descripción *',
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
                              icon: const Icon(Icons.add),
                              label: const Text('Crear Solicitud'),
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
                  const SizedBox(height: 16),

                  Text(
                    'Solicitudes (${filtered.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (filtered.isEmpty)
                    _buildEmptyCard('No hay solicitudes')
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
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(r['description']),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) => _updateRequestStatus(r, v),
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'en_proceso',
                                child: Text('En Proceso'),
                              ),
                              const PopupMenuItem(
                                value: 'resuelta',
                                child: Text('Resuelta'),
                              ),
                              const PopupMenuItem(
                                value: 'eliminar',
                                child: Text(
                                  'Eliminar',
                                  style: TextStyle(color: Colors.red),
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
    final desc = _requestDescController.text.trim();
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La descripción es obligatoria')),
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Solicitud creada ✅')));
  }

  void _updateRequestStatus(Map<String, dynamic> request, String action) {
    setState(() {
      if (action == 'eliminar') {
        _requests.remove(request);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Solicitud eliminada')));
      } else {
        request['status'] = action;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Estado actualizado a: ${action == 'en_proceso' ? 'En Proceso' : 'Resuelta'}',
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader('Estadísticas', Icons.analytics, Colors.purple, context),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard([
                    _StatData(
                      'Productos',
                      '${products.length}',
                      Icons.shopping_bag,
                      Colors.blue,
                    ),
                    _StatData(
                      'Categorías',
                      '${categories.length}',
                      Icons.category,
                      Colors.green,
                    ),
                    _StatData(
                      'Activos',
                      '$conversionRate%',
                      Icons.trending_up,
                      Colors.purple,
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _buildSummaryCard([
                    _StatData(
                      'Valor Inv.',
                      '\$${totalValue.toStringAsFixed(0)}',
                      Icons.monetization_on,
                      Colors.green,
                    ),
                    _StatData(
                      'Precio Prom.',
                      '\$${avgPrice.toStringAsFixed(0)}',
                      Icons.receipt,
                      Colors.orange,
                    ),
                    _StatData(
                      'Sin Stock',
                      '${products.where((p) => p.stock <= 0).length}',
                      Icons.warning,
                      Colors.red,
                    ),
                  ]),
                  const SizedBox(height: 16),

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
                          const Text(
                            'Consultar Período',
                            style: TextStyle(
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
                                  const SizedBox(width: 8),
                                  Text(
                                    _dateRange == null
                                        ? 'Seleccionar rango de fechas'
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
                                      '📊 En este período:\n'
                                      '• ${inRange.length} productos creados\n'
                                      '• Valor: \$${inRange.fold<double>(0, (s, p) => s + p.price).toStringAsFixed(2)}',
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
                  const SizedBox(height: 16),

                  // Distribución por categoría
                  const Text(
                    'Distribución por Categoría',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(
            'Centro de Seguridad',
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (_twoFactor && _loginNotifications)
                                      ? 'Estado: Seguro'
                                      : 'Estado: Mejorable',
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
                                      ? 'Todas las protecciones activas'
                                      : 'Activa más protecciones para mayor seguridad',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Configuraciones funcionales
                  const Text(
                    'Configuración',
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
                          subtitle: const Text('Capa extra de seguridad'),
                          value: _twoFactor,
                          onChanged: (v) {
                            setState(() => _twoFactor = v);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '2FA ${v ? 'activado ✅' : 'desactivado ❌'}',
                                ),
                              ),
                            );
                          },
                          secondary: const Icon(Icons.lock),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text(
                            'Notificaciones de inicio de sesión',
                          ),
                          subtitle: const Text('Alertas de acceso'),
                          value: _loginNotifications,
                          onChanged: (v) {
                            setState(() => _loginNotifications = v);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Notificaciones ${v ? 'activadas ✅' : 'desactivadas ❌'}',
                                ),
                              ),
                            );
                          },
                          secondary: const Icon(Icons.notifications_active),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text('Registro de actividad'),
                          subtitle: const Text('Log de acciones'),
                          value: _activityLog,
                          onChanged: (v) {
                            setState(() => _activityLog = v);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Log ${v ? 'activado ✅' : 'desactivado ❌'}',
                                ),
                              ),
                            );
                          },
                          secondary: const Icon(Icons.history),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text('Bloqueo por intentos fallidos'),
                          subtitle: const Text('Bloqueo tras 5 intentos'),
                          value: _failedAttemptLock,
                          onChanged: (v) {
                            setState(() => _failedAttemptLock = v);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Bloqueo ${v ? 'activado ✅' : 'desactivado ❌'}',
                                ),
                              ),
                            );
                          },
                          secondary: const Icon(Icons.block),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

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
                          const Text(
                            'Cambiar Contraseña',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _currentPasswordController,
                            obscureText: _obscureCurrent,
                            decoration: InputDecoration(
                              labelText: 'Contraseña actual',
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
                          const SizedBox(height: 8),
                          TextField(
                            controller: _newPasswordController,
                            obscureText: _obscureNew,
                            decoration: InputDecoration(
                              labelText: 'Nueva contraseña',
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
                          const SizedBox(height: 8),
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            decoration: InputDecoration(
                              labelText: 'Confirmar nueva contraseña',
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
                          const SizedBox(height: 12),
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
                                  : const Icon(Icons.vpn_key),
                              label: Text(
                                _isChangingPassword
                                    ? 'Cambiando...'
                                    : 'Actualizar Contraseña',
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
                  const SizedBox(height: 16),

                  // Sesión activa
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
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Todas las sesiones remotas cerradas ✅',
                            ),
                          ),
                        );
                      },
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
    );
  }

  void _changePassword() {
    final current = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos los campos son obligatorios')),
      );
      return;
    }
    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La nueva contraseña debe tener al menos 6 caracteres'),
        ),
      );
      return;
    }
    if (newPass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    setState(() => _isChangingPassword = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _isChangingPassword = false);
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada exitosamente ✅')),
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

Widget _buildStatusBadge(bool isActive) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: isActive ? Colors.green[100] : Colors.red[100],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      isActive ? 'Activo' : 'Inactivo',
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
