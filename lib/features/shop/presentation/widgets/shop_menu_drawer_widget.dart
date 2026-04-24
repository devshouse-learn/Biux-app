import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
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
    final l = Provider.of<LocaleNotifier>(context);
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
                  Row(
                    children: [
                      const Icon(Icons.store, color: Colors.white, size: 32),
                      SizedBox(width: 12),
                      Text(
                        l.t('biux_shop'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    user?.name ?? l.t('visitor'),
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      if (isAdmin) _buildRoleBadge(l.t('admin'), Colors.amber),
                      if (isSeller)
                        _buildRoleBadge(l.t('seller'), Colors.green),
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
                _buildSectionTitle(l.t('explore')),
                _buildMenuItem(
                  Icons.shopping_bag,
                  l.t('catalog'),
                  onTap: () => Navigator.pop(context),
                ),
                _buildMenuItem(
                  Icons.favorite,
                  l.t('favorites'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/shop/favorites');
                  },
                ),
                _buildMenuItem(
                  Icons.shopping_cart,
                  l.t('cart'),
                  badge: shopProvider.cartItemCount > 0
                      ? '${shopProvider.cartItemCount}'
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/shop/cart');
                  },
                ),

                Divider(height: 1, indent: 16, endIndent: 16),

                // --- Seguridad ---
                _buildSectionTitle(l.t('security_section')),
                _buildMenuItem(
                  Icons.security,
                  l.t('security_center'),
                  subtitle: l.t('security_center_subtitle'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SecurityCenterScreen(),
                      ),
                    );
                  },
                ),

                Divider(height: 1, indent: 16, endIndent: 16),

                // --- Informes ---
                _buildSectionTitle(l.t('reports')),
                _buildMenuItem(
                  Icons.flag,
                  l.t('reports'),
                  subtitle: l.t('reports_subtitle'),
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
                  l.t('statistics'),
                  subtitle: l.t('statistics_subtitle'),
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
                  Divider(height: 1, indent: 16, endIndent: 16),
                  _buildSectionTitle(l.t('administration')),
                  if (isAdmin)
                    _buildMenuItem(
                      Icons.admin_panel_settings,
                      l.t('admin_panel'),
                      subtitle: l.t('admin_panel_subtitle'),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/shop/admin');
                      },
                    ),
                  if (isAdmin)
                    _buildMenuItem(
                      Icons.people,
                      l.t('seller_requests'),
                      subtitle: l.t('seller_requests_subtitle'),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/shop/seller-requests');
                      },
                    ),
                  if (isAdmin)
                    _buildMenuItem(
                      Icons.manage_accounts,
                      l.t('manage_sellers'),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/shop/manage-sellers');
                      },
                    ),
                  if (isSeller && !isAdmin)
                    _buildMenuItem(
                      Icons.add_business,
                      l.t('my_products'),
                      subtitle: l.t('my_products_subtitle'),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/shop/admin');
                      },
                    ),
                ],

                Divider(height: 1, indent: 16, endIndent: 16),

                // --- Información ---
                _buildSectionTitle(l.t('information')),
                _buildMenuItem(
                  Icons.info_outline,
                  l.t('about_store'),
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                ),
                _buildMenuItem(
                  Icons.policy,
                  l.t('policies'),
                  onTap: () {
                    Navigator.pop(context);
                    _showPoliciesDialog(context);
                  },
                ),
                _buildMenuItem(
                  Icons.help_outline,
                  l.t('help'),
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
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.t('biux_shop')),
        content: Text(l.t('about_store_content')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.t('close')),
          ),
        ],
      ),
    );
  }

  void _showPoliciesDialog(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.t('store_policies')),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '📦 ${l.t('shipping_title')}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(l.t('shipping_content')),
              SizedBox(height: 12),
              Text(
                '🔄 ${l.t('returns_title')}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(l.t('returns_content')),
              SizedBox(height: 12),
              Text(
                '🔒 ${l.t('privacy_title')}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(l.t('privacy_content')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.t('accept')),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.t('help_center')),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '❓ ${l.t('how_to_buy')}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(l.t('how_to_buy_content')),
              SizedBox(height: 12),
              Text(
                '🏪 ${l.t('how_to_sell')}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(l.t('how_to_sell_content')),
              SizedBox(height: 12),
              Text(
                '🔐 ${l.t('bike_registration')}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(l.t('bike_registration_content')),
              SizedBox(height: 12),
              Text(
                '📧 ${l.t('contact')}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('soporte@biux.app'),
            ],
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
}
