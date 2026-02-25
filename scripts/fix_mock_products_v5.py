#!/usr/bin/env python3
"""
Reescribe mock_products.dart usando Unsplash Source con query por nombre.
URL formato: https://source.unsplash.com/600x600/?cycling+jersey
Esto busca fotos que coincidan con el query, NO aleatorias por ID.

NOTA: source.unsplash.com fue deprecado. Usaremos el approach directo
con la API de busqueda embebida en la URL.

ALTERNATIVA FINAL: Usar imagenes directas de sitios de ciclismo publicos
con URLs conocidas y verificadas.
"""

# URLs verificadas manualmente de productos de ciclismo reales
# Fuente: imagenes publicas de productos en sitios de ciclismo

content = r"""import 'package:biux/features/shop/domain/entities/product_entity.dart';
import 'package:biux/features/shop/domain/entities/category_entity.dart';

/// Productos de prueba para la tienda Biux
/// Usa imagenes generadas dinamicamente segun el nombre del producto
class MockProducts {
  /// Genera una URL de imagen basada en el nombre del producto
  /// Usa el servicio de Dicebear para generar iconos, o placeholder con texto
  static String _getProductImageUrl(String productName, String category) {
    // Usar DummyJSON fake store images que son fotos reales de productos
    // Mapeamos por categoria a imagenes conocidas
    final Map<String, String> categoryImages = {
      'Jerseys': 'https://fakestoreapi.com/img/71-3HjGNDUL._AC_SY879._SX._UX._SY._UY_.jpg',
      'Shorts': 'https://fakestoreapi.com/img/71YXzeOuslL._AC_UY879_.jpg',
      'Gloves': 'https://fakestoreapi.com/img/71pWzhdJNwL._AC_UL640_QL65_ML3_.jpg',
      'Helmets': 'https://fakestoreapi.com/img/61sbMiUnoGL._AC_UL640_QL65_ML3_.jpg',
      'Glasses': 'https://fakestoreapi.com/img/51UDEzMJVpL._AC_UL640_QL65_ML3_.jpg',
      'Shoes': 'https://fakestoreapi.com/img/71YAIFU48IL._AC_UL640_QL65_ML3_.jpg',
    };
    return categoryImages[category] ?? 'https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg';
  }

  static List<ProductEntity> getProducts() {
    return [
      // 1. JERSEY
      ProductEntity(
        id: 'prod_001',
        name: 'Jersey Ciclismo Pro',
        description: 'Jersey profesional para ciclismo de ruta',
        longDescription:
            'Jersey de alta calidad con tejido respirante y tecnologia de secado rapido. Diseno aerodinamico con bolsillos traseros.',
        price: 180000,
        stock: 25,
        category: ProductCategories.jerseys,
        sizes: ['S', 'M', 'L', 'XL'],
        images: [
          'https://static.nike.com/a/images/t_PDP_936_v1/f_auto,q_auto:eco/3e3a7a8c-8e4e-4f3f-b5c2-9d8e8e8e8e8e/dri-fit-cycling-jersey.jpg',
        ],
        isActive: true,
        sellerId: 'mock_seller_001',
        sellerName: 'BikeShop Pro',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }
}
"""

# NO, este enfoque tampoco funciona porque no puedo verificar URLs de Nike/Amazon

# MEJOR ENFOQUE: Subir las imagenes a Firebase Storage del proyecto
# y usar esas URLs directamente

print("=" * 60)
print("PROBLEMA IDENTIFICADO:")
print("=" * 60)
print()
print("No es posible garantizar que URLs externas muestren")
print("exactamente el producto correcto sin verificarlas manualmente.")
print()
print("SOLUCION RECOMENDADA:")
print("Subir 6 imagenes reales de productos de ciclismo")
print("a Firebase Storage del proyecto biux-1576614678644")
print("y usar esas URLs en mock_products.dart")
print()
print("Por ahora, NO se modifico el archivo.")
