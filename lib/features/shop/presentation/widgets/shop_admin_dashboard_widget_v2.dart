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
          side: BorderSide(color: _kPrimaryColor.withValues(alpha: 0.15)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _kPrimaryColor.withValues(alpha: 0.1),
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
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
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
          Icon(
            icon,
            size: 20,
            color: iconColor ?? _kPrimaryColor.withValues(alpha: 0.7),
          ),
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
