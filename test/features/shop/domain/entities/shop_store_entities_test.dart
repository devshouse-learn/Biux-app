import 'package:flutter_test/flutter_test.dart';
import 'package:biux/features/shop/domain/entities/product_entity.dart';
import 'package:biux/features/shop/domain/entities/order_entity.dart';
import 'package:biux/features/shop/domain/entities/category_entity.dart';
import 'package:biux/features/shop/domain/entities/seller_request_entity.dart';
import 'package:biux/features/shop/domain/entities/report_entity.dart';
import 'package:biux/features/store/domain/entities/product_entity.dart'
    as store;
import 'package:biux/features/store/domain/entities/order_entity.dart'
    as store_order;
import 'package:biux/features/store/domain/entities/coupon_entity.dart';

void main() {
  group('Shop - ProductEntity', () {
    test('debe crear producto con campos requeridos', () {
      final product = ProductEntity(
        id: 'p1',
        name: 'Casco Giro',
        description: 'Casco de ciclismo',
        price: 1500.0,
        images: ['https://example.com/img.jpg'],
        category: 'helmets',
        sizes: ['M', 'L'],
        sellerId: 'seller-1',
        sellerName: 'Tienda Pro',
        stock: 10,
        createdAt: DateTime(2025, 1, 1),
      );
      expect(product.name, 'Casco Giro');
      expect(product.price, 1500.0);
      expect(product.stock, 10);
    });
  });

  group('Shop - OrderEntity', () {
    test('OrderStatus debe tener constantes de estado', () {
      expect(OrderStatus.pending, isNotEmpty);
      expect(OrderStatus.completed, isNotEmpty);
      expect(OrderStatus.cancelled, isNotEmpty);
    });
  });

  group('Shop - CategoryEntity', () {
    test('ProductCategories debe tener categorías predefinidas', () {
      expect(ProductCategories.getAll(), isNotEmpty);
      expect(ProductCategories.getAll().length, greaterThanOrEqualTo(10));
    });
  });

  group('Shop - SellerRequestEntity', () {
    test('SellerRequestStatus debe tener 3 estados', () {
      expect(
        SellerRequestStatus.values,
        containsAll([
          SellerRequestStatus.pending,
          SellerRequestStatus.approved,
          SellerRequestStatus.rejected,
        ]),
      );
    });
  });

  group('Shop - ReportEntity', () {
    test('ReportType debe incluir tipos necesarios', () {
      expect(ReportType.values.length, greaterThanOrEqualTo(3));
    });

    test('ReportStatus debe incluir estados necesarios', () {
      expect(
        ReportStatus.values,
        containsAll([ReportStatus.pending, ReportStatus.resolved]),
      );
    });
  });

  group('Store - ProductEntity', () {
    test('debe crear producto con campos en español', () {
      final p = store.ProductEntity(
        id: 'sp1',
        nombre: 'Jersey azul',
        descripcion: 'Jersey de ciclismo',
        precio: 800.0,
        categoria: store.ProductCategory.ropa,
        vendedorId: 'v1',
        stock: 5,
        fechaCreacion: DateTime(2025, 1, 1),
      );
      expect(p.nombre, 'Jersey azul');
      expect(p.categoria, store.ProductCategory.ropa);
    });

    test('ProductCategory debe tener categorías', () {
      expect(store.ProductCategory.values.length, greaterThanOrEqualTo(5));
    });
  });

  group('Store - OrderEntity', () {
    test('OrderStatus debe tener estados en español', () {
      expect(
        store_order.OrderStatus.values,
        containsAll([
          store_order.OrderStatus.pendiente,
          store_order.OrderStatus.pagado,
          store_order.OrderStatus.cancelado,
        ]),
      );
    });

    test('PaymentMethod debe incluir métodos de pago', () {
      expect(store_order.PaymentMethod.values.length, greaterThanOrEqualTo(3));
    });
  });

  group('Store - CouponEntity', () {
    test('CouponType debe tener percentage y fixed', () {
      expect(
        CouponType.values,
        containsAll([CouponType.percentage, CouponType.fixed]),
      );
    });

    test('debe crear cupón de porcentaje', () {
      final coupon = CouponEntity(
        code: 'BIUX20',
        description: 'Descuento 20%',
        type: CouponType.percentage,
        value: 20.0,
        expirationDate: DateTime(2030, 12, 31),
      );
      expect(coupon.code, 'BIUX20');
      expect(coupon.type, CouponType.percentage);
      expect(coupon.value, 20.0);
    });
  });
}
