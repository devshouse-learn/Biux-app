import 'package:flutter/material.dart';

/// Widget de categorías compactas para la tienda Biux.
/// Chips pequeños con iconos y texto reducido en scroll horizontal.
class ShopCompactCategoriesWidget extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;

  const ShopCompactCategoriesWidget({
    super.key,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  static const _kPrimaryColor = Color(0xFF16242D);

  /// Lista de categorías con nombre e icono
  static final List<Map<String, dynamic>> categories = [
    {'name': 'Todo', 'icon': Icons.apps},
    {'name': 'Bicicletas', 'icon': Icons.pedal_bike},
    {'name': 'Ropa', 'icon': Icons.checkroom},
    {'name': 'Accesorios', 'icon': Icons.watch},
    {'name': 'Componentes', 'icon': Icons.settings},
    {'name': 'Herramientas', 'icon': Icons.build},
    {'name': 'Nutrición', 'icon': Icons.local_drink},
    {'name': 'Electrónica', 'icon': Icons.electrical_services},
    {'name': 'Protección', 'icon': Icons.shield},
  ];

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 38,
        margin: const EdgeInsets.only(top: 4, bottom: 2),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final cat = categories[index];
            final name = cat['name'] as String;
            final icon = cat['icon'] as IconData;
            final isSelected = selectedIndex == index;

            return ChoiceChip(
              label: Text(
                name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
              avatar: Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              selected: isSelected,
              onSelected: (_) => onCategorySelected(index),
              selectedColor: _kPrimaryColor,
              backgroundColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected ? _kPrimaryColor : Colors.grey[300]!,
                  width: 0.5,
                ),
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          },
        ),
      ),
    );
  }
}
