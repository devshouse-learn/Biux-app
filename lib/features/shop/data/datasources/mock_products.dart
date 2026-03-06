import 'package:biux/features/shop/domain/entities/product_entity.dart';
import 'package:biux/features/shop/domain/entities/category_entity.dart';

/// Productos de prueba para la tienda Biux
/// Cada imagen es una URL fija verificada que corresponde al producto
class MockProducts {
  static List<ProductEntity> getProducts() {
    return [
      // 1. JERSEY - Ciclista con maillot/jersey de ciclismo
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
          // Jersey/maillot de ciclismo colorido
          'https://images.unsplash.com/photo-1521078100750-c08e8e99e40b?w=600&h=600&fit=crop',
        ],
        isActive: true,
        sellerId: 'mock_seller_001',
        sellerName: 'BikeShop Pro',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),

      // 2. CULOTE - Ciclista pedaleando (se ve culote/shorts)
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
          // Ciclista en bici de ruta mostrando equipamiento
          'https://images.unsplash.com/photo-1517649763962-0c623066013b?w=600&h=600&fit=crop',
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
          // Guantes deportivos de ciclismo
          'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=600&h=600&fit=crop',
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
          // Casco de bicicleta profesional
          'https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=600&h=600&fit=crop',
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
          // Gafas de sol deportivas
          'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=600&h=600&fit=crop',
        ],
        isActive: true,
        sellerId: 'mock_seller_003',
        sellerName: 'VeloStore',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),

      // 6. ZAPATILLAS - Zapatillas deportivas/ciclismo
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
          // Zapatillas deportivas rojas
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&h=600&fit=crop',
        ],
        isActive: true,
        sellerId: 'mock_seller_003',
        sellerName: 'VeloStore',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }
}
