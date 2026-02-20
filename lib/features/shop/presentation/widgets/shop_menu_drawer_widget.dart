import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/features/shop/presentation/providers/shop_provider.dart';
import 'package:biux/features/shop/presentation/screens/security_center_screen.dart';
import 'package:biux/features/shop/presentation/screens/shop_reports_screen.dart';
import 'package:biux/features/shop/presentation/screens/shop_stats_screen.dart';

const _kPrimaryColor = Color(0xFF16242D);

/// Drawer menú lateral completo de la tienda
class ShopMenuDrawer extends StatelessWidget {
  const ShopMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final shopProvider = context.watch<ShopProvider>();
    final user = userProvider.user;
    final isAdmin = user?.isAdmin ?? false;
    final isSeller = user?.canSellProducts ?? false;

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header del drawer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: _kPrimaryColor,
              borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.store, color: Colors.white, size: 32),
                      SizedBox(width: 12),
                      Text(
                        'BiuX Shop',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.name ?? 'Visitante',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (isAdmin) _buildRoleBadge('Admin', Colors.amber),
                      if (isSeller) _buildRoleBadge('Vendedor', Colors.green),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Secciones principales
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Explorar ---
                _buildSectionTitle('Explorar'),
                _buildMenuItem(
                  Icons.shopping_bag,
                  'Catálogo',
                  onTap: () => Navigator.pop(context),
                ),
                _buildMenuItem(
                  Icons.favorite,
                  'Favoritos',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/shop/favorites');
                  },
                ),
                _buildMenuItem(
                  Icons.shopping_cart,
                  'Carrito',
                  badge: shopProvider.cartItemCount > 0
                      ? '${shopProvider.cartItemCount}'
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/shop/cart');
                  },
                ),

                const Divider(height: 1, indent: 16, endIndent: 16),

                // --- Seguridad ---
                _buildSectionTitle('Seguridad'),
                _buildMenuItem(
                  Icons.security,
                  'Centro de Seguridad',
                  subtitle: 'Registro, alertas y QR',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SecurityCenterScreen(),
                      ),
                    );
                  },
                ),

                const Divider(height: 1, indent: 16, endIndent: 16),

                // --- Informes ---
                _buildSectionTitle('Informes'),
                _buildMenuItem(
                  Icons.flag,
                  'Reportes',
                  subtitle: 'Reportar productos o usuarios',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ShopReportsScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  Icons.bar_chart,
                  'Estadísticas',
                  subtitle: 'Datos de la tienda',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ShopStatsScreen(),
                      ),
                    );
                  },
                ),

                // --- Administración (solo admin/seller) ---
                if (isAdmin || isSeller) ...[
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildSectionTitle('Administración'),
                  if (isAdmin)
                    _buildMenuItem(
                      Icons.admin_panel_settings,
                      'Panel Admin',
                      subtitle: 'Gestión completa',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/shop/admin');
                      },
                    ),
                  if (isAdmin)
                    _buildMenuItem(
                      Icons.people,
                      'Solicitudes de Vendedor',
                      subtitle: 'Aprobar/rechazar solicitudes',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/shop/seller-requests');
                      },
                    ),
                  if (isAdmin)
                    _buildMenuItem(
                      Icons.manage_accounts,
                      'Gestionar Vendedores',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/shop/manage-sellers');
                      },
                    ),
                  if (isSeller && !isAdmin)
                    _buildMenuItem(
                      Icons.add_business,
                      'Mis Productos',
                      subtitle: 'Gestionar mis productos',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/shop/admin');
                      },
                    ),
                ],

                const Divider(height: 1, indent: 16, endIndent: 16),

                // --- Información ---
                _buildSectionTitle('Información'),
                _buildMenuItem(
                  Icons.info_outline,
                  'Acerca de la Tienda',
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                ),
                _buildMenuItem(
                  Icons.policy,
                  'Políticas',
                  onTap: () {
                    Navigator.pop(context);
                    _showPoliciesDialog(context);
                  },
                ),
                _buildMenuItem(
                  Icons.help_outline,
                  'Ayuda',
                  onTap: () {
                    Navigator.pop(context);
                    _showHelpDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8, top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    String? subtitle,
    String? badge,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: _kPrimaryColor, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            )
          : null,
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('BiuX Shop'),
        content: const Text(
          'Tu tienda de ciclismo de confianza.\n\n'
          'Encuentra los mejores productos para tu bicicleta, '
          'accesorios, equipamiento y más.\n\n'
          'Versión 1.0.0',
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

  void _showPoliciesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Políticas de la Tienda'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('📦 Envíos', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                'Los envíos se realizan a través del vendedor. '
                'Consulta las condiciones de cada producto.',
              ),
              SizedBox(height: 12),
              Text(
                '🔄 Devoluciones',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Contacta al vendedor dentro de las primeras 48h '
                'para gestionar devoluciones.',
              ),
              SizedBox(height: 12),
              Text(
                '🔒 Privacidad',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Tu información personal está protegida. '
                'No compartimos datos con terceros.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Centro de Ayuda'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '❓ ¿Cómo comprar?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Explora el catálogo, añade productos al carrito '
                'y realiza tu pedido.',
              ),
              SizedBox(height: 12),
              Text(
                '🏪 ¿Cómo vender?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Solicita permisos de vendedor desde tu perfil '
                'y espera la aprobación del admin.',
              ),
              SizedBox(height: 12),
              Text(
                '🔐 Registro de Bicicleta',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Registra tu bici en el Centro de Seguridad '
                'para protegerla contra robos.',
              ),
              SizedBox(height: 12),
              Text(
                '📧 Contacto',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('soporte@biux.app'),
            ],
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
}
