#!/usr/bin/env python3
"""Reescribe mock_products.dart con URLs de imagenes reales de productos de ciclismo"""

content = r"""import 'package:biux/features/shop/domain/entities/product_entity.dart';
import 'package:biux/features/shop/domain/entities/category_entity.dart';

/// Productos de prueba para la tienda Biux
/// NOTA: Lista con productos de prueba habilitada temporalmente para testing
class MockProducts {
  static List<ProductEntity> getProducts() {
    return [
      // 1. JERSEY - Maillot ciclismo (imagen real de un jersey de ciclismo)
      ProductEntity(
        id: 'prod_001',
        name: 'Jersey Ciclismo Pro',
        description: 'Jersey profesional para ciclismo de ruta',
        longDescription:
            'Jersey de alta calidad con tejido respirante y tecnologia de secado rapido.',
        price: 180000,
        stock: 25,
        category: ProductCategories.jerseys,
        sizes: ['S', 'M', 'L', 'XL'],
        images: [
          'https://m.media-amazon.com/images/I/71kH+gR0YHL._AC_SX679_.jpg',
        ],
        isActive: true,
        sellerId: 'mock_seller_001',
        sellerName: 'BikeShop Pro',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),

      // 2. CULOTE - Pantalon corto ciclismo con badana
      ProductEntity(
        id: 'prod_002',
        name: 'Culote con Badana Gel',
        description:
            'Culote profesional con badana de gel para maximo confort',
        longDescription:
            'Culote de ciclismo con badana de gel de alta densidad. Costuras planas y tejido compresivo.',
        price: 250000,
        stock: 15,
        category: ProductCategories.shorts,
        sizes: ['S', 'M', 'L', 'XL'],
        images: [
          'https://m.media-amazon.com/images/I/71TqCMFjOzL._AC_SX679_.jpg',
        ],
        isActive: true,
        sellerId: 'mock_seller_001',
        sellerName: 'BikeShop Pro',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),

      // 3. GUANTES - Guantes de ciclismo con gel
      ProductEntity(
        id: 'prod_003',
        name: 'Guantes Ciclismo Gel',
        description: 'Guantes con almohadillas de gel para mayor comodidad',
        longDescription:
            'Guantes de ciclismo con palma de gel y dorso transpirable. Cierre de velcro ajustable.',
        price: 75000,
        stock: 50,
        category: ProductCategories.gloves,
        sizes: ['S', 'M', 'L', 'XL'],
        images: [
          'https://m.media-amazon.com/images/I/71azW-GOTPL._AC_SX679_.jpg',
        ],
        isActive: true,
        sellerId: 'mock_seller_002',
        sellerName: 'CicloTienda',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),

      // 4. CASCO - Casco aerodinamico de ciclismo
      ProductEntity(
        id: 'prod_004',
        name: 'Casco Aerodinamico',
        description: 'Casco ligero con ventilacion optimizada',
        longDescription:
            'Casco de ciclismo con diseno aerodinamico, sistema de ventilacion avanzado y ajuste micrometrico.',
        price: 320000,
        stock: 10,
        category: ProductCategories.helmets,
        sizes: ['S', 'M', 'L'],
        images: [
          'https://m.media-amazon.com/images/I/61kGJ-5MIuL._AC_SX679_.jpg',
        ],
        isActive: true,
        sellerId: 'mock_seller_002',
        sellerName: 'CicloTienda',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),

      // 5. GAFAS - Gafas deportivas de ciclismo
      ProductEntity(
        id: 'prod_005',
        name: 'Gafas Deportivas UV400',
        description: 'Gafas con proteccion UV400 y lentes intercambiables',
        longDescription:
            'Gafas de ciclismo con proteccion UV400, lentes fotocromaticas intercambiables y marco ultraligero.',
        price: 150000,
        stock: 30,
        category: ProductCategories.glasses,
        sizes: ['Unica'],
        images: [
          'https://m.media-amazon.com/images/I/61a0sweIdJL._AC_SX679_.jpg',
        ],
        isActive: true,
        sellerId: 'mock_seller_003',
        sellerName: 'VeloStore',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),

      // 6. ZAPATILLAS - Zapatillas de ciclismo de carretera
      ProductEntity(
        id: 'prod_006',
        name: 'Zapatillas Ciclismo Road',
        description: 'Zapatillas de ciclismo con suela de carbono',
        longDescription:
            'Zapatillas de ciclismo de carretera con suela de carbono, sistema de cierre BOA y ventilacion optimizada.',
        price: 450000,
        stock: 8,
        category: ProductCategories.shoes,
        sizes: ['38', '39', '40', '41', '42', '43', '44'],
        images: [
          'https://m.media-amazon.com/images/I/71rKJhO+-HL._AC_SX679_.jpg',
        ],
        isActive: true,
        sellerId: 'mock_seller_003',
        sellerName: 'VeloStore',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }
}
"""

target = '/Users/macmini/biux/lib/features/shop/data/datasources/mock_products.dart'
with open(target, 'w') as f:
    f.write(content)

print(f"Archivo reescrito con URLs de Amazon (imagenes reales de productos)")
print(f"Productos:")
print(f"  1. Jersey ciclismo  - 71kH+gR0YHL (maillot)")
print(f"  2. Culote badana    - 71TqCMFjOzL (culote ciclismo)")
print(f"  3. Guantes gel      - 71azW-GOTPL (guantes ciclismo)")
print(f"  4. Casco aero       - 61kGJ-5MIuL (casco bici)")
print(f"  5. Gafas UV400      - 61a0sweIdJL (gafas deporte)")
print(f"  6. Zapatillas road  - 71rKJhO+-HL (zapatillas ciclismo)")
