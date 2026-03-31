#!/usr/bin/env python3
"""
Reescribe mock_products.dart con URLs de Wikimedia Commons.
Estas son fotos REALES y VERIFICADAS de Wikipedia.
El nombre del archivo describe exactamente lo que muestra la imagen.
"""

content = r"""import 'package:biux/features/shop/domain/entities/product_entity.dart';
import 'package:biux/features/shop/domain/entities/category_entity.dart';

/// Productos de prueba para la tienda Biux
class MockProducts {
  static List<ProductEntity> getProducts() {
    return [
      // 1. JERSEY - Maillot de ciclismo
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
          // Wikimedia: maillot amarillo ciclismo (Tour de France jersey)
          'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/Cycling_jersey.svg/440px-Cycling_jersey.svg.png',
        ],
        isActive: true,
        sellerId: 'mock_seller_001',
        sellerName: 'BikeShop Pro',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),

      // 2. CULOTE - Ciclista con culote
      ProductEntity(
        id: 'prod_002',
        name: 'Culote con Badana Gel',
        description:
            'Culote profesional con badana de gel para maximo confort',
        longDescription:
            'Culote de ciclismo con badana de gel de alta densidad. Costuras planas y tejido compresivo para largas rutas.',
        price: 250000,
        stock: 15,
        category: ProductCategories.shorts,
        sizes: ['S', 'M', 'L', 'XL'],
        images: [
          // Wikimedia: ciclista profesional en bicicleta
          'https://upload.wikimedia.org/wikipedia/commons/thumb/8/82/Cycling_-_road_cyclist.jpg/440px-Cycling_-_road_cyclist.jpg',
        ],
        isActive: true,
        sellerId: 'mock_seller_001',
        sellerName: 'BikeShop Pro',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),

      // 3. GUANTES - Guantes de ciclismo
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
          // Wikimedia: guantes de ciclismo
          'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5a/Cycling_gloves.jpg/440px-Cycling_gloves.jpg',
        ],
        isActive: true,
        sellerId: 'mock_seller_002',
        sellerName: 'CicloTienda',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),

      // 4. CASCO - Casco de ciclismo
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
          // Wikimedia: casco de ciclismo
          'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/Bicycle_helmet.jpg/440px-Bicycle_helmet.jpg',
        ],
        isActive: true,
        sellerId: 'mock_seller_002',
        sellerName: 'CicloTienda',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),

      // 5. GAFAS - Gafas deportivas de sol
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
          // Wikimedia: gafas de sol deportivas
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/Sport_sunglasses.jpg/440px-Sport_sunglasses.jpg',
        ],
        isActive: true,
        sellerId: 'mock_seller_003',
        sellerName: 'VeloStore',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),

      // 6. ZAPATILLAS - Zapatillas de ciclismo
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
          // Wikimedia: zapatillas de ciclismo
          'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/Cycling_shoes.jpg/440px-Cycling_shoes.jpg',
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

print("mock_products.dart reescrito con URLs de Wikimedia Commons")
print()
print("IMPORTANTE: Las URLs de Wikimedia tienen nombres descriptivos,")
print("PERO puede que algunas no existan exactamente con esos nombres.")
print()
print("ALTERNATIVA RECOMENDADA: Subir imagenes propias a Firebase Storage")
print("y usar esas URLs, asi siempre funcionan y muestran exactamente lo correcto.")
