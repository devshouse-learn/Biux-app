// @override-entire-file
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';

const _kPrimaryColor = Color(0xFF16242D);

/// Panel de administración colapsable y organizado en secciones.
class ShopAdminDashboardWidget extends StatelessWidget {
  final VoidCallback? onManageProducts;
  final VoidCallback? onManageSellers;
  final VoidCallback? onViewReports;
  final VoidCallback? onViewRequests;
  final VoidCallback? onViewStats;
  final VoidCallback? onSecurityCenter;

  const ShopAdminDashboardWidget({
    super.key,
    this.onManageProducts,
    this.onManageSellers,
    this.onViewReports,
    this.onViewRequests,
    this.onViewStats,
    this.onSecurityCenter,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final isAdmin = user?.isAdmin ?? false;

    if (!isAdmin) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _kPrimaryColor.withOpacity(0.15)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _kPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                color: _kPrimaryColor,
                size: 22,
              ),
            ),
            title: const Text(
              'Panel de Administración',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _kPrimaryColor,
              ),
            ),
            subtitle: Text(
              'Gestiona tu tienda',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            children: [
              const Divider(height: 1),
              // ── Sección: Gestión ──
              _buildSectionHeader('Gestión'),
              _buildMenuItem(
                icon: Icons.inventory_2_outlined,
                label: 'Administrar productos',
                subtitle: 'Agregar, editar y eliminar',
                onTap: onManageProducts,
              ),
              _buildMenuItem(
                icon: Icons.storefront_outlined,
                label: 'Gestionar vendedores',
                subtitle: 'Permisos y aprobaciones',
                onTap: onManageSellers,
              ),
              _buildMenuItem(
                icon: Icons.pending_actions_outlined,
                label: 'Solicitudes pendientes',
                subtitle: 'Revisar nuevas solicitudes',
                onTap: onViewRequests,
                badge: true,
              ),
              const Divider(height: 1, indent: 56),
              // ── Sección: Análisis ──
              _buildSectionHeader('Análisis'),
              _buildMenuItem(
                icon: Icons.bar_chart_rounded,
                label: 'Reportes de ventas',
                subtitle: 'Estadísticas y tendencias',
                onTap: onViewReports,
              ),
              _buildMenuItem(
                icon: Icons.analytics_outlined,
                label: 'Estadísticas generales',
                subtitle: 'Métricas de la tienda',
                onTap: onViewStats,
              ),
              const Divider(height: 1, indent: 56),
              // ── Sección: Seguridad ──
              _buildSectionHeader('Seguridad'),
              _buildMenuItem(
                icon: Icons.shield_outlined,
                label: 'Centro de seguridad',
                subtitle: 'Alertas y bicicletas robadas',
                onTap: onSecurityCenter,
                iconColor: Colors.orange.shade700,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 12, bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade400,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    String? subtitle,
    VoidCallback? onTap,
    Color? iconColor,
    bool badge = false,
  }) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon,
              size: 20, color: iconColor ?? _kPrimaryColor.withOpacity(0.7)),
          if (badge)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _kPrimaryColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 18,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }
}

        final isAdmin = user?.isAdmin ?? false;
        final isSeller = user?.canSellProducts ?? false;

        if (!isAdmin && !isSeller) return const SizedBox.shrink();

        return Container(
          margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration = BoxDecoration(
            gradient: LinearGradient(
              colors: [_kPrimaryColor, _kPrimaryColor.withOpacity(0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _kPrimaryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isAdmin ? Icons.admin_panel_settings : Icons.store,
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
                            isAdmin
                                ? 'Panel de Administración'
                                : 'Panel de Vendedor',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            isAdmin
                                ? 'Gestiona productos, vendedores y más'
                                : 'Gestiona tus productos',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Stats rápidas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildQuickStat(
                      'Productos',
                      '${shopProvider.products.length}',
                      Icons.inventory_2,
                    ),
                    _buildQuickStat(
                      'En Carrito',
                      '${shopProvider.cartItemCount}',
                      Icons.shopping_cart,
                    ),
                    if (isAdmin)
                      _buildQuickStat(
                        'Solicitudes',
                        '•',
                        Icons.pending_actions,
                        highlight: true,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Menú de opciones
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (isSeller || isAdmin)
                      _buildMenuButton(
                        'Mis Productos',
                        Icons.inventory,
                        Colors.blue,
                        onManageProducts,
                      ),
                    if (isAdmin)
                      _buildMenuButton(
                        'Vendedores',
                        Icons.people,
                        Colors.green,
                        onManageSellers,
                      ),
                    if (isAdmin)
                      _buildMenuButton(
                        'Solicitudes',
                        Icons.assignment,
                        Colors.orange,
                        onViewRequests,
                      ),
                    _buildMenuButton(
                      'Reportes',
                      Icons.flag,
                      Colors.red,
                      onViewReports,
                    ),
                    if (isAdmin)
                      _buildMenuButton(
                        'Estadísticas',
                        Icons.bar_chart,
                        Colors.purple,
                        onViewStats,
                      ),
                    _buildMenuButton(
                      'Seguridad',
                      Icons.security,
                      Colors.teal,
                      onSecurityCenter,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStat(
    String label,
    String value,
    IconData icon, {
    bool highlight = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: highlight
              ? Colors.orange.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: highlight
              ? Border.all(color: Colors.orange.withOpacity(0.5))
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: highlight ? Colors.orange : Colors.white70,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: highlight ? Colors.orange : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
