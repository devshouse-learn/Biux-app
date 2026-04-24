import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/features/shop/presentation/providers/shop_provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

const _kPrimaryColor = Color(0xFF16242D);

/// Pantalla de estadísticas de la tienda
class ShopStatsScreen extends StatelessWidget {
  const ShopStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          l.t('store_stats'),
          style: const TextStyle(fontWeight: FontWeight.bold),
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
                _buildSummaryHeader(l, totalProducts, categoryCount.length),
                SizedBox(height: 24),

                // Estadísticas rápidas
                Text(
                  l.t('general_summary'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _kPrimaryColor,
                  ),
                ),
                SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _buildStatCard(
                      l.t('total_products'),
                      '$totalProducts',
                      Icons.inventory_2,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      l.t('categories'),
                      '${categoryCount.length}',
                      Icons.category,
                      Colors.purple,
                    ),
                    _buildStatCard(
                      l.t('cart_items'),
                      '${shopProvider.cartItemCount}',
                      Icons.shopping_cart,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      l.t('status_label'),
                      shopProvider.isLoadingProducts
                          ? l.t('loading')
                          : l.t('active_status'),
                      Icons.circle,
                      shopProvider.isLoadingProducts
                          ? Colors.amber
                          : Colors.green,
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Distribución por categoría
                Text(
                  l.t('distribution_by_category'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                if (categoryCount.isEmpty)
                  _buildEmptyState(l)
                else
                  ...categoryCount.entries.map((entry) {
                    final percentage = totalProducts > 0
                        ? (entry.value / totalProducts)
                        : 0.0;
                    return _buildCategoryBar(
                      l,
                      entry.key,
                      entry.value,
                      percentage,
                    );
                  }),

                SizedBox(height: 24),

                // Actividad reciente
                Text(
                  l.t('recent_activity'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _kPrimaryColor,
                  ),
                ),
                SizedBox(height: 12),
                _buildActivityItem(
                  Icons.shopping_bag,
                  l.t('store_operational'),
                  l.t('store_running_correctly'),
                  Colors.green,
                  l.t('now'),
                ),
                _buildActivityItem(
                  Icons.inventory,
                  l.t('inventory_updated'),
                  '$totalProducts ${l.t('products_available')}',
                  Colors.blue,
                  l.t('today'),
                ),
                _buildActivityItem(
                  Icons.trending_up,
                  l.t('stats_available'),
                  l.t('dashboard_active'),
                  Colors.purple,
                  l.t('today'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryHeader(
    LocaleNotifier l,
    int totalProducts,
    int totalCategories,
  ) {
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
          Text('📊 ', style: TextStyle(fontSize: 22)),
          Text(
            l.t('your_store_in_numbers'),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '$totalProducts ${l.t('count_products')} ${l.t('in_preposition')} $totalCategories ${l.t('count_categories')}',
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildMiniStat('🛒', l.t('sales'), '-'),
              SizedBox(width: 24),
              _buildMiniStat('⭐', l.t('rating'), '-'),
              SizedBox(width: 24),
              _buildMiniStat('👁️', l.t('views_label'), '-'),
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

  Widget _buildCategoryBar(
    LocaleNotifier l,
    String name,
    int count,
    double percentage,
  ) {
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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$count ${l.t('count_products')}',
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

  Widget _buildEmptyState(LocaleNotifier l) {
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
            SizedBox(height: 12),
            Text(
              l.t('no_products_yet_stats'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              l.t('stats_when_products'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
