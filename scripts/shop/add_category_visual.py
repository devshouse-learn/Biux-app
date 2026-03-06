#!/usr/bin/env python3
"""Agrega la clase _CategoryVisual al final de shop_screen_pro.dart"""
with open('/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart', 'r') as f:
    content = f.read()

# Agregar la clase al final del archivo
category_class = '''

/// Modelo visual para representar una categoría con icono y colores
class _CategoryVisual {
  final IconData icon;
  final List<Color> gradientColors;

  const _CategoryVisual({
    required this.icon,
    required this.gradientColors,
  });
}
'''

content = content.rstrip() + '\n' + category_class

with open('/Users/macmini/biux/lib/features/shop/presentation/screens/shop_screen_pro.dart', 'w') as f:
    f.write(content)

print("Clase _CategoryVisual agregada al final del archivo")
