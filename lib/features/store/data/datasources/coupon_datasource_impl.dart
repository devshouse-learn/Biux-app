import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/core/services/app_logger.dart';
import 'package:biux/features/store/domain/entities/coupon_entity.dart';
import 'package:biux/features/store/data/datasources/coupon_datasource.dart';

/// Implementación de CouponDatasource con soporte Firebase.
/// Intenta obtener cupones de Firestore; si falla, usa los cupones
/// locales de CouponDataSource como fallback.
class CouponDatasourceImpl {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CouponDataSource _localSource = CouponDataSource();
  static const String _collection = 'coupons';

  /// Obtiene cupones disponibles desde Firestore.
  /// Si Firestore no tiene cupones o falla, retorna los cupones locales.
  Future<List<Map<String, dynamic>>> getAvailableCoupons() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get()
          .timeout(const Duration(seconds: 5));

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'code': data['code'] ?? '',
            'discount': data['value'] ?? 0,
            'description': data['description'] ?? '',
            'type': data['type'] ?? 'percentage',
            'minPurchase': data['minPurchase'],
            'expirationDate': data['expirationDate'],
            'isActive': data['isActive'] ?? true,
          };
        }).toList();
      }
    } catch (e) {
      AppLogger.warning(
        'Error obteniendo cupones de Firestore, usando locales',
        tag: 'CouponDatasourceImpl',
        error: e,
      );
    }

    // Fallback: cupones locales
    final localCoupons = _localSource.getAllActiveCoupons();
    return localCoupons
        .map(
          (c) => {
            'code': c.code,
            'discount': c.value,
            'description': c.description,
            'type': c.type == CouponType.percentage ? 'percentage' : 'fixed',
            'minPurchase': c.minPurchase,
            'isActive': c.isActive,
          },
        )
        .toList();
  }

  /// Valida un cupón verificando primero en Firestore, luego localmente.
  Future<CouponEntity?> validateCoupon(String code) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('code', isEqualTo: code.toUpperCase())
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 5));

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        final coupon = CouponEntity(
          code: data['code'] ?? '',
          description: data['description'] ?? '',
          type: data['type'] == 'fixed'
              ? CouponType.fixed
              : CouponType.percentage,
          value: (data['value'] ?? 0).toDouble(),
          minPurchase: data['minPurchase']?.toDouble(),
          expirationDate: data['expirationDate'] != null
              ? DateTime.tryParse(data['expirationDate'])
              : null,
          isActive: data['isActive'] ?? true,
        );
        return coupon.isValid ? coupon : null;
      }
    } catch (e) {
      AppLogger.warning(
        'Error validando cupón en Firestore, usando local',
        tag: 'CouponDatasourceImpl',
        error: e,
      );
    }

    // Fallback: validación local
    final localCoupon = _localSource.getCouponByCode(code);
    if (localCoupon != null && localCoupon.isValid) {
      return localCoupon;
    }
    return null;
  }
}
