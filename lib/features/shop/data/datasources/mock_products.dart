import 'package:biux/features/shop/domain/entities/product_entity.dart';
import 'package:biux/features/shop/domain/entities/category_entity.dart';

/// Productos de prueba para la tienda Biux
/// NOTA: Lista con productos de prueba habilitada temporalmente para testing
class MockProducts {
  static List<ProductEntity> getProducts() {
    // Productos de prueba habilitados para testing
    // URLs: picsum.photos con IDs fijos = misma imagen siempre
    return [
      // JERSEYS
      ProductEntity(
        id: 'prod_001',
        name: 'Jersey Ciclismo Pro',
        description: 'Jersey profesional para ciclismo de ruta',
        longDescription:
            'Jersey de alta calidad con tejido respirante y tecnología de secado rápido. Ideal para entrenamientos largos y competencias.',
        price: 180000,
        stock: 25,
        category: ProductCategories.jerseys,
        images: ['https://picsum.photos/id/29/600/600.jpg'],
        sizes: ['S', 'M', 'L', 'XL'],
        sellerId: 'admin',
        sellerName: 'Biux Store',
        sellerCity: 'Bogotá',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),

      // SHORTS
      ProductEntity(
        id: 'prod_002',
        name: 'Culote Ciclismo Aero',
        description: 'Culote aerodinámico para competencia',
        longDescription:
            'Culote de ciclismo con diseño aerodinámico y badana de gel premium. Perfecto para largas distancias.',
        price: 220000,
        stock: 18,
        category: ProductCategories.shorts,
        images: ['https://picsum.photos/id/160/600/600.jpg'],
        sizes: ['S', 'M', 'L', 'XL'],
        sellerId: 'admin',
        sellerName: 'Biux Store',
        sellerCity: 'Medellín',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),

      // GUANTES
      ProductEntity(
        id: 'prod_003',
        name: 'Guantes Ciclismo GEL',
        description: 'Guantes con palma de gel anti-vibración',
        longDescription:
            'Guantes de ciclismo con tecnología de gel que absorbe las vibraciones del manillar. Tejido transpirable.',
        price: 100000,
        stock: 30,
        category: ProductCategories.gloves,
        images: ['https://picsum.photos/id/96/600/600.jpg'],
        sizes: ['S', 'M', 'L', 'XL'],
        sellerId: 'admin',
        sellerName: 'Biux Store',
        sellerCity: 'Cali',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),

      // CASCOS
      ProductEntity(
        id: 'prod_004',
        name: 'Casco Aerodinámico Elite',
        description: 'Casco profesional con tecnología aerodinámica',
        longDescription:
            'Casco de alta gama con diseño aerodinámico para competencias. Sistema de ventilación optimizado.',
        price: 720000,
        stock: 12,
        category: ProductCategories.helmets,
        images: ['https://picsum.photos/id/145/600/600.jpg'],
        sizes: ['S', 'M', 'L'],
        sellerId: 'admin',
        sellerName: 'Biux Store',
        sellerCity: 'Bogotá',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),

      // GAFAS
      ProductEntity(
        id: 'prod_005',
        name: 'Gafas Fotocromáticas Pro',
        description: 'Gafas deportivas con lentes fotocromáticas',
        longDescription:
            'Gafas de ciclismo con lentes que se adaptan automáticamente a las condiciones de luz. Protección UV total.',
        price: 340000,
        stock: 20,
        category: ProductCategories.glasses,
        images: ['https://picsum.photos/id/7/600/600.jpg'],
        sizes: ['Única'],
        sellerId: 'admin',
        sellerName: 'Biux Store',
        sellerCity: 'Medellín',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),

      // ZAPATILLAS
      ProductEntity(
        id: 'prod_006',
        name: 'Zapatillas Road Carbon',
        description: 'Zapatillas de carbono para ciclismo de ruta',
        longDescription:
            'Zapatillas profesionales con suela de carbono para máxima transferencia de potencia. Sistema de cierre BOA.',
        price: 1400000,
        stock: 8,
        category: ProductCategories.shoes,
        images: ['https://picsum.photos/id/21/600/600.jpg'],
        sizes: ['39', '40', '41', '42', '43', '44', '45'],
        sellerId: 'admin',
        sellerName: 'Biux Store',
        sellerCity: 'Bogotá',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }
}
