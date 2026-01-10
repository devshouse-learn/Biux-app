import 'package:biux/features/shop/domain/entities/product_entity.dart';

/// Productos de prueba para la tienda Biux
/// NOTA: Lista vacía por defecto. Los productos deben ser creados por usuarios autorizados.
class MockProducts {
  static List<ProductEntity> getProducts() {
    // Retornar lista vacía - los productos deben venir de Firebase
    // o ser creados por administradores/vendedores autorizados
    return [];

    // PRODUCTOS DE PRUEBA (COMENTADOS)
    // Descomentar solo para testing local
    /*
    return [
      // JERSEYS
      ProductEntity(
        id: 'prod_001',
        name: 'Jersey Ciclismo Pro',
        description: 'Jersey profesional para ciclismo de ruta',
        longDescription: 'Jersey de alta calidad con tejido respirante y tecnología de secado rápido.',
        price: 180000,
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
    ];
    */
  }
}
