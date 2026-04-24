import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
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
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

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
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    // Verificar permisos
    if (!widget.currentUser.canCreateProducts) {
      return Scaffold(
        appBar: AppBar(title: const Text('Panel de Vendedor')),
        body: const Center(child: Text('No tienes permisos de vendedor')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Productos'),
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
                  Text('${l.t('error_generic')}: ${provider.error}'),
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
        label: const Text('Agregar Producto'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No tienes productos',
            style: TextStyle(fontSize: 20, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega tu primer producto para empezar a vender',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddProductDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Agregar Producto'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductEntity product) {
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
                  product.activo ? 'Activo' : 'Inactivo',
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
                  Icon(Icons.edit),
                  SizedBox(width: 8),
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
                  Text(product.activo ? 'Desactivar' : 'Activar'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text(l.t('delete')),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Producto'),
        content: SingleChildScrollView(
          child: Text(
            'Formulario de creación de producto.\n\n'
            'Aquí implementarías un formulario completo con:\n'
            '• Nombre\n'
            '• Descripción\n'
            '• Precio\n'
            '• Categoría\n'
            '• Stock\n'
            '• Imágenes\n'
            '• Especificaciones\n\n'
            'Por ahora es una versión demo.',
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.t('close')),
          ),
          ElevatedButton(
            onPressed: () {
              // IMPLEMENTADO (STUB): Implementar creación real
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcionalidad en desarrollo')),
              );
            },
            child: Text(l.t('save')),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(ProductEntity product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Producto'),
        content: SingleChildScrollView(
          child: Text(
            'Editando: ${product.nombre}\n\n'
            'Formulario de edición de producto.\n\n'
            'Aquí implementarías un formulario prellenado con los datos actuales del producto.\n\n'
            'Por ahora es una versión demo.',
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              // IMPLEMENTADO (STUB): Implementar edición real
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcionalidad en desarrollo')),
              );
            },
            child: const Text('Guardar Cambios'),
          ),
        ],
      ),
    );
  }

  void _toggleProductStatus(ProductEntity product) {
    // IMPLEMENTADO (STUB): Implementar activar/desactivar producto
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Producto ${product.activo ? 'desactivado' : 'activado'} (Demo)',
        ),
      ),
    );
  }

  void _confirmDelete(ProductEntity product) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Producto'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${product.nombre}"?\n\n'
          'Esta acción no se puede deshacer.',
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
                    const SnackBar(
                      content: Text('Producto eliminado'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${l.t('error_generic')}: $e'),
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
