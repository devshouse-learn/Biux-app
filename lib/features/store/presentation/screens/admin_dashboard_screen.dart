import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/features/users/domain/entities/user_entity.dart';
import 'package:biux/features/store/presentation/providers/product_provider.dart';

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
    // Verificar permisos de admin
    if (!widget.currentUser.isAdministrador) {
      return Scaffold(
        appBar: AppBar(title: const Text('Panel de Administración')),
        body: const Center(child: Text('No tienes permisos de administrador')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Usuarios'),
            Tab(icon: Icon(Icons.store), text: 'Vendedores'),
            Tab(icon: Icon(Icons.inventory), text: 'Productos'),
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gestión de Usuarios',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aquí puedes ver todos los usuarios registrados en la plataforma y gestionar sus roles.',
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showUsersList(),
                  icon: const Icon(Icons.people),
                  label: const Text('Ver Todos los Usuarios'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildStatsCard('Total de Usuarios', '0', Icons.people, Colors.blue),
      ],
    );
  }

  // Tab 2: Gestión de vendedores
  Widget _buildSellersTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gestión de Vendedores',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Autoriza o revoca permisos de vendedor a los usuarios.',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAuthorizeSellerDialog(),
                        icon: const Icon(Icons.person_add),
                        label: const Text('Autorizar Vendedor'),
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
                        label: const Text('Revocar Permisos'),
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
        _buildStatsCard('Vendedores Activos', '0', Icons.store, Colors.green),
      ],
    );
  }

  // Tab 3: Gestión de productos
  Widget _buildProductsTab() {
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
                      const Text(
                        'Gestión de Productos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Como administrador puedes eliminar cualquier producto y marcarlo como destacado.',
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<ProductProvider>().loadAllProducts();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Recargar Productos'),
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
                      'Total Productos',
                      '${provider.products.length}',
                      Icons.inventory,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatsCard(
                      'Destacados',
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
                  ? const Center(child: Text('No hay productos'))
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
                              'Vendedor: ${product.vendedorNombre ?? 'Desconocido'}\n'
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lista de Usuarios'),
        content: const SingleChildScrollView(
          child: Text(
            'Aquí se mostraría la lista completa de usuarios con opciones para:\n\n'
            '• Ver perfil\n'
            '• Cambiar rol\n'
            '• Suspender cuenta\n'
            '• Ver historial de compras\n\n'
            'Esta es una versión demo.',
          ),
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

  void _showAuthorizeSellerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Autorizar Vendedor'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selecciona un usuario para autorizarlo como vendedor:'),
              SizedBox(height: 16),
              Text(
                'Lista de usuarios normales:\n\n'
                '• Usuario 1\n'
                '• Usuario 2\n'
                '• Usuario 3\n\n'
                'Esta es una versión demo.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // PENDIENTE: Implementar autorización real
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Usuario autorizado como vendedor (Demo)'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Autorizar'),
          ),
        ],
      ),
    );
  }

  void _showRevokeSellerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revocar Permisos de Vendedor'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selecciona un vendedor para revocar sus permisos:'),
              SizedBox(height: 16),
              Text(
                'Lista de vendedores activos:\n\n'
                '• Vendedor 1\n'
                '• Vendedor 2\n'
                '• Vendedor 3\n\n'
                'Esta es una versión demo.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // PENDIENTE: Implementar revocación real
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Permisos de vendedor revocados (Demo)'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Revocar'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProduct(product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${product.nombre}"?\n\n'
          'Este producto pertenece a: ${product.vendedorNombre ?? 'Desconocido'}\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
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
                      content: Text('Producto eliminado por el administrador'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
