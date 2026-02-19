import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/features/shop/presentation/providers/shop_provider.dart';

const _kPrimaryColor = Color(0xFF16242D);

/// Pantalla de estadísticas de la tienda
class ShopStatsScreen extends StatelessWidget {
  const ShopStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Estadísticas de la Tienda',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ShopProvider>(
        builder: (context, shopProvider, _) {
          final products = shopProvider.products;
          final totalProducts = products.length;

          // Agrupar por categoría
          final Map<String, int> categoryCount = {};
          for (final p in products) {
            final cat = p.category;
            categoryCount[cat] = (categoryCount[cat] ?? 0) + 1;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con resumen
                _buildSummaryHeader(totalProducts, categoryCount.length),
                const SizedBox(height: 24),

                // Estadísticas rápidas
                const Text(
                  'Resumen General',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _buildStatCard(
                      'Productos Totales',
                      '$totalProducts',
                      Icons.inventory_2,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Categorías',
                      '${categoryCount.length}',
                      Icons.category,
                      Colors.purple,
                    ),
                    _buildStatCard(
                      'Artículos en Carrito',
                      '${shopProvider.cartItemCount}',
                      Icons.shopping_cart,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'Estado',
                      shopProvider.isLoadingProducts ? 'Cargando' : 'Activo',
                      Icons.circle,
                      shopProvider.isLoadingProducts
                          ? Colors.amber
                          : Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Distribución por categoría
                const Text(
                  'Distribución por Categoría',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                if (categoryCount.isEmpty)
                  _buildEmptyState()
                else
                  ...categoryCount.entries.map((entry) {
                    final percentage = totalProducts > 0
                        ? (entry.value / totalProducts)
                        : 0.0;
                    return _buildCategoryBar(
                      entry.key,
                      entry.value,
                      percentage,
                    );
                  }),

                const SizedBox(height: 24),

                // Actividad reciente
                const Text(
                  'Actividad Reciente',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                _buildActivityItem(
                  Icons.shopping_bag,
                  'Tienda operativa',
                  'La tienda está funcionando correctamente',
                  Colors.green,
                  'Ahora',
                ),
                _buildActivityItem(
                  Icons.inventory,
                  'Inventario actualizado',
                  '$totalProducts productos disponibles',
                  Colors.blue,
                  'Hoy',
                ),
                _buildActivityItem(
                  Icons.trending_up,
                  'Estadísticas disponibles',
                  'Panel de control activo',
                  Colors.purple,
                  'Hoy',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryHeader(int totalProducts, int totalCategories) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kPrimaryColor, Color(0xFF2A4A5C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Tu Tienda en Números',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$totalProducts productos en $totalCategories categorías',
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMiniStat('🛒', 'Ventas', '-'),
              const SizedBox(width: 24),
              _buildMiniStat('⭐', 'Rating', '-'),
              const SizedBox(width: 24),
              _buildMiniStat('👁️', 'Vistas', '-'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String emoji, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$emoji $value',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white60),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(String name, int count, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$count productos',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(_kPrimaryColor),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    String time,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        color: Colors.white,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
          trailing: Text(
            time,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 60,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              'No hay productos aún',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Las estadísticas se mostrarán cuando haya productos.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
