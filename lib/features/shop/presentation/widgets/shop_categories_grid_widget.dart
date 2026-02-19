import 'package:flutter/material.dart';

const _kPrimaryColor = Color(0xFF16242D);

/// Categorías principales para el grid
const _shopCategories = <_ShopCategoryItem>[
  _ShopCategoryItem(id: 'bicicletas', name: 'Bicicletas', icon: '🚲'),
  _ShopCategoryItem(id: 'componentes', name: 'Componentes', icon: '⚙️'),
  _ShopCategoryItem(id: 'accesorios', name: 'Accesorios', icon: '🎒'),
  _ShopCategoryItem(id: 'ropa', name: 'Ropa', icon: '👕'),
  _ShopCategoryItem(id: 'proteccion', name: 'Protección', icon: '🪖'),
  _ShopCategoryItem(id: 'nutricion', name: 'Nutrición', icon: '🍌'),
  _ShopCategoryItem(id: 'entrenamiento', name: 'Entrenamiento', icon: '📊'),
  _ShopCategoryItem(id: 'mantenimiento', name: 'Mantenimiento', icon: '🧴'),
  _ShopCategoryItem(id: 'otros', name: 'Otros', icon: '📦'),
];

class _ShopCategoryItem {
  final String id;
  final String name;
  final String icon;
  const _ShopCategoryItem({
    required this.id,
    required this.name,
    required this.icon,
  });
}

/// Grid de categorías para la tienda
class ShopCategoriesGridWidget extends StatelessWidget {
  final String? selectedCategoryId;
  final ValueChanged<String> onCategorySelected;

  const ShopCategoriesGridWidget({
    super.key,
    this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.category, color: _kPrimaryColor, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Categorías',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _kPrimaryColor,
                ),
              ),
              const Spacer(),
              if (selectedCategoryId != null && selectedCategoryId!.isNotEmpty)
                TextButton.icon(
                  onPressed: () => onCategorySelected(''),
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Limpiar'),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _shopCategories.length,
            itemBuilder: (context, index) {
              final cat = _shopCategories[index];
              final isSelected = selectedCategoryId == cat.id;

              return GestureDetector(
                onTap: () => onCategorySelected(cat.id),
                child: Container(
                  width: 90,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? _kPrimaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? _kPrimaryColor : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _kPrimaryColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(cat.icon, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 6),
                      Text(
                        cat.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : _kPrimaryColor,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
  }
}
