import 'package:flutter/material.dart';
import 'package:biux/features/shop/domain/entities/category_entity.dart';

/// Categorías compactas y organizadas en scroll horizontal.
/// Chips pequeños con iconos y texto reducido.
class ShopCompactCategoriesWidget extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;

  const ShopCompactCategoriesWidget({
    super.key,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  static const _kPrimaryColor = Color(0xFF16242D);

  @override
  Widget build(BuildContext context) {
    final categories = <Map<String, Object?>>[
      {'name': 'Todo', 'icon': Icons.pedal_bike},
      {'name': ProductCategories.bikes, 'icon': Icons.pedal_bike},
      {'name': ProductCategories.jerseys, 'icon': Icons.checkroom},
      {'name': ProductCategories.accessories, 'icon': Icons.watch},
      {'name': ProductCategories.components, 'icon': Icons.settings},
      {'name': ProductCategories.maintenance, 'icon': Icons.build},
      {'name': ProductCategories.nutrition, 'icon': Icons.local_drink},
      {
        'name': ProductCategories.electronics,
        'icon': Icons.electrical_services,
      },
      {'name': ProductCategories.safety, 'icon': Icons.shield},
    ];

    return SliverToBoxAdapter(
      child: Container(
        height: 40,
        margin: const EdgeInsets.symmetric(vertical: 4),
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
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          },
        ),
      ),
    );
  }
}
