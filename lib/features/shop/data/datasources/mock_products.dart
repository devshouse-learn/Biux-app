import 'package:biux/features/shop/domain/entities/product_entity.dart';
import 'package:biux/features/shop/domain/entities/category_entity.dart';

/// Productos de prueba para la tienda Biux
/// NOTA: Lista con productos de prueba habilitada temporalmente para testing
class MockProducts {
  static List<ProductEntity> getProducts() {
    // Productos de prueba habilitados para testing
    return [
      // JERSEYS
      ProductEntity(
        id: 'prod_001',
        name: 'Jersey Ciclismo Pro',
        description: 'Jersey profesional para ciclismo de ruta',
        longDescription: 'Jersey de alta calidad con tejido respirante y tecnología de secado rápido. Ideal para entrenamientos largos y competencias. Fabricado con materiales de primera calidad.',
        price: 45,  // En USD, se convierte a COP en UI
        stock: 25,
        category: ProductCategories.jerseys,
        images: ['https://images.unsplash.com/photo-1558769132-cb1aea1f9565?w=800'],
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
        longDescription: 'Culote de ciclismo con diseño aerodinámico y badana de gel premium. Perfecto para largas distancias.',
        price: 55,
        stock: 18,
        category: ProductCategories.shorts,
        images: ['https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800'],
        sizes: ['S', 'M', 'L', 'XL'],
        sellerId: 'admin',
        sellerName: 'Biux Store',
        sellerCity: 'Medellín',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),

      // ACCESORIOS
      ProductEntity(
        id: 'prod_003',
        name: 'Guantes Ciclismo GEL',
        description: 'Guantes con palma de gel anti-vibración',
        longDescription: 'Guantes de ciclismo con tecnología de gel que absorbe las vibraciones del manillar. Tejido transpirable.',
        price: 25,
        stock: 30,
        category: ProductCategories.gloves,
        images: ['https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800'],
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
        longDescription: 'Casco de alta gama con diseño aerodinámico para competencias. Sistema de ventilación optimizado y ajuste preciso.',
        price: 180,
        stock: 12,
        category: ProductCategories.helmets,
        images: ['https://images.unsplash.com/photo-1558618047-d8840d70a05d?w=800'],
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
        longDescription: 'Gafas de ciclismo con lentes que se adaptan automáticamente a las condiciones de luz. Protección UV total.',
        price: 85,
        stock: 20,
        category: ProductCategories.glasses,
        images: ['https://images.unsplash.com/photo-1473496169904-658ba7c44d8a?w=800'],
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
        longDescription: 'Zapatillas profesionales con suela de carbono para máxima transferencia de potencia. Sistema de cierre BOA.',
        price: 350,
        stock: 8,
        category: ProductCategories.shoes,
        images: ['https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=800'],
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
