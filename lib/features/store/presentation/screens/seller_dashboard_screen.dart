import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/features/store/domain/entities/product_entity.dart';
import 'package:biux/features/store/presentation/providers/product_provider.dart';
import 'package:biux/features/users/domain/entities/user_entity.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

/// Panel de vendedor para gestionar sus productos
class SellerDashboardScreen extends StatefulWidget {
  final UserEntity currentUser;

  const SellerDashboardScreen({super.key, required this.currentUser});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadSellerProducts();
  }

  void _loadSellerProducts() {
    context.read<ProductProvider>().loadSellerProducts(widget.currentUser.id);
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);

    // Verificar permisos
    if (!widget.currentUser.canCreateProducts) {
      return Scaffold(
        appBar: AppBar(title: Text(l.t('seller_panel'))),
        body: Center(child: Text(l.t('no_seller_permissions'))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('my_products')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSellerProducts,
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${l.t('error')}: ${provider.error}'),
                  ElevatedButton(
                    onPressed: _loadSellerProducts,
                    child: Text(l.t('retry')),
                  ),
                ],
              ),
            );
          }

          if (provider.products.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async => _loadSellerProducts(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.products.length,
              itemBuilder: (context, index) {
                final product = provider.products[index];
                return _buildProductCard(product);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(),
        icon: const Icon(Icons.add),
        label: Text(l.t('add_product')),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l = Provider.of<LocaleNotifier>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            l.t('no_products_yet'),
            style: TextStyle(fontSize: 20, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            l.t('add_first_product_desc'),
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddProductDialog(),
            icon: const Icon(Icons.add),
            label: Text(l.t('add_product')),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductEntity product) {
    final l = Provider.of<LocaleNotifier>(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: product.imagenPrincipal != null
              ? Image.network(
                  product.imagenPrincipal!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image),
                    );
                  },
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image),
                ),
        ),
        title: Text(
          product.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '\$${product.precio.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  product.activo ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: product.activo ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  product.activo
                      ? l.t('active_status')
                      : l.t('inactive_status'),
                  style: TextStyle(
                    fontSize: 12,
                    color: product.activo ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Stock: ${product.stock}',
                  style: TextStyle(
                    fontSize: 12,
                    color: product.stock > 0 ? Colors.black : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit),
                  const SizedBox(width: 8),
                  Text(l.t('edit')),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    product.activo ? Icons.visibility_off : Icons.visibility,
                  ),
                  const SizedBox(width: 8),
                  Text(product.activo ? l.t('deactivate') : l.t('activate')),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    l.t('delete'),
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditProductDialog(product);
                break;
              case 'toggle':
                _toggleProductStatus(product);
                break;
              case 'delete':
                _confirmDelete(product);
                break;
            }
          },
        ),
      ),
    );
  }

  void _showAddProductDialog() {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.t('add_product')),
        content: SingleChildScrollView(
          child: Text(
            l.t('add_product_form_demo'),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.t('close')),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implementar creación real
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l.t('feature_in_development'))),
              );
            },
            child: Text(l.t('save')),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(ProductEntity product) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.t('edit_product')),
        content: SingleChildScrollView(
          child: Text(
            '${l.t('editing_label')}: ${product.nombre}\n\n${l.t('edit_product_form_demo')}',
            style: const TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implementar edición real
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l.t('feature_in_development'))),
              );
            },
            child: Text(l.t('save_changes')),
          ),
        ],
      ),
    );
  }

  void _toggleProductStatus(ProductEntity product) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    // TODO: Implementar activar/desactivar producto
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${product.activo ? l.t('deactivate') : l.t('activate')} (Demo)',
        ),
      ),
    );
  }

  void _confirmDelete(ProductEntity product) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.t('delete_product')),
        content: Text(
          '${l.t('delete_product_confirm')}\n\n"${product.nombre}"\n\n'
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
                      content: Text(l.t('product_deleted')),
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
