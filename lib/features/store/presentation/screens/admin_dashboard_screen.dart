import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/features/users/domain/entities/user_entity.dart';
import 'package:biux/features/store/presentation/providers/product_provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

/// Panel de administración para gestionar usuarios, vendedores y productos
class AdminDashboardScreen extends StatefulWidget {
  final UserEntity currentUser;

  const AdminDashboardScreen({super.key, required this.currentUser});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);

    // Verificar permisos de admin
    if (!widget.currentUser.isAdministrador) {
      return Scaffold(
        appBar: AppBar(title: Text(l.t('admin_panel_title'))),
        body: Center(child: Text(l.t('no_admin_permissions'))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('admin_panel_title')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.people), text: l.t('users')),
            Tab(icon: const Icon(Icons.store), text: l.t('sellers_tab')),
            Tab(icon: const Icon(Icons.inventory), text: l.t('products_tab')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildUsersTab(), _buildSellersTab(), _buildProductsTab()],
      ),
    );
  }

  // Tab 1: Gestión de usuarios
  Widget _buildUsersTab() {
    final l = Provider.of<LocaleNotifier>(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.t('user_management'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(l.t('user_management_desc')),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showUsersList(),
                  icon: const Icon(Icons.people),
                  label: Text(l.t('view_all_users')),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildStatsCard(l.t('total_users'), '0', Icons.people, Colors.blue),
      ],
    );
  }

  // Tab 2: Gestión de vendedores
  Widget _buildSellersTab() {
    final l = Provider.of<LocaleNotifier>(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.t('seller_management'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(l.t('seller_management_desc')),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAuthorizeSellerDialog(),
                        icon: const Icon(Icons.person_add),
                        label: Text(l.t('authorize_seller')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showRevokeSellerDialog(),
                        icon: const Icon(Icons.person_remove),
                        label: Text(l.t('revoke_permissions')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildStatsCard(l.t('active_sellers'), '0', Icons.store, Colors.green),
      ],
    );
  }

  // Tab 3: Gestión de productos
  Widget _buildProductsTab() {
    final l = Provider.of<LocaleNotifier>(context);
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.t('product_management'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(l.t('product_management_desc')),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<ProductProvider>().loadAllProducts();
                        },
                        icon: const Icon(Icons.refresh),
                        label: Text(l.t('reload_products')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatsCard(
                      l.t('total_products'),
                      '${provider.products.length}',
                      Icons.inventory,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatsCard(
                      l.t('featured'),
                      '${provider.featuredProducts.length}',
                      Icons.star,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.products.isEmpty
                  ? Center(child: Text(l.t('no_products')))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: provider.products.length,
                      itemBuilder: (context, index) {
                        final product = provider.products[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: product.imagenPrincipal != null
                                  ? Image.network(
                                      product.imagenPrincipal!,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 50,
                                              height: 50,
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.image,
                                                size: 25,
                                              ),
                                            );
                                          },
                                    )
                                  : Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.image, size: 25),
                                    ),
                            ),
                            title: Text(
                              product.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${l.t('seller')}: ${product.vendedorNombre ?? l.t('unknown')}\n'
                              '\$${product.precio.toStringAsFixed(2)} • Stock: ${product.stock}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (product.destacado)
                                  const Icon(
                                    Icons.star,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      _confirmDeleteProduct(product),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUsersList() {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.t('users_list')),
        content: SingleChildScrollView(
          child: Text(
            l.t('users_list_demo_content'),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.t('close')),
          ),
        ],
      ),
    );
  }

  void _showAuthorizeSellerDialog() {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.t('authorize_seller')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.t('select_user_to_authorize')),
              const SizedBox(height: 16),
              Text(
                l.t('authorize_seller_demo_list'),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              // PENDIENTE: Implementar autorización real
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l.t('user_authorized_seller_demo')),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(l.t('authorize')),
          ),
        ],
      ),
    );
  }

  void _showRevokeSellerDialog() {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.t('revoke_seller_permissions')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.t('select_seller_to_revoke')),
              const SizedBox(height: 16),
              Text(
                l.t('revoke_seller_demo_list'),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              // PENDIENTE: Implementar revocación real
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l.t('seller_permissions_revoked_demo')),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l.t('revoke')),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProduct(product) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.t('delete_product')),
        content: Text(
          '${l.t('delete_product_confirm')}\n\n"${product.nombre}"\n\n'
          '${l.t('seller')}: ${product.vendedorNombre ?? l.t('unknown')}\n\n'
          '${l.t('action_cannot_be_undone')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<ProductProvider>().deleteProduct(
                  product.id,
                  product,
                  widget.currentUser,
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l.t('product_deleted_by_admin')),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${l.t('error')}: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l.t('delete')),
          ),
        ],
      ),
    );
  }
}
