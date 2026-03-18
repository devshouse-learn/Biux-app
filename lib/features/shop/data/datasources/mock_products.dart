import 'package:biux/features/shop/domain/entities/product_entity.dart';
import 'package:biux/features/shop/domain/entities/category_entity.dart';

/// Productos de prueba para la tienda Biux
/// Las imágenes están alojadas permanentemente en GitHub raw
class MockProducts {
  /// Base URL permanente de GitHub raw para imágenes de productos
  static const String _imageBase =
      'https://raw.githubusercontent.com/devshouse-learn/Biux-app/features/taliana/img/shop/products';

  static List<ProductEntity> getProducts() {
    return [
      // 1. JERSEY DE CICLISMO
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
        images: ['$_imageBase/jersey_pro.jpg'],
        isActive: true,
        sellerId: 'mock_seller_001',
        sellerName: 'BikeShop Pro',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),

      // 2. CULOTE CON BADANA GEL
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
        images: ['$_imageBase/culote_gel.jpg'],
        isActive: true,
        sellerId: 'mock_seller_001',
        sellerName: 'BikeShop Pro',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),

      // 3. GUANTES CICLISMO GEL
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
        images: ['$_imageBase/guantes_gel.jpg'],
        isActive: true,
        sellerId: 'mock_seller_002',
        sellerName: 'CicloTienda',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),

      // 4. CASCO AERODINAMICO
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
        images: ['$_imageBase/casco_aero.jpg'],
        isActive: true,
        sellerId: 'mock_seller_002',
        sellerName: 'CicloTienda',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),

      // 5. GAFAS DEPORTIVAS UV400
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
        images: ['$_imageBase/gafas_uv400.jpg'],
        isActive: true,
        sellerId: 'mock_seller_003',
        sellerName: 'VeloStore',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),

      // 6. ZAPATILLAS CICLISMO ROAD
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
        images: ['$_imageBase/zapatillas_road.jpg'],
        isActive: true,
        sellerId: 'mock_seller_003',
        sellerName: 'VeloStore',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }
}
