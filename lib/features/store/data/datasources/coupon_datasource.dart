import 'package:biux/features/store/domain/entities/coupon_entity.dart';

/// Fuente de datos para cupones (actualmente hardcodeados)
/// TODO: Migrar a Firebase cuando se requiera gestión dinámica
class CouponDataSource {
  /// Cupones disponibles en la tienda
  static final Map<String, CouponEntity> _coupons = {
    'BIENVENIDO10': CouponEntity(
      code: 'BIENVENIDO10',
      description: '10% de descuento en tu primera compra',
      type: CouponType.percentage,
      value: 10,
      minPurchase: 50000,
      isActive: true,
    ),
    'DESCUENTO5000': CouponEntity(
      code: 'DESCUENTO5000',
      description: '\$5,000 de descuento',
      type: CouponType.fixed,
      value: 5000,
      minPurchase: 100000,
      isActive: true,
    ),
    'VERANO20': CouponEntity(
      code: 'VERANO20',
      description: '20% de descuento - Promoción de verano',
      type: CouponType.percentage,
      value: 20,
      minPurchase: 150000,
      expirationDate: DateTime(2025, 3, 31),
      isActive: true,
    ),
    'CICLISTA15': CouponEntity(
      code: 'CICLISTA15',
      description: '15% de descuento para ciclistas',
      type: CouponType.percentage,
      value: 15,
      minPurchase: 80000,
      isActive: true,
    ),
    'ENVIOGRATIS': CouponEntity(
      code: 'ENVIOGRATIS',
      description: 'Envío gratis (equivalente a \$10,000)',
      type: CouponType.fixed,
      value: 10000,
      minPurchase: 50000,
      isActive: true,
    ),
  };

  /// Obtener cupón por código
  CouponEntity? getCouponByCode(String code) {
    return _coupons[code.toUpperCase()];
  }

  /// Validar si un cupón existe y es válido
  bool validateCoupon(String code) {
    final coupon = getCouponByCode(code);
    return coupon?.isValid ?? false;
  }

  /// Obtener todos los cupones activos (para debug/admin)
  List<CouponEntity> getAllActiveCoupons() {
    return _coupons.values.where((c) => c.isValid).toList();
  }
}
