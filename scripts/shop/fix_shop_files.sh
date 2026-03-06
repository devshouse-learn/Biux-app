#!/bin/bash
# Script para corregir los archivos corrupted por ediciones parciales

# 1. Reemplazar shop_admin_dashboard_widget.dart con la versión limpia
cp /Users/macmini/biux/lib/features/shop/presentation/widgets/shop_admin_dashboard_widget_v2.dart \
   /Users/macmini/biux/lib/features/shop/presentation/widgets/shop_admin_dashboard_widget.dart

echo "✅ shop_admin_dashboard_widget.dart reemplazado con versión limpia"

# 2. Limpiar shop_screen_pro.dart - eliminar residuos entre líneas
# Esto requiere edición manual en VS Code
echo ""
echo "⚠️  ACCIÓN MANUAL REQUERIDA en shop_screen_pro.dart:"
echo ""
echo "Abre el archivo shop_screen_pro.dart y busca la zona de slivers (alrededor de las líneas 78-131)."
echo "La lista de slivers 'children: [' debe quedar EXACTAMENTE así:"
echo ""
echo '          _buildChromeStyleAppBar(),'
echo ''
echo '          _buildCategoryChips(),'
echo ''
echo '          const SliverToBoxAdapter(child: ShopInfoWidget()),'
echo '          SliverToBoxAdapter(child: ShopAdminDashboardWidget()),'
echo ''
echo '          // Ofertas'
echo '          SliverToBoxAdapter(child: _buildOffersBar()),'
echo ''
echo '          // Productos destacados'
echo '          _buildFeaturedSection(),'
echo ''
echo '          // Toolbar'
echo '          SliverToBoxAdapter(child: _buildMinimalToolbar()),'
echo ''
echo '          // Filtros avanzados'
echo '          if (_showFilters) SliverToBoxAdapter(child: _buildAdvancedFilters()),'
echo ''
echo '          // Grid de productos'
echo '          _buildProductsGrid(),'
echo ''
echo "BORRA todo el código residual entre la línea de ShopAdminDashboardWidget"
echo "y la línea de _buildOffersBar (son líneas con context, selectedCategory,"
echo "Provider.of, filterByCategory, y cierres de paréntesis sobrantes)."
echo ""
echo "También borra las líneas DUPLICADAS de _buildOffersBar, _buildFeaturedSection,"
echo "_buildMinimalToolbar, _buildAdvancedFilters, y _buildProductsGrid que están"
echo "después de las que ya inserté."
